#!/usr/bin/env python3
"""Package approved artwork into desktop icon formats (macOS sips/iconutil).

No design changes: only resampling, PNG-to-ICO wrapping and asset catalog export.
Run from any directory: python3 scripts/export_desktop_icons.py
"""
from pathlib import Path
import shutil
import struct
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]
BRAND = ROOT / 'assets/branding'
SIZES = (16, 24, 32, 48, 64, 128, 256, 512, 1024)


def resize(source, target, size):
    target.parent.mkdir(parents=True, exist_ok=True)
    subprocess.run(['sips', '-z', str(size), str(size), str(source), '--out', str(target)],
                   check=True, stdout=subprocess.DEVNULL)


def ico(frames, target):
    entries = []
    data = []
    offset = 6 + 16 * len(frames)
    for size, path in frames:
        blob = path.read_bytes()
        entries.append(struct.pack('<BBBBHHII', size % 256, size % 256, 0, 0, 1, 32, len(blob), offset))
        data.append(blob)
        offset += len(blob)
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_bytes(struct.pack('<HHH', 0, 1, len(entries)) + b''.join(entries + data))


def main():
    for variant in ('light', 'dark'):
        source = BRAND / f'marker-{variant}-master.png'
        if not source.exists():
            raise SystemExit(f'Missing approved artwork: {source}')
        exported = BRAND / 'export' / variant
        for size in SIZES:
            resize(source, exported / f'marker-{size}.png', size)
        resize(source, BRAND / f'marker-{variant}.png', 1024)
        ico([(size, exported / f'marker-{size}.png') for size in SIZES if size <= 256],
            exported / 'marker.ico')
        with tempfile.TemporaryDirectory() as temporary:
            iconset = Path(temporary) / 'Marker.iconset'
            iconset.mkdir()
            for size in (16, 32, 128, 256, 512):
                for scale in (1, 2):
                    suffix = '@2x' if scale == 2 else ''
                    shutil.copyfile(exported / f'marker-{size * scale}.png',
                                    iconset / f'icon_{size}x{size}{suffix}.png')
            subprocess.run(['iconutil', '-c', 'icns', str(iconset), '-o', str(exported / 'Marker.icns')], check=True)
    # NSImage appearance resources used for the running macOS Dock tile.
    import json
    for variant in ('light', 'dark'):
        images = ROOT / 'macos/Runner/Assets.xcassets' / f'MarkerIcon{variant.title()}.imageset'
        images.mkdir(exist_ok=True)
        entries = []
        for size, scale in ((512, '1x'), (1024, '2x')):
            shutil.copyfile(BRAND / 'export' / variant / f'marker-{size}.png', images / f'marker-{size}.png')
            entries.append({'idiom': 'mac', 'filename': f'marker-{size}.png', 'scale': scale})
        (images / 'Contents.json').write_text(json.dumps({'images': entries, 'info': {'author': 'xcode', 'version': 1}}, indent=2) + '\n', encoding='utf-8')
    # Native primary icons remain deterministic across operating systems.
    for size in (16, 32, 64, 128, 256, 512, 1024):
        shutil.copyfile(BRAND / 'export/light' / f'marker-{size}.png',
                        ROOT / 'macos/Runner/Assets.xcassets/AppIcon.appiconset' / f'app_icon_{size}.png')
    shutil.copyfile(BRAND / 'export/light/marker.ico', ROOT / 'windows/runner/resources/app_icon.ico')
    shutil.copyfile(BRAND / 'export/dark/marker.ico', ROOT / 'windows/runner/resources/app_icon_dark.ico')
    for variant in ('light', 'dark'):
        name = 'marker' if variant == 'light' else 'marker-dark'
        for size in SIZES:
            target = ROOT / 'linux/packaging/icons/hicolor' / f'{size}x{size}' / 'apps' / f'{name}.png'
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(BRAND / 'export' / variant / f'marker-{size}.png', target)
    print('Exported macOS iconset/ICNS, Windows ICO, Linux hicolor, and light/dark Flutter assets.')


if __name__ == '__main__':
    main()
