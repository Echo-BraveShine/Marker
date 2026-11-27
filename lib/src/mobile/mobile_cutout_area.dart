import 'dart:math' as math;
import 'dart:ui' show DisplayFeatureType;
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';

/// Content avoids the camera; corner controls also avoid rounded screen edges.
class MobileCutoutArea extends StatefulWidget {
  const MobileCutoutArea({super.key, required this.child});
  final Widget child;
  static EdgeInsets insetsOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_CutoutInsets>()?.insets ??
      EdgeInsets.zero;
  static EdgeInsets controlsOf(BuildContext context) {
    final safe = MediaQuery.viewPaddingOf(context);
    // The home surface already reserves 16 logical pixels at each outer edge.
    return EdgeInsets.only(
      left: math.max(insetsOf(context).left, math.max(0, safe.left - 16)),
      right: math.max(insetsOf(context).right, math.max(0, safe.right - 16)),
      bottom: safe.bottom,
    );
  }

  @override
  State<MobileCutoutArea> createState() => _MobileCutoutAreaState();
}

class _MobileCutoutAreaState extends State<MobileCutoutArea>
    with WidgetsBindingObserver {
  String? _side;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _refresh();
    });
  }

  @override
  void didChangeMetrics() {
    _refresh();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refresh();
  }

  Future<void> _refresh() async {
    try {
      final side = await const MethodChannel(
        'marker/display',
      ).invokeMethod<String>('cutoutSide');
      if (mounted) setState(() => _side = side);
    } on MissingPluginException {
      /* Use engine cutout geometry where available. */
    } on PlatformException {
      /* Keep conservative insets until geometry is available. */
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    var left = _side == 'right' || _side == 'none'
        ? 0.0
        : media.viewPadding.left;
    var right = _side == 'left' || _side == 'none'
        ? 0.0
        : media.viewPadding.right;
    final cuts = media.displayFeatures
        .where((f) => f.type == DisplayFeatureType.cutout)
        .toList();
    if (cuts.isNotEmpty) {
      left = 0;
      right = 0;
      for (final cut in cuts) {
        if (cut.bounds.left <= 1) {
          left = math.max(left, cut.bounds.right);
        }
        if (cut.bounds.right >= media.size.width - 1) {
          right = math.max(right, media.size.width - cut.bounds.left);
        }
      }
    }
    return _CutoutInsets(
      insets: EdgeInsets.only(
        left: math.max(0, left - 16),
        right: math.max(0, right - 16),
      ),
      child: widget.child,
    );
  }
}

class _CutoutInsets extends InheritedWidget {
  const _CutoutInsets({required this.insets, required super.child});
  final EdgeInsets insets;
  @override
  bool updateShouldNotify(_CutoutInsets oldWidget) =>
      oldWidget.insets != insets;
}
