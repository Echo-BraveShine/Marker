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
      expect(
        resolveDocumentUri('images/a%20b.png', '/tmp/中文/test.md').toFilePath(),
        '/tmp/中文/images/a b.png',
      );
      expect(
        resolveDocumentUri('../image.png', '/tmp/docs/test.md').toFilePath(),
        '/tmp/image.png',
      );
      expect(
        resolveDocumentUri('https://example.com/a.png', '/tmp/a.md').scheme,
        'https',
      );
      expect(resolveDocumentUri('image.png', null).hasScheme, isFalse);
    },
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
