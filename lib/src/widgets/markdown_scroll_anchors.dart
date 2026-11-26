import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;

/// Match parsed top-level blocks to monotonically increasing source lines.
/// Parsing remains entirely owned by Markdown, including references and Setext.
List<int> markdownBlockLines(String source, List<md.Node> nodes) {
  final lines = source.split('\n');
  String normalize(String value) =>
      value.replaceAll(RegExp(r'[\s#>*_`~\[\]!|\\]'), '');
  String firstText(md.Node node) {
    if (node is md.Text && node.text.trim().isNotEmpty) {
      return node.text.split('\n').first;
    }
    if (node is md.Element) {
      if (node.tag == 'img') return node.attributes['alt'] ?? '';
      for (final child in node.children ?? <md.Node>[]) {
        final text = firstText(child);
        if (text.isNotEmpty) return text;
      }
    }
    return '';
  }

  final result = <int>[];
  var cursor = 0;
  for (final node in nodes) {
    var needle = normalize(firstText(node));
    if (needle.length > 30) needle = needle.substring(0, 30);
    var found = -1;
    for (var i = cursor; i < lines.length; i++) {
      if (needle.isNotEmpty && normalize(lines[i]).contains(needle)) {
        found = i;
        break;
      }
      if (needle.isEmpty && lines[i].trim().isNotEmpty) {
        found = i;
        break;
      }
    }
    if (found < 0) found = cursor.clamp(0, lines.length - 1);
    var start = found;
    if (node is md.Element &&
        (node.tag == 'pre' ||
            node.tag == 'mermaid' ||
            node.tag == 'math-block')) {
      if (found > cursor &&
          RegExp(r'^\s*(```|~~~|\$\$)').hasMatch(lines[found - 1])) {
        start--;
      }
    }
    result.add(start);
    cursor = found + 1;
  }
  return result;
}

class MarkdownScrollAnchors {
  final keys = <GlobalKey>[];
  final _contentKey = GlobalKey();
  Size? _measuredSize;
  List<({int line, double offset})>? _cachedPositions;
  List<int> lines = [];
  void prepare(List<int> starts) {
    lines = List.of(starts);
    _cachedPositions = null;
    while (keys.length < starts.length) {
      keys.add(GlobalKey());
    }
  }

  List<({int line, double offset})> positions(ScrollController controller) {
    if (!controller.hasClients) return [];
    final content =
        _contentKey.currentContext?.findRenderObject() as RenderBox?;
    final size = content?.hasSize == true ? content!.size : null;
    if (size != null && size == _measuredSize && _cachedPositions != null) {
      return _cachedPositions!;
    }
    final result = <({int line, double offset})>[];
    for (var i = 0; i < lines.length; i++) {
      final render = keys[i].currentContext?.findRenderObject();
      if (render == null || !render.attached) continue;
      final viewport = RenderAbstractViewport.maybeOf(render);
      if (viewport == null) continue;
      result.add((
        line: lines[i],
        offset: viewport.getOffsetToReveal(render, 0).offset,
      ));
    }
    _measuredSize = size;
    _cachedPositions = result;
    return result;
  }
}

class AnchoredMarkdown extends Markdown {
  const AnchoredMarkdown({
    super.key,
    required super.data,
    required this.sourceLines,
    required this.anchors,
    super.controller,
    super.extensionSet,
    super.blockSyntaxes,
    super.inlineSyntaxes,
    super.builders,
    super.onTapLink,
    super.sizedImageBuilder,
    super.selectable,
    super.padding,
    super.styleSheet,
  });
  final List<int> sourceLines;
  final MarkdownScrollAnchors anchors;
  @override
  Widget build(BuildContext context, List<Widget>? children) {
    anchors.prepare(sourceLines);
    // Markdown inserts one spacing widget between top-level blocks.
    return SingleChildScrollView(
      controller: controller,
      padding: padding,
      child: Column(
        key: anchors._contentKey,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < children!.length; i++)
            if (i.isEven && i ~/ 2 < anchors.lines.length)
              KeyedSubtree(key: anchors.keys[i ~/ 2], child: children[i])
            else
              children[i],
        ],
      ),
    );
  }
}

/// Piecewise interpolation aligns corresponding source blocks, not total lengths.
double interpolateScroll(
  double value,
  List<({double source, double target})> anchors,
) {
  if (anchors.isEmpty) return value;
  if (value <= anchors.first.source) return anchors.first.target;
  for (var i = 1; i < anchors.length; i++) {
    final a = anchors[i - 1], b = anchors[i];
    if (value <= b.source) {
      final span = b.source - a.source;
      return span <= 0
          ? b.target
          : a.target + (b.target - a.target) * (value - a.source) / span;
    }
  }
  return anchors.last.target;
}
