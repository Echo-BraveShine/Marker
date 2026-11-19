#!/usr/bin/env bash
# Validate the actual AppImage process, not just the archive or a transient X ID.
set -euo pipefail
if [[ "${1:-}" != --inside ]]; then
  app=$(realpath "${1:?Usage: linux-smoke.sh app.AppImage}")
  tools=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
  scratch=$(mktemp -d)
  trap 'rm -rf "$scratch"' EXIT
  XDG_CONFIG_HOME="$scratch/config" XDG_DATA_HOME="$scratch/data" \
    LIBGL_ALWAYS_SOFTWARE=1 GALLIUM_DRIVER=llvmpipe GDK_BACKEND=x11 NO_AT_BRIDGE=1 \
    xvfb-run -a -s '-screen 0 1280x900x24 +extension GLX' \
    dbus-run-session -- bash "$tools/linux-smoke.sh" --inside "$app" "$scratch/app.log" 45
  exit
fi
shift
app=$1
log=$2
limit=${3:-45}
setsid env APPIMAGE_EXTRACT_AND_RUN=1 "$app" >"$log" 2>&1 &
app_pid=$!
cleanup() {
  kill -- "-$app_pid" 2>/dev/null || true
  wait "$app_pid" 2>/dev/null || true
}
trap cleanup EXIT
failed() {
  echo "::error::$1" >&2
  cat "$log" >&2
  if [[ -s "$log.x11" ]]; then cat "$log.x11" >&2; fi
  exit 1
}
alive() { kill -0 "$app_pid" 2>/dev/null; }
start=$SECONDS
stable=0
last_windows=''
while (( SECONDS - start < limit )); do
  alive || failed 'AppImage exited before the window was ready'
  # GTK can create/destroy helper windows during startup. XQueryTree results can
  # become stale before xdotool reads attributes; retry this bounded observation.
  if windows=$(xdotool search --onlyvisible --name '^Untitled\.md( •)?$' 2>"$log.x11") && [[ -n "$windows" ]]; then
    if [[ "$windows" == "$last_windows" ]]; then stable=$((stable + 1))
    else stable=1; last_windows=$windows; fi
    if (( stable >= 3 )); then
      sleep 1
      alive || failed 'AppImage exited immediately after showing its window'
      echo 'AppImage visible window and process checks passed'
      exit 0
    fi
  else
    stable=0
    last_windows=''
  fi
  sleep 0.3
done
failed 'AppImage did not show a stable visible window within the startup timeout'
