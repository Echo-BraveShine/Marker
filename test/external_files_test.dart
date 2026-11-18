import 'package:flutter_test/flutter_test.dart';
import 'package:marker/src/providers/external_files.dart';

void main() {
  test('Open With accepts Unicode paths, file URLs and Windows arguments', () {
    expect(
      markdownOpenPaths([
        '--flag',
        '/tmp/中文 文档.md',
        'file:///tmp/a%20b.markdown',
        '/tmp/中文 文档.md',
        r'C:\Docs\file.MD',
        '/tmp/image.png',
      ]),
      ['/tmp/中文 文档.md', '/tmp/a b.markdown', r'C:\Docs\file.MD'],
    );
  });
}
