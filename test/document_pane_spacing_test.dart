import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marker/main.dart';
import 'package:marker/src/theme/marker_style.dart';
import 'package:marker/src/widgets/markdown_extensions.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('editor viewport reaches pane top and bottom in each mode', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(1200, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [mermaidPreviewEnabledProvider.overrideWithValue(false)],
        child: const MarkerApp(),
      ),
    );
    await tester.pumpAndSettle();
    for (final mode in ['编辑', '分屏', '预览', '编辑', '分屏']) {
      await tester.tap(
        find.descendant(
          of: find.byType(CupertinoSlidingSegmentedControl<int>),
          matching: find.text(mode),
        ),
      );
      await tester.pumpAndSettle();
      if (mode == '预览') continue;
      final field = find.byKey(const Key('editor'));
      final bounds = tester.getRect(field);
      final editable = tester
          .state<EditableTextState>(
            find.descendant(of: field, matching: find.byType(EditableText)),
          )
          .renderEditable;
      final origin = editable.localToGlobal(Offset.zero);
      expect(origin.dy, closeTo(bounds.top, 0.01));
      expect(origin.dy + editable.size.height, closeTo(bounds.bottom, 0.01));
      expect(
        tester.widget<CupertinoTextField>(field).padding,
        MarkerStyle.documentPadding,
      );
      if (mode == '分屏') {
        final preview = tester.getRect(find.byKey(const Key('preview')));
        expect(bounds.top, closeTo(preview.top, 0.01));
        expect(bounds.bottom, closeTo(preview.bottom, 0.01));
      }
    }
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
