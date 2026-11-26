import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:marker/src/providers/sample_document_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late Directory directory;
  late SampleDocumentStore store;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    directory = await Directory.systemTemp.createTemp('marker-example-');
    store = SampleDocumentStore(directory: () async => directory);
  });
  tearDown(() => directory.delete(recursive: true));

  test('first launch creates a real file only once', () async {
    final path = (await store.initialize('# Example'))!;
    expect(await File(path).readAsString(), '# Example');
    expect(await store.initialize('# Replacement'), isNull);
    expect(await File(path).readAsString(), '# Example');
  });
  test('deletion is respected until explicitly opening the example', () async {
    final path = (await store.initialize('# Example'))!;
    await File(path).delete();
    expect(await store.initialize('# Example'), isNull);
    expect(await File(path).exists(), isFalse);
    expect(await store.open('# Example'), path);
    expect(await File(path).readAsString(), '# Example');
  });
  test('explicit reopening preserves user edits and resources', () async {
    final path = await store.open('# Example');
    await File(path).writeAsString('![photo](Welcome.assets/photo.png)');
    final assets = Directory(path.replaceFirst('.md', '.assets'));
    await assets.create();
    await File('${assets.path}/photo.png').writeAsBytes([1, 2, 3]);
    expect(await store.open('# New template'), path);
    expect(await File(path).readAsString(), contains('Welcome.assets'));
    expect(await File('${assets.path}/photo.png').readAsBytes(), [1, 2, 3]);
  });
}
