import 'package:flutter/widgets.dart';
import 'package:flutter/scheduler.dart';

/// Maps document progress, avoiding feedback when the follower is updated.
class LinkedScroll {
  LinkedScroll(this.editor, this.preview, {required this.enabled}) {
    editor.addListener(_fromEditor);
    preview.addListener(_fromPreview);
  }
  final ScrollController editor, preview;
  final bool Function() enabled;
  bool _updating = false;
  int? _frame;
  ScrollController? _source, _target;
  void _fromEditor() => _sync(editor, preview);
  void _fromPreview() => _sync(preview, editor);
  void _sync(ScrollController source, ScrollController target) {
    if (_updating || !enabled()) return;
    _source = source;
    _target = target;
    _frame ??= SchedulerBinding.instance.scheduleFrameCallback((_) {
      _frame = null;
      _apply(_source!, _target!);
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
    if (!a.hasContentDimensions ||
        !b.hasContentDimensions ||
        a.maxScrollExtent <= 0 ||
        b.maxScrollExtent <= 0) {
      return;
    }
    final offset =
        (a.pixels / a.maxScrollExtent).clamp(0.0, 1.0) * b.maxScrollExtent;
    if ((offset - b.pixels).abs() < .5) return;
    _updating = true;
    try {
      target.jumpTo(offset);
    } finally {
      _updating = false;
    }
  }

  void dispose() {
    if (_frame != null) {
      SchedulerBinding.instance.cancelFrameCallbackWithId(_frame!);
    }
    editor.removeListener(_fromEditor);
    preview.removeListener(_fromPreview);
  }
}
