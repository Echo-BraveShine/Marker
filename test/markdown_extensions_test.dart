import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:marker/src/widgets/markdown_extensions.dart';

void main() {
  String render(String text) => md.markdownToHtml(
    text,
    extensionSet: md.ExtensionSet.gitHubFlavored,
    blockSyntaxes: [MermaidSyntax(), MathBlockSyntax()],
    inlineSyntaxes: [MathInlineSyntax()],
  );
  testWidgets('math builders render equations', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Markdown(
            data: 'Inline \$x^2\$.\n\n\$\$\n\\frac{a}{b}\n\$\$',
            blockSyntaxes: [MathBlockSyntax()],
            inlineSyntaxes: [MathInlineSyntax()],
            builders: {
              'math-inline': MathBuilder(),
              'math-block': MathBuilder(block: true),
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(Math), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });
  test(
    'relative images resolve against document, preserving encoded paths',
    () {
      final root = Directory.systemTemp.path;
      String localPath(String relative) =>
          [root, ...relative.split('/')].join(Platform.pathSeparator);
      final document = File(localPath('中文/test.md')).absolute;
      final nested = File(localPath('docs/test.md')).absolute;
      expect(
        resolveDocumentUri('images/a%20b.png', document.path).toFilePath(),
        File(localPath('中文/images/a b.png')).absolute.path,
      );
      expect(
        resolveDocumentUri('../image.png', nested.path).toFilePath(),
        File(localPath('image.png')).absolute.path,
      );
      expect(
        resolveDocumentUri('https://example.com/a.png', document.path).scheme,
        'https',
      );
      expect(resolveDocumentUri('image.png', null).hasScheme, isFalse);
    },
  );

  test(
    'Windows relative images preserve drive, UNC and encoded Unicode',
    () {
      expect(
        resolveDocumentUri(
          'images/a%20b.png',
          r'C:\Docs\中文\test.md',
        ).toFilePath(),
        r'C:\Docs\中文\images\a b.png',
      );
      expect(
        resolveDocumentUri(
          '../%E5%9B%BE.png',
          r'\\server\share\docs\test.md',
        ).toFilePath(),
        r'\\server\share\图.png',
      );
    },
    skip: !Platform.isWindows,
  );
  test('inline and display math parse without affecting code', () {
    expect(
      render(r'Formula $x^2$.'),
      contains('<math-inline>x^2</math-inline>'),
    );
    expect(render('\$\$\nx^2\n\$\$'), contains('<math-block>x^2</math-block>'));
    expect(render(r'$$x^2$$'), contains('<math-block>x^2</math-block>'));
    expect(render(r'`$x$`'), isNot(contains('<math-inline>')));
    expect(render('```\n\$x\$\n```'), isNot(contains('<math-inline>')));
  });
  test(
    'mermaid fences are separate from ordinary code and support tilde fences',
    () {
      expect(
        render('```mermaid\nflowchart LR\nA --> B\n```'),
        contains('<mermaid>'),
      );
      expect(
        render('~~~mermaid\nflowchart LR\nA --> B\n~~~'),
        contains('<mermaid>'),
      );
      expect(
        render('```dart\nvoid main() {}\n```'),
        contains('<pre><code class="language-dart">'),
      );
    },
  );
  test('footnotes generate reference, definition and return link', () {
    final html = render('Text[^one].\n\n[^one]: Footnote **content**.');
    expect(html, contains('id="fn-one"'));
    expect(html, contains('href="#fn-one"'));
    expect(html, contains('<strong>content</strong>'));
    expect(html, contains('footnote-backref'));
  });
}
