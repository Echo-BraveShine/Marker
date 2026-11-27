#!/usr/bin/env python3
"""Prepare and inspect a Microsoft Store package; MakeAppx runs on Windows."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import shutil
import struct
import xml.etree.ElementTree as ET
import zipfile

ROOT = Path(__file__).resolve().parents[1]
NS = {
    '': 'http://schemas.microsoft.com/appx/manifest/foundation/windows10',
    'uap': 'http://schemas.microsoft.com/appx/manifest/uap/windows10',
    'uap3': 'http://schemas.microsoft.com/appx/manifest/uap/windows10/3',
    'rescap': 'http://schemas.microsoft.com/appx/manifest/foundation/windows10/restrictedcapabilities',
}
for prefix, uri in NS.items():
    ET.register_namespace(prefix, uri)
LANGUAGES = ('en-US', 'zh-Hans', 'zh-Hant', 'ja-JP', 'ko-KR', 'de-DE',
             'fr-FR', 'es-ES', 'pt-BR', 'it-IT', 'ru-RU', 'tr-TR', 'pl-PL', 'id-ID')
ASSETS = {'StoreLogo.png': 50, 'Square44x44Logo.png': 44,
          'Square150x150Logo.png': 150, 'Square310x310Logo.png': 310}
REQUIRED = ('marker.exe', 'flutter_windows.dll', 'data/icudtl.dat', 'data/app.so',
            'data/flutter_assets/AssetManifest.bin', 'msvcp140.dll',
            'vcruntime140.dll', 'vcruntime140_1.dll',
            'data/flutter_assets/assets/fonts/OFL-NotoSansSC.txt',
            'data/flutter_assets/assets/fonts/OFL-NotoSansKR.txt',
            'data/flutter_assets/assets/export/marker-fonts-OFL.txt',
            'data/flutter_assets/assets/export/katex-fonts-LICENSE.txt')


def version_parts(version):
    if not re.fullmatch(r'(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)\.0', version):
        raise ValueError('Store version must be Major.Minor.Build.0 (e.g. 1.0.0.0)')
    parts = tuple(map(int, version.split('.')))
    if parts[0] == 0 or any(p > 65535 for p in parts):
        raise ValueError('Store version requires Major >= 1; each part must be <= 65535')
    return parts


def identity(root=ROOT):
    values = json.loads((root / 'windows/store/identity.json').read_text(encoding='utf-8'))
    if any(not isinstance(v, str) or v != v.strip() or not v for v in values.values()):
        raise ValueError('Store identity values must be nonempty without surrounding whitespace')
    return values


def manifest(version, values):
    version_parts(version)
    def node(parent, tag, text=None, **attrs):
        prefix, local = tag.split(':') if ':' in tag else ('', tag)
        child = ET.SubElement(parent, f'{{{NS[prefix]}}}{local}', attrs)
        child.text = text
        return child
    package = ET.Element(f'{{{NS[""]}}}Package', {'IgnorableNamespaces': 'uap uap3 rescap'})
    node(package, 'Identity', Name=values['name'], Publisher=values['publisher'],
         Version=version, ProcessorArchitecture='x64')
    properties = node(package, 'Properties')
    node(properties, 'DisplayName', values['display_name'])
    node(properties, 'PublisherDisplayName', values['publisher_display_name'])
    node(properties, 'Logo', r'Assets\StoreLogo.png')
    dependencies = node(package, 'Dependencies')
    node(dependencies, 'TargetDeviceFamily', Name='Windows.Desktop',
         MinVersion='10.0.19041.0', MaxVersionTested='10.0.26100.0')
    resources = node(package, 'Resources')
    for language in LANGUAGES:
        node(resources, 'Resource', Language=language)
    applications = node(package, 'Applications')
    app = node(applications, 'Application', Id='App', Executable='marker.exe',
               EntryPoint='Windows.FullTrustApplication')
    visual = node(app, 'uap:VisualElements', DisplayName=values['display_name'],
                  Description='Markdown editor and preview', BackgroundColor='transparent',
                  Square44x44Logo=r'Assets\Square44x44Logo.png',
                  Square150x150Logo=r'Assets\Square150x150Logo.png')
    node(visual, 'uap:DefaultTile', Square310x310Logo=r'Assets\Square310x310Logo.png')
    extensions = node(app, 'Extensions')
    extension = node(extensions, 'uap:Extension', Category='windows.fileTypeAssociation')
    association = node(extension, 'uap3:FileTypeAssociation', Name='markdown', Parameters='"%1"')
    node(association, 'uap:DisplayName', 'Markdown')
    node(association, 'uap:Logo', r'Assets\Square44x44Logo.png')
    types = node(association, 'uap:SupportedFileTypes')
    for suffix in ('.md', '.markdown'):
        node(types, 'uap:FileType', suffix, ContentType='text/markdown')
    capabilities = node(package, 'Capabilities')
    node(capabilities, 'Capability', Name='internetClient')
    node(capabilities, 'rescap:Capability', Name='runFullTrust')
    ET.indent(package, space='  ')
    return ET.tostring(package, encoding='utf-8', xml_declaration=True)


def validate_assets(directory):
    for name, size in ASSETS.items():
        data = (directory / name).read_bytes()
        if data[:8] != b'\x89PNG\r\n\x1a\n' or struct.unpack('>II', data[16:24]) != (size, size):
            raise ValueError(f'Invalid Store PNG: {name} (expected {size} x {size})')


def prepare(bundle, output, version, root=ROOT):
    version_parts(version)
    if output.exists():
        raise ValueError(f'Staging directory already exists: {output}')
    for name in REQUIRED:
        file = bundle / name
        if not file.is_file() or file.stat().st_size == 0:
            raise ValueError(f'Incomplete Release bundle: {name}')
    validate_assets(root / 'windows/store/Assets')
    # A store build must not silently include stale debug DLLs or certificate keys.
    for file in bundle.rglob('*'):
        if file.is_symlink() or file.suffix.lower() in ('.pfx', '.p12', '.key', '.cer'):
            raise ValueError(f'Unexpected package input: {file.name}')
    shutil.copytree(bundle, output, ignore=shutil.ignore_patterns('*.pdb'))
    shutil.copytree(root / 'windows/store/Assets', output / 'Assets')
    (output / 'AppxManifest.xml').write_bytes(manifest(version, identity(root)))


def verify(package, version, root=ROOT):
    expected = manifest(version, identity(root))
    with zipfile.ZipFile(package) as archive:
        for name in (*REQUIRED, *(f'Assets/{name}' for name in ASSETS), 'AppxBlockMap.xml', '[Content_Types].xml'):
            if archive.getinfo(name).file_size == 0:
                raise ValueError(f'Empty package member: {name}')
        actual = ET.fromstring(archive.read('AppxManifest.xml'))
        desired = ET.fromstring(expected)
        def semantic(element):
            return (element.tag, sorted(element.attrib.items()), (element.text or '').strip(),
                    tuple(semantic(child) for child in element))
        if semantic(actual) != semantic(desired):
            raise ValueError('Packaged manifest differs from Store identity/version contract')
    digest = hashlib.sha256(package.read_bytes()).hexdigest()
    package.with_suffix('.msix.sha256').write_text(f'{digest}  {package.name}\n', encoding='utf-8')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--version', required=True)
    parser.add_argument('--bundle', type=Path)
    parser.add_argument('--output', type=Path)
    parser.add_argument('--verify', type=Path)
    args = parser.parse_args()
    parts = version_parts(args.version)
    if args.verify:
        verify(args.verify, args.version)
    elif args.bundle and args.output:
        prepare(args.bundle, args.output, args.version)
    else:
        print('.'.join(map(str, parts[:3])))


if __name__ == '__main__':
    main()
