import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:marker/src/export/document_html.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'semantic export preserves extensions while escaping active HTML and unsafe links',
    () {
      final result = parseExportMarkup('''# 标题

**加粗** 和 [安全](https://example.com) 与 [危险](javascript:alert)

<script>alert("bad")</script>

<span style="color:#ff0000">红色 **粗体**</span>

\$x^2\$ 和

\$\$
\\frac{a}{b}
\$\$

```mermaid
flowchart LR
A --> B
```

| A | B |
|---|---|
| 1 | 2 |

- [x] 已完成

脚注[^1]

[^1]: 注释
''');
      expect(result.body, contains('<h1>标题</h1>'));
      expect(result.body, contains('<strong>加粗</strong>'));
      expect(result.body, isNot(contains('<script>')));
      expect(result.body, isNot(contains('href="javascript:')));
      expect(result.body, contains('class="math-inline"'));
      expect(result.body, contains('class="math-block"'));
      expect(result.body, contains('class="mermaid"'));
      expect(result.body, contains('color:#ff0000'));
      expect(result.body, contains('<table>'));
      expect(result.body, contains('type="checkbox" disabled checked'));
      expect(result.body, contains('注释'));
    },
  );
  test(
    'self-contained HTML embeds local Unicode images, fonts, formulas and renderer licenses',
    () async {
      final folder = await Directory.systemTemp.createTemp('marker-export-中文-');
      addTearDown(() => folder.delete(recursive: true));
      final image = File('${folder.path}/图片 test.png');
      await image.writeAsBytes(
        base64Decode(
          'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAACklEQVR4nGMAAQAABQABDQottAAAAABJRU5ErkJggg==',
        ),
      );
      final html = await ExportHtmlBuilder().build(
        source: '正文 ![图](图片%20test.png)\n\n\$x^2\$',
        title: '中文导出',
        documentPath: '${folder.path}/文档.md',
      );
      expect(html, contains('src="data:image/png;base64,'));
      expect(html, isNot(contains('marker-image:0')));
      expect(html, contains('font-weight:700'));
      expect(html, contains('unicode-range:U+2E80-D7AF'));
      expect(html, contains('data:font/woff2;base64,'));
      expect(html, isNot(contains('url(fonts/')));
      expect(html, contains('marker-third-party'));
      expect(html, contains('@page{size:A4;'));
      expect(html, contains('window.markerExport'));
    },
  );
  test('exports realistic native rendering fixtures when requested', () async {
    final target = Platform.environment['MARKER_EXPORT_FIXTURES'];
    if (target == null) return;
    Directory(target).createSync(recursive: true);
    final source =
        '''# Marker 导出测试

中文可以复制。Selectable text: Marker export 12345.

这是 **粗体**、*斜体*、~~删除线~~ 和 [链接](https://example.com)。

<span style="color:#e53935">红色文本</span>

行内公式 \$E=mc^2\$，块级公式：

\$\$
\\int_0^1 x^2\\,dx=\\frac{1}{3}
\$\$

```mermaid
flowchart LR
  A[开始] --> B[编辑中文文档] --> C[导出 PDF]
```

| 功能 | 状态 |
|---|---|
| PDF | 可复制 |
| PNG | 完整长图 |

- [x] 自动分页
- [ ] 下一项

> 引用：内容完整保留。

脚注内容[^1]。

[^1]: 这是脚注说明。

```dart
void main() { print('Marker'); }
```

${List.generate(100, (i) => '段落 $i：这是长文自动分页测试。Long document paragraph $i preserves selectable text.').join('\n\n')}

最后一段 END-OF-DOCUMENT-98765。
''';
    final builder = ExportHtmlBuilder();
    for (final dark in [false, true]) {
      final html = await builder.build(
        source: source,
        title: 'Marker 导出测试',
        dark: dark,
      );
      await File(
        '$target/document-${dark ? 'dark' : 'light'}.html',
      ).writeAsString(html);
    }
  });
}
