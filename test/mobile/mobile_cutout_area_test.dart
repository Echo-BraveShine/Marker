import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marker/src/mobile/mobile_cutout_area.dart';

void main() {
  testWidgets('only camera side reserves central content space', (
    tester,
  ) async {
    const channel = MethodChannel('marker/display');
    var side = 'left';
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (_) async => side,
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        null,
      ),
    );
    EdgeInsets? captured;
    for (final value in ['left', 'right', 'none']) {
      side = value;
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            size: Size(900, 400),
            viewPadding: EdgeInsets.symmetric(horizontal: 50),
          ),
          child: MobileCutoutArea(
            key: ValueKey(value),
            child: Builder(
              builder: (context) {
                captured = MobileCutoutArea.insetsOf(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(captured!.left, value == 'left' ? 34 : 0);
      expect(captured!.right, value == 'right' ? 34 : 0);
    }
  });
}
