import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marker/src/theme/marker_app_theme.dart';
import 'package:marker/src/widgets/settings_scroll_frame.dart';

void main() {
  for (final page in [0, 1, 3]) {
    testWidgets('settings page $page keeps heading and border fixed', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: MarkerAppTheme().light(),
          home: Scaffold(
            body: SizedBox(
              width: 600,
              height: 260,
              child: SettingsScrollFrame(
                title: 'Settings',
                page: page,
                child: Column(
                  children: List.generate(
                    30,
                    (i) => SizedBox(height: 50, child: Text('Row $i')),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      final frame = find.byKey(ValueKey('settings-frame-$page'));
      final before = tester.getRect(frame);
      final heading = tester.getRect(find.text('Settings'));
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -350),
      );
      await tester.pumpAndSettle();
      expect(tester.getRect(frame), before);
      expect(tester.getRect(find.text('Settings')), heading);
      final state = tester.state<ScrollableState>(find.byType(Scrollable));
      expect(state.position.pixels, greaterThan(0));
      expect(tester.takeException(), isNull);
    });
  }
}
