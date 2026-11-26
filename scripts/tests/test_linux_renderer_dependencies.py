import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

SCRIPT = Path(__file__).resolve().parents[1] / 'check_linux_renderer_dependencies.py'


class LinuxRendererDependenciesTests(unittest.TestCase):
    def check_graph(self, plugins):
        with tempfile.TemporaryDirectory() as folder:
            (Path(folder) / '.flutter-plugins-dependencies').write_text(
                json.dumps({'plugins': {'linux': plugins}}), encoding='utf-8')
            return subprocess.run(
                [sys.executable, str(SCRIPT), '--project-dir', folder],
                env=dict(os.environ, SOURCE_SHA='old-tag-commit'),
                capture_output=True, text=True, encoding='utf-8')

    def test_old_source_graph_reports_tag_mismatch(self):
        result = self.check_graph([{'name': 'flutter_inappwebview_linux'}])
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('old-tag-commit', result.stderr)
        self.assertIn('new release tag', result.stderr)

    def test_native_gtk_graph_remains_supported(self):
        result = self.check_graph([{'name': 'desktop_drop'}, {'name': 'file_selector_linux'}])
        self.assertEqual(result.returncode, 0, result.stderr)


if __name__ == '__main__':
    unittest.main()
