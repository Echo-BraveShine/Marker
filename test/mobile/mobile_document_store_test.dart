import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:file_selector/file_selector.dart';
import 'package:marker/src/mobile/mobile_document_store.dart';

class _PickerFile extends XFile {
  _PickerFile(super.path, this.pickerName);
  final String pickerName;
  @override
  String get name => pickerName;
}

void main() {
  test(
    'ZIP import retains relative assets and rejects paths outside its folder',
    () async {
      final root = await Directory.systemTemp.createTemp('marker-zip-import-');
      try {
        final store = MobileDocumentStore(
          directory: () async => Directory(p.join(root.path, 'documents')),
        );
        final archive = Archive()
          ..addFile(
            ArchiveFile.string('note/note.md', '![image](note.assets/a.png)'),
          )
          ..addFile(ArchiveFile('note/note.assets/a.png', 3, [1, 2, 3]));
        final source = File(p.join(root.path, 'package.zip'));
        await source.writeAsBytes(ZipEncoder().encode(archive));
        final imported = File(await store.importDocument(XFile(source.path)));
        expect(await imported.readAsString(), contains('note.assets/a.png'));
        expect(
          await File(
            p.join(imported.parent.path, 'note.assets', 'a.png'),
          ).readAsBytes(),
          [1, 2, 3],
        );
        final invalid = Archive()
          ..addFile(ArchiveFile.string('../outside.md', 'bad'));
        await source.writeAsBytes(ZipEncoder().encode(invalid));
        await expectLater(
          store.importDocument(XFile(source.path)),
          throwsFormatException,
        );
        expect(
          await File(p.join(root.path, 'documents', 'outside.md')).exists(),
          isFalse,
        );
        final folders = await Directory(
          p.join(root.path, 'documents'),
        ).list().toList();
        expect(folders, hasLength(1));
      } finally {
        await root.delete(recursive: true);
      }
    },
  );
  test('picker names can contain Windows or POSIX paths', () async {
    final root = await Directory.systemTemp.createTemp('marker-picker-name-');
    try {
      final source = File(p.join(root.path, '原稿.md'));
      await source.writeAsString('# 中文');
      final store = MobileDocumentStore(
        directory: () async => Directory(p.join(root.path, 'documents')),
      );
      for (final name in [
        r'C:\picker cache\原稿.md',
        '/picker cache/原稿.md',
        '原稿.md',
      ]) {
        final imported = File(
          await store.importDocument(_PickerFile(source.path, name)),
        );
        expect(p.basename(imported.path), '原稿.md');
        expect(await imported.readAsString(), '# 中文');
      }
    } finally {
      await root.delete(recursive: true);
    }
  });
  test(
    'imported copies survive picker cache deletion and preserve originals',
    () async {
      final root = await Directory.systemTemp.createTemp('marker-mobile-');
      try {
        final source = File(p.join(root.path, '原稿.md'));
        await source.writeAsString('# 中文');
        final store = MobileDocumentStore(
          directory: () async => Directory(p.join(root.path, 'documents')),
        );
        final copy = File(await store.importDocument(XFile(source.path)));
        await copy.writeAsString('# Edited');
        expect(await source.readAsString(), '# 中文');
        await source.delete();
        expect(await copy.readAsString(), '# Edited');
        expect(await store.savePath('新文档'), endsWith('新文档.md'));
        final first = await store.newDocumentPath();
        await File(first).writeAsString('keep');
        final second = await store.newDocumentPath();
        expect(second, isNot(first));
        expect(await File(first).readAsString(), 'keep');
        for (final name in [
          '',
          '..',
          '../outside.md',
          r'a\b.md',
          '/tmp/a.md',
        ]) {
          expect(
            () => MobileDocumentStore.filename(name),
            throwsFormatException,
          );
        }
      } finally {
        await root.delete(recursive: true);
      }
    },
  );
}
