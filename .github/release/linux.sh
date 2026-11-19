#!/usr/bin/env bash
set -euo pipefail
umask 022
tools_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
packaging_dir="$tools_dir/../../linux/packaging"
architecture=${MARKER_LINUX_ARCH:-x64}
case "$architecture" in
  x64) deb_arch=amd64; image_arch=x86_64 ;;
  arm64) deb_arch=arm64; image_arch=aarch64 ;;
  *) echo "Unsupported Linux architecture: $architecture" >&2; exit 1 ;;
esac
bundle="build/linux/$architecture/release/bundle"
glibc_version=$(getconf GNU_LIBC_VERSION | awk '{print $2}')
python3 - "$bundle/data/flutter_assets/version.json" <<'PY'
import json, os, sys
info = json.load(open(sys.argv[1], encoding='utf-8'))
assert info['version'] == os.environ['EXPECTED_VERSION']
assert info['build_number'] == os.environ['EXPECTED_BUILD']
PY
mkdir -p dist
install -Dm644 "$tools_dir/dev.ekko.marker.metainfo.xml" \
  "$bundle/share/metainfo/dev.ekko.marker.metainfo.xml"
# Include a relocatable user installer alongside the bundle.
cp "$packaging_dir/install-user.sh" "$packaging_dir/installer.py" "$packaging_dir/installer_i18n.py" \
  "$packaging_dir/installer-welcome.png" "$bundle/"
cp "$packaging_dir/dev.ekko.marker.desktop" "$packaging_dir/dev.ekko.marker.xml" "$bundle/"
tar -czf "dist/Marker-linux-$architecture.tar.gz" -C "$bundle" .
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
Architecture: $deb_arch
Section: editors
Priority: optional
Maintainer: Marker <noreply@users.noreply.github.com>
Depends: libc6 (>= $glibc_version), libstdc++6, libgtk-3-0t64 | libgtk-3-0, libgl1, libsecret-1-0, shared-mime-info, desktop-file-utils
Homepage: https://github.com/Echo-BraveShine/Marker
Description: Markdown editor with live preview / Markdown 编辑与实时预览
 Write Markdown with syntax highlighting, math and Mermaid support.
 在本地编辑和预览 Markdown、数学公式与 Mermaid 图表。
CONTROL
for action in postinst postrm; do
  cp "$tools_dir/linux-$action" "$staging/DEBIAN/$action"
  chmod 0755 "$staging/DEBIAN/$action"
done
dpkg-deb --build --root-owner-group "$staging" "dist/Marker-linux-$deb_arch.deb"

test "$(dpkg-deb -f "dist/Marker-linux-$deb_arch.deb" Version)" = "$EXPECTED_VERSION-$EXPECTED_BUILD"
test "$(dpkg-deb -f "dist/Marker-linux-$deb_arch.deb" Architecture)" = "$deb_arch"

# Reuse the same compiled bundle for all four distribution formats.
bash "$tools_dir/linux-appimage.sh" "$bundle" "$image_arch"
bash "$tools_dir/linux-rpm.sh" "dist/Marker-linux-$architecture.tar.gz" "$image_arch"
