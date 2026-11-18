import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marker/src/theme/marker_app_theme.dart';
import 'package:marker/src/widgets/marker_markdown_style.dart';
import 'package:markdown/markdown.dart' as md;

void main() {
  testWidgets('rendered heading levels have distinct font sizes', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: MarkerAppTheme().light(),
        home: Scaffold(
          body: Builder(
            builder: (context) => Markdown(
              data:
                  '# Heading one\n\n## Heading two\n\n### Heading three\n\n#### Heading four\n\n##### Heading five\n\n###### Heading six',
              selectable: true,
              styleSheet: MarkerMarkdownStyle.build(context),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final texts = tester.widgetList<SelectableText>(
      find.byType(SelectableText),
    );
    final sizes = {
      for (final text in texts)
        text.textSpan?.toPlainText(): text.textSpan?.style?.fontSize,
    };
    expect(sizes['Heading one'], 28);
    expect(sizes['Heading two'], 22);
    expect(sizes['Heading three'], 18);
    expect(sizes['Heading four'], 16);
    expect(sizes['Heading five'], 15);
    expect(sizes['Heading six'], 14);
    expect(tester.takeException(), isNull);
  });
  test('GFM parser recognizes core blocks and inline extensions', () {
    final html = md.markdownToHtml(
      '# H1\n\n## H2\n\n**bold** *italic* ~~deleted~~ `code`\n\n> quote\n\n- item\n\n1. ordered\n\n---\n\n```dart\nvoid main() {}\n```\n\n| A | B |\n|---|---|\n| 1 | 2 |\n\n- [x] done\n\n[link](https://example.com)\n\n![alt](image.png)',
      extensionSet: md.ExtensionSet.gitHubFlavored,
    );
    for (final tag in [
      'h1',
      'h2',
      'strong',
      'em',
      'del',
      'code',
      'blockquote',
      'ul',
      'ol',
      'hr',
      'pre',
      'table',
      'input',
      'a',
      'img',
    ]) {
      expect(html, contains('<$tag'));
    }
  });
  test('headings require separator and remain literal in code fences', () {
    expect(md.markdownToHtml('#标题\n\n##标题'), isNot(contains('<h')));
    expect(
      md.markdownToHtml('```\n# title\n```'),
      contains('<pre><code># title'),
    );
    expect(
      md.markdownToHtml('Setext title\n===\n\nSubtitle\n---'),
      contains('<h1>Setext title</h1>'),
    );
  });
}
