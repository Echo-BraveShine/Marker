import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:marker/src/resources/resource_service.dart';
import 'package:marker/src/resources/resource_references.dart';

Uint8List png([int suffix = 0]) => Uint8List.fromList([
  ...base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAACklEQVR4nGMAAQAABQABDQottAAAAABJRU5ErkJggg==',
  ),
  suffix,
]);
void main() {
  late Directory folder;
  late String document;
  late DocumentResourceService service;
  setUp(() async {
    folder = await Directory.systemTemp.createTemp('marker-资源-');
    document = p.join(folder.path, '中文 文档.md');
    await File(document).writeAsString('original');
    service = DocumentResourceService();
  });
  tearDown(() => folder.delete(recursive: true));
  test(
    'references use parser offsets, retain titles, and never alter code/links',
    () {
      const source =
          '中文 ![图片 **粗体**](<images/a%20b.png> "标题")\r\n\r\n![参考][pic]\r\n\r\n[pic]: images/a%20b.png "引用标题"\r\n[普通链接][pic]\r\n`![code](images/a%20b.png)`\r\n\r\n```md\r\n![code](images/a%20b.png)\r\n```\r\n';
      final refs = parseResourceReferences(source);
      expect(refs.images.length, 2);
      final rewritten = refs.rewrite(source, {
        'images/a%20b.png': '文档.assets/new.png',
      });
      expect(rewritten, contains('![图片 **粗体**](<文档.assets/new.png> "标题")'));
      expect(rewritten, contains('![参考](<文档.assets/new.png> "引用标题")'));
      expect(rewritten, contains('[pic]: images/a%20b.png'));
      expect(rewritten, contains('`![code](images/a%20b.png)`'));
      expect(rewritten, contains('```md\r\n![code](images/a%20b.png)'));
      expect(rewritten, contains('[普通链接][pic]'));
    },
  );
  test(
    'opening/scanning is read only; first import creates assets and retains originals',
    () async {
      await service.scan('![missing](missing.png)', document);
      final directory = await service.resourceDirectory(document);
      expect(await directory.exists(), isFalse);
      final original = File(p.join(folder.path, '图片 #100%.png'));
      await original.writeAsBytes(png());
      final first = await service.importImage(
        document,
        ResourceInput(name: p.basename(original.path), path: original.path),
      );
      expect(await original.exists(), isTrue);
      expect(await File(first.path).readAsBytes(), png());
      expect(first.reference, contains('%23'));
      expect(first.reference, contains('%25'));
      final duplicate = await service.importImage(
        document,
        ResourceInput(name: 'other.png', bytes: png()),
      );
      expect(duplicate.path, first.path);
      expect(duplicate.created, isFalse);
      final conflict = await service.importImage(
        document,
        ResourceInput(name: p.basename(original.path), bytes: png(1)),
      );
      expect(conflict.path, isNot(first.path));
      expect(await File(first.path).readAsBytes(), png());
    },
  );
  test(
    'collect resolves references and preserves normal links to the same definition',
    () async {
      final image = File(p.join(folder.path, 'local.png'));
      await image.writeAsBytes(png());
      final result = await service.collect(
        text: '![a][same]\n\n[same]: local.png "title"\n\n[normal][same]\n',
        documentPath: document,
      );
      expect(result.issues, isEmpty);
      expect(result.text, contains('![a](<'));
      expect(result.text, contains('[same]: local.png "title"'));
      expect(result.text, contains('[normal][same]'));
      final scanned = await service.scan(result.text, document);
      expect(scanned.items.single.availability, ResourceAvailability.local);
      expect(scanned.items.single.managed, isTrue);
    },
  );
  test(
    'save copy and ZIP are standalone and leave the original untouched',
    () async {
      final image = File(p.join(folder.path, 'local.png'));
      await image.writeAsBytes(png());
      const source = '![图](local.png "title")\n\nhttps://example.com';
      final destination = Directory(p.join(folder.path, 'new'));
      await destination.create();
      final target = p.join(destination.path, 'copy.md');
      final result = await service.saveCopy(
        text: source,
        sourcePath: document,
        targetPath: target,
      );
      expect(result.issues, isEmpty);
      expect(await File(document).readAsString(), 'original');
      expect(
        (await service.scan(result.text, target)).items.single.availability,
        ResourceAvailability.local,
      );
      final zip = p.join(folder.path, 'share.zip');
      await service.package(text: source, sourcePath: document, zipPath: zip);
      final archive = ZipDecoder().decodeBytes(
        await File(zip).readAsBytes(),
        verify: true,
      );
      final md = archive.files.where((f) => f.name.endsWith('.md')).single;
      expect(utf8.decode(md.content as List<int>), contains('.assets/'));
      expect(archive.files.any((f) => f.name.endsWith('.png')), isTrue);
      expect(
        archive.files.any(
          (f) => f.name.contains('local.png') && f.name.contains('..'),
        ),
        isFalse,
      );
    },
  );
  test(
    'failed copy does not publish a partial document or overwrite destination',
    () async {
      final target = p.join(folder.path, 'copy.md');
      await File(target).writeAsString('keep');
      await expectLater(
        service.saveCopy(
          text: '![x](missing.png)',
          sourcePath: document,
          targetPath: target,
        ),
        throwsA(isA<ResourceFailure>()),
      );
      expect(await File(target).readAsString(), 'keep');
      expect(
        await Directory(p.join(folder.path, 'copy.assets')).exists(),
        isFalse,
      );
    },
  );
  test(
    'cleanup protects saved/draft/neighbour references and modified/unmanaged files',
    () async {
      final image = await service.importImage(
        document,
        ResourceInput(name: 'a.png', bytes: png()),
      );
      await File(document).writeAsString(imageMarkdown('a', image.reference));
      expect(
        await service.unused(document, [ResourceDraft(document, '')]),
        isEmpty,
      );
      await File(document).writeAsString('');
      expect(
        await service.unused(document, [
          ResourceDraft(document, imageMarkdown('a', image.reference)),
        ]),
        isEmpty,
      );
      final neighbour = File(p.join(folder.path, 'neighbour.md'));
      await neighbour.writeAsString(imageMarkdown('a', image.reference));
      expect(await service.unused(document, []), isEmpty);
      await neighbour.delete();
      final candidates = await service.unused(document, []);
      expect(candidates.map((f) => f.path), [image.path]);
      await File(image.path).writeAsBytes(png(7));
      expect(await service.unused(document, []), isEmpty);
      final untracked = File(p.join(p.dirname(image.path), 'user.png'));
      await untracked.writeAsBytes(png());
      expect(await service.unused(document, []), isEmpty);
    },
  );
  test('symlink resource directories are never used for imports', () async {
    if (Platform.isWindows) return;
    final actual = await Directory(p.join(folder.path, 'shared')).create();
    final assets = await service.resourceDirectory(document);
    await Link(assets.path).create(actual.path);
    await expectLater(
      service.importImage(document, ResourceInput(name: 'a.png', bytes: png())),
      throwsA(isA<ResourceFailure>()),
    );
    expect(await actual.list().isEmpty, isTrue);
  });
  test('HTML/code and fenced comments cannot turn into managed images', () {
    final refs = parseResourceReferences(
      '```html\n<!-- <img src="fake.png">\n![fake](fake.png)\n```\n\n![real](real.png)\n',
    );
    expect(refs.images.map((i) => i.source), ['real.png']);
    expect(refs.unsupported, isEmpty);
    expect(
      parseResourceReferences('`<img src="code.png">`').unsupported,
      isEmpty,
    );
    expect(parseResourceReferences('<img src="real.png">').unsupported, [
      'HTML <img>',
    ]);
  });
  test(
    'collect cancellation removes only resources created by that operation',
    () async {
      final existing = await service.importImage(
        document,
        ResourceInput(name: 'existing.png', bytes: png(9)),
      );
      final a = File(p.join(folder.path, 'a.png'));
      await a.writeAsBytes(png(1));
      final b = File(p.join(folder.path, 'b.png'));
      await b.writeAsBytes(png(2));
      final cancellation = ResourceCancellation();
      await expectLater(
        service.collect(
          text: '![a](a.png) ![b](b.png)',
          documentPath: document,
          cancellation: cancellation,
          onProgress: (progress) {
            if (progress.done == 1) cancellation.cancelled = true;
          },
        ),
        throwsA(isA<ResourceCancelled>()),
      );
      expect(await File(existing.path).exists(), isTrue);
      final unused = await service.unused(document, []);
      expect(unused.map((i) => i.name), ['existing.png']);
      expect(await a.exists(), isTrue);
      expect(await b.exists(), isTrue);
    },
  );
  test(
    'renaming preserves images, ownership and other files, and refuses conflicts',
    () async {
      final image = await service.importImage(
        document,
        ResourceInput(name: 'a.png', bytes: png()),
      );
      final text = imageMarkdown('a', image.reference);
      await File(document).writeAsString(text);
      final renamed = p.join(folder.path, 'renamed.md');
      final updated = await service.renameDocument(
        sourcePath: document,
        targetPath: renamed,
        text: text,
      );
      expect(await File(document).exists(), isFalse);
      expect(await File(renamed).readAsString(), updated);
      expect(updated, contains('renamed.assets/'));
      expect(await Directory(p.dirname(image.path)).exists(), isFalse);
      final scan = await service.scan(updated, renamed);
      expect(scan.items.single.managed, isTrue);
      final extra = await service.importImage(
        renamed,
        ResourceInput(name: 'extra.png', bytes: png(1)),
      );
      expect(p.basename(p.dirname(extra.path)), 'renamed.assets');
      expect(
        await service.unused(renamed, [ResourceDraft(renamed, updated)]),
        hasLength(1),
      );
      final existing = File(p.join(folder.path, 'existing.md'));
      await existing.writeAsString('keep');
      await expectLater(
        service.renameDocument(
          sourcePath: renamed,
          targetPath: existing.path,
          text: text,
        ),
        throwsA(isA<ResourceFailure>()),
      );
      expect(await existing.readAsString(), 'keep');
      expect(await File(renamed).exists(), isTrue);
    },
  );
  test(
    'asset name conflict leaves document and original images unchanged',
    () async {
      final image = await service.importImage(
        document,
        ResourceInput(name: 'a.png', bytes: png()),
      );
      final text = imageMarkdown('a', image.reference);
      await File(document).writeAsString(text);
      final target = p.join(folder.path, 'new.md');
      final conflict = Directory(p.join(folder.path, 'new.assets'));
      await conflict.create();
      await expectLater(
        service.renameDocument(
          sourcePath: document,
          targetPath: target,
          text: text,
        ),
        throwsA(isA<ResourceFailure>()),
      );
      expect(await File(document).readAsString(), text);
      expect(await File(image.path).exists(), isTrue);
      expect(await File(target).exists(), isFalse);
    },
  );
  test(
    'failed publication rolls moved assets and management records back',
    () async {
      final image = await service.importImage(
        document,
        ResourceInput(name: 'a.png', bytes: png()),
      );
      final text = imageMarkdown('a', image.reference);
      await File(document).writeAsString(text);
      final target = p.join(folder.path, 'new.md');
      await expectLater(
        _RenameFailure(
          target,
        ).renameDocument(sourcePath: document, targetPath: target, text: text),
        throwsA(isA<FileSystemException>()),
      );
      expect(await File(document).readAsString(), text);
      expect(await File(image.path).exists(), isTrue);
      expect(
        await Directory(p.join(folder.path, 'new.assets')).exists(),
        isFalse,
      );
      expect((await service.scan(text, document)).items.single.managed, isTrue);
    },
  );
  test(
    'conventional untracked assets rename without creating a management record',
    () async {
      final old = Directory(p.join(folder.path, '中文 文档.assets'));
      await old.create();
      final image = File(p.join(old.path, '图 #%.png'));
      await image.writeAsBytes(png());
      final text = imageMarkdown('a', resourceReference(image.path, document));
      final target = p.join(folder.path, '新名字.md');
      final updated = await service.renameDocument(
        sourcePath: document,
        targetPath: target,
        text: text,
      );
      expect(await old.exists(), isFalse);
      expect(
        (await service.scan(updated, target)).items.single.availability,
        ResourceAvailability.local,
      );
      expect(
        await File(
          p.join(folder.path, '新名字.assets', '.marker-resources.json'),
        ).exists(),
        isFalse,
      );
    },
  );
  test(
    'overwriting a copy keeps prior assets and cleans all owned directories safely',
    () async {
      final input = File(p.join(folder.path, 'source.png'));
      await input.writeAsBytes(png());
      final target = p.join(folder.path, 'copy.md');
      await service.saveCopy(
        text: '![a](source.png)',
        sourcePath: document,
        targetPath: target,
      );
      final first = (await service.scan(
        await File(target).readAsString(),
        target,
      )).items.single.path!;
      await input.writeAsBytes(png(1));
      await service.saveCopy(
        text: '![a](source.png)',
        sourcePath: document,
        targetPath: target,
      );
      final second = (await service.scan(
        await File(target).readAsString(),
        target,
      )).items.single.path!;
      expect(first, isNot(second));
      expect(await File(first).exists(), isTrue);
      final unused = await service.unused(target, []);
      expect(unused.map((i) => i.path), [first]);
    },
  );
  test(
    'trash failure keeps file and record; changed references are checked again',
    () async {
      final image = await service.importImage(
        document,
        ResourceInput(name: 'a.png', bytes: png()),
      );
      final items = await service.unused(document, []);
      await expectLater(
        service.trashUnused(document, items, [], (_) async {
          throw StateError('Trash unavailable');
        }),
        throwsStateError,
      );
      expect(await File(image.path).exists(), isTrue);
      await File(document).writeAsString(imageMarkdown('a', image.reference));
      var called = false;
      final moved = await service.trashUnused(document, items, [], (_) async {
        called = true;
      });
      expect(called, isFalse);
      expect(moved, 0);
    },
  );
  test(
    'network images are fetched only on request, validating redirects and content',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(() => server.close(force: true));
      var requests = 0;
      server.listen((request) async {
        requests++;
        expect(request.headers.value(HttpHeaders.authorizationHeader), isNull);
        if (request.uri.path == '/redirect') {
          request.response.statusCode = 302;
          request.response.headers.set(
            HttpHeaders.locationHeader,
            '/image.png',
          );
        } else if (request.uri.path == '/bad') {
          request.response.write('<html>not an image</html>');
        } else {
          request.response.add(png());
        }
        await request.response.close();
      });
      final source = '![web](http://127.0.0.1:${server.port}/redirect)';
      final linked = await service.collect(
        text: source,
        documentPath: document,
      );
      expect(requests, 0);
      expect(linked.text, source);
      final downloaded = await service.collect(
        text: source,
        documentPath: document,
        downloadRemote: true,
      );
      expect(downloaded.issues, isEmpty);
      expect(requests, 2);
      expect(
        (await service.scan(
          downloaded.text,
          document,
        )).items.single.availability,
        ResourceAvailability.local,
      );
      final bad = await service.collect(
        text: '![bad](http://127.0.0.1:${server.port}/bad)',
        documentPath: document,
        downloadRemote: true,
      );
      expect(bad.issues, hasLength(1));
      expect(bad.text, contains('/bad)'));
    },
  );
  test(
    'unknown management records are preserved and new imports use another folder',
    () async {
      final assets = await service.resourceDirectory(document);
      await assets.create();
      final record = File(p.join(assets.path, '.marker-resources.json'));
      await record.writeAsString('{invalid');
      final imported = await service.importImage(
        document,
        ResourceInput(name: 'a.png', bytes: png()),
      );
      expect(p.dirname(imported.path), isNot(assets.path));
      expect(await record.readAsString(), '{invalid');
      await expectLater(
        service.importImage(
          document,
          ResourceInput(
            name: 'invalid.png',
            bytes: Uint8List.fromList([0, 1, 2]),
          ),
        ),
        throwsA(isA<ResourceFailure>()),
      );
    },
  );
  test(
    'cancelling a stalled network request closes it without publishing a file',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(() => server.close(force: true));
      final started = Completer<void>();
      server.listen((request) {
        if (!started.isCompleted) started.complete();
      });
      final token = ResourceCancellation();
      final future = service.download(
        'http://127.0.0.1:${server.port}/slow.png',
        token,
      );
      final expectation = expectLater(
        future,
        throwsA(isA<ResourceCancelled>()),
      );
      await started.future;
      token.cancelled = true;
      await expectation.timeout(const Duration(seconds: 3));
    },
  );
  test(
    'cancelling first collection removes its empty newly created asset folder',
    () async {
      final a = File(p.join(folder.path, 'a.png'));
      await a.writeAsBytes(png(1));
      final b = File(p.join(folder.path, 'b.png'));
      await b.writeAsBytes(png(2));
      final token = ResourceCancellation();
      await expectLater(
        service.collect(
          text: '![a](a.png) ![b](b.png)',
          documentPath: document,
          cancellation: token,
          onProgress: (progress) {
            if (progress.done == 1) token.cancelled = true;
          },
        ),
        throwsA(isA<ResourceCancelled>()),
      );
      expect(
        await Directory(p.join(folder.path, '中文 文档.assets')).exists(),
        isFalse,
      );
      expect(await File(document).readAsString(), 'original');
    },
  );
  test(
    'copy rollback preserves a foreign file added during document publication',
    () async {
      final input = File(p.join(folder.path, 'source.png'));
      await input.writeAsBytes(png());
      final target = p.join(folder.path, 'copy.md');
      final writer = _FailingWriter(target);
      await expectLater(
        writer.saveCopy(
          text: '![x](source.png)',
          sourcePath: document,
          targetPath: target,
        ),
        throwsA(isA<FileSystemException>()),
      );
      expect(await File(target).exists(), isFalse);
      expect(
        await File(
          p.join(folder.path, 'copy.assets', 'user.txt'),
        ).readAsString(),
        'keep',
      );
      expect(
        await Directory(
          p.join(folder.path, 'copy.assets'),
        ).list().where((f) => f.path.endsWith('.png')).isEmpty,
        isTrue,
      );
      expect(await File(document).readAsString(), 'original');
    },
  );
}

class _FailingWriter extends DocumentResourceService {
  _FailingWriter(this.destination);
  final String destination;
  @override
  Future<void> atomicWrite(File target, String text) async {
    if (target.path == destination) {
      await File(
        p.join(p.dirname(destination), 'copy.assets', 'user.txt'),
      ).writeAsString('keep');
      throw FileSystemException('Simulated publication failure', target.path);
    }
    return super.atomicWrite(target, text);
  }
}

class _RenameFailure extends DocumentResourceService {
  _RenameFailure(this.target);
  final String target;
  @override
  Future<void> atomicWrite(File file, String text) {
    if (file.path == target) {
      throw FileSystemException('Publication failed', target);
    }
    return super.atomicWrite(file, text);
  }
}
