import 'dart:convert';
import 'dart:isolate';
import 'package:markdown/markdown.dart' as md;

/// Offsets refer to the original UTF-16 Markdown, never regenerated HTML.
class ImageReference {
  const ImageReference({
    required this.start,
    required this.end,
    required this.source,
    required this.alt,
    required this.rawAlt,
    this.title,
  });
  final int start, end;
  final String source, alt, rawAlt;
  final String? title;
  bool get network =>
      Uri.tryParse(source)?.scheme == 'http' ||
      Uri.tryParse(source)?.scheme == 'https';
  String markdown(String path) =>
      '![$rawAlt](<$path>${title == null ? '' : ' "${title!.replaceAll(r'\', r'\\').replaceAll('"', r'\"')}"'})';
}

class ResourceReferences {
  const ResourceReferences(
    this.images,
    this.unsupported, [
    this.links = const [],
  ]);
  final List<ImageReference> images;
  final List<String> unsupported;
  final List<String> links;
  String rewrite(String source, Map<String, String> replacements) {
    var result = source;
    for (final image in images.reversed) {
      final replacement = replacements[image.source];
      if (replacement != null) {
        result = result.replaceRange(
          image.start,
          image.end,
          image.markdown(replacement),
        );
      }
    }
    return result;
  }
}

Future<ResourceReferences> parseResourceReferencesAsync(String source) =>
    Isolate.run(() => parseResourceReferences(source));

ResourceReferences parseResourceReferences(String source) {
  final tracked = <ImageReference>[];
  final syntax = _TrackedImages(tracked, source);
  final document = md.Document(
    encodeHtml: false,
    extensionSet: md.ExtensionSet.gitHubFlavored,
    inlineSyntaxes: [syntax],
  );
  final nodes = document.parseLines(const LineSplitter().convert(source));
  // The block pass populates reference definitions. Track inline offsets against
  // the untouched source separately; code/HTML/definitions are masked first.
  tracked.clear();
  md.InlineParser(_maskBlocks(source), document).parse();
  final actual = <String, int>{};
  var hasHtmlImage = false;
  final links = <String>[];
  void visit(md.Node node) {
    if (node is md.Element) {
      if (node.tag == 'code' || node.tag == 'pre') return;
      if (node.tag == 'a' && node.attributes['href'] != null) {
        links.add(node.attributes['href']!);
      }
      if (node.tag == 'img') {
        final key = '${node.attributes['src']}\u0000${node.attributes['alt']}';
        actual[key] = (actual[key] ?? 0) + 1;
      }
      for (final child in node.children ?? <md.Node>[]) {
        visit(child);
      }
    } else if (node is md.Text &&
        RegExp(
          r'<img\b',
          caseSensitive: false,
        ).hasMatch(node.text.replaceAll(RegExp(r'<!--[\s\S]*?-->'), ''))) {
      hasHtmlImage = true;
    }
  }

  for (final node in nodes) {
    visit(node);
  }
  final images = <ImageReference>[];
  final warnings = <String>[];
  tracked.sort((a, b) => a.start.compareTo(b.start));
  for (final image in tracked) {
    final key = '${image.source}\u0000${image.alt}';
    if ((actual[key] ?? 0) == 0) continue;
    if (images.isNotEmpty && image.start < images.last.end) {
      warnings.add(image.source);
      continue;
    }
    images.add(image);
    actual[key] = actual[key]! - 1;
  }
  for (final entry in actual.entries) {
    if (entry.value > 0) warnings.add(entry.key.split('\u0000').first);
  }
  if (hasHtmlImage) warnings.add('HTML <img>');
  return ResourceReferences(images, warnings.toSet().toList(), links);
}

class _TrackedImages extends md.ImageSyntax {
  _TrackedImages(this.references, this.original);
  final List<ImageReference> references;
  final String original;
  @override
  Iterable<md.Node>? close(
    md.InlineParser parser,
    covariant md.SimpleDelimiter opener,
    md.Delimiter? closer, {
    String? tag,
    required List<md.Node> Function() getChildren,
  }) {
    final closing = parser.pos;
    final result = super
        .close(parser, opener, closer, tag: tag, getChildren: getChildren)
        ?.toList();
    final start = opener.endPos - opener.length;
    for (final node in result ?? <md.Node>[]) {
      if (node is md.Element &&
          node.tag == 'img' &&
          start >= 0 &&
          parser.pos < original.length) {
        references.add(
          ImageReference(
            start: start,
            end: parser.pos + 1,
            source: node.attributes['src']!,
            alt: node.attributes['alt'] ?? '',
            rawAlt: original.substring(opener.endPos, closing),
            title: node.attributes['title'],
          ),
        );
      }
    }
    return result;
  }
}

String _maskBlocks(String source, {bool maskHtml = true}) {
  String? fence;
  var fenceLength = 0;
  var html = false;
  var comment = false;
  final output = StringBuffer();
  for (final match in RegExp(r'[^\r\n]*(?:\r\n|\r|\n|$)').allMatches(source)) {
    final line = match[0]!;
    if (line.isEmpty) continue;
    final plain = line
        .replaceFirst(RegExp(r'^\s*(?:>\s*)+'), '')
        .replaceFirst(RegExp(r'^ {0,3}(?:[-+*]|\d+[.)]) '), '');
    var masked = false;
    if (fence != null) {
      masked = true;
      if (RegExp(
        '^\\s*${RegExp.escape(fence)}{$fenceLength,}\\s*\$',
      ).hasMatch(plain.trimRight())) {
        fence = null;
      }
    } else {
      final open = RegExp(r'^ {0,3}(`{3,}|~{3,})').firstMatch(plain);
      if (open != null) {
        fence = open[1]![0];
        fenceLength = open[1]!.length;
        masked = true;
      }
    }
    if (masked) {
      output.write(line.replaceAll(RegExp(r'[^\r\n]'), ' '));
      continue;
    }
    if (plain.contains('<!--')) comment = true;
    if (comment) {
      masked = true;
      if (plain.contains('-->')) comment = false;
    }
    if (maskHtml &&
        RegExp(
          r'^\s*<(?:div|table|pre|script|style|section|details|p)(?:\s|>)',
          caseSensitive: false,
        ).hasMatch(plain)) {
      html = true;
    }
    if (html && maskHtml) {
      masked = true;
      if (plain.trim().isEmpty ||
          RegExp(
            r'</(?:div|table|pre|script|style|section|details|p)>',
            caseSensitive: false,
          ).hasMatch(plain)) {
        html = false;
      }
    }
    if (RegExp(r'^(?: {4}|\t)|^ {0,3}\[[^\]]+\]:').hasMatch(plain)) {
      masked = true;
    }
    // Inline HTML extensions are conservatively reported rather than rewritten.
    if (maskHtml &&
        RegExp(r'<(?:img|span)\b', caseSensitive: false).hasMatch(plain)) {
      masked = true;
    }
    output.write(masked ? line.replaceAll(RegExp(r'[^\r\n]'), ' ') : line);
  }
  return output.toString();
}
