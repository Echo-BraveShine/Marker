import base64
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

SCRIPT = Path(__file__).resolve().parents[1] / 'prepare_android_signing.py'


class AndroidSigningTests(unittest.TestCase):
    def test_missing_secrets_do_not_create_a_key(self):
        with tempfile.TemporaryDirectory() as folder:
            env = {k: v for k, v in os.environ.items() if not k.startswith('ANDROID_KEY')}
            env.update(RUNNER_TEMP=folder, GITHUB_ENV=str(Path(folder) / 'env'))
            result = subprocess.run([sys.executable, str(SCRIPT)], env=env, capture_output=True, text=True)
            self.assertNotEqual(result.returncode, 0)
            self.assertIn('ANDROID_KEYSTORE_BASE64', result.stderr)
            self.assertFalse((Path(folder) / 'marker-release.jks').exists())

    def test_key_is_restored_privately_without_logging_credentials(self):
        with tempfile.TemporaryDirectory() as folder:
            key = b'private signing key bytes'
            env = dict(os.environ, RUNNER_TEMP=folder, GITHUB_ENV=str(Path(folder) / 'env'),
                       ANDROID_KEYSTORE_BASE64=base64.b64encode(key).decode(),
                       ANDROID_KEYSTORE_PASSWORD='private-password', ANDROID_KEY_ALIAS='marker',
                       ANDROID_KEY_PASSWORD='private-password')
            result = subprocess.run([sys.executable, str(SCRIPT)], env=env, capture_output=True, text=True)
            self.assertEqual(result.returncode, 0, result.stderr)
            path = Path(folder) / 'marker-release.jks'
            self.assertEqual(path.read_bytes(), key)
            self.assertIn(str(path), (Path(folder) / 'env').read_text())
            self.assertNotIn('private-password', result.stdout + result.stderr)
            if os.name != 'nt':
                self.assertEqual(path.stat().st_mode & 0o777, 0o600)
