part of '../resource_service_test.dart';

void _registerResourceServiceRelocationCases() {
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
