#!/usr/bin/env python3
"""Install Marker-owned Gradle CI defaults without changing Flutter or plugins."""
import os
from pathlib import Path
import shutil


def configure(gradle_home=None):
    home = Path(gradle_home or os.environ.get('GRADLE_USER_HOME') or Path.home() / '.gradle')
    target = home / 'init.d/marker-android-repositories.gradle'
    target.parent.mkdir(parents=True, exist_ok=True)
    source = Path(__file__).resolve().parent / 'ci/android-repositories.init.gradle'
    shutil.copyfile(source, target)
    return target


if __name__ == '__main__':
    print(f'Installed Android CI repository policy: {configure()}')
