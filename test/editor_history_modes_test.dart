import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:marker/main.dart';
import 'package:marker/src/widgets/markdown_extensions.dart';

void main() {
  testWidgets('undo and redo survive all view mode transitions', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      ProviderScope(
        overrides: [mermaidPreviewEnabledProvider.overrideWithValue(false)],
        child: const MarkerApp(),
      ),
    );
    await tester.pumpAndSettle();
    final finder = find.byKey(const Key('editor'));
    final field = tester.widget<CupertinoTextField>(finder);
    final history = field.undoController!;
    await tester.enterText(finder, 'History base');
    await tester.pump(const Duration(milliseconds: 600));
    await tester.enterText(finder, 'History changed');
    await tester.pump(const Duration(milliseconds: 600));
    for (final mode in ['编辑', '分屏', '预览', '分屏', '编辑']) {
      await tester.tap(
        find.descendant(
          of: find.byType(CupertinoSlidingSegmentedControl<int>),
          matching: find.text(mode),
        ),
      );
      await tester.pumpAndSettle();
      expect(history.value.canUndo, isTrue, reason: mode);
      history.undo();
      await tester.pumpAndSettle();
      expect(field.controller!.text, 'History base', reason: mode);
      expect(history.value.canRedo, isTrue, reason: mode);
      history.redo();
      await tester.pumpAndSettle();
      expect(field.controller!.text, 'History changed', reason: mode);
    }
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
