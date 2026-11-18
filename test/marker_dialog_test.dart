import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marker/src/theme/marker_app_theme.dart';
import 'package:marker/src/widgets/marker_dialog.dart';

void main() {
  testWidgets(
    'shared panel scrolls content and wraps actions in small windows',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(420, 360));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          theme: MarkerAppTheme().light(),
          home: Builder(
            builder: (context) => CupertinoButton(
              onPressed: () => showMarkerDialog<void>(
                context: context,
                builder: (context) => MarkerDialog(
                  title: const Text('保存更改'),
                  content: Text(List.filled(30, '文档内容').join('\n')),
                  actions: [
                    MarkerDialogButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('取消'),
                    ),
                    MarkerDialogButton(
                      primary: true,
                      onPressed: () {},
                      child: const Text('保存文档'),
                    ),
                  ],
                ),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.byType(MarkerDialog), findsOneWidget);
      expect(tester.takeException(), isNull);
      expect(
        tester.getRect(find.byType(MarkerDialogButton).last).bottom,
        lessThanOrEqualTo(336),
      );
      await tester.tap(find.byKey(const Key('dialog-close')));
      await tester.pumpAndSettle();
      expect(find.byType(MarkerDialog), findsNothing);
    },
  );
}
