#!/usr/bin/env bash
set -euo pipefail
tools_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
app=build/macos/Build/Products/Release/marker.app
plist="$app/Contents/Info.plist"
[[ "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$plist")" == "$EXPECTED_VERSION" ]]
[[ "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' "$plist")" == "$EXPECTED_BUILD" ]]
check_slices() {
  local root=$1 expected=$2 binary architectures arch
  while IFS= read -r -d '' binary; do
    if [[ "$(file -b "$binary")" == *Mach-O* ]]; then
      architectures=$(lipo -archs "$binary")
      for arch in $expected; do
        if [[ " $architectures " != *" $arch "* ]]; then
          echo "Missing $arch in $binary: $architectures" >&2
          return 1
        fi
      done
      if [[ "$expected" != *' '* && "$architectures" != "$expected" ]]; then
        echo "Expected only $expected in $binary: $architectures" >&2
        return 1
      fi
    fi
  done < <(find "$root" -type f -print0)
}
check_slices "$app" 'arm64 x86_64'
# Thinning invalidates signatures; seal the universal ZIP and each DMG app.
codesign --force --deep --sign - --preserve-metadata=entitlements,requirements,flags,runtime "$app"
codesign --verify --deep --strict "$app"
mkdir -p dist
ditto -c -k --sequesterRsrc --keepParent "$app" dist/Marker-macos.zip
staging=$(mktemp -d)
trap 'rm -rf "$staging"' EXIT
for architecture in arm64 x86_64; do
  stage="$staging/$architecture"
  mkdir -p "$stage"
  ditto --arch "$architecture" "$app" "$stage/Marker.app"
  check_slices "$stage/Marker.app" "$architecture"
  codesign --force --deep --sign - --preserve-metadata=entitlements,requirements,flags,runtime "$stage/Marker.app"
  codesign --verify --deep --strict "$stage/Marker.app"
  output="dist/Marker-macos-$architecture.dmg"
  "${DMGBUILD:-dmgbuild}" -s "$tools_dir/macos-dmg.py" \
    -D "app=$stage/Marker.app" -D "background=$tools_dir/macos-background.png" Marker "$output"
  hdiutil verify "$output"
done
