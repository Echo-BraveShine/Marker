import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_selector/file_selector.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('UTF-8 Chinese filenames support save, overwrite and save as', () async {
    final directory = await Directory.systemTemp.createTemp('marker-test-');
    addTearDown(() => directory.delete(recursive: true));
    final path = '${directory.path}/中文文档.md';
    Future<void> save(String path, String text) => XFile.fromData(
      Uint8List.fromList(utf8.encode(text)),
      mimeType: 'text/markdown',
    ).saveTo(path);
    await save(path, '# 你好 🌍');
    expect(await XFile(path).readAsString(), '# 你好 🌍');
    await save(path, '覆盖后的内容');
    expect(await XFile(path).readAsString(), '覆盖后的内容');
    final other = '${directory.path}/另存为.md';
    await save(other, '新内容');
    expect(await XFile(path).readAsString(), '覆盖后的内容');
    expect(await XFile(other).readAsString(), '新内容');
    await expectLater(
      save('${directory.path}/不存在/文档.md', 'text'),
      throwsA(isA<FileSystemException>()),
    );
  });
}
