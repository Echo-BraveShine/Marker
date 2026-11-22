import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
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
    'export retains footnote definitions, repeated references and return anchors',
    () {
      final markup = parseExportMarkup(
        'Text[^one] and again[^one].\n\n[^one]: Footnote **content**.\n\n[^unused]: Hidden note.',
      );
      expect(markup.body, contains('<section class="footnotes">'));
      expect(markup.body, contains('id="fn-one"'));
      expect(markup.body, contains('href="#fn-one"'));
      expect(markup.body, contains('id="fnref-one"'));
      expect(markup.body, contains('href="#fnref-one"'));
      expect(markup.body, contains('<strong>content</strong>'));
      expect(markup.body, isNot(contains('Hidden note')));
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
  test(
    'still exports freeze GIF frames while HTML can preserve animation',
    () async {
      const data =
          'data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7';
      final builder = ExportHtmlBuilder();
      final frozen = await builder.build(source: '![]($data)', title: 'Still');
      expect(frozen, contains('src="data:image/png;base64,'));
      expect(frozen, isNot(contains('src="data:image/gif;base64,')));
      final original = await builder.build(
        source: '![]($data)',
        title: 'Animation',
        freezeAnimations: false,
      );
      expect(original, contains('src="$data"'));
    },
  );
  test('exports a selected local document fixture when requested', () async {
    final sourcePath = Platform.environment['MARKER_EXPORT_SOURCE'];
    final target = Platform.environment['MARKER_EXPORT_FIXTURES'];
    if (sourcePath == null || target == null) return;
    await Directory(target).create(recursive: true);
    final html = await ExportHtmlBuilder().build(
      source: await File(sourcePath).readAsString(),
      title: File(sourcePath).uri.pathSegments.last,
      documentPath: sourcePath,
    );
    await File('$target/selected-document.html').writeAsString(html);
  });
  test('exports realistic native rendering fixtures when requested', () async {
    final target = Platform.environment['MARKER_EXPORT_FIXTURES'];
    if (target == null) return;
    Directory(target).createSync(recursive: true);
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    canvas.drawRect(
      const ui.Rect.fromLTWH(0, 0, 800, 450),
      ui.Paint()..color = const ui.Color(0xffdcecff),
    );
    final picture = recorder.endRecording();
    final image = await picture.toImage(800, 450);
    final imageData = await image.toByteData(format: ui.ImageByteFormat.png);
    final boundaryImage = base64Encode(
      imageData!.buffer.asUint8List(
        imageData.offsetInBytes,
        imageData.lengthInBytes,
      ),
    );
    image.dispose();
    picture.dispose();
    final source =
        '''# Marker 导出测试

中文可以复制。Selectable text: Marker export 12345.

## Boundary heading level 2
### Boundary heading level 3
#### Boundary heading level 4
##### Boundary heading level 5
###### Boundary heading level 6

![pagination boundary](data:image/png;base64,$boundaryImage)

Boundary Setext 1
===
Boundary Setext 2
---

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

[^1]: 这是脚注说明。 FOOTNOTE-END-45678

```dart
void main() { print('Marker'); }
```

${List.generate(20, (i) => '段落 $i：这是长文自动分页测试。Long document paragraph $i preserves selectable text.').join('\n\n')}

```text
CODE-BLOCK-START
${List.generate(24, (i) => 'Code line $i keeps the block together.').join('\n')}
CODE-BLOCK-END
```

PARAGRAPH-START ${List.filled(45, 'A paragraph that fits on one page should stay together.').join(' ')} PARAGRAPH-END

| TABLE-START | Value |
|---|---|
${List.generate(5, (i) => '| Row $i | Data |').join('\n')}
| TABLE-END | Done |

## Long Table Test

This section tests a long table that spans multiple pages.

| Header A | Header B | Header C |
|---|---|---|
${List.generate(35, (i) => '| ROW-$i-START | Cell A$i | Row $i content remains together across page boundaries; this cell wraps to several lines. ROW-$i-END-FINAL |').join('\n')}
| TRAILER | End | Marking the end of the long table. |

## HEADING-WITH-CONTENT

HEADING-CONTENT stays with its heading.

```text
OVERSIZED-START
${List.generate(85, (i) => 'Oversized-line-$i stays readable across pages.').join('\n')}
OVERSIZED-END
```

${List.generate(80, (i) => '段落 ${i + 20}：这是长文自动分页测试。Long document paragraph ${i + 20} preserves selectable text.').join('\n\n')}

最后一段 END-OF-DOCUMENT-98765。
''';
    final builder = ExportHtmlBuilder();
    final complex = StringBuffer(source);
    final paragraph =
        '复杂文档包含中英文、链接、公式与表格。 ${List.filled(30, 'Selectable text remains complete.').join(' ')}';
    for (var i = 0; i < 90; i++) {
      complex.writeln(
        '\n\n## COMPLEX-SECTION-$i\n\n$paragraph\n\n$paragraph\n',
      );
      complex.writeln(r'''

| Name | Expression | Status |
|---|---|---|
| Alpha | $x^2+y^2$ | Complete |
| Beta | $E=mc^2$ | Ready |
| Gamma | $\sqrt{2}$ | Ready |

$$
\begin{aligned} f(x)&=\int_0^1 x^2\,dx \\ g(x)&=\sum_{n=1}^{10}\frac{1}{n^2} \end{aligned}
$$
''');
      if (i % 4 == 0) {
        complex.writeln(r'''

```mermaid
flowchart LR
 A[Start] --> B[中文编辑]
 B --> C{Preview}
 C --> D[Formula]
 C --> E[Table]
 D --> F[Export]
 E --> F
 F --> G[Finish]
```
''');
      }
      if (i % 6 == 0) {
        complex.writeln(
          '\n\n![image](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAMAAAACCAIAAAASFvFNAAAAFElEQVR4nGM0qfjGAAZMEIqBgQEAHN4BptKOUnYAAAAASUVORK5CYII=)\n',
        );
      }
    }
    complex.writeln('\n\nCOMPLEX-END-12345\n');
    await File('$target/document-complex.html').writeAsString(
      await builder.build(
        source: complex.toString(),
        title: 'Complex export regression',
      ),
    );
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
