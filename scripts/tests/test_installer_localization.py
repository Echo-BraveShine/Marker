import importlib.util
import os
import subprocess
import tempfile
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[2]
spec = importlib.util.spec_from_file_location('installer_i18n', ROOT / 'linux/packaging/installer_i18n.py')
i18n = importlib.util.module_from_spec(spec)
spec.loader.exec_module(i18n)


class InstallerLocalizationTests(unittest.TestCase):
    def test_system_locale_and_explicit_choice(self):
        cases = [({}, 'en'), ({'LANG': 'zh_CN.UTF-8'}, 'zh'),
                 ({'LANG': 'en_US.UTF-8'}, 'en'),
                 ({'LANGUAGE': 'zh_CN:en_US'}, 'zh'),
                 ({'LC_ALL': 'en_US.UTF-8', 'LANG': 'zh_CN.UTF-8'}, 'en'),
                 ({'MARKER_INSTALLER_LANGUAGE': 'en', 'LANG': 'zh_CN.UTF-8'}, 'en'),
                 ({'MARKER_INSTALLER_LANGUAGE': 'zh', 'LANG': 'en_US.UTF-8'}, 'zh')]
        for environment, expected in cases:
            with self.subTest(environment=environment):
                self.assertEqual(i18n.language_for_environment(environment), expected)

    @unittest.skipIf(os.name == 'nt', 'Linux shell installer runs on POSIX')
    def test_command_line_reports_translated_invalid_bundle(self):
        with tempfile.TemporaryDirectory() as folder:
            for language, message in [('zh', '安装目录中未找到 Marker 程序。'),
                                      ('en', 'Marker executable not found in bundle.')]:
                result = subprocess.run(['bash', str(ROOT / 'linux/packaging/install-user.sh'), folder],
                                        env=dict(os.environ, MARKER_INSTALLER_LANGUAGE=language),
                                        capture_output=True, text=True, encoding='utf-8')
                self.assertEqual(result.returncode, 1)
                self.assertIn(message, result.stderr)

    def test_both_languages_cover_the_complete_install_flow(self):
        for key in ('title', 'welcome', 'close', 'install', 'working', 'failed', 'error', 'ready', 'open', 'language'):
            self.assertTrue(i18n.TEXT['zh'][key])
            self.assertTrue(i18n.TEXT['en'][key])
            self.assertNotEqual(i18n.TEXT['zh'][key], i18n.TEXT['en'][key])


if __name__ == '__main__':
    unittest.main()
