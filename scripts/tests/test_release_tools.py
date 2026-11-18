import hashlib
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

TOOLS = Path(__file__).resolve().parents[1]


class ReleaseToolsTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix='marker-release-中文-')
        self.addCleanup(self.temporary.cleanup)
        self.project = Path(self.temporary.name)
        self.output = self.project / 'github-output'

    def run_tool(self, name, *arguments):
        env = dict(os.environ, GITHUB_OUTPUT=str(self.output),
                   PYTHONWARNDEFAULTENCODING='1', PYTHONWARNINGS='error::EncodingWarning')
        return subprocess.run([sys.executable, str(TOOLS / name), '--project-dir',
                               str(self.project), *arguments], env=env,
                              capture_output=True, text=True, encoding='utf-8')

    def test_utf8_version_and_github_output_from_separate_project(self):
        (self.project / 'pubspec.yaml').write_text(
            'description: "中文版本说明"\nversion: 0.0.1+7\n', encoding='utf-8')
        result = self.run_tool('release_version.py', '--tag', 'v0.0.1')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.output.read_bytes(), b'version=0.0.1\nbuild=7\n')

    def test_mismatch_and_out_of_range_build_are_rejected(self):
        for content, tag in [('version: 0.0.1+1', 'v0.0.2'),
                             ('version: 0.0.1+65536', 'v0.0.1')]:
            (self.project / 'pubspec.yaml').write_text(content, encoding='utf-8')
            result = self.run_tool('release_version.py', '--tag', tag)
            self.assertNotEqual(result.returncode, 0)
            self.assertFalse(self.output.exists())

    def test_missing_and_empty_packages_are_rejected(self):
        folder = self.project / 'dist'
        folder.mkdir()
        package = folder / 'Marker-Windows-x64-Setup.exe'
        package.write_bytes(b'installer')
        self.assertNotEqual(self.run_tool('release_checksums.py', '--platform', 'windows').returncode, 0)
        (folder / 'Marker-windows-x64.zip').write_bytes(b'')
        self.assertNotEqual(self.run_tool('release_checksums.py', '--platform', 'windows').returncode, 0)
        self.assertFalse((folder / 'SHA256SUMS-windows.txt').exists())

    def test_complete_packages_have_correct_checksums_on_all_platforms(self):
        expected = {
            'macos': ['Marker-macos-universal.dmg', 'Marker-macos-universal.zip'],
            'windows': ['Marker-Windows-x64-Setup.exe', 'Marker-windows-x64.zip'],
            'linux': ['Marker-linux-amd64.deb', 'Marker-linux-x64.tar.gz'],
        }
        folder = self.project / 'dist'
        folder.mkdir()
        for platform, names in expected.items():
            for name in names:
                (folder / name).write_bytes(name.encode('utf-8'))
            result = self.run_tool('release_checksums.py', '--platform', platform)
            self.assertEqual(result.returncode, 0, result.stderr)
            text = (folder / f'SHA256SUMS-{platform}.txt').read_text(encoding='utf-8')
            self.assertEqual(text, ''.join(
                f'{hashlib.sha256(name.encode("utf-8")).hexdigest()}  {name}\n' for name in sorted(names)))


if __name__ == '__main__':
    unittest.main()
