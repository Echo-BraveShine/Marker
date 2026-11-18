#!/usr/bin/env bash
set -euo pipefail
bundle=build/linux/x64/release/bundle
python3 - "$bundle/data/flutter_assets/version.json" <<'PY'
import json, os, sys
info = json.load(open(sys.argv[1]))
assert info['version'] == os.environ['EXPECTED_VERSION']
assert info['build_number'] == os.environ['EXPECTED_BUILD']
PY
mkdir -p dist
# Include a relocatable user installer alongside the bundle.
cp linux/packaging/install-user.sh "$bundle/install-user.sh"
cp linux/packaging/dev.ekko.marker.desktop linux/packaging/dev.ekko.marker.xml "$bundle/"
tar -czf dist/Marker-linux-x64.tar.gz -C "$bundle" .
staging=$(mktemp -d)
trap 'rm -rf "$staging"' EXIT
mkdir -p "$staging/DEBIAN" "$staging/opt/marker" "$staging/usr/bin" "$staging/usr/share"
chmod 0755 "$staging"
cp -a "$bundle/." "$staging/opt/marker/"
cp -a "$bundle/share/." "$staging/usr/share/"
ln -s /opt/marker/marker "$staging/usr/bin/marker"
cat > "$staging/DEBIAN/control" <<CONTROL
Package: marker
Version: $EXPECTED_VERSION-$EXPECTED_BUILD
Architecture: amd64
Section: editors
Priority: optional
Maintainer: Marker <noreply@users.noreply.github.com>
Depends: libc6 (>= 2.39), libstdc++6, libgtk-3-0t64 | libgtk-3-0, libgl1, libsecret-1-0, shared-mime-info, desktop-file-utils
Homepage: https://github.com/Echo-BraveShine/Marker
Description: Markdown editor with live preview
 Write Markdown with syntax highlighting, math and Mermaid support.
CONTROL
for action in postinst postrm; do
  cp ".github/release/linux-$action" "$staging/DEBIAN/$action"
  chmod 0755 "$staging/DEBIAN/$action"
done
dpkg-deb --build --root-owner-group "$staging" dist/Marker-linux-amd64.deb
