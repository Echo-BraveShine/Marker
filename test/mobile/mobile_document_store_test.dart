import 'dart:io';
import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:file_selector/file_selector.dart';
import 'package:marker/src/mobile/mobile_document_store.dart';

void main() {
  test(
    'ZIP import retains relative assets and rejects paths outside its folder',
    () async {
      final root = await Directory.systemTemp.createTemp('marker-zip-import-');
      try {
        final store = MobileDocumentStore(
          directory: () async => Directory('${root.path}/documents'),
        );
        final archive = Archive()
          ..addFile(
            ArchiveFile.string('note/note.md', '![image](note.assets/a.png)'),
          )
          ..addFile(ArchiveFile('note/note.assets/a.png', 3, [1, 2, 3]));
        final source = File('${root.path}/package.zip');
        await source.writeAsBytes(ZipEncoder().encode(archive));
        final imported = File(await store.importDocument(XFile(source.path)));
        expect(await imported.readAsString(), contains('note.assets/a.png'));
        expect(
          await File('${imported.parent.path}/note.assets/a.png').readAsBytes(),
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
          await File('${root.path}/documents/outside.md').exists(),
          isFalse,
        );
        final folders = await Directory(
          '${root.path}/documents',
        ).list().toList();
        expect(folders, hasLength(1));
      } finally {
        await root.delete(recursive: true);
      }
    },
  );
  test(
    'imported copies survive picker cache deletion and preserve originals',
    () async {
      final root = await Directory.systemTemp.createTemp('marker-mobile-');
      try {
        final source = File('${root.path}/原稿.md');
        await source.writeAsString('# 中文');
        final store = MobileDocumentStore(
          directory: () async => Directory('${root.path}/documents'),
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
