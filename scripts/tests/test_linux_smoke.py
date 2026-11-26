import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[2]


@unittest.skipUnless(os.name == 'posix' and hasattr(os, 'setsid'), 'Requires POSIX process groups')
class LinuxSmokeTests(unittest.TestCase):
    def run_probe(self, mode, app='sleep 20', limit='4'):
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            executable = root / 'app'
            executable.write_text('#!/bin/sh\n' + app + '\n', encoding='utf-8')
            executable.chmod(0o755)
            if not shutil.which('setsid'):
                launcher = root / 'setsid'
                launcher.write_text('#!' + sys.executable + '\nimport os,sys\nos.setsid()\nos.execvp(sys.argv[1],sys.argv[1:])\n', encoding='utf-8')
                launcher.chmod(0o755)
            probe = root / 'xdotool'
            probe.write_text('''#!/bin/sh
case "$*" in
  *--class*) ;;
  *) echo 'Document title is Welcome.md, not Untitled.md' >&2; exit 1 ;;
esac
n=0
[ ! -f "$PROBE_STATE" ] || n=$(cat "$PROBE_STATE")
n=$((n+1)); echo "$n" > "$PROBE_STATE"
if [ "$PROBE_MODE" = never ] || [ "$n" -lt 3 ]; then
 echo 'X Error: BadWindow' >&2; exit 1
fi
echo 1234
''', encoding='utf-8')
            probe.chmod(0o755)
            env = dict(os.environ, PATH=str(root) + os.pathsep + os.environ['PATH'],
                       PROBE_STATE=str(root / 'state'), PROBE_MODE=mode)
            return subprocess.run(['bash', str(ROOT / '.github/release/linux-smoke.sh'),
                                   '--inside', str(executable), str(root / 'app.log'), limit],
                                  env=env, capture_output=True, text=True, timeout=12)

    def test_matches_application_identity_independent_of_document_title(self):
        result = self.run_probe('welcome')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('process checks passed', result.stdout)

    def test_retries_transient_bad_window(self):
        result = self.run_probe('retry')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('process checks passed', result.stdout)

    def test_application_exit_still_fails(self):
        result = self.run_probe('retry', app='exit 7')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('exited before', result.stderr)

    def test_missing_window_times_out(self):
        result = self.run_probe('never', limit='2')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('startup timeout', result.stderr)
