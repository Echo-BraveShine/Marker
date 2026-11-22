#!/usr/bin/env bash
set -euo pipefail
root=$(cd "$(dirname "$0")/../.." && pwd)
sdk=${FLUTTER_ROOT:-$(cd "$(dirname "$(command -v flutter)")/.." && pwd)}
staging=$(mktemp -d)
trap 'rm -rf "$staging"' EXIT
cd "$root"
MARKER_EXPORT_FIXTURES="$staging" "$sdk/bin/flutter" test test/document_export_test.dart --no-pub
# Compile the actual application renderer without launching the user's app.
python3 - "$root" "$staging" <<'PY'
from pathlib import Path
import sys
root, staging = map(Path, sys.argv[1:])
source = (root / 'macos/Runner/MainFlutterWindow.swift').read_text(encoding='utf-8')
renderer = 'private final class DocumentExportJob:' + source.split('private final class DocumentExportJob:', 1)[1]
harness = (root / 'test/macos_document_export_test.swift').read_text(encoding='utf-8')
combined = 'import Cocoa\nimport WebKit\nimport PDFKit\n' + renderer + '\n' + harness.replace('import Cocoa\nimport WebKit\nimport PDFKit\n', '', 1)
(staging / 'main.swift').write_text(combined, encoding='utf-8')
PY
xcrun swiftc "$staging/main.swift" -o "$staging/export-test"
"$staging/export-test" "$staging/document-light.html" "$staging/document.pdf" pdf
"$staging/export-test" "$staging/document-light.html" "$staging/light.png" png
"$staging/export-test" "$staging/document-dark.html" "$staging/dark.png" png

"$staging/export-test" "$staging/document-complex.html" "$staging/complex.pdf" pdf
