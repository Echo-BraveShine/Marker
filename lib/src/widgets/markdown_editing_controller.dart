import 'package:flutter/material.dart';
import '../theme/marker_colors.dart';
import '../theme/highlight_style.dart';
import 'markdown_highlighter.dart';

/// Foreground-only syntax rendering retains selection, undo and line geometry.
class MarkdownEditingController extends TextEditingController {
  MarkdownEditingController({super.text});
  bool highlightEnabled = false;
  MarkerColors colors = MarkerColors.light;
  EditorHighlightStyle highlightStyle = EditorHighlightStyle.classic;
  String? _cachedText;
  MarkerColors? _cachedColors;
  EditorHighlightStyle? _cachedStyle;
  List<TextSpan> _spans = [];

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    if (!highlightEnabled) {
      return super.buildTextSpan(
        context: context,
        style: style,
        withComposing: withComposing,
      );
    }
    if (_cachedText != text ||
        _cachedColors != colors ||
        _cachedStyle != highlightStyle) {
      _cachedText = text;
      _cachedColors = colors;
      _cachedStyle = highlightStyle;
      _spans = MarkdownHighlighter(
        HighlightPalette.from(highlightStyle, colors),
      ).highlight(text);
    }
    if (!withComposing ||
        !value.isComposingRangeValid ||
        value.composing.isCollapsed) {
      return TextSpan(style: style, children: _spans);
    }
    // Add IME underlines without removing syntax colors from the document.
    final spans = <TextSpan>[];
    var offset = 0;
    for (final span in _spans) {
      final content = span.text!;
      final end = offset + content.length;
      final from = value.composing.start.clamp(offset, end) - offset;
      final to = value.composing.end.clamp(offset, end) - offset;
      if (from < to) {
        if (from > 0) {
          spans.add(
            TextSpan(text: content.substring(0, from), style: span.style),
          );
        }
        spans.add(
          TextSpan(
            text: content.substring(from, to),
            style: span.style?.copyWith(decoration: TextDecoration.underline),
          ),
        );
        if (to < content.length) {
          spans.add(TextSpan(text: content.substring(to), style: span.style));
        }
      } else {
        spans.add(span);
      }
      offset = end;
    }
    return TextSpan(style: style, children: spans);
  }
}
