import 'dart:convert';
import 'dart:io';
import 'dart:typed_data' show BytesBuilder;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:markdown/markdown.dart' as md;
import '../widgets/markdown_extensions.dart';

const _escape = HtmlEscape(HtmlEscapeMode.element);
const _attribute = HtmlEscape(HtmlEscapeMode.attribute);
Uint8List _assetBytes(ByteData data) =>
    data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

class ExportMarkup {
  ExportMarkup(this.body, this.images, this.links);
  final String body;
  final List<String> images;
  final List<String> links;
}

/// Serializes the Markdown AST, escaping raw HTML rather than executing it.
ExportMarkup parseExportMarkup(String source) {
  final document = md.Document(
    encodeHtml: false,
    extensionSet: md.ExtensionSet.gitHubFlavored,
    blockSyntaxes: [MermaidSyntax(), MathBlockSyntax()],
    inlineSyntaxes: [TextColorSyntax(), MathInlineSyntax()],
  );
  final images = <String>[];
  final links = <String>[];
  String render(md.Node node) {
    if (node is md.Text) return _escape.convert(node.textContent);
    if (node is! md.Element) return '';
    final tag = node.tag;
    final content = node.children?.map(render).join() ?? '';
    if (tag == 'mermaid' || tag == 'math-block' || tag == 'math-inline') {
      return '<${tag == 'math-inline' ? 'span' : 'div'} class="$tag">${_escape.convert(node.textContent)}</${tag == 'math-inline' ? 'span' : 'div'}>';
    }
    if (tag == 'text-color') {
      final color = node.attributes['color'] ?? '';
      if (parseMarkdownColor(color) == null) return content;
      final inline = document.parseInline(node.textContent).map(render).join();
      return '<span style="color:${_attribute.convert(color)}">$inline</span>';
    }
    if (tag == 'img') {
      final source = node.attributes['src'] ?? '';
      final id = images.length;
      images.add(source);
      return '<img src="marker-image:$id" alt="${_attribute.convert(node.attributes['alt'] ?? '')}">';
    }
    if (!const {
      'h1',
      'h2',
      'h3',
      'h4',
      'h5',
      'h6',
      'p',
      'blockquote',
      'pre',
      'code',
      'em',
      'strong',
      'del',
      'a',
      'ul',
      'ol',
      'li',
      'hr',
      'br',
      'table',
      'thead',
      'tbody',
      'tr',
      'th',
      'td',
      'input',
      'sup',
      'section',
      'div',
    }.contains(tag)) {
      return content;
    }
    final attributes = <String>[];
    for (final entry in node.attributes.entries) {
      final name = entry.key, value = entry.value;
      if (name == 'id' ||
          name == 'title' ||
          name == 'class' ||
          name == 'start' && int.tryParse(value) != null ||
          name == 'align' &&
              const ['left', 'center', 'right'].contains(value)) {
        attributes.add('$name="${_attribute.convert(value)}"');
      }
      if (tag == 'a' && name == 'href') {
        final uri = Uri.tryParse(value);
        if (uri != null &&
            (!uri.hasScheme ||
                ['http', 'https', 'mailto', 'file'].contains(uri.scheme))) {
          var href = value;
          if (!uri.hasScheme && !value.startsWith('#')) {
            href = 'marker-link:${links.length}';
            links.add(value);
          }
          attributes.add('href="${_attribute.convert(href)}"');
        }
      }
    }
    if (tag == 'input') {
      attributes.add(
        'type="checkbox" disabled ${node.attributes.containsKey('checked') ? 'checked' : ''}',
      );
    }
    return '<$tag${attributes.isEmpty ? '' : ' ${attributes.join(' ')}'}>${const {'img', 'hr', 'br', 'input'}.contains(tag) ? '' : '$content</$tag>'}';
  }

  return ExportMarkup(
    document
        .parseLines(const LineSplitter().convert(source))
        .map(render)
        .join('\n'),
    images,
    links,
  );
}

typedef ExportAssetLoader = Future<ByteData> Function(String key);

class ExportHtmlBuilder {
  ExportHtmlBuilder({ExportAssetLoader? loadAsset})
    : _loadAsset = loadAsset ?? rootBundle.load;
  final ExportAssetLoader _loadAsset;
  Future<String> _string(String key) async =>
      utf8.decode(_assetBytes(await _loadAsset(key)));
  Future<String> build({
    required String source,
    required String title,
    String? documentPath,
    bool dark = false,
  }) async {
    final markup = await compute(parseExportMarkup, source);
    var body = markup.body;
    final embedded = <String, String>{};
    for (var i = 0; i < markup.images.length; i++) {
      final value = markup.images[i];
      final uri = resolveDocumentUri(value, documentPath);
      final image = embedded[value] ??= await _image(uri);
      body = body.replaceAll(
        'src="marker-image:$i"',
        'src="${_attribute.convert(image)}"',
      );
    }
    for (var i = 0; i < markup.links.length; i++) {
      final uri = resolveDocumentUri(markup.links[i], documentPath);
      body = body.replaceAll(
        'href="marker-link:$i"',
        'href="${_attribute.convert(uri.toString())}"',
      );
    }
    final mermaid = await _string('assets/mermaid.min.js');
    final katex = await _string('assets/export/katex.min.js');
    var katexCss = await _string('assets/export/katex.min.css');
    // Modern desktop engines use WOFF2; omit redundant WOFF/TTF fallbacks.
    katexCss = katexCss.replaceAllMapped(RegExp(r'src:([^;}]+)'), (m) {
      final woff = RegExp(
        r'url\(([^)]+\.woff2)\)\s*format\("woff2"\)',
      ).firstMatch(m[1]!);
      return woff == null ? m[0]! : 'src:${woff[0]}';
    });
    final fonts = RegExp(
      r'url\((fonts/[^)]+\.woff2)\)',
    ).allMatches(katexCss).map((m) => m[1]!).toSet();
    for (final font in fonts) {
      final data = await _loadAsset('assets/export/$font');
      katexCss = katexCss.replaceAll(
        'url($font)',
        'url(data:font/woff2;base64,${base64Encode(_assetBytes(data))})',
      );
    }
    final licenses = <String, String>{};
    for (final name in [
      'assets/export/katex-LICENSE',
      'assets/export/katex-fonts-LICENSE.txt',
      'assets/export/marker-fonts-OFL.txt',
      'assets/mermaid.LICENSE',
    ]) {
      licenses[name] = await _string(name);
    }
    final licenseMetadata = jsonEncode(licenses).replaceAll('<', r'\u003c');
    final faces = StringBuffer();
    for (final family in ['Latin', 'CJK']) {
      for (final style in ['Regular', 'Bold']) {
        final data = await _loadAsset(
          'assets/export/fonts/Marker$family-$style.woff2',
        );
        faces.write(
          '@font-face{font-family:MarkerExportFont;font-weight:${style == 'Bold' ? 700 : 400};src:url(data:font/woff2;base64,${base64Encode(_assetBytes(data))});${family == 'CJK' ? 'unicode-range:U+2E80-D7AF,U+F900-FFEF,U+20000-2FA1F;' : ''}}',
        );
      }
    }
    final css =
        '''$faces
html,body{margin:0;background:${dark ? '#1c1c1e' : '#fff'};color:${dark ? '#f5f5f7' : '#1d1d1f'}}
body{font:16px/1.7 MarkerExportFont,-apple-system,sans-serif;font-variant-ligatures:none}article{box-sizing:border-box;max-width:1100px;margin:auto;padding:36px}
h1,h2,h3,h4,h5,h6{line-height:1.35;margin:1.3em 0 .6em;font-weight:700;break-after:avoid}h1{font-size:32px}h2{font-size:26px}h3{font-size:22px}h4{font-size:19px}h5{font-size:17px}h6{font-size:16px}
p{margin:.7em 0}a{color:${dark ? '#64b5ff' : '#06c'};text-decoration:none}img,svg{max-width:100%;height:auto}img{display:block;margin:12px 0;break-inside:avoid}
pre,code{font-family:ui-monospace,Menlo,Consolas,MarkerExportFont,monospace;font-size:.88em}code{background:${dark ? '#2c2c2e' : '#f5f5f7'};padding:2px 4px;border-radius:4px}pre{white-space:pre-wrap;overflow-wrap:anywhere;padding:16px;background:${dark ? '#2c2c2e' : '#f5f5f7'};border-radius:10px}pre code{padding:0;background:none}
blockquote{margin:16px 0;padding:2px 16px;border-left:3px solid #b0b0b8;color:${dark ? '#c5c5cb' : '#6e6e73'}}table{border-collapse:collapse;width:100%;font-size:.9em}th,td{border:1px solid ${dark ? '#48484a' : '#d1d1d6'};padding:8px 12px;text-align:left}th{background:${dark ? '#2c2c2e' : '#f5f5f7'}}tr{break-inside:avoid}td[align=right],th[align=right]{text-align:right}td[align=center],th[align=center]{text-align:center}hr{border:0;border-top:1px solid #aaa;margin:24px 0}.mermaid,.math-block{margin:16px 0;break-inside:avoid}.math-block{text-align:center}.math-inline{display:inline}input{accent-color:#06c}li{margin:3px 0}sup{line-height:0}
@page{size:A4;margin:18mm}@media print{html,body{background:#fff;color:#1d1d1f}body{font-size:11.5pt}article{padding:0;max-width:none}p{orphans:3;widows:3}pre{border:1px solid #ddd}.mermaid svg{max-height:240mm}a{color:#06c}}
''';
    String script(String value) => value.replaceAll(
      RegExp('</script', caseSensitive: false),
      r'<\/script',
    );
    return '''<!doctype html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><meta http-equiv="Content-Security-Policy" content="default-src 'none';script-src 'unsafe-inline';style-src 'unsafe-inline';img-src data:;font-src data:;connect-src 'none';"><title>${_escape.convert(title)}</title><style>$katexCss\n$css</style></head><body><article id="document">$body</article><script type="application/json" id="marker-third-party">$licenseMetadata</script><script>${script(katex)}</script><script>${script(mermaid)}</script><script>
window.markerExport={ready:false};
// Native PDF pagination uses actual line boxes, keeping text and figures intact.
window.markerExportBreaks=pageHeight=>{
const article=document.getElementById('document'),origin=article.getBoundingClientRect().top,protectedRanges=[];
const add=rect=>{if(rect.height>0&&rect.height<pageHeight*.95)protectedRanges.push([rect.top-origin,rect.bottom-origin]);};
const walker=document.createTreeWalker(article,NodeFilter.SHOW_TEXT);let node;
while(node=walker.nextNode()){if(node.parentElement.closest('style,script,.katex-mathml'))continue;const range=document.createRange();range.selectNodeContents(node);for(const rect of range.getClientRects())add(rect);}
for(const element of article.querySelectorAll('img,.mermaid,.math-block,tr,h1,h2,h3,h4,h5,h6'))add(element.getBoundingClientRect());
protectedRanges.sort((a,b)=>a[0]-b[0]);const merged=[];
for(const range of protectedRanges){const last=merged[merged.length-1];if(last&&range[0]<last[1])last[1]=Math.max(last[1],range[1]);else merged.push(range);}
const total=Math.ceil(article.getBoundingClientRect().height),cuts=[0];let start=0;
while(start+pageHeight<total){let cut=start+pageHeight;const hit=merged.find(range=>range[0]<cut&&range[1]>cut);if(hit&&hit[0]>start+1)cut=hit[0];cuts.push(cut);start=cut;}cuts.push(total);return cuts;
};
const notify=value=>{window.markerExport=value;if(window.webkit?.messageHandlers?.marker)window.webkit.messageHandlers.marker.postMessage(value);};
(async()=>{try{
mermaid.initialize({startOnLoad:false,securityLevel:'strict',theme:'${dark ? 'dark' : 'default'}',fontFamily:'MarkerExportFont,sans-serif'});
await document.fonts.load('16px MarkerExportFont','中文Aa');
for(const node of document.querySelectorAll('.math-inline,.math-block')){katex.render(node.textContent,node,{displayMode:node.classList.contains('math-block'),throwOnError:true,trust:false,strict:'ignore'});}
let id=0;for(const node of document.querySelectorAll('.mermaid')){const result=await mermaid.render('markerExport'+id++,node.textContent);node.innerHTML=result.svg;}
await Promise.all(Array.from(document.images).map(img=>img.decode()));await document.fonts.ready;
setTimeout(()=>notify({ready:true,height:Math.ceil(document.getElementById('document').getBoundingClientRect().height)}),100);
}catch(e){notify({error:String(e.message||e).slice(0,800)});}})();
</script></body></html>''';
  }

  Future<String> _image(Uri uri) async {
    if (uri.scheme == 'data' &&
        RegExp(
          r'^data:image/(?:png|jpeg|gif|webp|svg\+xml);base64,',
        ).hasMatch(uri.toString())) {
      return uri.toString();
    }
    Uint8List bytes;
    String mime;
    if (uri.scheme == 'file') {
      bytes = await File.fromUri(uri).readAsBytes();
      mime = _mime(uri.path);
    } else if (uri.scheme == 'https' || uri.scheme == 'http') {
      final client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 15);
      try {
        final response = await (await client.getUrl(
          uri,
        )).close().timeout(const Duration(seconds: 20));
        if (response.statusCode != 200) {
          throw HttpException('Image HTTP ${response.statusCode}', uri: uri);
        }
        final builder = BytesBuilder();
        await for (final chunk in response.timeout(
          const Duration(seconds: 20),
        )) {
          builder.add(chunk);
          if (builder.length > 25 * 1024 * 1024) {
            throw StateError('Image exceeds 25 MB: $uri');
          }
        }
        bytes = builder.takeBytes();
        mime = response.headers.contentType?.mimeType ?? _mime(uri.path);
      } finally {
        client.close(force: true);
      }
    } else {
      throw StateError(
        '图片路径无法解析，请先保存文档 / Save the document to resolve image: $uri',
      );
    }
    if (bytes.length > 25 * 1024 * 1024 || !mime.startsWith('image/')) {
      throw StateError('Unsupported image: $uri');
    }
    return 'data:$mime;base64,${base64Encode(bytes)}';
  }

  String _mime(String path) => switch (path.toLowerCase().split('.').last) {
    'jpg' || 'jpeg' => 'image/jpeg',
    'gif' => 'image/gif',
    'webp' => 'image/webp',
    'svg' => 'image/svg+xml',
    _ => 'image/png',
  };
}
