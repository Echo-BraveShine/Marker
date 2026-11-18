import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:marker/src/theme/highlight_style.dart';
import 'package:marker/src/theme/marker_colors.dart';
import 'package:marker/src/widgets/markdown_highlighter.dart';
import 'package:marker/src/providers/theme_provider.dart';

void main() {
  final palette = HighlightPalette.from(
    EditorHighlightStyle.classic,
    MarkerColors.light,
  );
  List<TextSpan> parse(String source) {
    final spans = MarkdownHighlighter(palette).highlight(source);
    expect(TextSpan(children: spans).toPlainText(), source);
    return spans;
  }

  Color? colorAt(List<TextSpan> spans, int index) {
    var offset = 0;
    for (final span in spans) {
      offset += span.text!.length;
      if (index < offset) return span.style?.color;
    }
    return null;
  }

  test('nested formatting, links and escapes keep original text', () {
    const source =
        r'**bold *italic* [link](file.md)** and \*literal\* and `**code**`';
    final spans = parse(source);
    expect(
      colorAt(spans, source.indexOf('bold')),
      palette[HighlightRole.emphasis],
    );
    expect(colorAt(spans, source.indexOf('link')), palette[HighlightRole.link]);
    expect(colorAt(spans, source.indexOf('literal')), isNull);
    expect(
      colorAt(spans, source.indexOf('**code')),
      palette[HighlightRole.code],
    );
  });
  test('fences protect code, accept longer closers, and tokenize JSON', () {
    const source =
        '```json\r\n{"name": "**text**", "count": 42}\r\n````\r\n# title';
    final spans = parse(source);
    expect(
      colorAt(spans, source.indexOf('**text')),
      palette[HighlightRole.string],
    );
    expect(colorAt(spans, source.indexOf('42')), palette[HighlightRole.number]);
    expect(
      colorAt(spans, source.indexOf('title')),
      palette[HighlightRole.title],
    );
  });
  test('unknown and unfinished fences remain code', () {
    for (final source in [
      '~~~unknown\n# not a heading\n~~~\n# heading',
      '```dart\nfinal x = 1;',
    ]) {
      final spans = parse(source);
      if (source.contains('not a heading')) {
        expect(
          colorAt(spans, source.indexOf('# not')),
          palette[HighlightRole.code],
        );
      }
    }
  });
  test('formulas, footnotes, reference links, setext and indented code', () {
    const source =
        'Heading\n===\n\n[^note]: footnote\n[site]: file.md\n\n\$\$\nx^2\n\$\$\n\\(y^2\\)\n\n    **code**\n';
    final spans = parse(source);
    expect(colorAt(spans, 0), palette[HighlightRole.title]);
    expect(
      colorAt(spans, source.indexOf('footnote')),
      palette[HighlightRole.link],
    );
    expect(colorAt(spans, source.indexOf('x^2')), palette[HighlightRole.math]);
    expect(colorAt(spans, source.indexOf('y^2')), palette[HighlightRole.math]);
    expect(
      colorAt(spans, source.indexOf('**code')),
      palette[HighlightRole.code],
    );
  });
  test('Mermaid comments and keywords use separate colors', () {
    const source = '```mermaid\nflowchart LR\n%% comment\nA --> B\n```';
    final spans = parse(source);
    expect(
      colorAt(spans, source.indexOf('flowchart')),
      palette[HighlightRole.link],
    );
    expect(
      colorAt(spans, source.indexOf('comment')),
      palette[HighlightRole.comment],
    );
  });
  test('all palettes adapt to light and dark and retain source', () {
    const source = '# Title\n**bold** `code`\n```json\n{"n": 3}\n```';
    for (final colors in [MarkerColors.light, MarkerColors.dark]) {
      final codeColors = <Color?>{};
      for (final style in EditorHighlightStyle.values) {
        final palette = HighlightPalette.from(style, colors);
        final spans = MarkdownHighlighter(palette).highlight(source);
        expect(TextSpan(children: spans).toPlainText(), source);
        codeColors.add(palette[HighlightRole.code]);
      }
      expect(codeColors.length, EditorHighlightStyle.values.length);
    }
  });
  test(
    'highlight preference persists and unknown preference falls back',
    () async {
      SharedPreferences.setMockInitialValues({
        'editorHighlightStyle': 'future-style',
      });
      final first = ProviderContainer();
      addTearDown(first.dispose);
      await first.read(themeProvider.notifier).init();
      expect(first.read(themeProvider).highlightEnabled, isFalse);
      expect(
        first.read(themeProvider).highlightStyle,
        EditorHighlightStyle.classic,
      );
      await first
          .read(themeProvider.notifier)
          .setHighlightStyle(EditorHighlightStyle.solarized);
      await first.read(themeProvider.notifier).setHighlightEnabled(true);
      final next = ProviderContainer();
      addTearDown(next.dispose);
      await next.read(themeProvider.notifier).init();
      expect(next.read(themeProvider).highlightEnabled, isTrue);
      await next.read(themeProvider.notifier).setHighlightEnabled(false);
      final restored = ProviderContainer();
      addTearDown(restored.dispose);
      await restored.read(themeProvider.notifier).init();
      expect(restored.read(themeProvider).highlightEnabled, isFalse);
      expect(
        restored.read(themeProvider).highlightStyle,
        EditorHighlightStyle.solarized,
      );
      expect(
        next.read(themeProvider).highlightStyle,
        EditorHighlightStyle.solarized,
      );
    },
  );
}
