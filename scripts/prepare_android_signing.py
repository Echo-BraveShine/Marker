#!/usr/bin/env python3
"""Restore the stable signing key without logging or persisting passwords."""
import base64
import os
from pathlib import Path


def main():
    required = ('ANDROID_KEYSTORE_BASE64', 'ANDROID_KEYSTORE_PASSWORD',
                'ANDROID_KEY_ALIAS', 'ANDROID_KEY_PASSWORD')
    missing = [name for name in required if not os.environ.get(name)]
    if missing:
        raise SystemExit('Configure repository Actions secrets: ' + ', '.join(missing))
    try:
        key = base64.b64decode(''.join(os.environ['ANDROID_KEYSTORE_BASE64'].split()), validate=True)
    except ValueError:
        raise SystemExit('ANDROID_KEYSTORE_BASE64 is not valid base64') from None
    if not key:
        raise SystemExit('Android signing key is empty')
    target = Path(os.environ['RUNNER_TEMP']) / 'marker-release.jks'
    with target.open('wb') as stream:
        target.chmod(0o600)
        stream.write(key)
    with open(os.environ['GITHUB_ENV'], 'a', encoding='utf-8') as stream:
        stream.write(f'MARKER_ANDROID_KEYSTORE_PATH={target}\n')


if __name__ == '__main__':
    main()
