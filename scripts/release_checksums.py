#!/usr/bin/env python3
import hashlib
from pathlib import Path
import sys

folder = Path(__file__).resolve().parents[1] / 'dist'
if not folder.is_dir():
    raise SystemExit('No release packages found; build and package first')
files = sorted(p for p in folder.iterdir() if p.is_file() and not p.name.startswith('SHA256SUMS'))
if not files:
    raise SystemExit('No release packages found')
lines = []
for path in files:
    digest = hashlib.sha256()
    with path.open('rb') as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b''):
            digest.update(chunk)
    lines.append(f'{digest.hexdigest()}  {path.name}\n')
(folder / f'SHA256SUMS-{sys.platform}.txt').write_text(''.join(lines), encoding='utf-8')
