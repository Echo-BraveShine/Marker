import 'package:flutter/cupertino.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:marker/main.dart';
import 'package:marker/src/widgets/line_number_gutter.dart';
import 'package:marker/src/widgets/markdown_extensions.dart';

void main() {
  test(
    'line index handles empty lines, mixed endings, Unicode and deep positions',
    () {
      final index = LineNumberIndex()..update('一\r\n\r\n😀x\nlast\r');
      expect(index.length, 5);
      expect(index.lineAt(3), 1);
      expect(index.lineAt(5), 2);
      expect(index.lineAt(9), 3);
      index.update(List.generate(10000, (i) => 'line $i').join('\n'));
      expect(index.lineAt(index.start(9999)), 9999);
      expect(index.characters, greaterThan(80000));
    },
  );
  testWidgets(
    'caret movement retains the parsed preview; gutter reuses editor geometry',
    (tester) async {
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
      final finder = find.byKey(const Key('editor'));
      await tester.enterText(
        finder,
        List.generate(1000, (i) => 'Line $i **bold** and more text').join('\n'),
      );
      await tester.pumpAndSettle();
      final preview = tester.widget<Markdown>(find.byKey(const Key('preview')));
      final field = tester.widget<CupertinoTextField>(finder);
      field.controller!.selection = const TextSelection.collapsed(offset: 10);
      await tester.pumpAndSettle();
      expect(
        identical(
          preview,
          tester.widget<Markdown>(find.byKey(const Key('preview'))),
        ),
        isTrue,
      );
      final gutter = tester.widget<LineNumberGutter>(
        find.byKey(const Key('line-numbers')),
      );
      expect(gutter.editable(), isNotNull);
      expect(gutter.index.length, 1000);
      field.scrollController!.jumpTo(
        field.scrollController!.position.maxScrollExtent * .95,
      );
      await tester.pump();
      final paint = tester
          .widget<CustomPaint>(
            find.descendant(
              of: find.byKey(const Key('line-numbers')),
              matching: find.byType(CustomPaint),
            ),
          )
          .painter!;
      expect(
        (Canvas canvas) => paint.paint(canvas, Size(gutter.width, 700)),
        paints..paragraph(),
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
