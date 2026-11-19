#!/usr/bin/env bash
# Run after exporting fixtures with MARKER_MERMAID_FIXTURES=... flutter test
# test/mermaid_diagram_test.dart. Requires WebKitGTK 4.1, g++, Xvfb and DBus.
set -euo pipefail
fixtures=$(realpath "$1")
root=$(cd "$(dirname "$0")/../.." && pwd)
staging=$(mktemp -d)
trap 'rm -rf "$staging"' EXIT
read -r -a flags <<< "$(pkg-config --cflags --libs webkit2gtk-4.1)"
g++ -std=c++14 -Wall -Wextra -Werror "$root/test/linux_launcher_test.cc" -o "$staging/launcher-test" "${flags[@]}"
TMPDIR="$staging" "$staging/launcher-test"
g++ -std=c++14 -Wall -Wextra -Werror "$root/test/linux_mermaid_test.cc" "$root/linux/runner/mermaid_renderer.cc" -o "$staging/mermaid-test" "${flags[@]}"
for fixture in "$fixtures"/*.html; do
  echo "Rendering $(basename "$fixture")"
  LIBGL_ALWAYS_SOFTWARE=1 dbus-run-session -- xvfb-run -a "$staging/mermaid-test" "$fixture" "$staging/diagram.png"
done
