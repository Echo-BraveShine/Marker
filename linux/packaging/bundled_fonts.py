"""Expose the bundle's Chinese font to GTK without installing a system font."""
import ctypes
import ctypes.util
import os
from pathlib import Path


def register_bundled_font(bundle, *, library_loader=ctypes.CDLL, library_finder=ctypes.util.find_library):
    path = Path(bundle) / 'data/flutter_assets/assets/fonts/NotoSansSC.ttf'
    if not path.is_file():
        return False
    library = library_finder('fontconfig')
    if not library:
        return False
    try:
        fontconfig = library_loader(library)
        fontconfig.FcConfigGetCurrent.restype = ctypes.c_void_p
        fontconfig.FcConfigGetCurrent.argtypes = []
        fontconfig.FcConfigAppFontAddFile.restype = ctypes.c_int
        fontconfig.FcConfigAppFontAddFile.argtypes = [ctypes.c_void_p, ctypes.c_char_p]
        config = fontconfig.FcConfigGetCurrent()
        return bool(config and fontconfig.FcConfigAppFontAddFile(config, os.fsencode(path)))
    except (OSError, AttributeError):
        return False
