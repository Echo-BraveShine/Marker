#!/usr/bin/env bash
# Run as root inside the prepared Ubuntu VM. Registration credentials are read
# from the environment and passed through Runner's secret-masking input API.
set -euo pipefail
[[ "$(id -u)" == 0 ]] || { echo 'Run this service setup as root.' >&2; exit 1; }
: "${MARKER_RUNNER_TOKEN:?Supply the repository registration token in MARKER_RUNNER_TOKEN}"
runner=/opt/marker-ci/runner
[[ -f "$runner/config.sh" ]] || { echo 'Runner package has not been prepared.' >&2; exit 1; }
[[ ! -f "$runner/.runner" ]] || { echo 'Runner is already registered; refusing to replace it.' >&2; exit 1; }
export ACTIONS_RUNNER_INPUT_TOKEN="$MARKER_RUNNER_TOKEN"
unset MARKER_RUNNER_TOKEN
export HOME=/var/lib/marker-runner USER=marker-runner LOGNAME=marker-runner
export PATH=/opt/marker-ci/flutter/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
cd "$runner"
runuser -u marker-runner --preserve-environment -- ./config.sh --unattended \
  --url https://github.com/Echo-BraveShine/Marker \
  --name marker-parallels-ubuntu-arm64 --labels marker-linux-arm64 --work _work
unset ACTIONS_RUNNER_INPUT_TOKEN
./svc.sh install marker-runner
./svc.sh start
./svc.sh status
