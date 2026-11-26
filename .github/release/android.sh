#!/usr/bin/env bash
set -euo pipefail
apk=build/app/outputs/flutter-apk/app-release.apk
# Verify all three supported Android ABIs and the native manifest version.
python3 - "$apk" <<'PY'
import sys, zipfile
with zipfile.ZipFile(sys.argv[1]) as apk:
    for abi in ('armeabi-v7a', 'arm64-v8a', 'x86_64'):
        assert f'lib/{abi}/libapp.so' in apk.namelist(), f'Missing ABI: {abi}'
PY
sdk="${ANDROID_SDK_ROOT:-${ANDROID_HOME:-}}"
test -n "$sdk"
analyzer=$(find "$sdk/cmdline-tools" -name apkanalyzer -type f | sort -V | tail -n 1)
test -n "$analyzer"
test "$("$analyzer" manifest application-id "$apk")" = dev.ekko.marker
test "$("$analyzer" manifest version-name "$apk")" = "$EXPECTED_VERSION"
test "$("$analyzer" manifest version-code "$apk")" = "$EXPECTED_BUILD"
signer=$(find "$sdk/build-tools" -name apksigner -type f | sort -V | tail -n 1)
test -n "$signer"
"$signer" verify --verbose "$apk"
mkdir -p dist
cp "$apk" dist/Marker-android-universal.apk
