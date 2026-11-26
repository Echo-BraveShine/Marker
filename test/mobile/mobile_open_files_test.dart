import 'dart:async';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:marker/src/mobile/mobile_document_store.dart';
import 'package:marker/src/mobile/mobile_open_files.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory root;
  late MobileDocumentStore store;
  late File source;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    root = await Directory.systemTemp.createTemp('marker-incoming-');
    store = MobileDocumentStore(
      directory: () async => Directory(p.join(root.path, 'documents')),
    );
    source = File(p.join(root.path, '中文 空格 #%.md'));
    await source.writeAsString('# Original');
  });
  tearDown(() => root.delete(recursive: true));

  test('reopening identical source keeps edits in its existing copy', () async {
    final first = await store.openImportedDocument(XFile(source.path));
    expect(first.reused, isFalse);
    await File(first.path).writeAsString('# Edited in Marker');
    final second = await store.openImportedDocument(XFile(source.path));
    expect(second, (path: first.path, reused: true));
    expect(await File(second.path).readAsString(), '# Edited in Marker');
    expect(await source.readAsString(), '# Original');
  });
  test(
    'files already owned by Marker open directly and cannot escape the document root',
    () async {
      final docs = Directory(p.join(root.path, 'documents'));
      await docs.create();
      final owned = File(p.join(docs.path, 'owned.md'));
      await owned.writeAsString('# Owned');
      final direct = await store.openImportedDocument(XFile(owned.path));
      expect(direct, (path: owned.path, reused: true));
      final delivered = await store.openImportedDocument(
        XFile(source.path),
        ownedRelativePath: 'owned.md',
      );
      expect(delivered.path, owned.path);
      final invalid = await store.openImportedDocument(
        XFile(source.path),
        ownedRelativePath: p.join('..', p.basename(source.path)),
      );
      expect(invalid.reused, isFalse);
      expect(p.isWithin(docs.path, invalid.path), isTrue);
      await owned.delete();
      await expectLater(
        store.openImportedDocument(
          XFile(source.path),
          ownedRelativePath: 'owned.md',
        ),
        throwsA(isA<FileSystemException>()),
      );
      expect(await owned.exists(), isFalse);
    },
  );
  test('changed source creates a new copy without replacing edits', () async {
    final first = await store.openImportedDocument(XFile(source.path));
    await File(first.path).writeAsString('# My edits');
    await source.writeAsString('# New source version');
    final second = await store.openImportedDocument(XFile(source.path));
    expect(second.reused, isFalse);
    expect(second.path, isNot(first.path));
    expect(await File(first.path).readAsString(), '# My edits');
  });
  test(
    'explicit reopening recreates a deleted copy and ignores damaged index',
    () async {
      final first = await store.openImportedDocument(XFile(source.path));
      await File(first.path).delete();
      final second = await store.openImportedDocument(XFile(source.path));
      expect(second.reused, isFalse);
      expect(await File(second.path).readAsString(), '# Original');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('mobileImportsV1', '[]');
      final third = await store.openImportedDocument(XFile(source.path));
      expect(third.reused, isFalse);
    },
  );
  test('import index follows a sandbox root relocation', () async {
    final first = await store.openImportedDocument(XFile(source.path));
    final oldRoot = Directory(p.join(root.path, 'documents'));
    final newRoot = p.join(root.path, 'moved-documents');
    await oldRoot.rename(newRoot);
    final restored = MobileDocumentStore(
      directory: () async => Directory(newRoot),
    );
    final second = await restored.openImportedDocument(XFile(source.path));
    expect(second.reused, isTrue);
    expect(
      second.path,
      p.join(newRoot, p.relative(first.path, from: oldRoot.path)),
    );
  });
  test(
    'external ZIP keeps relative pictures and deduplicates repeated opens',
    () async {
      final archive = Archive()
        ..addFile(
          ArchiveFile.string('note/note.md', '![photo](note.assets/中文.png)'),
        )
        ..addFile(ArchiveFile('note/note.assets/中文.png', 3, [1, 2, 3]));
      final zip = File(p.join(root.path, 'package.zip'));
      await zip.writeAsBytes(ZipEncoder().encode(archive));
      final first = await store.openImportedDocument(XFile(zip.path));
      expect(
        await File(
          p.join(p.dirname(first.path), 'note.assets', '中文.png'),
        ).readAsBytes(),
        [1, 2, 3],
      );
      expect(
        (await store.openImportedDocument(XFile(zip.path))).reused,
        isTrue,
      );
    },
  );
  test(
    'unsupported files and oversized Markdown leave no import debris',
    () async {
      final invalid = File(p.join(root.path, 'app.exe'));
      await invalid.writeAsString('not a document');
      await expectLater(
        store.openImportedDocument(XFile(invalid.path)),
        throwsFormatException,
      );
      final writer = await source.open(mode: FileMode.write);
      await writer.truncate(MobileDocumentStore.maxMarkdownBytes + 1);
      await writer.close();
      await expectLater(
        store.importDocument(XFile(source.path)),
        throwsFormatException,
      );
      expect(
        await Directory(p.join(root.path, 'documents')).list().toList(),
        isEmpty,
      );
    },
  );
  test(
    'bridge delivers cold and warm files and acknowledges staging',
    () async {
      final calls = <MethodCall>[];
      final receiver = MobileOpenFiles();
      final delivered = <MobileOpenFile>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(MobileOpenFiles.channel, (call) async {
            calls.add(call);
            return call.method == 'start'
                ? [
                    {'token': 'cold', 'path': source.path},
                  ]
                : null;
          });
      addTearDown(
        () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(MobileOpenFiles.channel, null),
      );
      await receiver.connect(delivered.addAll);
      expect(delivered.single.path, source.path);
      final response = Completer<void>();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .handlePlatformMessage(
            MobileOpenFiles.channel.name,
            const StandardMethodCodec().encodeMethodCall(
              MethodCall('openFiles', [
                {'token': 'warm', 'path': source.path},
                {'token': 'error', 'error': 'Denied'},
              ]),
            ),
            (_) => response.complete(),
          );
      await response.future;
      expect(delivered.map((f) => f.token), ['cold', 'warm', 'error']);
      await receiver.acknowledge('cold');
      await receiver.disconnect();
      expect(calls.map((c) => c.method), ['start', 'ack', 'stop']);
    },
  );
  test('malformed native payloads cannot break the incoming queue', () {
    expect(MobileOpenFile.decode('invalid'), isEmpty);
    final result = MobileOpenFile.decode([
      null,
      {},
      {'token': 1, 'path': 'x'},
      {'token': 'error', 'path': 1, 'error': 'Cannot read'},
    ]);
    expect(result.single.error, 'Cannot read');
    expect(result.single.path, isNull);
  });
}
