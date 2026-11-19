import 'package:flutter/material.dart';
import '../theme/marker_colors.dart';
import '../theme/highlight_style.dart';
import 'markdown_highlighter.dart';
import 'editor_search.dart';

/// Source-preserving syntax, search and IME rendering keeps editing geometry.
class MarkdownEditingController extends TextEditingController {
  MarkdownEditingController({super.text});
  bool highlightEnabled = false;
  MarkerColors colors = MarkerColors.light;
  EditorHighlightStyle highlightStyle = EditorHighlightStyle.classic;
  String searchQuery = '';
  bool searchCaseSensitive = false;
  String? _matchedText, _matchedQuery;
  bool? _matchedCaseSensitive;
  List<TextRange> _matches = const [];
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
    if (!highlightEnabled && searchQuery.isEmpty) {
      return super.buildTextSpan(
        context: context,
        style: style,
        withComposing: withComposing,
      );
    }
    if (highlightEnabled &&
        (_cachedText != text ||
            _cachedColors != colors ||
            _cachedStyle != highlightStyle)) {
      _cachedText = text;
      _cachedColors = colors;
      _cachedStyle = highlightStyle;
      _spans = MarkdownHighlighter(
        HighlightPalette.from(highlightStyle, colors),
      ).highlight(text);
    }
    if (_matchedText != text ||
        _matchedQuery != searchQuery ||
        _matchedCaseSensitive != searchCaseSensitive) {
      _matchedText = text;
      _matchedQuery = searchQuery;
      _matchedCaseSensitive = searchCaseSensitive;
      _matches = findEditorMatches(
        text,
        searchQuery,
        caseSensitive: searchCaseSensitive,
      );
    }
    final composing = withComposing && value.isComposingRangeValid
        ? value.composing
        : TextRange.empty;
    if (highlightEnabled && _matches.isEmpty && composing.isCollapsed) {
      return TextSpan(style: style, children: _spans);
    }
    final dark = colors.bgEditor.computeLuminance() < .5;
    final matchColor = dark ? const Color(0xFF66551F) : const Color(0xFFFFF0A6);
    final currentColor = dark
        ? const Color(0xFF986720)
        : const Color(0xFFFFD275);
    final source = highlightEnabled ? _spans : [TextSpan(text: text)];
    final spans = <TextSpan>[];
    var offset = 0;
    var matchIndex = 0;
    // Walk tokens and matches together; searching never changes the document.
    for (final span in source) {
      final content = span.text!;
      final end = offset + content.length;
      var cursor = offset;
      while (cursor < end) {
        while (matchIndex < _matches.length &&
            _matches[matchIndex].end <= cursor) {
          matchIndex++;
        }
        final match = matchIndex < _matches.length
            ? _matches[matchIndex]
            : null;
        final inside = match != null && match.start <= cursor;
        var next = end;
        if (match != null) {
          final boundary = inside ? match.end : match.start;
          if (boundary < next) next = boundary;
        }
        if (!composing.isCollapsed && composing.isValid) {
          if (composing.start > cursor && composing.start < next) {
            next = composing.start;
          }
          if (composing.end > cursor && composing.end < next) {
            next = composing.end;
          }
        }
        var tokenStyle = span.style ?? const TextStyle();
        if (inside) {
          final current =
              selection.isValid &&
              selection.start == match.start &&
              selection.end == match.end;
          tokenStyle = tokenStyle.copyWith(
            backgroundColor: current ? currentColor : matchColor,
          );
        }
        if (composing.isValid &&
            !composing.isCollapsed &&
            composing.start <= cursor &&
            cursor < composing.end) {
          tokenStyle = tokenStyle.copyWith(
            decoration: TextDecoration.underline,
          );
        }
        spans.add(
          TextSpan(
            text: content.substring(cursor - offset, next - offset),
            style: tokenStyle,
          ),
        );
        cursor = next;
      }
      offset = end;
    }
    return TextSpan(style: style, children: spans);
  }
}
