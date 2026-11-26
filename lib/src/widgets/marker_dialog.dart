import '../theme/marker_fonts.dart';
import 'marker_floating_surface.dart';
import '../theme/marker_style.dart';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Theme;
import '../theme/marker_colors.dart';

Future<T?> showMarkerDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = false,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: Localizations.localeOf(context).languageCode == 'zh'
        ? '关闭面板'
        : 'Dismiss panel',
    barrierColor: CupertinoColors.black.withValues(alpha: .18),
    transitionDuration: const Duration(milliseconds: 180),
    pageBuilder: (context, animation, secondary) => builder(context),
    transitionBuilder: (context, animation, secondary, child) => FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: Tween<double>(begin: .98, end: 1).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        ),
        child: child,
      ),
    ),
  );
}

/// Shared desktop panel chrome for settings, confirmations and pickers.
class MarkerDialog extends StatelessWidget {
  const MarkerDialog({
    super.key,
    required this.title,
    required this.content,
    this.actions = const [],
    this.width = 420,
    this.height,
    this.contentPadding = const EdgeInsets.all(20),
    this.scrollable = true,
  });
  final Widget title, content;
  final List<Widget> actions;
  final double width;
  final double? height;
  final EdgeInsets contentPadding;
  final bool scrollable;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<MarkerColors>()!;
    final available = math.max(
      120.0,
      MediaQuery.sizeOf(context).height -
          MediaQuery.viewInsetsOf(context).bottom -
          48,
    );
    final body = Padding(padding: contentPadding, child: content);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: CupertinoTheme(
        data: CupertinoThemeData(
          textTheme: MarkerFonts.cupertino,
          brightness: Theme.of(context).brightness,
          primaryColor: colors.textAccent,
        ),
        child: SafeArea(
          minimum: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: width,
                maxHeight: available,
              ),
              child: MarkerFloatingSurface(
                width: width,
                height: height == null ? null : math.min(height!, available),
                child: DefaultTextStyle(
                  style: TextStyle(
                    fontFamily: MarkerFonts.ui,
                    fontFamilyFallback: MarkerFonts.fallback,
                    fontSize: 13,
                    height: 1.38,
                    color: colors.textPrimary,
                  ),
                  child: Column(
                    mainAxisSize: height == null
                        ? MainAxisSize.min
                        : MainAxisSize.max,
                    children: [
                      Container(
                        color: colors.bgToolbar,
                        padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: DefaultTextStyle.merge(
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                                child: title,
                              ),
                            ),
                            CupertinoButton(
                              key: const Key('dialog-close'),
                              minimumSize: Size.zero,
                              padding: const EdgeInsets.all(6),
                              onPressed: () => Navigator.pop(context),
                              child: Icon(
                                CupertinoIcons.xmark,
                                size: 13,
                                color: colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Flexible(
                        fit: height == null ? FlexFit.loose : FlexFit.tight,
                        child: scrollable
                            ? SingleChildScrollView(child: body)
                            : body,
                      ),
                      if (actions.isNotEmpty)
                        Container(
                          width: double.infinity,
                          color: colors.bgToolbar,
                          padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                          child: Wrap(
                            alignment: WrapAlignment.end,
                            spacing: 8,
                            runSpacing: 8,
                            children: actions,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MarkerDialogButton extends StatelessWidget {
  const MarkerDialogButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.primary = false,
    this.isDestructiveAction = false,
  });
  final Widget child;
  final VoidCallback? onPressed;
  final bool primary, isDestructiveAction;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<MarkerColors>()!;
    final foreground = primary
        ? CupertinoColors.white
        : isDestructiveAction
        ? CupertinoColors.systemRed.resolveFrom(context)
        : colors.textPrimary;
    return Container(
      decoration: BoxDecoration(
        color: primary ? colors.textAccent : colors.bgEditor,
        borderRadius: BorderRadius.circular(MarkerStyle.controlRadius),
        border: Border.all(
          color: primary ? colors.textAccent : colors.separator,
        ),
      ),
      child: CupertinoButton(
        minimumSize: const Size(72, 28),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        onPressed: onPressed,
        child: DefaultTextStyle(
          style: TextStyle(
            fontFamily: MarkerFonts.ui,
            fontFamilyFallback: MarkerFonts.fallback,
            fontSize: 12,
            fontWeight: primary ? FontWeight.w600 : FontWeight.w400,
            color: foreground,
          ),
          child: child,
        ),
      ),
    );
  }
}
