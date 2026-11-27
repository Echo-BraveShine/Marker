import importlib.util
from pathlib import Path
import tempfile
import subprocess
import shutil
import sys
import unittest
import xml.etree.ElementTree as ET
import zipfile

ROOT = Path(__file__).resolve().parents[2]
SPEC = importlib.util.spec_from_file_location('windows_store', ROOT / 'scripts/windows_store.py')
store = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(store)


class WindowsStoreTests(unittest.TestCase):
    def test_identity_languages_file_activation_and_capabilities(self):
        values = store.identity()
        self.assertEqual(values['name'], 'Ekko.MarkerDocument')
        self.assertEqual(values['publisher'], 'CN=BA61D7A5-6B75-4849-9DEE-E6EC853CF873')
        self.assertEqual(values['publisher_display_name'], 'Ekko')
        self.assertEqual(values['display_name'], 'Marker Document')
        self.assertEqual(values['package_family_name'], 'Ekko.MarkerDocument_b7jpczkdr5bmw')
        self.assertEqual(values['store_id'], '9MZ7T2N8TWM4')
        document = ET.fromstring(store.manifest('1.2.3.0', values))
        ns = store.NS
        self.assertEqual(document.find('Identity', ns).attrib['Version'], '1.2.3.0')
        self.assertEqual(document.find('Identity', ns).attrib['ProcessorArchitecture'], 'x64')
        self.assertEqual(document.find('Properties/DisplayName', ns).text, 'Marker Document')
        app = document.find('Applications/Application', ns)
        self.assertEqual(app.find('uap:VisualElements', ns).attrib['DisplayName'], 'Marker Document')
        self.assertEqual(app.attrib['Executable'], 'marker.exe')
        self.assertEqual(app.attrib['EntryPoint'], 'Windows.FullTrustApplication')
        tile = app.find('uap:VisualElements/uap:DefaultTile', ns)
        self.assertIn('Square310x310Logo', tile.attrib)
        self.assertEqual(tile.attrib['Wide310x150Logo'], r'Assets\Wide310x150Logo.png')

        association = app.find('Extensions/uap:Extension/uap3:FileTypeAssociation', ns)
        self.assertEqual(association.attrib['Parameters'], '"%1"')
        self.assertEqual([e.text for e in association.findall('uap:SupportedFileTypes/uap:FileType', ns)], ['.md', '.markdown'])
        self.assertEqual(len(document.findall('Resources/Resource', ns)), 14)
        capabilities = {e.attrib['Name'] for e in document.find('Capabilities', ns)}
        self.assertEqual(capabilities, {'internetClient', 'runFullTrust'})
        store.validate_assets(ROOT / 'windows/store/Assets')

    def test_missing_or_square_wide_tile_asset_is_rejected(self):
        with tempfile.TemporaryDirectory() as temporary:
            assets = Path(temporary) / 'Assets'
            shutil.copytree(ROOT / 'windows/store/Assets', assets)
            wide = assets / 'Wide310x150Logo.png'
            wide.unlink()
            with self.assertRaises(FileNotFoundError):
                store.validate_assets(assets)
            shutil.copyfile(assets / 'Square310x310Logo.png', wide)
            with self.assertRaisesRegex(ValueError, '310 x 150'):
                store.validate_assets(assets)

    def test_invalid_store_versions_are_rejected(self):
        for value in ('0.1.0.0', '1.0.0.1', '1.0.0', '01.0.0.0', '1.65536.0.0', '1.0.0.0\n', '1.0.0.0;echo bad'):
            with self.subTest(value=value), self.assertRaises(ValueError):
                store.version_parts(value)
        self.assertEqual(store.version_parts('1.65535.9.0'), (1, 65535, 9, 0))

    def test_input_normalization_and_workflow_output(self):
        for value in ('1.0.0', 'v1.0.0', '1.0.0.0', ' 1.0.0 \n'):
            self.assertEqual(store.normalize_version(value), '1.0.0.0')
        with tempfile.TemporaryDirectory() as temporary:
            output = Path(temporary) / 'output.txt'
            result = subprocess.run(
                [sys.executable, str(ROOT / 'scripts/windows_store.py'),
                 '--version', 'v1.0.0', '--normalized', '--github-output', str(output)],
                capture_output=True, text=True)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(result.stdout.strip(), '1.0.0.0')
            self.assertEqual(output.read_text(encoding='utf-8'), 'store_version=1.0.0.0\n')

    def test_invalid_cli_version_explains_rules_without_traceback_or_outputs(self):
        with tempfile.TemporaryDirectory() as temporary:
            output = Path(temporary) / 'output.txt'
            result = subprocess.run(
                [sys.executable, str(ROOT / 'scripts/windows_store.py'),
                 '--version', '0.1.0', '--github-output', str(output)],
                capture_output=True, text=True)
            self.assertNotEqual(result.returncode, 0)
            self.assertIn('0.1.0', result.stderr)
            self.assertIn('Major must be >= 1', result.stderr)
            self.assertNotIn('Traceback', result.stderr)
            self.assertFalse(output.exists())

    def test_pubspec_automatically_sets_store_version_and_ignores_build_revision(self):
        with tempfile.TemporaryDirectory() as temporary:
            directory = Path(temporary)
            pubspec = directory / '中文 pubspec.yaml'
            output = directory / 'github-output'
            for version in ('1.0.0+1', '1.0.0+2', '1.2.3'):
                pubspec.write_text(f'\ufeffdescription: "中文"\nversion: "{version}" # app version\n', encoding='utf-8')
                expected = version.split('+')[0] + '.0'
                self.assertEqual(store.version_from_pubspec(pubspec), expected)
            result = subprocess.run([
                sys.executable, str(ROOT / 'scripts/windows_store.py'),
                '--pubspec', str(pubspec), '--normalized', '--github-output', str(output)],
                capture_output=True, text=True)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(result.stdout.strip(), '1.2.3.0')
            self.assertEqual(output.read_text(encoding='utf-8'), 'store_version=1.2.3.0\n')

    def test_missing_unstable_or_incompatible_pubspec_version_is_rejected(self):
        with tempfile.TemporaryDirectory() as temporary:
            pubspec = Path(temporary) / 'pubspec.yaml'
            for text in ('name: marker', 'version: 1.0.0-beta+1', 'version: 0.1.0+1'):
                pubspec.write_text(text, encoding='utf-8')
                with self.subTest(text=text), self.assertRaises(ValueError):
                    store.version_from_pubspec(pubspec)

    def bundle(self, directory):
        bundle = directory / '中文 空格 bundle'
        for name in store.REQUIRED:
            file = bundle / name
            file.parent.mkdir(parents=True, exist_ok=True)
            file.write_bytes(b'release fixture')
        return bundle

    def test_staging_preserves_assets_and_licenses_without_symbols_or_overwrite(self):
        with tempfile.TemporaryDirectory() as temporary:
            directory = Path(temporary)
            bundle = self.bundle(directory)
            license_file = bundle / 'data/flutter_assets/assets/fonts/OFL-NotoSansKR.txt'
            license_file.parent.mkdir(parents=True, exist_ok=True)
            license_file.write_text('license fixture', encoding='utf-8')
            (bundle / 'marker.pdb').write_bytes(b'symbols')
            output = directory / '商店 暂存'
            store.prepare(bundle, output, '1.0.0.0')
            self.assertTrue((output / license_file.relative_to(bundle)).is_file())
            self.assertFalse((output / 'marker.pdb').exists())
            with self.assertRaises(ValueError):
                store.prepare(bundle, output, '1.0.0.0')

    def test_incomplete_or_credential_containing_bundle_is_rejected(self):
        with tempfile.TemporaryDirectory() as temporary:
            directory = Path(temporary)
            bundle = self.bundle(directory)
            (bundle / 'data/app.so').unlink()
            with self.assertRaisesRegex(ValueError, 'app.so'):
                store.prepare(bundle, directory / 'stage', '1.0.0.0')
            (bundle / 'data/app.so').write_bytes(b'app')
            (bundle / 'private.pfx').write_bytes(b'not a real key')
            with self.assertRaisesRegex(ValueError, 'Unexpected package input'):
                store.prepare(bundle, directory / 'stage', '1.0.0.0')

    def test_final_archive_must_match_identity_and_version(self):
        with tempfile.TemporaryDirectory() as temporary:
            directory = Path(temporary)
            stage = directory / 'stage'
            store.prepare(self.bundle(directory), stage, '1.0.0.0')
            package = directory / 'Marker.msix'
            with zipfile.ZipFile(package, 'w') as archive:
                for file in stage.rglob('*'):
                    if file.is_file():
                        archive.write(file, file.relative_to(stage).as_posix())
                archive.writestr('AppxBlockMap.xml', '<BlockMap/>')
                archive.writestr('[Content_Types].xml', '<Types/>')
            store.verify(package, '1.0.0.0')
            self.assertTrue(package.with_suffix('.msix.sha256').is_file())
            with self.assertRaisesRegex(ValueError, 'differs'):
                store.verify(package, '1.0.1.0')


if __name__ == '__main__':
    unittest.main()
