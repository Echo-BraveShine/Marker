#!/usr/bin/env bash
set -euo pipefail

if ! command -v patchelf >/dev/null; then
  echo '::error::RPM packaging requires patchelf on PATH.' >&2
  exit 1
fi

bundle_archive=$(realpath "$1")
arch=$2
output="$PWD/dist/Marker-linux-$arch.rpm"
mkdir -p dist
staging=$(mktemp -d)
trap 'rm -rf "$staging"' EXIT
mkdir -p "$staging/SOURCES"
cp "$bundle_archive" "$staging/SOURCES/marker.tar.gz"

rpmbuild -bb --target "$arch" --define "_topdir $staging" \
  --define "marker_version $EXPECTED_VERSION" --define "marker_build $EXPECTED_BUILD" \
  "$(dirname "$0")/marker.spec"
install -m 0644 "$staging/RPMS/$arch/marker-$EXPECTED_VERSION-$EXPECTED_BUILD.$arch.rpm" "$output"
test "$(rpm -qp --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}' "$output")" \
  = "$EXPECTED_VERSION-$EXPECTED_BUILD.$arch"
rpm -qpl "$output" > "$staging/files"
grep -Fx /opt/marker/marker "$staging/files"
grep -Fx /usr/bin/marker "$staging/files"
grep -Fx /usr/share/applications/dev.ekko.marker.desktop "$staging/files"
grep -Fx /usr/share/mime/packages/dev.ekko.marker.xml "$staging/files"
grep -Fx /usr/share/metainfo/dev.ekko.marker.metainfo.xml "$staging/files"
