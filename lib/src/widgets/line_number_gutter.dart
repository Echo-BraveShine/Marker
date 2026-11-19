import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';

/// Logical line starts are indexed once per text edit, never per scroll tick.
class LineNumberIndex {
  String _text = '';
  List<int> _starts = [0];
  int _characters = 0;
  void update(String text) {
    if (text == _text) return;
    _text = text;
    _starts = [
      0,
      for (final match in RegExp(r'\r\n?|\n').allMatches(text)) match.end,
    ];
    _characters = text.runes.length;
  }

  int get length => _starts.length;
  int get characters => _characters;
  int start(int line) => _starts[line];
  int lineAt(int offset) {
    var low = 0, high = _starts.length;
    while (low < high) {
      final middle = (low + high) ~/ 2;
      if (_starts[middle] <= offset) {
        low = middle + 1;
      } else {
        high = middle;
      }
    }
    return (low - 1).clamp(0, _starts.length - 1);
  }
}

/// Reuses the editor's existing layout and paints only visible logical lines.
class LineNumberGutter extends StatefulWidget {
  const LineNumberGutter({
    super.key,
    required this.controller,
    required this.scrollController,
    required this.style,
    required this.color,
    required this.width,
    required this.index,
    required this.editable,
  });
  final TextEditingController controller;
  final ScrollController scrollController;
  final TextStyle style;
  final Color color;
  final double width;
  final LineNumberIndex index;
  final RenderEditable? Function() editable;
  @override
  State<LineNumberGutter> createState() => _LineNumberGutterState();
}

class _LineNumberGutterState extends State<LineNumberGutter> {
  final _paintKey = GlobalKey();
  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: ExcludeSemantics(
      child: SizedBox(
        width: widget.width,
        child: ClipRect(
          child: CustomPaint(
            key: _paintKey,
            painter: _Numbers(
              widget.controller,
              widget.scrollController,
              widget.style,
              widget.color,
              MediaQuery.textScalerOf(context),
              widget.index,
              widget.editable,
              () => _paintKey.currentContext?.findRenderObject() as RenderBox?,
            ),
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
    this.color,
    this.scaler,
    this.index,
    this.editable,
    this.gutter,
  ) : super(repaint: Listenable.merge([controller, scroll]));
  final TextEditingController controller;
  final ScrollController scroll;
  final TextStyle style;
  final Color color;
  final TextScaler scaler;
  final LineNumberIndex index;
  final RenderEditable? Function() editable;
  final RenderBox? Function() gutter;
  @override
  void paint(Canvas canvas, Size size) {
    final field = editable(), box = gutter();
    if (field == null || box == null || !field.attached || !field.hasSize) {
      return;
    }
    index.update(controller.text);
    final origin = box.globalToLocal(field.localToGlobal(Offset.zero));
    final first = field.getPositionForPoint(field.localToGlobal(Offset.zero));
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, origin.dy, size.width, field.size.height));
    for (var i = index.lineAt(first.offset); i < index.length; i++) {
      final caret = field.getLocalRectForCaret(
        TextPosition(offset: index.start(i)),
      );
      final center = origin.dy + caret.center.dy;
      if (center - field.preferredLineHeight > size.height) break;
      if (center + field.preferredLineHeight < 0) continue;
      final number = TextPainter(
        text: TextSpan(
          text: '${i + 1}',
          style: style.copyWith(color: color),
        ),
        textDirection: TextDirection.ltr,
        textScaler: scaler,
        strutStyle: StrutStyle.fromTextStyle(style, forceStrutHeight: true),
      )..layout();
      number.paint(
        canvas,
        Offset(size.width - number.width - 4, center - number.height / 2),
      );
      number.dispose();
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _Numbers old) =>
      old.style != style ||
      old.color != color ||
      old.scaler != scaler ||
      old.index != index;
}
