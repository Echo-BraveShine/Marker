import importlib.util
import os
from pathlib import Path
from tempfile import TemporaryDirectory
from types import SimpleNamespace
import unittest
from unittest.mock import Mock

ROOT = Path(__file__).resolve().parents[2]
spec = importlib.util.spec_from_file_location('bundled_fonts', ROOT / 'linux/packaging/bundled_fonts.py')
fonts = importlib.util.module_from_spec(spec)
spec.loader.exec_module(fonts)


class BundledFontTests(unittest.TestCase):
    def test_installer_registers_unicode_bundle_path_without_system_install(self):
        with TemporaryDirectory(prefix='中文安装-') as folder:
            font = Path(folder) / 'data/flutter_assets/assets/fonts/NotoSansSC.ttf'
            font.parent.mkdir(parents=True)
            font.write_bytes(b'font fixture')
            native = SimpleNamespace(FcConfigGetCurrent=Mock(return_value=1234),
                                     FcConfigAppFontAddFile=Mock(return_value=1))
            loader = Mock(return_value=native)
            self.assertTrue(fonts.register_bundled_font(folder, library_loader=loader,
                                                       library_finder=lambda _: 'libfontconfig.so.1'))
            native.FcConfigAppFontAddFile.assert_called_once_with(1234, os.fsencode(font))
            native.FcConfigAppFontAddFile.return_value = 0
            self.assertFalse(fonts.register_bundled_font(folder, library_loader=loader,
                                                        library_finder=lambda _: 'libfontconfig.so.1'))

    def test_missing_font_or_optional_library_is_graceful(self):
        with TemporaryDirectory() as folder:
            loader = Mock()
            self.assertFalse(fonts.register_bundled_font(folder, library_loader=loader))
            loader.assert_not_called()
            font = Path(folder) / 'data/flutter_assets/assets/fonts/NotoSansSC.ttf'
            font.parent.mkdir(parents=True)
            font.touch()
            self.assertFalse(fonts.register_bundled_font(folder, library_finder=lambda _: None))


if __name__ == '__main__':
    unittest.main()
