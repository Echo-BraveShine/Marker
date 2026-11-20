#!/usr/bin/env bash
# Run after exporting fixtures with MARKER_MERMAID_FIXTURES=... flutter test
# test/mermaid_diagram_test.dart. Requires WebKitGTK 4.1, g++, Xvfb and DBus.
set -euo pipefail
fixtures=$(realpath "$1")
root=$(cd "$(dirname "$0")/../.." && pwd)
staging=$(mktemp -d)
results="$fixtures/rendered"
mkdir -p "$results"
trap 'rm -rf "$staging"' EXIT
read -r -a flags <<< "$(pkg-config --cflags --libs webkit2gtk-4.1)"
g++ -std=c++14 -Wall -Wextra -Werror "$root/test/linux_snapshot_crop_test.cc" -o "$staging/crop-test" "${flags[@]}"
"$staging/crop-test"
g++ -std=c++14 -Wall -Wextra -Werror "$root/test/linux_launcher_test.cc" -o "$staging/launcher-test" "${flags[@]}"
TMPDIR="$staging" "$staging/launcher-test"
g++ -std=c++14 -Wall -Wextra -Werror "$root/test/linux_mermaid_test.cc" "$root/linux/runner/mermaid_renderer.cc" -o "$staging/mermaid-test" "${flags[@]}"
status=0
for fixture in "$fixtures"/*.html; do
  echo "Rendering $(basename "$fixture")"
  if ! NO_AT_BRIDGE=1 LIBGL_ALWAYS_SOFTWARE=1 dbus-run-session -- xvfb-run -a "$staging/mermaid-test" "$fixture" "$results/$(basename "${fixture%.html}").png"; then
    status=1
  fi
done
exit "$status"
