import importlib.util
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[2]
SPEC = importlib.util.spec_from_file_location('configure_android_ci', ROOT / 'scripts/configure_android_ci.py')
ci = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(ci)
MIRROR = 'https://maven-central.storage-download.googleapis.com/maven2/'


class AndroidCiRepositoriesTests(unittest.TestCase):
    def test_policy_install_is_idempotent_and_preserves_other_init_scripts(self):
        with tempfile.TemporaryDirectory(prefix='marker-gradle-policy-') as temporary:
            home = Path(temporary) / '中文 Gradle'
            unrelated = home / 'init.d/existing.gradle'
            unrelated.parent.mkdir(parents=True)
            unrelated.write_text('// untouched', encoding='utf-8')
            target = ci.configure(home)
            expected = (ROOT / 'scripts/ci/android-repositories.init.gradle').read_bytes()
            self.assertEqual(target.read_bytes(), expected)
            self.assertEqual(ci.configure(home).read_bytes(), expected)
            self.assertEqual(unrelated.read_text(encoding='utf-8'), '// untouched')

    @unittest.skipUnless(os.environ.get('MARKER_GRADLE_EXECUTABLE'), 'Opt-in offline Gradle fixture; no Android SDK needed')
    def test_policy_applies_to_plugin_project_and_flutter_style_included_build(self):
        with tempfile.TemporaryDirectory(prefix='marker-gradle-fixture-') as temporary:
            root = Path(temporary)
            included = root / 'included'
            included.mkdir()
            (root / 'settings.gradle').write_text('''
pluginManagement { repositories { mavenCentral(); gradlePluginPortal() } }
rootProject.name = 'main'
includeBuild('included')
assert pluginManagement.repositories.first().url.toString() == '%s'
''' % MIRROR, encoding='utf-8')
            (included / 'settings.gradle').write_text('''
rootProject.name = 'included'
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories { mavenCentral() }
}
assert pluginManagement.repositories.first().url.toString() == '%s'
assert dependencyResolutionManagement.repositories.first().url.toString() == '%s'
''' % (MIRROR, MIRROR), encoding='utf-8')
            (root / 'build.gradle').write_text('''
repositories { mavenCentral(); maven { url = uri('https://example.com/private/') } }
tasks.register('verifyPolicy') {
    dependsOn gradle.includedBuild('included').task(':verifyPolicy')
    doLast {
        assert repositories.first().url.toString() == '%s'
        assert repositories.last().url.toString() == 'https://example.com/private/'
        assert buildscript.repositories.first().url.toString() == '%s'
        assert gradle.startParameter.maxWorkerCount <= 2
        println 'MAIN POLICY PASSED'
    }
}
''' % (MIRROR, MIRROR), encoding='utf-8')
            (included / 'build.gradle').write_text('''
tasks.register('verifyPolicy') {
    doLast {
        assert repositories.empty
        assert buildscript.repositories.first().url.toString() == '%s'
        println 'INCLUDED POLICY PASSED'
    }
}
''' % MIRROR, encoding='utf-8')
            result = subprocess.run([
                os.environ['MARKER_GRADLE_EXECUTABLE'], '--offline', '--no-daemon',
                '--console=plain', '-I', str(ROOT / 'scripts/ci/android-repositories.init.gradle'),
                '-p', str(root), 'verifyPolicy'], capture_output=True, text=True, timeout=120)
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            self.assertIn('MAIN POLICY PASSED', result.stdout)
            self.assertIn('INCLUDED POLICY PASSED', result.stdout)


if __name__ == '__main__':
    unittest.main()
