import 'package:flutter/widgets.dart';

class MermaidRenderScope extends InheritedWidget {
  const MermaidRenderScope({
    super.key,
    required this.waitForIdle,
    required super.child,
  });
  final Future<void> Function() waitForIdle;
  static Future<void> Function()? idleOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<MermaidRenderScope>()
      ?.waitForIdle;
  @override
  bool updateShouldNotify(MermaidRenderScope oldWidget) =>
      waitForIdle != oldWidget.waitForIdle;
}
