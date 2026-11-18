import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marker/src/providers/text_color_provider.dart';
import 'package:marker/src/theme/marker_app_theme.dart';
import 'package:marker/src/widgets/text_color_picker.dart';

void main() {
  test('HSV selection supports hue, saturation, brightness and presets', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final subscription = container.listen(textColorProvider, (_, _) {});
    addTearDown(subscription.close);
    final notifier = container.read(textColorProvider.notifier);
    notifier.setWheel(0, 1);
    notifier.setBrightness(1);
    expect(container.read(textColorProvider).hex, '#FF0000');
    notifier.setWheel(0, 0);
    expect(container.read(textColorProvider).hex, '#FFFFFF');
    notifier.setBrightness(0);
    expect(container.read(textColorProvider).hex, '#000000');
    notifier.setHex('#0066CC');
    expect(container.read(textColorProvider).hex, '#0066CC');
  });
  testWidgets(
    'wheel, swatches and hex input synchronize without truncating typing',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: MarkerAppTheme().light(),
            home: const TextColorPicker(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final field = find.byKey(const Key('text-color-hex'));
      await tester.tapAt(
        tester.getCenter(find.byKey(const Key('text-color-wheel'))),
      );
      await tester.pump();
      expect(
        tester.widget<CupertinoTextField>(field).controller!.text,
        '#CCCCCC',
      );
      await tester.tap(find.byKey(const ValueKey('text-color-#E53935')));
      await tester.pump();
      expect(
        tester.widget<CupertinoTextField>(field).controller!.text,
        '#E53935',
      );
      await tester.enterText(field, '#123');
      await tester.pump();
      expect(tester.widget<CupertinoTextField>(field).controller!.text, '#123');
      await tester.enterText(field, '#123456');
      await tester.pump();
      expect(
        tester.widget<CupertinoTextField>(field).controller!.text,
        '#123456',
      );
      expect(tester.takeException(), isNull);
    },
  );
}
