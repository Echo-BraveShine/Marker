part of '../resource_service_test.dart';

void _registerResourceServiceDeletedFilesCases() {
  Future<({ManagedImage image, String text})> importedDocument() async {
    final image = await service.importImage(
      document,
      ResourceInput(name: '图片.png', bytes: png()),
    );
    final text = '# Draft\n${imageMarkdown('图', image.reference)}';
    await service.atomicWrite(File(document), text);
    return (image: image, text: text);
  }

  test(
    'saving after Markdown deletion recreates it and preserves assets',
    () async {
      final original = await importedDocument();
      final bytes = await File(original.image.path).readAsBytes();
      await File(document).delete();
      await service.atomicWrite(File(document), original.text);
      expect(await File(document).readAsString(), original.text);
      expect(await File(original.image.path).readAsBytes(), bytes);
      expect((await service.scan(original.text, document)).unresolved, isEmpty);
    },
  );

  test(
    'Save As copies assets even when the source Markdown was deleted',
    () async {
      final original = await importedDocument();
      await File(document).delete();
      final destination = await Directory(
        p.join(folder.path, 'another'),
      ).create();
      final target = p.join(destination.path, '副本.md');
      final result = await service.saveCopy(
        text: original.text,
        sourcePath: document,
        targetPath: target,
      );
      expect(result.issues, isEmpty);
      expect(await File(target).readAsString(), result.text);
      expect(result.images, hasLength(1));
      expect(await File(result.images.single.path).readAsBytes(), png());
      // The copy remains usable after the original assets are removed.
      await File(original.image.path).parent.delete(recursive: true);
      expect((await service.scan(result.text, target)).unresolved, isEmpty);
      expect(await File(document).exists(), isFalse);
    },
  );

  test('saving Markdown cannot recover deleted image bytes', () async {
    final original = await importedDocument();
    await File(original.image.path).parent.delete(recursive: true);
    await File(document).delete();
    await service.atomicWrite(File(document), original.text);
    expect(await File(document).readAsString(), original.text);
    expect(await File(original.image.path).exists(), isFalse);
    expect(
      (await service.scan(original.text, document)).unresolved,
      hasLength(1),
    );
    final target = File(p.join(folder.path, 'protected.md'));
    await target.writeAsString('Keep existing document');
    await expectLater(
      service.saveCopy(
        text: original.text,
        sourcePath: document,
        targetPath: target.path,
      ),
      throwsA(isA<ResourceFailure>()),
    );
    expect(await target.readAsString(), 'Keep existing document');
    expect(
      await Directory(p.join(folder.path, 'protected.assets')).exists(),
      isFalse,
    );
  });
}
