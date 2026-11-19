#!/usr/bin/env bash
set -euo pipefail
language="${MARKER_INSTALLER_LANGUAGE:-${LC_ALL:-${LANGUAGE:-${LC_MESSAGES:-${LANG:-en}}}}}"
case "$language" in zh*) zh=1 ;; *) zh=0 ;; esac
if (( zh )); then
  printf '\n  Marker · 让灵感，自在落笔。\n\n'
else
  printf '\n  Marker · Make room for words.\n\n'
fi
if [[ "${1:-}" == --gui ]]; then
  bundle="$(cd -- "${2:-.}" && pwd)"
  if ! python3 -c 'import gi; gi.require_version("Gtk", "3.0")' >/dev/null 2>&1; then
    if (( zh )); then echo '图形安装需要 python3-gi 和 GTK 3。也可运行：bash install-user.sh .' >&2
    else echo 'The graphical installer requires python3-gi and GTK 3. Or run: bash install-user.sh .' >&2; fi
    exit 1
  fi
  exec python3 "$bundle/installer.py" "$bundle"
fi
bundle="${1:-}"
if [[ -z "$bundle" ]]; then
  if (( zh )); then echo '用法：bash install-user.sh 安装包所在目录，或 bash install-user.sh --gui 安装包所在目录' >&2
  else echo 'Usage: bash install-user.sh /path/to/bundle, or bash install-user.sh --gui /path/to/bundle' >&2; fi
  exit 1
fi
if [[ ! -x "$bundle/marker" ]]; then
  if (( zh )); then echo '安装目录中未找到 Marker 程序。' >&2
  else echo 'Marker executable not found in bundle.' >&2; fi
  exit 1
fi
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
pathlib.Path(target).write_text(pathlib.Path(source).read_text(encoding='utf-8').replace('Exec=marker %F', f'Exec="{quoted}" %F'), encoding='utf-8')
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
if (( zh )); then
  echo 'Marker 已为当前用户安装。可在 Markdown 文档的「打开方式」中选择 Marker。'
else
  echo 'Marker installed for this user. Choose Marker from Open With for Markdown files.'
fi
