import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marker/src/theme/marker_app_theme.dart';
import 'package:marker/src/widgets/shortcut_settings.dart';

void main() {
  testWidgets('shortcut list scrolls inside a stationary border', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: MarkerAppTheme().light(),
        home: const Scaffold(
          body: Center(
            child: SizedBox(
              width: 500,
              height: 280,
              child: ShortcutSettings(zh: true),
            ),
          ),
        ),
      ),
    );
    final frame = find.byKey(const Key('shortcut-frame'));
    final before = tester.getRect(frame);
    final list = find.byType(ListView);
    final scrollable = tester.state<ScrollableState>(
      find.descendant(of: list, matching: find.byType(Scrollable)).first,
    );
    await tester.drag(list, const Offset(0, -240));
    await tester.pumpAndSettle();
    expect(scrollable.position.pixels, greaterThan(0));
    expect(tester.getRect(frame), before);
    expect(tester.takeException(), isNull);
  });
}
