#!/usr/bin/env bash
set -euo pipefail
root=$(cd "$(dirname "$0")/../.." && pwd)
sdk=${FLUTTER_ROOT:-$(cd "$(dirname "$(command -v flutter)")/.." && pwd)}
framework=''
for architecture in arm64 x64; do
  candidate="$sdk/bin/cache/artifacts/engine/darwin-$architecture/FlutterMacOS.xcframework/macos-arm64_x86_64"
  if [[ -d "$candidate/FlutterMacOS.framework" ]]; then
    framework=$candidate
    break
  fi
done
[[ -n "$framework" ]] || { echo 'Flutter macOS debug framework missing; run flutter precache --macos' >&2; exit 1; }
staging=$(mktemp -d)
trap 'rm -rf "$staging"' EXIT
swiftc "$root/third_party/desktop_drop/macos/desktop_drop/Sources/desktop_drop/DesktopDropPlugin.swift" \
  "$root/test/macos_drop_test.swift" -F "$framework" -framework FlutterMacOS \
  -Xlinker -rpath -Xlinker "$framework" -o "$staging/drop-test"
"$staging/drop-test"
