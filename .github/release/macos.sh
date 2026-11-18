#!/usr/bin/env bash
set -euo pipefail
app=build/macos/Build/Products/Release/marker.app
plist="$app/Contents/Info.plist"
[[ "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$plist")" == "$EXPECTED_VERSION" ]]
[[ "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' "$plist")" == "$EXPECTED_BUILD" ]]
# Reject partial-architecture plugins instead of shipping a broken universal app.
while IFS= read -r -d '' binary; do
  if file "$binary" | grep -q 'Mach-O'; then
    architectures=$(lipo -archs "$binary")
    if [[ " $architectures " != *" arm64 "* || " $architectures " != *" x86_64 "* ]]; then
      echo "Missing universal architecture in $binary: $architectures" >&2
      exit 1
    fi
  fi
done < <(find "$app" -type f -print0)
# Development distribution without a Developer ID secret: ad-hoc seal only.
codesign --force --deep --sign - --preserve-metadata=entitlements "$app"
codesign --verify --deep --strict "$app"
mkdir -p dist
ditto -c -k --sequesterRsrc --keepParent "$app" dist/Marker-macos-universal.zip
staging=$(mktemp -d)
trap 'rm -rf "$staging"' EXIT
ditto "$app" "$staging/Marker.app"
ln -s /Applications "$staging/Applications"
hdiutil create -volname Marker -srcfolder "$staging" -ov -format UDZO dist/Marker-macos-universal.dmg
