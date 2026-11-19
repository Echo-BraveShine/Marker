import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marker/src/theme/marker_app_theme.dart';
import 'package:marker/src/theme/marker_fonts.dart';
import 'package:marker/src/widgets/cjk_math.dart';

void main() {
  for (final expression in [
    r'x + \text{中文，文字。}',
    r'\sum_{\text{项目}=1}^{n} x',
    r'\begin{aligned}\text{数量}&=x\\y&=\text{总数}\end{aligned}',
    r'x + \frac{\text{数量}}{\sqrt{\text{总数}}}',
    r'\begin{pmatrix}\text{开始}&x\\y&\text{结束}\end{pmatrix}',
  ]) {
    testWidgets(
      'Chinese math keeps bundled glyphs in $expression',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: MarkerAppTheme().light(),
            home: Scaffold(
              body: markerMath(expression, mathStyle: MathStyle.display),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final glyphs = tester.widgetList<RichText>(find.byType(RichText));
        final cjk = glyphs.where(
          (w) => RegExp(r'[\u4e00-\u9fff]').hasMatch(w.text.toPlainText()),
        );
        expect(cjk, isNotEmpty);
        for (final glyph in cjk) {
          expect(glyph.text.style!.fontFamily, MarkerFonts.cjkFamily);
        }
        expect(
          glyphs.any(
            (w) =>
                w.text.style?.fontFamily?.startsWith(
                  'packages/flutter_math_fork/KaTeX_',
                ) ??
                false,
          ),
          isTrue,
        );
        expect(tester.takeException(), isNull);
      },
      variant: TargetPlatformVariant({TargetPlatform.linux}),
    );
  }
}
