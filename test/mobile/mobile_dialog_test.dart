import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marker/src/mobile/landscape_desktop_viewport.dart';
import 'package:marker/src/resources/resource_text_dialog.dart';
import 'package:marker/src/theme/marker_app_theme.dart';
import 'package:marker/src/widgets/marker_dialog.dart';

void main() {
  testWidgets('landscape input and confirmation stay above keyboard', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(844, 390));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpWidget(
      MaterialApp(
        theme: MarkerAppTheme().light(),
        builder: (context, child) => LandscapeDesktopViewport(child: child!),
        home: Builder(
          builder: (context) => CupertinoButton(
            onPressed: () => showMarkerDialog<void>(
              context: context,
              builder: (_) => const ResourceTextDialog(
                title: 'Rename',
                placeholder: 'Name',
                initial: '',
                confirm: 'Save',
              ),
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    tester.view.viewInsets = FakeViewPadding(
      bottom: 180 * tester.view.devicePixelRatio,
    );
    await tester.pumpAndSettle();
    expect(
      tester.getRect(find.byKey(const Key('resource-text-input'))).bottom,
      lessThanOrEqualTo(210),
    );
    expect(
      tester.getRect(find.byType(MarkerDialogButton)).bottom,
      lessThanOrEqualTo(210),
    );
    expect(tester.takeException(), isNull);
  });
}
