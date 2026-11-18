import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:marker/src/widgets/markdown_extensions.dart';
import 'package:marker/src/widgets/text_color_picker.dart';

void main() {
  test('color validation accepts hex and rejects arbitrary CSS', () {
    expect(normalizeTextColor('#abc'), '#AABBCC');
    expect(normalizeTextColor('123456'), '#123456');
    expect(normalizeTextColor('red; background:url(x)'), isNull);
    expect(parseMarkdownColor('#abc'), const Color(0xFFAABBCC));
    final html = md.markdownToHtml(
      '<span style="color:#E53935">hello</span>',
      inlineSyntaxes: [TextColorSyntax()],
    );
    expect(html, contains('<text-color color="#E53935">hello</text-color>'));
    final rejected = md.markdownToHtml(
      '<span style="color:red;background:url(x)">hello</span>',
      inlineSyntaxes: [TextColorSyntax()],
    );
    expect(rejected, isNot(contains('<text-color')));
  });
  testWidgets('preview displays chosen color and formatted content', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Markdown(
            data:
                'Before <span style="color:#E53935">colored **bold**</span> after',
            selectable: true,
            inlineSyntaxes: [TextColorSyntax()],
            builders: {'text-color': TextColorBuilder()},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final text = tester
        .widgetList<SelectableText>(find.byType(SelectableText))
        .firstWhere(
          (widget) => widget.textSpan?.toPlainText() == 'colored bold',
        );
    final spans = text.textSpan!.children!.cast<TextSpan>();
    expect(
      spans.every((span) => span.style?.color == const Color(0xFFE53935)),
      isTrue,
    );
    expect(spans.last.style?.fontWeight, FontWeight.bold);
    expect(tester.takeException(), isNull);
  });
}
