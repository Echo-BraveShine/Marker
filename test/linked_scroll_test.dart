import 'package:flutter/widgets.dart';
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
    b.jumpTo(b.position.maxScrollExtent * .75);
    await tester.pump();
    expect(a.offset / a.position.maxScrollExtent, closeTo(.75, .001));
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
}
