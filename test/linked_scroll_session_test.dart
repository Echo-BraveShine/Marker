import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marker/src/widgets/linked_scroll.dart';

void main() {
  testWidgets(
    'real editor follows a stable gesture mapping across changing preview height',
    (tester) async {
      final editor = ScrollController(), preview = ScrollController();
      final text = TextEditingController(
        text: List.generate(
          400,
          (i) => 'Line $i with editable text',
        ).join('\n'),
      );
      final link = LinkedScroll(editor, preview, enabled: () => true);
      var height = 6000.0;
      late StateSetter resize;
      addTearDown(() async {
        link.dispose();
        await tester.pumpWidget(const SizedBox());
        editor.dispose();
        preview.dispose();
        text.dispose();
      });
      await tester.pumpWidget(
        CupertinoApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              resize = setState;
              return Row(
                children: [
                  Expanded(
                    child: LinkedScrollRegion(
                      link: link,
                      controller: editor,
                      child: CupertinoTextField(
                        controller: text,
                        scrollController: editor,
                        expands: true,
                        maxLines: null,
                      ),
                    ),
                  ),
                  Expanded(
                    child: LinkedScrollRegion(
                      link: link,
                      controller: preview,
                      child: ListView(
                        key: const Key('right'),
                        controller: preview,
                        physics: const ClampingScrollPhysics(),
                        children: [SizedBox(height: height)],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      );
      final ratio =
          editor.position.maxScrollExtent / preview.position.maxScrollExtent;
      expect(ratio, greaterThan(0));
      link.takeControl(preview, newGesture: true);
      preview.jumpTo(400);
      await tester.pump();
      expect(editor.offset, closeTo(400 * ratio, .01));
      resize(() => height = 10000);
      await tester.pump();
      expect(preview.offset, 400);
      preview.jumpTo(500);
      await tester.pump();
      expect(editor.offset, closeTo(500 * ratio, .01));
      final anchor = editor.offset;
      await tester.pump(const Duration(milliseconds: 250));
      final freshRatio =
          editor.position.maxScrollExtent / preview.position.maxScrollExtent;
      link.takeControl(preview);
      preview.jumpTo(600);
      await tester.pump();
      expect(editor.offset, closeTo(anchor + 100 * freshRatio, .01));
      editor.jumpTo(0); // Late caret correction must not become driving input.
      await tester.pump();
      expect(preview.offset, 600);
      await tester.fling(
        find.byKey(const Key('right')),
        const Offset(0, -400),
        1400,
      );
      await tester.pump(const Duration(milliseconds: 16));
      expect(preview.position.activity, isA<BallisticScrollActivity>());
      editor.jumpTo(0);
      var previous = preview.offset;
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 16));
        expect(preview.offset, greaterThanOrEqualTo(previous));
        previous = preview.offset;
      }
      expect(preview.position.isScrollingNotifier.value, isTrue);
      link.dispose();
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('reset, disable and disposal discard pending synchronization', (
    tester,
  ) async {
    final a = ScrollController(), b = ScrollController();
    var enabled = true;
    final link = LinkedScroll(a, b, enabled: () => enabled);
    addTearDown(() async {
      link.dispose();
      await tester.pumpWidget(const SizedBox());
      a.dispose();
      b.dispose();
    });
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          children: [
            Expanded(
              child: ListView(
                controller: a,
                children: const [SizedBox(height: 5000)],
              ),
            ),
            Expanded(
              child: ListView(
                controller: b,
                children: const [SizedBox(height: 8000)],
              ),
            ),
          ],
        ),
      ),
    );
    a.jumpTo(500);
    link.reset();
    await tester.pump();
    expect(b.offset, 0);
    enabled = false;
    a.jumpTo(800);
    await tester.pump();
    expect(b.offset, 0);
    enabled = true;
    link.takeControl(b, newGesture: true);
    b.jumpTo(b.position.maxScrollExtent);
    await tester.pump();
    expect(a.offset, a.position.maxScrollExtent);
    final before = a.offset;
    b.jumpTo(500);
    link.dispose();
    await tester.pump();
    expect(a.offset, before);
    expect(tester.takeException(), isNull);
  });
}
