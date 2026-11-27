import 'package:flutter/widgets.dart';
import '../theme/marker_colors.dart';

/// Extend adjacent pane surfaces through the narrow rounded-corner margins.
class MobileWorkbenchSurface extends StatelessWidget {
  const MobileWorkbenchSurface({
    super.key,
    required this.enabled,
    required this.colors,
    required this.editorOnly,
    required this.child,
  });
  final bool enabled, editorOnly;
  final MarkerColors colors;
  final Widget child;
  @override
  Widget build(BuildContext context) => enabled
      ? CustomPaint(painter: _SurfacePainter(colors, editorOnly), child: child)
      : child;
}

class _SurfacePainter extends CustomPainter {
  const _SurfacePainter(this.colors, this.editorOnly);
  final MarkerColors colors;
  final bool editorOnly;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = colors.bgSidebar;
    canvas.drawRect(Offset.zero & size, paint);
    final right = size.width / 2;
    paint.color = editorOnly ? colors.bgEditor : colors.bgPreview;
    canvas.drawRect(Rect.fromLTWH(right, 0, right, size.height), paint);
    paint.color = colors.bgToolbar;
    canvas.drawRect(Rect.fromLTWH(right, 0, right, 44), paint);
    canvas.drawRect(Rect.fromLTWH(right, size.height - 24, right, 24), paint);
  }

  @override
  bool shouldRepaint(_SurfacePainter oldDelegate) =>
      colors != oldDelegate.colors || editorOnly != oldDelegate.editorOnly;
}
