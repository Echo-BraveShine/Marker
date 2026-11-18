import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:marker/src/widgets/desktop_startup.dart';

void main() {
  testWidgets('hidden window is revealed even when no first frame can arrive', (
    tester,
  ) async {
    final events = <String>[];
    final pending = revealDesktopWindow(
      firstFrame: Completer<void>().future,
      show: () async {
        events.add('show');
      },
      focus: () async {
        events.add('focus');
      },
    );
    await tester.pump(const Duration(milliseconds: 499));
    expect(events, isEmpty);
    await tester.pump(const Duration(milliseconds: 1));
    await pending;
    expect(events, ['show', 'focus']);
  });
  test('ready frame shows without waiting for the fallback timeout', () async {
    var visible = false;
    await revealDesktopWindow(
      firstFrame: Future.value(),
      show: () async {
        visible = true;
      },
      focus: () async {},
    );
    expect(visible, isTrue);
  });
}
