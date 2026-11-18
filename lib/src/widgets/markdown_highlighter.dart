import 'package:flutter/painting.dart';
import 'package:highlight/highlight.dart' as syntax;
import '../theme/highlight_style.dart';

/// Source-preserving block scanner followed by nested inline tokenization.
/// Only foreground colors change, so shaping and line geometry stay intact.
class MarkdownHighlighter {
  MarkdownHighlighter(this.palette);
  final HighlightPalette palette;
  static final _codeCache = <String, List<syntax.Node>>{};
  static final _lines = RegExp(r'[^\n]*\n|[^\n]+$');
  static final _fence = RegExp(r'^ {0,3}(`{3,}|~{3,})([^\n]*)');
  static final _inline = RegExp(
    r'\\[^\n(]|(`+)([^\n]*?)\1|!?\[[^\]\n]*\](?:\([^\n]*?\)|\[[^\]\n]*\])|\[\^[^\]\n]+\]|<[^>\n]+>|\$[^$\n]+\$|\\\([^\n]*?\\\)|\*\*\*[^\n]+?\*\*\*|___[^\n]+?___|\*\*[^\n]+?\*\*|__[^\n]+?__|~~[^\n]+?~~|\*[^*\n]+\*|_[^_\n]+_',
  );
  static final _prefix = RegExp(
    r'^ {0,3}(?:#{1,6}(?:[ \t]+|$)|(?:>[ \t]*)+|(?:[-+*]|\d+[.)])[ \t]+(?:\[[ xX]\][ \t]+)?)',
  );
  static final _reference = RegExp(r'^ {0,3}\[(?:\^)?[^\]]+\]:');
  static final _rule = RegExp(
    r'^ {0,3}(?:(?:\*[ \t]*){3,}|(?:-[ \t]*){3,}|(?:_[ \t]*){3,})\r?$',
  );
  static final _setext = RegExp(r'^ {0,3}(?:=+|-+)[ \t]*\r?$');

  TextSpan _span(String text, HighlightRole role) => TextSpan(
    text: text,
    style: TextStyle(color: palette[role]),
  );

  List<TextSpan> highlight(String source) {
    final lines = _lines.allMatches(source).map((m) => m[0]!).toList();
    final output = <TextSpan>[];
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final opening = _fence.firstMatch(line);
      if (opening != null) {
        output.add(_span(line, HighlightRole.marker));
        final marker = opening[1]!;
        final language = opening[2]!
            .trim()
            .split(RegExp(r'\s+'))
            .first
            .toLowerCase();
        final body = StringBuffer();
        i++;
        final close = RegExp(
          '^ {0,3}${RegExp.escape(marker[0])}{${marker.length},}[ \\t]*\\r?\\n?\$',
        );
        while (i < lines.length && !close.hasMatch(lines[i])) {
          body.write(lines[i++]);
        }
        output.addAll(_code(body.toString(), language));
        if (i < lines.length) output.add(_span(lines[i], HighlightRole.marker));
        continue;
      }
      if (RegExp(r'^(?: {4}|\t)').hasMatch(line) &&
          (i == 0 || lines[i - 1].trim().isEmpty)) {
        do {
          output.add(_span(lines[i], HighlightRole.code));
          i++;
        } while (i < lines.length &&
            (lines[i].trim().isEmpty ||
                RegExp(r'^(?: {4}|\t)').hasMatch(lines[i])));
        i--;
        continue;
      }
      final trimmed = line.trim();
      if (trimmed.startsWith(r'$$') || trimmed.startsWith(r'\[')) {
        final delimiter = trimmed.startsWith(r'$$') ? r'$$' : r'\]';
        output.add(_span(line, HighlightRole.math));
        if (!trimmed.substring(2).contains(delimiter)) {
          while (++i < lines.length) {
            output.add(_span(lines[i], HighlightRole.math));
            if (lines[i].contains(delimiter)) break;
          }
        }
        continue;
      }
      final plainLine = line.replaceFirst(RegExp(r'\r?\n$'), '');
      if (_rule.hasMatch(plainLine) || _setext.hasMatch(plainLine)) {
        output.add(_span(line, HighlightRole.marker));
        continue;
      }
      if (_reference.hasMatch(line)) {
        output.add(_span(line, HighlightRole.link));
        continue;
      }
      final prefix = _prefix.firstMatch(line);
      var role = HighlightRole.plain;
      var start = 0;
      if (prefix != null) {
        final mark = prefix[0]!;
        role = mark.trimLeft().startsWith('#')
            ? HighlightRole.title
            : mark.trimLeft().startsWith('>')
            ? HighlightRole.quote
            : HighlightRole.plain;
        output.add(_span(mark, HighlightRole.marker));
        start = prefix.end;
      } else if (i + 1 < lines.length &&
          plainLine.trim().isNotEmpty &&
          _setext.hasMatch(lines[i + 1].replaceFirst(RegExp(r'\r?\n$'), ''))) {
        role = HighlightRole.title;
      }
      output.addAll(_inlines(line.substring(start), role));
    }
    return output;
  }

  List<TextSpan> _inlines(String text, HighlightRole base, [int depth = 0]) {
    if (depth > 8) return [_span(text, base)];
    final spans = <TextSpan>[];
    var end = 0;
    for (final match in _inline.allMatches(text)) {
      if (match.start > end) {
        spans.addAll(_plain(text.substring(end, match.start), base));
      }
      final token = match[0]!;
      if (token.startsWith('\\') && !token.startsWith(r'\(')) {
        spans.add(_span(token, base));
      } else if (token.startsWith('`')) {
        spans.add(_span(token, HighlightRole.code));
      } else if (token.startsWith(r'$') || token.startsWith(r'\(')) {
        spans.add(_span(token, HighlightRole.math));
      } else if (token.startsWith('[') ||
          token.startsWith('![') ||
          token.startsWith('<')) {
        spans.add(_span(token, HighlightRole.link));
      } else {
        final width = token.startsWith('***') || token.startsWith('___')
            ? 3
            : token.startsWith('**') ||
                  token.startsWith('__') ||
                  token.startsWith('~~')
            ? 2
            : 1;
        spans.add(_span(token.substring(0, width), HighlightRole.marker));
        spans.addAll(
          _inlines(
            token.substring(width, token.length - width),
            HighlightRole.emphasis,
            depth + 1,
          ),
        );
        spans.add(
          _span(token.substring(token.length - width), HighlightRole.marker),
        );
      }
      end = match.end;
    }
    if (end < text.length) spans.addAll(_plain(text.substring(end), base));
    return spans;
  }

  List<TextSpan> _plain(String text, HighlightRole role) {
    if (!text.contains('|')) return [_span(text, role)];
    final parts = text.split('|');
    return [
      for (var i = 0; i < parts.length; i++) ...[
        if (i > 0) _span('|', HighlightRole.table),
        _span(parts[i], role),
      ],
    ];
  }

  List<TextSpan> _code(String text, String language) {
    if (text.isEmpty) return [];
    if (language == 'mermaid') {
      final pattern = RegExp(
        r'\b(?:graph|flowchart|sequenceDiagram|classDiagram|stateDiagram(?:-v2)?|erDiagram|gantt|pie|mindmap|timeline|subgraph|end|participant|actor|section|title|TD|LR|TB|BT|RL)\b|-->|==>|-\.->|%%[^\n]*|"[^"\n]*"',
      );
      final spans = <TextSpan>[];
      var end = 0;
      for (final match in pattern.allMatches(text)) {
        if (match.start > end) {
          spans.add(
            _span(text.substring(end, match.start), HighlightRole.code),
          );
        }
        final token = match[0]!;
        spans.add(
          _span(
            token,
            token.startsWith('%%')
                ? HighlightRole.comment
                : token.startsWith('"')
                ? HighlightRole.string
                : HighlightRole.link,
          ),
        );
        end = match.end;
      }
      if (end < text.length) {
        spans.add(_span(text.substring(end), HighlightRole.code));
      }
      return spans;
    }
    if (language.isEmpty || text.length > 100000) {
      return [_span(text, HighlightRole.code)];
    }
    try {
      final key = '$language\u0000$text';
      var nodes = _codeCache.remove(key);
      nodes ??= syntax.highlight.parse(text, language: language).nodes ?? [];
      _codeCache[key] = nodes;
      if (_codeCache.length > 16) _codeCache.remove(_codeCache.keys.first);
      final spans = <TextSpan>[];
      void visit(syntax.Node node, HighlightRole inherited) {
        final name = node.className ?? '';
        final role = name.contains('comment')
            ? HighlightRole.comment
            : name.contains('string') || name.contains('regexp')
            ? HighlightRole.string
            : name.contains('number') || name.contains('literal')
            ? HighlightRole.number
            : name.contains('keyword') ||
                  name.contains('built_in') ||
                  name.contains('type')
            ? HighlightRole.keyword
            : name.contains('title') || name.contains('attr')
            ? HighlightRole.link
            : inherited;
        if (node.value != null) spans.add(_span(node.value!, role));
        for (final child in node.children ?? <syntax.Node>[]) {
          visit(child, role);
        }
      }

      for (final node in nodes) {
        visit(node, HighlightRole.code);
      }
      if (spans.map((s) => s.text ?? '').join() == text) return spans;
    } catch (_) {
      // Unknown languages retain their source and a neutral code color.
    }
    return [_span(text, HighlightRole.code)];
  }
}
