#!/usr/bin/env python3
"""Validate pubspec/tag consistency and share the version with GitHub Actions."""
import argparse
import os
from pathlib import Path
import re


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--tag', required=True)
    parser.add_argument('--project-dir', type=Path, default=Path(__file__).resolve().parents[1])
    args = parser.parse_args()
    root = args.project_dir
    match = re.search(r'^version:\s*(\d+\.\d+\.\d+)\+(\d+)\s*$', (root / 'pubspec.yaml').read_text(encoding='utf-8'), re.M)
    if not match or args.tag != f'v{match[1]}':
        raise SystemExit('Release tag must match pubspec version X.Y.Z+BUILD')
    version, build = match.groups()
    if any(int(number) > 65535 for number in version.split('.') + [build]):
        raise SystemExit('Windows version components must be <= 65535')
    if any(int(number) > 255 for number in version.split('.')[:2]):
        raise SystemExit('MSI major and minor version components must be <= 255')
    values = f'version={version}\nbuild={build}\n'
    print(values, end='')
    if output := os.environ.get('GITHUB_OUTPUT'):
        with open(output, 'a', encoding='utf-8', newline='\n') as stream:
            stream.write(values)


if __name__ == '__main__':
    main()
