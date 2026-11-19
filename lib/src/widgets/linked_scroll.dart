import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;
import 'package:flutter/widgets.dart';
import 'package:flutter/scheduler.dart';

/// Only the driving pane can publish progress, including across layout frames.
class LinkedScroll {
  LinkedScroll(this.editor, this.preview, {required this.enabled}) {
    editor.addListener(_fromEditor);
    preview.addListener(_fromPreview);
  }
  final ScrollController editor, preview;
  final bool Function() enabled;
  bool _updating = false;
  int? _frame;
  ScrollController? _leader, _source, _target;

  /// Explicit user input, editing or link navigation transfers scroll ownership.
  void takeControl(ScrollController controller) {
    if (_leader == controller) return;
    reset();
    _leader = controller;
  }

  void reset() {
    if (_frame != null) {
      SchedulerBinding.instance.cancelFrameCallbackWithId(_frame!);
      _frame = null;
    }
    _leader = _source = _target = null;
  }

  void _fromEditor() => _sync(editor, preview);
  void _fromPreview() => _sync(preview, editor);
  void _sync(ScrollController source, ScrollController target) {
    if (_updating || !enabled()) return;
    _leader ??= source;
    // jumpTo can trigger another frame of extent/caret correction. That must
    // never feed back into the pane under the user's pointer or cancel its fling.
    if (_leader != source) return;
    _source = source;
    _target = target;
    _frame ??= SchedulerBinding.instance.scheduleFrameCallback((_) {
      _frame = null;
      if (_source == _leader) _apply(_source!, _target!);
    });
  }

  void _apply(ScrollController source, ScrollController target) {
    if (_updating ||
        !enabled() ||
        source.positions.length != 1 ||
        target.positions.length != 1) {
      return;
    }
    final a = source.position;
    final b = target.position;
    if (!a.hasContentDimensions || !b.hasContentDimensions) return;
    final sourceExtent = a.maxScrollExtent - a.minScrollExtent;
    final targetExtent = b.maxScrollExtent - b.minScrollExtent;
    if (sourceExtent <= 0 || targetExtent <= 0) return;
    final progress = ((a.pixels - a.minScrollExtent) / sourceExtent).clamp(
      0.0,
      1.0,
    );
    final offset = b.minScrollExtent + progress * targetExtent;
    if ((offset - b.pixels).abs() < .5) return;
    _updating = true;
    try {
      target.jumpTo(offset);
    } finally {
      _updating = false;
    }
  }

  void dispose() {
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
    onPointerDown: (_) => link.takeControl(controller),
    onPointerPanZoomStart: (_) => link.takeControl(controller),
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
