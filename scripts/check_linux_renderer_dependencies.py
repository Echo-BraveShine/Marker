#!/usr/bin/env python3
"""Reject obsolete WPE registration before compiling Marker's GTK renderer."""
import argparse
import json
import os
from pathlib import Path


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--project-dir', type=Path, default=Path.cwd())
    args = parser.parse_args()
    graph = args.project_dir / '.flutter-plugins-dependencies'
    if not graph.is_file():
        raise SystemExit('Run flutter pub get before checking Linux dependencies')
    data = json.loads(graph.read_text(encoding='utf-8'))
    plugins = data.get('plugins', {}).get('linux', [])
    if any(plugin.get('name') == 'flutter_inappwebview_linux' for plugin in plugins):
        sha = os.environ.get('SOURCE_SHA', 'current checkout')
        raise SystemExit(
            f'Linux source {sha} still registers the unused WPE WebKit plugin. '
            'Marker uses its native WebKitGTK renderer. Commit the official platform-only '
            'dependencies in pubspec.yaml and pubspec.lock, then build a new release tag '
            'containing that commit. '
            'Re-running an older tag does not include branch fixes. '
            'Do not add an external WPE package source to work around this mismatch.'
        )
    print('Linux renderer dependencies verified: no unused WPE plugin registered')


if __name__ == '__main__':
    main()
