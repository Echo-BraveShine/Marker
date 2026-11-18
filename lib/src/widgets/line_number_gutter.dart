import 'package:flutter/cupertino.dart';

/// Uses the editor's wrap width and scroll offset; continuation rows stay blank.
class LineNumberGutter extends StatelessWidget {
  const LineNumberGutter({
    super.key,
    required this.controller,
    required this.scrollController,
    required this.style,
    required this.textWidth,
    required this.color,
    required this.width,
  });
  final TextEditingController controller;
  final ScrollController scrollController;
  final TextStyle style;
  final double textWidth;
  final Color color;
  final double width;
  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox(
      width: width,
      child: ClipRect(
        child: CustomPaint(
          painter: _Numbers(
            controller,
            scrollController,
            style,
            textWidth,
            color,
            MediaQuery.textScalerOf(context),
          ),
        ),
      ),
    ),
  );
}

class _Numbers extends CustomPainter {
  _Numbers(
    this.controller,
    this.scroll,
    this.style,
    this.textWidth,
    this.color,
    this.scaler,
  ) : super(repaint: Listenable.merge([controller, scroll]));
  final TextEditingController controller;
  final ScrollController scroll;
  final TextStyle style;
  final double textWidth;
  final Color color;
  final TextScaler scaler;
  @override
  void paint(Canvas canvas, Size size) {
    var y = 10.0 - (scroll.positions.length == 1 ? scroll.offset : 0);
    final lines = controller.text.split('\n');
    for (var i = 0; i < lines.length; i++) {
      final paragraph = TextPainter(
        text: TextSpan(text: lines[i].isEmpty ? ' ' : lines[i], style: style),
        textDirection: TextDirection.ltr,
        textScaler: scaler,
        strutStyle: StrutStyle.fromTextStyle(style, forceStrutHeight: true),
      )..layout(maxWidth: textWidth);
      if (y + paragraph.height >= 0 && y < size.height) {
        final number = TextPainter(
          text: TextSpan(
            text: '${i + 1}',
            style: style.copyWith(color: color),
          ),
          textDirection: TextDirection.ltr,
          textScaler: scaler,
          strutStyle: StrutStyle.fromTextStyle(style, forceStrutHeight: true),
        )..layout();
        number.paint(canvas, Offset(size.width - number.width - 4, y));
        number.dispose();
      }
      y += paragraph.height;
      paragraph.dispose();
      if (y > size.height) break;
    }
  }

  @override
  bool shouldRepaint(covariant _Numbers old) =>
      old.style != style ||
      old.textWidth != textWidth ||
      old.color != color ||
      old.scaler != scaler;
}
