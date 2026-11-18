import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:marker/src/providers/external_files.dart';

void main() {
  test('Open With accepts Unicode paths, file URLs and Windows arguments', () {
    final root = Directory.systemTemp.path;
    final unicode = '$root${Platform.pathSeparator}中文 文档.md';
    final linked = File('$root${Platform.pathSeparator}a b.markdown');
    expect(
      markdownOpenPaths([
        '--flag',
        unicode,
        linked.uri.toString(),
        unicode,
        r'C:\Docs\file.MD',
        '$root${Platform.pathSeparator}image.png',
      ]),
      [unicode, linked.path, r'C:\Docs\file.MD'],
    );
  });
  test('Windows Open With decodes drive and UNC file URLs', () {
    expect(
      markdownOpenPaths([
        'file:///C:/Docs/a%20b.md',
        'file://server/share/%E4%B8%AD%E6%96%87.markdown',
      ]),
      [r'C:\Docs\a b.md', r'\\server\share\中文.markdown'],
    );
  }, skip: !Platform.isWindows);
}
