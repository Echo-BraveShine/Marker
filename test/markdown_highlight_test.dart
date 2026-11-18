import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marker/src/widgets/markdown_editing_controller.dart';
import 'package:marker/src/theme/marker_colors.dart';

void main() {
  testWidgets(
    'highlight preserves source and follows theme with IME composing',
    (tester) async {
      final controller = MarkdownEditingController(
        text: '# Title\n\n**Bold** and `code` [link](https://example.com)',
      );
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final light = controller.buildTextSpan(
                context: context,
                style: const TextStyle(fontSize: 14),
                withComposing: true,
              );
              expect(light.toPlainText(), controller.text);
              expect(
                light.children!.whereType<TextSpan>().any(
                  (span) =>
                      span.style?.color == MarkerColors.light.syntaxCodeInline,
                ),
                isTrue,
              );
              controller.colors = MarkerColors.dark;
              final dark = controller.buildTextSpan(
                context: context,
                style: const TextStyle(fontSize: 14),
                withComposing: true,
              );
              expect(dark.toPlainText(), controller.text);
              expect(
                dark.children!.whereType<TextSpan>().any(
                  (span) =>
                      span.style?.color == MarkerColors.dark.syntaxCodeInline,
                ),
                isTrue,
              );
              controller.value = const TextEditingValue(
                text: '中文输入',
                selection: TextSelection.collapsed(offset: 4),
                composing: TextRange(start: 0, end: 4),
              );
              expect(
                controller
                    .buildTextSpan(
                      context: context,
                      style: null,
                      withComposing: true,
                    )
                    .toPlainText(),
                '中文输入',
              );
              return const SizedBox();
            },
          ),
        ),
      );
    },
  );
}
