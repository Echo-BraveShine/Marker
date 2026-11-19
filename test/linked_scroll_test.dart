import 'package:flutter/widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marker/src/widgets/linked_scroll.dart';

void main() {
  testWidgets('scroll progress maps in both directions and can be disabled', (
    tester,
  ) async {
    final a = ScrollController(), b = ScrollController();
    var enabled = true;
    final link = LinkedScroll(a, b, enabled: () => enabled);
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          children: [
            Expanded(
              child: ListView(
                controller: a,
                children: const [SizedBox(height: 3000)],
              ),
            ),
            Expanded(
              child: ListView(
                controller: b,
                children: const [SizedBox(height: 6000)],
              ),
            ),
          ],
        ),
      ),
    );
    a.jumpTo(a.position.maxScrollExtent * .4);
    await tester.pump();
    expect(b.offset / b.position.maxScrollExtent, closeTo(.4, .001));
    link.takeControl(b);
    b.jumpTo(b.position.maxScrollExtent * .75);
    await tester.pump();
    expect(a.offset / a.position.maxScrollExtent, closeTo(.75, .001));
    link.takeControl(a);
    var updates = 0;
    b.addListener(() => updates++);
    for (var i = 1; i <= 20; i++) {
      a.jumpTo(a.position.maxScrollExtent * i / 20);
    }
    expect(updates, 0);
    await tester.pump();
    expect(updates, 1);
    expect(b.offset / b.position.maxScrollExtent, closeTo(1, .001));
    enabled = false;
    a.jumpTo(0);
    expect(b.offset / b.position.maxScrollExtent, closeTo(1, .001));
    await tester.pumpWidget(const SizedBox());
    link.dispose();
    a.dispose();
    b.dispose();
  });
  testWidgets('delayed follower correction must not move the driving preview', (
    tester,
  ) async {
    final editor = ScrollController(), preview = ScrollController();
    final link = LinkedScroll(editor, preview, enabled: () => true);
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          children: [
            Expanded(
              child: ListView(
                controller: editor,
                children: const [SizedBox(height: 3000)],
              ),
            ),
            Expanded(
              child: ListView(
                controller: preview,
                children: const [SizedBox(height: 6000)],
              ),
            ),
          ],
        ),
      ),
    );
    preview.jumpTo(preview.position.maxScrollExtent * .4);
    await tester.pump();
    final drivenOffset = preview.offset;
    // Simulate an editor caret reveal or late layout correction after jumpTo returns.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      editor.jumpTo(editor.position.maxScrollExtent * .7);
    });
    await tester.pump();
    await tester.pump();
    expect(preview.offset, drivenOffset);
    await tester.pumpWidget(const SizedBox());
    link.dispose();
    editor.dispose();
    preview.dispose();
  });
  testWidgets(
    'wheel handoff preserves preview inertia through follower corrections',
    (tester) async {
      final editor = ScrollController(), preview = ScrollController();
      final link = LinkedScroll(editor, preview, enabled: () => true);
      Widget pane(ScrollController controller, String name, double height) =>
          Expanded(
            child: LinkedScrollRegion(
              link: link,
              controller: controller,
              child: ListView(
                key: ValueKey(name),
                controller: controller,
                physics: const ClampingScrollPhysics(),
                children: [SizedBox(height: height)],
              ),
            ),
          );
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            children: [
              pane(editor, 'left', 5000),
              pane(preview, 'right', 9000),
            ],
          ),
        ),
      );
      Future<void> wheel(String name, double delta) async {
        await tester.sendEventToBinding(
          PointerScrollEvent(
            position: tester.getCenter(find.byKey(ValueKey(name))),
            scrollDelta: Offset(0, delta),
          ),
        );
        await tester.pump();
        await tester.pump();
      }

      await wheel('right', 400);
      expect(preview.offset, 400);
      expect(
        editor.offset / editor.position.maxScrollExtent,
        closeTo(preview.offset / preview.position.maxScrollExtent, .001),
      );
      await wheel('left', 300);
      expect(
        preview.offset / preview.position.maxScrollExtent,
        closeTo(editor.offset / editor.position.maxScrollExtent, .001),
      );
      await tester.fling(
        find.byKey(const ValueKey('right')),
        const Offset(0, -450),
        1400,
      );
      await tester.pump(const Duration(milliseconds: 16));
      expect(preview.position.activity, isA<BallisticScrollActivity>());
      var previous = preview.offset;
      // A late follower correction must not interrupt a trackpad/touch fling.
      editor.jumpTo(0);
      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 16));
        expect(preview.offset, greaterThanOrEqualTo(previous));
        previous = preview.offset;
      }
      expect(preview.position.isScrollingNotifier.value, isTrue);
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox());
      link.dispose();
      editor.dispose();
      preview.dispose();
    },
  );
}
