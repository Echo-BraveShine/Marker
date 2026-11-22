import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:marker/src/export/export_destination.dart';
import 'package:path/path.dart' as p;
import 'support/file_cleanup.dart';

void main() {
  late Directory folder;
  final writer = ExportDestinationWriter();
  setUp(
    () async => folder = await Directory.systemTemp.createTemp(
      'marker-export-destination-',
    ),
  );
  tearDown(
    () => withWindowsFileLockRetry(() => folder.delete(recursive: true)),
  );

  test('Unicode and spaces survive extension normalization', () async {
    final selected = p.join(folder.path, '中文 图');
    final bytes = Uint8List.fromList([1, 2, 3]);
    final target = await writer.write(
      bytes,
      selectedPath: selected,
      extension: 'png',
    );
    expect(target, p.join(folder.path, '中文 图.png'));
    expect(await File(target).readAsBytes(), bytes);
    expect(folder.listSync().whereType<Directory>(), isEmpty);
    expect(
      writer.resolvePath(p.join(folder.path, 'new.txt'), extension: 'PDF'),
      p.join(folder.path, 'new.pdf'),
    );
  });

  test(
    'confirmed output can be replaced and unrelated temporary files survive',
    () async {
      final target = File(p.join(folder.path, 'existing.pdf'));
      await target.writeAsString('old');
      final unrelated = await Directory(
        p.join(folder.path, 'marker-temp'),
      ).create();
      await File(p.join(unrelated.path, 'user.txt')).writeAsString('keep');
      await writer.write(
        Uint8List.fromList([4, 5]),
        selectedPath: target.path,
        extension: 'pdf',
      );
      expect(await target.readAsBytes(), [4, 5]);
      expect(
        await File(p.join(unrelated.path, 'user.txt')).readAsString(),
        'keep',
      );
      expect(
        folder.listSync().whereType<Directory>().map((e) => p.basename(e.path)),
        ['marker-temp'],
      );
    },
  );

  test('unsafe targets and empty data preserve existing files', () async {
    final original = File(p.join(folder.path, 'source.MD'));
    await original.writeAsString('markdown');
    for (final selected in [
      '',
      '  ',
      original.path,
      p.join(folder.path, 'source.markdown'),
      folder.path,
    ]) {
      expect(
        () => writer.resolvePath(selected, extension: 'pdf'),
        throwsA(isA<ExportDestinationException>()),
      );
    }
    final dottedFolder = await Directory(
      p.join(folder.path, 'folder.pdf'),
    ).create();
    expect(
      () => writer.resolvePath(dottedFolder.path, extension: 'pdf'),
      throwsA(isA<ExportDestinationException>()),
    );
    final target = File(p.join(folder.path, 'existing.pdf'));
    await target.writeAsString('keep');
    expect(
      () => writer.resolvePath(
        p.join(folder.path, 'existing.txt'),
        extension: 'pdf',
      ),
      throwsA(isA<ExportDestinationException>()),
    );
    await expectLater(
      writer.write(Uint8List(0), selectedPath: target.path, extension: 'pdf'),
      throwsA(isA<ExportDestinationException>()),
    );
    expect(await target.readAsString(), 'keep');
    expect(await original.readAsString(), 'markdown');
    expect(folder.listSync().whereType<Directory>().length, 1);
  });

  test(
    'source aliases are rejected before and after extension normalization',
    () async {
      final source = File(p.join(folder.path, 'UpperCaseSource.MD'));
      await source.writeAsString('keep');
      for (final name in ['alias.pdf', 'alias']) {
        final alias = Link(p.join(folder.path, name));
        try {
          await alias.create(source.path);
        } on FileSystemException {
          if (Platform.isWindows) {
            return;
          } // Symlink privilege may be unavailable.
          rethrow;
        }
        expect(
          () => writer.resolvePath(
            alias.path,
            extension: 'pdf',
            sourcePath: source.path,
          ),
          throwsA(isA<ExportDestinationException>()),
        );
      }
      expect(await source.readAsString(), 'keep');
    },
  );

  test(
    'missing output directory fails without changing existing files',
    () async {
      final existing = File(p.join(folder.path, 'existing.pdf'));
      await existing.writeAsString('keep');
      await expectLater(
        writer.write(
          Uint8List.fromList([1]),
          selectedPath: p.join(folder.path, 'missing', 'out.pdf'),
          extension: 'pdf',
        ),
        throwsA(isA<FileSystemException>()),
      );
      expect(await existing.readAsString(), 'keep');
      expect(folder.listSync().whereType<Directory>(), isEmpty);
    },
  );
}
