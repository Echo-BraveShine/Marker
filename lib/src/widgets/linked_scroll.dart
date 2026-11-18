import 'package:flutter/widgets.dart';

/// Maps document progress, avoiding feedback when the follower is updated.
class LinkedScroll {
  LinkedScroll(this.editor, this.preview, {required this.enabled}) {
    editor.addListener(_fromEditor);
    preview.addListener(_fromPreview);
  }
  final ScrollController editor, preview;
  final bool Function() enabled;
  bool _updating = false;
  void _fromEditor() => _sync(editor, preview);
  void _fromPreview() => _sync(preview, editor);
  void _sync(ScrollController source, ScrollController target) {
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
    editor.removeListener(_fromEditor);
    preview.removeListener(_fromPreview);
  }
}
