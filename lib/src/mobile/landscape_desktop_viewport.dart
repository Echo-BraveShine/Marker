import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Theme, Colors;
import 'package:flutter/services.dart';
import '../theme/marker_colors.dart';
import 'mobile_cutout_area.dart';

/// Keep desktop geometry on landscape phones, including dialogs and overlays.
class LandscapeDesktopViewport extends StatelessWidget {
  const LandscapeDesktopViewport({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final android = defaultTargetPlatform == TargetPlatform.android;
    final theme = Theme.of(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarContrastEnforced: false,
        statusBarIconBrightness: theme.brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
        systemNavigationBarIconBrightness: theme.brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
      ),
      child: ColoredBox(
        color: theme.extension<MarkerColors>()!.bgWindow,
        // Apply physical system-bar insets before scaling desktop geometry.
        // iOS retains its existing edge layout and camera-side handling.
        child: SafeArea(
          left: false,
          right: false,
          top: android,
          bottom: android,
          maintainBottomViewPadding: true,
          child: _viewport(context),
        ),
      ),
    );
  }

  Widget _viewport(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final media = MediaQuery.of(context);
      final usableWidth = constraints.maxWidth - media.viewPadding.horizontal;
      final scale = (usableWidth / 900).clamp(0.1, 1.0);
      final width = constraints.maxWidth / scale;
      final height = constraints.maxHeight / scale;
      EdgeInsets scaled(EdgeInsets value) => EdgeInsets.fromLTRB(
        value.left / scale,
        value.top / scale,
        value.right / scale,
        value.bottom / scale,
      );
      return FittedBox(
        fit: BoxFit.contain,
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: width,
          height: height,
          child: MediaQuery(
            data: media.copyWith(
              size: Size(width, height),
              padding: scaled(media.padding),
              viewPadding: scaled(media.viewPadding),
              viewInsets: scaled(media.viewInsets),
            ),
            child: MobileCutoutArea(child: child),
          ),
        ),
      );
    },
  );
}
