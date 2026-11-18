import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Theme;
import '../theme/marker_colors.dart';
import '../theme/marker_style.dart';

/// Shared visual surface for syntax popovers, dialogs and context menus.
class MarkerFloatingSurface extends StatelessWidget {
  const MarkerFloatingSurface({
    super.key,
    this.width,
    this.height,
    this.padding,
    required this.child,
  });
  final double? width, height;
  final EdgeInsets? padding;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<MarkerColors>()!;
    return Container(
      width: width,
      height: height,
      padding: padding,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: c.bgToolbar,
        borderRadius: BorderRadius.circular(MarkerStyle.floatingRadius),
        border: Border.all(color: c.separatorSoft),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF111111).withValues(alpha: .18),
            blurRadius: 28,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}
