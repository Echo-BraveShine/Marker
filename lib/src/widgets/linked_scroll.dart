import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;
import 'package:flutter/widgets.dart';
import 'package:flutter/scheduler.dart';

class _ScrollMapping {
  const _ScrollMapping(
    this.source,
    this.target,
    this.sourceAnchor,
    this.targetAnchor,
    this.ratio,
    this.sourceViewport,
    this.targetViewport,
  );
  final ScrollPosition source, target;
  final double sourceAnchor,
      targetAnchor,
      ratio,
      sourceViewport,
      targetViewport;
}

/// A gesture owns both its driving pane and its local offset mapping.
class LinkedScroll {
  LinkedScroll(
    this.editor,
    this.preview, {
    required this.enabled,
    this.mapOffset,
  }) {
    editor.addListener(_fromEditor);
    preview.addListener(_fromPreview);
  }
  final ScrollController editor, preview;
  final bool Function() enabled;
  final double? Function(bool fromEditor, double offset)? mapOffset;
  bool _updating = false, _disposed = false;
  int? _frame;
  Timer? _idleTimer;
  ScrollController? _leader, _source, _target;
  _ScrollMapping? _mapping;

  void takeControl(ScrollController controller, {bool newGesture = false}) {
    if (_updating || _disposed) return;
    if (_leader != controller || newGesture) {
      reset();
      _leader = controller;
    }
    final target = controller == editor ? preview : editor;
    if (_mapping == null) _capture(controller, target);
    _rearmIdleTimer();
  }

  void takeEditorControl() => takeControl(editor, newGesture: true);

  void reset() {
    if (_frame != null) {
      SchedulerBinding.instance.cancelFrameCallbackWithId(_frame!);
      _frame = null;
    }
    _idleTimer?.cancel();
    _idleTimer = null;
    _mapping = null;
    _leader = _source = _target = null;
  }

  void _fromEditor() => _sync(editor, preview);
  void _fromPreview() => _sync(preview, editor);

  void _capture(
    ScrollController source,
    ScrollController target, {
    bool implicit = false,
  }) {
    if (source.positions.length != 1 || target.positions.length != 1) return;
    final a = source.position, b = target.position;
    if (!a.hasContentDimensions || !b.hasContentDimensions) return;
    final extentA = a.maxScrollExtent - a.minScrollExtent;
    final extentB = b.maxScrollExtent - b.minScrollExtent;
    if (!extentA.isFinite ||
        !extentB.isFinite ||
        extentA <= 0 ||
        extentB <= 0) {
      return;
    }
    _mapping = _ScrollMapping(
      a,
      b,
      implicit ? a.minScrollExtent : a.pixels,
      implicit ? b.minScrollExtent : b.pixels,
      extentB / extentA,
      a.viewportDimension,
      b.viewportDimension,
    );
  }

  void _sync(ScrollController source, ScrollController target) {
    if (_updating || _disposed) return;
    if (!enabled()) {
      reset();
      return;
    }
    _leader ??= source;
    if (_leader != source) return;
    if (_mapping == null) _capture(source, target, implicit: true);
    _source = source;
    _target = target;
    _rearmIdleTimer();
    _frame ??= SchedulerBinding.instance.scheduleFrameCallback((_) {
      _frame = null;
      if (!_disposed &&
          _source != null &&
          _source == _leader &&
          _target != null) {
        _apply(_source!, _target!);
      }
    });
  }

  void _apply(ScrollController source, ScrollController target) {
    if (_updating || _disposed) return;
    if (!enabled()) {
      reset();
      return;
    }
    if (source.positions.length != 1 || target.positions.length != 1) return;
    final a = source.position, b = target.position;
    if (!a.hasContentDimensions || !b.hasContentDimensions) return;
    final mapping = _mapping;
    if (mapping == null) {
      _capture(source, target, implicit: true);
    } else if (!identical(a, mapping.source) ||
        !identical(b, mapping.target) ||
        a.viewportDimension != mapping.sourceViewport ||
        b.viewportDimension != mapping.targetViewport) {
      _capture(source, target);
    }
    final current = _mapping;
    if (current == null) return;
    // Content extents can change as images/lazy blocks lay out. Keep the gesture's
    // captured ratio and anchors; only clamp against the current destination.
    var offset =
        (current.targetAnchor +
                (a.pixels - current.sourceAnchor) * current.ratio)
            .clamp(b.minScrollExtent, b.maxScrollExtent)
            .toDouble();
    final semantic = mapOffset?.call(source == editor, a.pixels);
    if (semantic != null && semantic.isFinite) {
      offset = semantic.clamp(b.minScrollExtent, b.maxScrollExtent).toDouble();
    }
    if (a.pixels <= a.minScrollExtent) offset = b.minScrollExtent;
    if (a.pixels >= a.maxScrollExtent) offset = b.maxScrollExtent;
    if (!offset.isFinite || (offset - b.pixels).abs() < .5) return;
    _updating = true;
    try {
      target.jumpTo(offset);
    } finally {
      _updating = false;
    }
  }

  void _rearmIdleTimer() {
    _idleTimer?.cancel();
    _idleTimer = Timer(const Duration(milliseconds: 150), () {
      _idleTimer = null;
      if (_disposed) return;
      final leader = _leader;
      if (_frame != null ||
          (leader != null &&
              leader.positions.length == 1 &&
              leader.position.isScrollingNotifier.value)) {
        _rearmIdleTimer();
      } else {
        // Keep ownership so delayed follower corrections still cannot feed back.
        // Fresh user input will capture current extents and offset anchors.
        _mapping = null;
      }
    });
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    reset();
    editor.removeListener(_fromEditor);
    preview.removeListener(_fromPreview);
  }
}

/// Recognizes wheels, trackpads, thumb drags and touch drags before linking.
class LinkedScrollRegion extends StatelessWidget {
  const LinkedScrollRegion({
    super.key,
    required this.link,
    required this.controller,
    required this.child,
  });
  final LinkedScroll link;
  final ScrollController controller;
  final Widget child;

  @override
  Widget build(BuildContext context) => Listener(
    onPointerDown: (_) => link.takeControl(controller, newGesture: true),
    onPointerPanZoomStart: (_) =>
        link.takeControl(controller, newGesture: true),
    onPointerSignal: (event) {
      if (event is PointerScrollEvent && event.scrollDelta.dy != 0) {
        link.takeControl(controller);
      }
    },
    child: NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.depth == 0 &&
            notification.metrics.axis == Axis.vertical &&
            ((notification is ScrollStartNotification &&
                    notification.dragDetails != null) ||
                (notification is UserScrollNotification &&
                    notification.direction != ScrollDirection.idle))) {
          link.takeControl(controller);
        }
        return false;
      },
      child: child,
    ),
  );
}
