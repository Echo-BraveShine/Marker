import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[2]
NAMES = [
    'Marker-macos.zip', 'Marker-macos-arm64.dmg', 'Marker-macos-x86_64.dmg',
    'Marker-Windows-x64-Setup.exe', 'Marker-windows-x64.zip', 'Marker-Windows-x64.msi', 'Marker-Windows-x64-zh-CN.msi',
    'Marker-linux-x64.tar.gz', 'Marker-linux-amd64.deb',
    'Marker-linux-x86_64.AppImage', 'Marker-linux-x86_64.rpm',
    'Marker-linux-arm64.tar.gz', 'Marker-linux-arm64.deb',
    'Marker-linux-aarch64.AppImage', 'Marker-linux-aarch64.rpm',
]

FAKE_GH = r'''
import json, os, pathlib, shutil, sys
root = pathlib.Path(os.environ['FAKE_REMOTE'])
state = json.loads((root / 'state.json').read_text(encoding='utf-8'))
a = sys.argv[1:]
if a[:2] == ['release', 'view']:
    if a[2].startswith('--'):
        print('v0.0.0'); sys.exit(0)
    if not state['exists']: sys.exit(1)
    print(json.dumps({'isDraft': state.get('draft', False),
      'assets': [{'name': p.name} for p in (root / 'assets').iterdir()]}))
elif a[:2] == ['release', 'download']:
    name = a[a.index('--pattern') + 1]
    shutil.copyfile(root / 'assets' / name, pathlib.Path(a[a.index('--dir') + 1]) / name)
elif a[:2] in (['release', 'upload'], ['release', 'create']):
    if a[1] == 'create': state['exists'] = True
    for value in a[3:]:
        if value.startswith('--'): break
        path = pathlib.Path(value)
        target = root / 'assets' / path.name
        if target.exists(): raise RuntimeError('Attempted to replace a published asset')
        shutil.copyfile(path, target)
    (root / 'state.json').write_text(json.dumps(state), encoding='utf-8')
elif a[:2] == ['release', 'edit']:
    state['draft'] = False
    (root / 'state.json').write_text(json.dumps(state), encoding='utf-8')
else:
    raise RuntimeError(a)
'''


@unittest.skipUnless(os.name != 'nt' and shutil.which('jq') and shutil.which('sha256sum'),
                     'Publish runs on Ubuntu; requires POSIX bash/jq/sha256sum')
class PublishTests(unittest.TestCase):
    def setUp(self):
        temp = tempfile.TemporaryDirectory(prefix='marker-publish-')
        self.addCleanup(temp.cleanup)
        self.root = Path(temp.name)
        self.dist = self.root / 'dist'
        self.dist.mkdir()
        self.remote = self.root / 'remote'
        self.assets = self.remote / 'assets'
        self.assets.mkdir(parents=True)
        for name in NAMES:
            (self.dist / name).write_bytes(b'new-' + name.encode('utf-8'))
        self.manifest(self.dist)
        bindir = self.root / 'bin'
        bindir.mkdir()
        gh = bindir / 'gh'
        gh.write_text(f'#!{sys.executable}\n' + FAKE_GH, encoding='utf-8')
        gh.chmod(0o755)
        self.env = dict(os.environ, PATH=str(bindir) + os.pathsep + os.environ['PATH'],
                        FAKE_REMOTE=str(self.remote), RELEASE_TAG='v0.0.1')

    def manifest(self, folder):
        (folder / 'SHA256SUMS.txt').write_text(''.join(
            f'{hashlib.sha256((folder / name).read_bytes()).hexdigest()}  {name}\n'
            for name in NAMES), encoding='utf-8')

    def state(self, exists=True, draft=False):
        (self.remote / 'state.json').write_text(json.dumps({'exists': exists, 'draft': draft}), encoding='utf-8')

    def publish(self):
        return subprocess.run(['bash', str(ROOT / '.github/release/publish.sh')],
                              cwd=self.root, env=self.env, capture_output=True,
                              text=True, encoding='utf-8')

    def test_creates_new_release(self):
        self.state(exists=False)
        result = self.publish()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(len(list(self.assets.iterdir())), 16)

    def test_resumes_partial_draft_without_overwriting_original_package(self):
        self.state(draft=True)
        original = self.assets / NAMES[0]
        original.write_bytes(b'original published package')
        result = self.publish()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(original.read_bytes(), b'original published package')
        self.assertEqual(len(list(self.assets.iterdir())), 16)
        self.assertIn(hashlib.sha256(original.read_bytes()).hexdigest(),
                      (self.assets / 'SHA256SUMS.txt').read_text(encoding='utf-8'))
        self.assertFalse(json.loads((self.remote / 'state.json').read_text(encoding='utf-8'))['draft'])

    def test_complete_release_stays_immutable(self):
        self.state()
        for name in NAMES:
            (self.assets / name).write_bytes(b'old-' + name.encode('utf-8'))
        self.manifest(self.assets)
        before = {p.name: p.read_bytes() for p in self.assets.iterdir()}
        result = self.publish()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(before, {p.name: p.read_bytes() for p in self.assets.iterdir()})

    def test_missing_architecture_blocks_release(self):
        self.state(exists=False)
        (self.dist / 'Marker-linux-aarch64.rpm').unlink()
        result = self.publish()
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(list(self.assets.iterdir()), [])

    def test_stale_format_cannot_replace_a_required_package(self):
        self.state(exists=False)
        (self.dist / 'Marker-macos-x86_64.dmg').rename(self.dist / 'Marker-macos-universal.dmg')
        result = self.publish()
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(list(self.assets.iterdir()), [])

    def test_existing_checksum_contract_rejects_inconsistent_rebuild(self):
        self.state()
        for name in NAMES:
            (self.assets / name).write_bytes(b'old-' + name.encode('utf-8'))
        self.manifest(self.assets)
        (self.assets / NAMES[-1]).unlink()
        before = {p.name: p.read_bytes() for p in self.assets.iterdir()}
        result = self.publish()
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(before, {p.name: p.read_bytes() for p in self.assets.iterdir()})


if __name__ == '__main__':
    unittest.main()
