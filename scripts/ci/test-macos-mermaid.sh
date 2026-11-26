#!/usr/bin/env bash
# Exercise the production WKWebView renderer without launching the user's app.
set -euo pipefail
root=$(cd "$(dirname "$0")/../.." && pwd)
sdk=${FLUTTER_ROOT:-$(cd "$(dirname "$(command -v flutter)")/.." && pwd)}
staging=$(mktemp -d)
trap 'rm -rf "$staging"' EXIT
cd "$root"
MARKER_MERMAID_FIXTURES="$staging" "$sdk/bin/flutter" test test/mermaid_diagram_test.dart --no-pub
python3 - "$root" "$staging" <<'PY'
from pathlib import Path
import sys
root, staging = map(Path, sys.argv[1:])
source = (root / 'macos/Runner/MainFlutterWindow.swift').read_text(encoding='utf-8')
renderer = 'private final class DocumentExportJob:' + source.split('private final class DocumentExportJob:', 1)[1]
harness = (root / 'test/macos_mermaid_test.swift').read_text(encoding='utf-8')
(staging / 'main.swift').write_text('import Cocoa\nimport WebKit\nimport PDFKit\n' + renderer + '\n' + harness.replace('import Cocoa\nimport WebKit\nimport PDFKit\n', '', 1), encoding='utf-8')
PY
xcrun swiftc "$staging/main.swift" -o "$staging/mermaid-test"
results=${MARKER_MERMAID_OUTPUT:-$staging/rendered}
mkdir -p "$results"
for appearance in light dark; do
  "$staging/mermaid-test" "$staging/windows/shared-assets-$appearance.html" "$results/$appearance.png"
done
