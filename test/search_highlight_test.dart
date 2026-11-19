import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marker/main.dart';
import 'package:marker/src/theme/marker_colors.dart';
import 'package:marker/src/widgets/markdown_editing_controller.dart';
import 'package:marker/src/widgets/markdown_extensions.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<TextSpan> leaves(TextSpan span) => [
  if (span.text != null) span,
  for (final child in span.children ?? const <InlineSpan>[])
    ...leaves(child as TextSpan),
];

void main() {
  for (final syntax in [false, true]) {
    for (final dark in [false, true]) {
      testWidgets('search overlays syntax=$syntax dark=$dark and keeps IME', (
        tester,
      ) async {
        late BuildContext context;
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (c) {
                context = c;
                return const SizedBox();
              },
            ),
          ),
        );
        final controller =
            MarkdownEditingController(text: '# 中文 **Apple** apple')
              ..highlightEnabled = syntax
              ..colors = dark ? MarkerColors.dark : MarkerColors.light
              ..searchQuery = 'apple'
              ..value = const TextEditingValue(
                text: '# 中文 **Apple** apple',
                selection: TextSelection(baseOffset: 7, extentOffset: 12),
                composing: TextRange(start: 8, end: 10),
              );
        addTearDown(controller.dispose);
        List<TextSpan> render() => leaves(
          controller.buildTextSpan(
            context: context,
            style: const TextStyle(fontSize: 14),
            withComposing: true,
          ),
        );
        final before = controller.value;
        final spans = render();
        expect(spans.map((s) => s.text).join(), before.text);
        expect(controller.value, before);
        final marked = spans.where((s) => s.style?.backgroundColor != null);
        expect(marked.map((s) => s.text).join(), 'Appleapple');
        expect(marked.map((s) => s.style!.backgroundColor).toSet().length, 2);
        expect(
          spans
              .where((s) => s.style?.decoration == TextDecoration.underline)
              .map((s) => s.text)
              .join(),
          'pp',
        );
        controller.searchCaseSensitive = true;
        expect(
          render()
              .where((s) => s.style?.backgroundColor != null)
              .map((s) => s.text)
              .join(),
          'apple',
        );
        controller.searchQuery = '';
        expect(render().every((s) => s.style?.backgroundColor == null), isTrue);
      });
    }
  }

  testWidgets('search paints while search field focused and clears on close', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [mermaidPreviewEnabledProvider.overrideWithValue(false)],
        child: const MarkerApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('editor')), '中文 Apple apple');
    await tester.tap(find.byIcon(CupertinoIcons.search));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('search-query')), 'apple');
    await tester.pumpAndSettle();
    EditableText editor() => tester
        .widgetList<EditableText>(find.byType(EditableText))
        .firstWhere((w) => w.controller is MarkdownEditingController);
    List<TextSpan> painted() => leaves(
      tester
              .state<EditableTextState>(find.byWidget(editor()))
              .renderEditable
              .text!
          as TextSpan,
    );
    expect(
      painted()
          .where((s) => s.style?.backgroundColor != null)
          .map((s) => s.text)
          .join(),
      'Appleapple',
    );
    final firstColor = painted()
        .firstWhere((s) => s.text == 'Apple')
        .style!
        .backgroundColor;
    await tester.tap(find.byKey(const Key('search-next')));
    await tester.pumpAndSettle();
    expect(
      painted().firstWhere((s) => s.text == 'Apple').style!.backgroundColor,
      isNot(firstColor),
    );
    await tester.enterText(
      find.byKey(const Key('search-replacement')),
      'fruit',
    );
    await tester.tap(find.byKey(const Key('replace-all')));
    await tester.pumpAndSettle();
    expect(editor().controller.text, '中文 fruit fruit');
    expect(painted().every((s) => s.style?.backgroundColor == null), isTrue);
    await tester.enterText(find.byKey(const Key('search-query')), 'fruit');
    await tester.pumpAndSettle();
    expect(painted().any((s) => s.style?.backgroundColor != null), isTrue);
    await tester.tap(find.byKey(const Key('search-close')));
    await tester.pumpAndSettle();
    expect(painted().every((s) => s.style?.backgroundColor == null), isTrue);
    expect(tester.takeException(), isNull);
  });
}
