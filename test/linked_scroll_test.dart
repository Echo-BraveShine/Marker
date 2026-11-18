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
    expect(b.offset / b.position.maxScrollExtent, closeTo(.4, .001));
    b.jumpTo(b.position.maxScrollExtent * .75);
    expect(a.offset / a.position.maxScrollExtent, closeTo(.75, .001));
    enabled = false;
    a.jumpTo(0);
    expect(b.offset / b.position.maxScrollExtent, closeTo(.75, .001));
    await tester.pumpWidget(const SizedBox());
    link.dispose();
    a.dispose();
    b.dispose();
  });
}
