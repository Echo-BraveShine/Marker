#!/usr/bin/env python3
"""Reject incomplete platform packages before generating release checksums."""
import argparse
import hashlib
from pathlib import Path
import sys

ARTIFACTS = {
    'macos': ('Marker-macos.zip', 'Marker-macos-arm64.dmg', 'Marker-macos-x86_64.dmg'),
    'windows': ('Marker-Windows-x64-Setup.exe', 'Marker-windows-x64.zip', 'Marker-Windows-x64.msi', 'Marker-Windows-x64-zh-CN.msi'),
    'linux': ('Marker-linux-x64.tar.gz', 'Marker-linux-amd64.deb',
              'Marker-linux-x86_64.AppImage', 'Marker-linux-x86_64.rpm'),
}
LINUX_ARM64 = ('Marker-linux-arm64.tar.gz', 'Marker-linux-arm64.deb',
               'Marker-linux-aarch64.AppImage', 'Marker-linux-aarch64.rpm')


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--project-dir', type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument('--platform', choices=ARTIFACTS, default={
        'darwin': 'macos', 'win32': 'windows', 'linux': 'linux',
    }.get(sys.platform))
    parser.add_argument('--architecture', choices=('x64', 'arm64', 'universal'))
    args = parser.parse_args()
    if args.platform is None:
        raise SystemExit('Specify the release platform')
    folder = args.project_dir / 'dist'
    architecture = args.architecture or ('universal' if args.platform == 'macos' else 'x64')
    supported = {'macos': ('universal',), 'windows': ('x64',), 'linux': ('x64', 'arm64')}
    if architecture not in supported[args.platform]:
        raise SystemExit(f'Unsupported release target: {args.platform}/{architecture}')
    names = LINUX_ARM64 if args.platform == 'linux' and architecture == 'arm64' else ARTIFACTS[args.platform]
    files = [folder / name for name in names]
    for path in files:
        if not path.is_file() or path.stat().st_size == 0:
            raise SystemExit(f'Missing or empty release package: {path.name}')
    lines = []
    for path in sorted(files):
        digest = hashlib.sha256()
        with path.open('rb') as stream:
            for chunk in iter(lambda: stream.read(1024 * 1024), b''):
                digest.update(chunk)
        lines.append(f'{digest.hexdigest()}  {path.name}\n')
    (folder / f'SHA256SUMS-{args.platform}-{architecture}.txt').write_bytes(''.join(lines).encode('utf-8'))


if __name__ == '__main__':
    main()
