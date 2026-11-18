import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final desktopIconProvider = Provider((ref) => DesktopIconController());

/// Serializes native updates so quick appearance changes cannot finish out of order.
class DesktopIconController {
  static const channel = MethodChannel('marker/appearance');
  bool? _requested, _applied;
  Future<void>? _pending;

  Future<void> setDark(bool dark) {
    _requested = dark;
    return _pending ??= _drain().whenComplete(() => _pending = null);
  }

  Future<void> _drain() async {
    while (_requested != _applied) {
      final target = _requested!;
      try {
        await channel
            .invokeMethod<void>('setDark', target)
            .timeout(const Duration(seconds: 2));
        _applied = target;
      } on Exception catch (error) {
        debugPrint('Desktop icon update failed: $error');
        break;
      }
    }
  }
}

/// Lives below MaterialApp's effective Theme, including automatic system mode.
class DesktopIconSync extends ConsumerWidget {
  const DesktopIconSync({
    super.key,
    required this.enabled,
    required this.child,
  });
  final bool enabled;
  final Widget child;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (enabled) {
      final dark = Theme.of(context).brightness == Brightness.dark;
      final controller = ref.read(desktopIconProvider);
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => controller.setDark(dark),
      );
    }
    return child;
  }
}
