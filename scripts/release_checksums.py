#!/usr/bin/env python3
"""Reject incomplete platform packages before generating release checksums."""
import argparse
import hashlib
from pathlib import Path
import sys

ARTIFACTS = {
    'macos': ('Marker-macos-universal.zip', 'Marker-macos-universal.dmg'),
    'windows': ('Marker-Windows-x64-Setup.exe', 'Marker-windows-x64.zip'),
    'linux': ('Marker-linux-x64.tar.gz', 'Marker-linux-amd64.deb'),
}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--project-dir', type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument('--platform', choices=ARTIFACTS, default={
        'darwin': 'macos', 'win32': 'windows', 'linux': 'linux',
    }.get(sys.platform))
    parser.add_argument('--architecture', choices=('x64', 'arm64'), default='x64')
    args = parser.parse_args()
    if args.platform is None:
        raise SystemExit('Specify the release platform')
    folder = args.project_dir / 'dist'
    names = ARTIFACTS[args.platform]
    if args.architecture == 'arm64':
        if args.platform != 'linux':
            raise SystemExit('ARM64 checksum packaging is currently supported for Linux only')
        names = ('Marker-linux-arm64.tar.gz', 'Marker-linux-arm64.deb')
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
    (folder / f'SHA256SUMS-{args.platform}.txt').write_text(''.join(lines), encoding='utf-8')


if __name__ == '__main__':
    main()
