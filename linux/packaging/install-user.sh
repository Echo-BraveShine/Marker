#!/usr/bin/env bash
set -euo pipefail
bundle="${1:?Usage: install-user.sh /path/to/flutter/release/bundle}"
[[ -x "$bundle/marker" ]] || { echo 'Marker executable not found in bundle.' >&2; exit 1; }
script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
app_dir="$HOME/.local/share/marker"
applications_dir="$HOME/.local/share/applications"
mime_dir="$HOME/.local/share/mime"
mkdir -p "$app_dir" "$applications_dir" "$mime_dir/packages"
cp -R "$bundle/." "$app_dir/"
cp "$script_dir/dev.ekko.marker.xml" "$mime_dir/packages/"
python3 - "$script_dir/dev.ekko.marker.desktop" "$applications_dir/dev.ekko.marker.desktop" "$app_dir/marker" <<'PY'
import pathlib, sys
source, target, executable = sys.argv[1:]
quoted = executable.replace('\\', '\\\\').replace('"', '\\"').replace('`', '\\`').replace('$', '\\$').replace('%', '%%')
pathlib.Path(target).write_text(pathlib.Path(source).read_text().replace('Exec=marker %F', f'Exec="{quoted}" %F'))
PY
icon_source="$app_dir/share/icons/hicolor"
if [[ -d "$icon_source" ]]; then
  mkdir -p "$HOME/.local/share/icons/hicolor"
  cp -R "$icon_source/." "$HOME/.local/share/icons/hicolor/"
  if command -v gtk-update-icon-cache >/dev/null && [[ -f "$HOME/.local/share/icons/hicolor/index.theme" ]]; then
    gtk-update-icon-cache -f "$HOME/.local/share/icons/hicolor"
  fi
fi
if command -v update-mime-database >/dev/null; then update-mime-database "$mime_dir"; fi
if command -v update-desktop-database >/dev/null; then update-desktop-database "$applications_dir"; fi
echo 'Marker installed for this user. Choose Marker from Open With for Markdown files.'
