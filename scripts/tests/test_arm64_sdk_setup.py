"""Exercise the real ARM64 workflow step without downloading or booting Flutter."""
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import textwrap
import unittest

ROOT = Path(__file__).resolve().parents[2]


@unittest.skipUnless(os.name == 'posix' and shutil.which('bash'), 'Requires POSIX shell')
class Arm64SdkSetupTests(unittest.TestCase):
    def probe(self, version='3.44.9', fail=False):
        workflow = (ROOT / '.github/workflows/release.yml').read_text(encoding='utf-8')
        step = workflow.split('      - name: Set up Flutter on Linux ARM64\n', 1)[1].split('      - name:', 1)[0]
        script = textwrap.dedent(step.split('        run: |\n', 1)[1])
        with tempfile.TemporaryDirectory(prefix='marker-arm64-bootstrap-') as folder:
            root = Path(folder)
            (root / '.fvmrc').write_text(json.dumps({'flutter': '3.44.9'}), encoding='utf-8')
            sdk = root / 'flutter-arm64'
            binary = sdk / 'bin'
            binary.mkdir(parents=True)
            flutter = binary / 'flutter'
            flutter.write_text('#!' + sys.executable + '\n' + textwrap.dedent('''\
                import json, os, pathlib, sys
                print('[1/3] Building Flutter tool...')
                print('2 packages are discontinued.')
                print('59 packages have newer versions incompatible with dependency constraints.')
                if os.environ['PROBE_FAIL'] == 'true': sys.exit(23)
                target = pathlib.Path(__file__).parent / 'cache' / 'flutter.version.json'
                target.parent.mkdir()
                target.write_text(json.dumps({'frameworkVersion': os.environ['PROBE_VERSION']}))
                print(json.dumps({'frameworkVersion': os.environ['PROBE_VERSION']}))
                '''), encoding='utf-8')
            flutter.chmod(0o755)
            dart = binary / 'dart'
            dart.write_text('#!/bin/sh\necho \'Dart SDK on "linux_arm64"\'\n', encoding='utf-8')
            dart.chmod(0o755)
            output = root / 'github-path'
            env = dict(os.environ, RUNNER_TEMP=str(root), GITHUB_PATH=str(output),
                       PROBE_VERSION=version, PROBE_FAIL=str(fail).lower())
            result = subprocess.run(['bash', '-e', '-o', 'pipefail', '-c', script],
                                    cwd=root, env=env, capture_output=True, text=True, timeout=10)
            return result, output.exists()

    def test_packaging_checkouts_include_workflow_without_nested_project(self):
        workflow = (ROOT / '.github/workflows/release.yml').read_text(encoding='utf-8')
        blocks = workflow.split('          sparse-checkout: |\n')[1:]
        self.assertEqual(len(blocks), 2)
        for block in blocks:
            patterns = []
            for line in block.splitlines():
                if not line.startswith('            '):
                    break
                patterns.append(line.strip())
            self.assertIn('/.github/workflows/release.yml', patterns)
            self.assertNotIn('/pubspec.yaml', patterns)
            self.assertNotIn('/*', patterns)

    def test_bootstrap_noise_does_not_corrupt_version_check(self):
        result, exported = self.probe()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('packages are discontinued', result.stdout)
        self.assertTrue(exported)

    def test_wrong_sdk_is_rejected(self):
        result, exported = self.probe(version='0.0.0')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('Cached Flutter version mismatch', result.stdout)
        self.assertFalse(exported)

    def test_bootstrap_failure_is_not_masked_by_json_parser(self):
        result, exported = self.probe(fail=True)
        self.assertEqual(result.returncode, 23, result.stderr)
        self.assertNotIn('JSONDecodeError', result.stderr)
        self.assertFalse(exported)
