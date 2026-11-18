import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:markdown/markdown.dart' as md;

Uri resolveDocumentUri(String value, String? documentPath) {
  final uri = Uri.parse(value);
  if (uri.hasScheme || documentPath == null) return uri;
  return File(documentPath).absolute.uri.resolveUri(uri);
}

class MathInlineSyntax extends md.InlineSyntax {
  MathInlineSyntax() : super(r'\$([^\$\n]+)\$');
  @override
  bool onMatch(md.InlineParser parser, Match match) {
    parser.addNode(md.Element.text('math-inline', match[1]!));
    return true;
  }
}

class MathBlockSyntax extends md.BlockSyntax {
  @override
  RegExp get pattern => RegExp(r'^\s*\$\$');
  @override
  md.Node parse(md.BlockParser parser) {
    final opening = parser.current.content.trim().substring(2);
    parser.advance();
    if (opening.endsWith(r'$$') && opening.length >= 2) {
      return md.Element.text(
        'math-block',
        opening.substring(0, opening.length - 2),
      );
    }
    final lines = <String>[if (opening.isNotEmpty) opening];
    while (!parser.isDone && parser.current.content.trim() != r'$$') {
      lines.add(parser.current.content);
      parser.advance();
    }
    if (!parser.isDone) parser.advance();
    return md.Element.text('math-block', lines.join('\n'));
  }
}

class MermaidSyntax extends md.FencedCodeBlockSyntax {
  @override
  RegExp get pattern => RegExp(r'^ {0,3}(`{3,}|~{3,})mermaid\s*$');
  @override
  md.Node parse(md.BlockParser parser) {
    // Let the standard fence parser handle closing length, indentation and EOF.
    final pre = const md.FencedCodeBlockSyntax().parse(parser) as md.Element;
    return md.Element.text('mermaid', pre.textContent);
  }
}

class MathBuilder extends MarkdownElementBuilder {
  MathBuilder({this.block = false});
  final bool block;
  @override
  bool isBlockElement() => block;
  @override
  Widget? visitText(md.Text text, TextStyle? preferredStyle) =>
      const SizedBox.shrink();
  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    final math = Math.tex(
      element.textContent,
      mathStyle: block ? MathStyle.display : MathStyle.text,
      textStyle: parentStyle,
      onErrorFallback: (error) =>
          Text('公式错误：${element.textContent}', style: parentStyle),
    );
    return block
        ? SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: math,
            ),
          )
        : math;
  }
}

final mermaidPreviewEnabledProvider = Provider<bool>((ref) => true);

class MermaidBuilder extends MarkdownElementBuilder {
  MermaidBuilder({this.enabled = true});
  final bool enabled;
  @override
  Widget? visitText(md.Text text, TextStyle? preferredStyle) =>
      const SizedBox.shrink();
  @override
  bool isBlockElement() => true;
  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) => !enabled
      ? const Text('Mermaid')
      : MermaidDiagram(
          source: element.textContent,
          dark: CupertinoTheme.brightnessOf(context) == Brightness.dark,
        );
}

class MermaidDiagram extends StatelessWidget {
  const MermaidDiagram({super.key, required this.source, required this.dark});
  final String source;
  final bool dark;
  static final Future<String> _script = rootBundle.loadString(
    'assets/mermaid.min.js',
  );
  @override
  Widget build(BuildContext context) {
    if (kIsWeb ||
        ![
          TargetPlatform.macOS,
          TargetPlatform.windows,
          TargetPlatform.iOS,
          TargetPlatform.android,
        ].contains(defaultTargetPlatform)) {
      return const Text('此平台暂不支持 Mermaid 预览');
    }
    return FutureBuilder<String>(
      future: _script,
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Text('Mermaid 加载失败');
        if (!snapshot.hasData) {
          return const SizedBox(
            height: 80,
            child: Center(child: CupertinoActivityIndicator()),
          );
        }
        final html =
            '''<!doctype html><html><head><meta name="viewport" content="width=device-width,initial-scale=1"><meta http-equiv="Content-Security-Policy" content="default-src 'none'; script-src 'unsafe-inline'; style-src 'unsafe-inline'; img-src data:;"><style>body{margin:12px;color:${dark ? '#f5f5f7' : '#1d1d1f'};font:13px -apple-system,sans-serif}svg{max-width:100%;height:auto}pre{white-space:pre-wrap}</style></head><body><div id="diagram"></div><script>${snapshot.data}</script><script>
mermaid.initialize({startOnLoad:false,securityLevel:'strict',theme:'${dark ? 'dark' : 'default'}'});
(async()=>{try{const result=await mermaid.render('markerDiagram',${jsonEncode(source).replaceAll('<', r'\u003c')});document.getElementById('diagram').innerHTML=result.svg;}catch(e){document.getElementById('diagram').textContent='Mermaid: '+e.message;}})();
</script></body></html>''';
        return SizedBox(
          height: 340,
          child: InAppWebView(
            key: ValueKey('$dark:$source'),
            initialData: InAppWebViewInitialData(data: html),
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              disableContextMenu: true,
              transparentBackground: true,
            ),
          ),
        );
      },
    );
  }
}

/// Only recognizes color spans. Other HTML/CSS remains outside the renderer.
class TextColorSyntax extends md.InlineSyntax {
  TextColorSyntax()
    : super(
        r'''<span\s+style\s*=\s*["']\s*color\s*:\s*(#[0-9a-fA-F]{6}|#[0-9a-fA-F]{3}|red|orange|green|blue|purple|gray|black|white)\s*;?\s*["']\s*>([\s\S]*?)</span>''',
      );
  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final element = md.Element.text('text-color', match[2]!);
    element.attributes['color'] = match[1]!;
    parser.addNode(element);
    return true;
  }
}

Color? parseMarkdownColor(String value) {
  const named = {
    'red': 0xFFFF0000,
    'orange': 0xFFFFA500,
    'green': 0xFF008000,
    'blue': 0xFF0000FF,
    'purple': 0xFF800080,
    'gray': 0xFF808080,
    'black': 0xFF000000,
    'white': 0xFFFFFFFF,
  };
  if (named.containsKey(value)) return Color(named[value]!);
  var hex = value.startsWith('#') ? value.substring(1) : '';
  if (!RegExp(r'^(?:[0-9a-fA-F]{3}|[0-9a-fA-F]{6})$').hasMatch(hex)) {
    return null;
  }
  if (hex.length == 3) hex = hex.split('').map((c) => '$c$c').join();
  return Color(int.parse('FF$hex', radix: 16));
}

class TextColorBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    final color = parseMarkdownColor(element.attributes['color'] ?? '');
    final base = (parentStyle ?? const TextStyle()).copyWith(color: color);
    return MarkdownBody(
      data: element.textContent,
      selectable: true,
      shrinkWrap: true,
      styleSheet: MarkdownStyleSheet(
        p: base,
        strong: base.copyWith(fontWeight: FontWeight.bold),
        em: base.copyWith(fontStyle: FontStyle.italic),
        del: base.copyWith(decoration: TextDecoration.lineThrough),
        a: base.copyWith(decoration: TextDecoration.underline),
      ),
    );
  }
}
