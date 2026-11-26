import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'export_network_images.dart';
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
    bool freezeAnimations = true,
  }) async {
    final markup = await compute(parseExportMarkup, source);
    var body = markup.body;
    final embedded = <String, String>{};
    var embeddedLength = 0;
    for (var i = 0; i < markup.images.length; i++) {
      final value = markup.images[i];
      final uri = resolveDocumentUri(value, documentPath);
      final image = embedded[value] ??= await _image(
        uri,
        freezeAnimations: freezeAnimations,
      );
      embeddedLength += image.length;
      if (embeddedLength > 128 * 1024 * 1024) {
        throw StateError('图片总量过大 / Embedded images exceed 128 MB');
      }
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
    final monoFont = await _loadAsset(
      'assets/export/fonts/KaTeX_Typewriter-Regular.woff2',
    );
    faces.write(
      '@font-face{font-family:MarkerExportMono;src:url(data:font/woff2;base64,${base64Encode(_assetBytes(monoFont))});}',
    );
    final css =
        '''$faces
${freezeAnimations ? '*{animation:none!important;transition:none!important}' : ''}
html,body{margin:0;background:${dark ? '#1c1c1e' : '#fff'};color:${dark ? '#f5f5f7' : '#1d1d1f'}}
body{font:16px/1.7 MarkerExportFont,-apple-system,sans-serif;font-variant-ligatures:none}article{display:flow-root;overflow-wrap:anywhere;box-sizing:border-box;max-width:1100px;margin:auto;padding:clamp(24px,4vw,48px)}article>:first-child{margin-top:0}article>:last-child{margin-bottom:0}
h1,h2,h3,h4,h5,h6{line-height:1.35;margin:1.3em 0 .6em;font-weight:700;break-after:avoid}h1{font-size:32px}h2{font-size:26px}h3{font-size:22px}h4{font-size:19px}h5{font-size:17px}h6{font-size:16px}
p{margin:.7em 0}a{color:${dark ? '#64b5ff' : '#06c'};text-decoration:none}img,svg{max-width:100%;height:auto;box-sizing:border-box}img{object-fit:contain}img{display:block;margin:12px 0;break-inside:avoid}
pre,code{font-family:MarkerExportMono,MarkerExportFont,monospace;font-size:.88em}code{background:${dark ? '#2c2c2e' : '#f5f5f7'};padding:2px 4px;border-radius:4px}pre{white-space:pre-wrap;overflow-wrap:anywhere;padding:16px;background:${dark ? '#2c2c2e' : '#f5f5f7'};border-radius:10px}pre code{padding:0;background:none}
blockquote{margin:16px 0;padding:2px 16px;border-left:3px solid #b0b0b8;color:${dark ? '#c5c5cb' : '#6e6e73'}}table{table-layout:fixed;border-collapse:collapse;width:100%;font-size:.9em}th,td{box-sizing:border-box;overflow-wrap:anywhere;word-break:normal;min-width:0;border:1px solid ${dark ? '#48484a' : '#d1d1d6'};padding:8px 12px;text-align:left}th{background:${dark ? '#2c2c2e' : '#f5f5f7'}}tr{break-inside:avoid}td[align=right],th[align=right]{text-align:right}td[align=center],th[align=center]{text-align:center}hr{border:0;border-top:1px solid #aaa;margin:24px 0}.mermaid,.math-block{margin:16px 0;break-inside:avoid}.math-block{text-align:center;max-width:100%;overflow:hidden}.math-block>.katex-display{max-width:100%;margin:0}.mermaid{max-width:100%;box-sizing:border-box;overflow:hidden}pre,table,blockquote{max-width:100%;box-sizing:border-box}.math-inline{display:inline}input{accent-color:#06c}li{margin:3px 0}sup{line-height:0}.footnotes{font-size:.9em;border-top:1px solid #aaa;margin-top:24px;padding-top:8px}.footnotes p{margin:.4em 0}.footnote-ref{font-size:.75em;vertical-align:super}.footnote-backref{margin-left:4px}
@page{size:A4;margin:18mm}@media print{html,body{background:#fff;color:#1d1d1f}body{font-size:11.5pt}article{padding:0;max-width:none}p{orphans:3;widows:3}pre{break-inside:avoid;page-break-inside:avoid}table,blockquote,li,.footnotes{break-inside:auto;page-break-inside:auto}thead{display:table-header-group}img{max-height:240mm;object-fit:contain}pre{border:1px solid #ddd}.mermaid svg{max-height:240mm}a{color:#06c}}
''';
    String script(String value) => value.replaceAll(
      RegExp('</script', caseSensitive: false),
      r'<\/script',
    );
    return '''<!doctype html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><meta http-equiv="Content-Security-Policy" content="default-src 'none';script-src 'unsafe-inline';style-src 'unsafe-inline';img-src data:;font-src data:;connect-src 'none';"><title>${_escape.convert(title)}</title><style>$katexCss\n$css</style></head><body><article id="document">$body</article><script type="application/json" id="marker-third-party">$licenseMetadata</script><script>${script(katex)}</script><script>${script(mermaid)}</script><script>
window.markerExport={ready:false};
// Coordinates are document-relative, matching WKPDFConfiguration.rect. Using
// article-relative offsets drops the final lines when top margins collapse.
// TOP-DOWN GREEDY PAGINATION: Walk units in source order, filling pages without
// retroactive movement. Never combine heading chains with following content.
window.markerExportBreaks=pageHeight=>{
if(!Number.isFinite(pageHeight)||pageHeight<64)throw Error('Invalid PDF page height');
const article=document.getElementById('document');
const isHeading=node=>/^H[1-6]\$/.test(node.tagName);
// Build ordered non-overlapping layout units from article.children.
// Headings are atomic; paragraphs/tables/images are atomic; oversized content
// splits into lines (or table rows) as needed. NEVER combine a sequence of headings
// with a whole following paragraph/image. Treat headings individually.
const units=[];
// Normalize tagName to uppercase for HTML elements.
const upperTag=(el)=>el.tagName.toUpperCase();
// Collect line-level rectangles from text/content for oversized blocks.
// Returns merged/contiguous line rectangles.
const collectLines=(element)=>{
const walker=document.createTreeWalker(element,NodeFilter.SHOW_TEXT);
let node;
while(node=walker.nextNode()){
if(node.parentElement.closest('style,script,.katex,.math-block,.mermaid'))continue;
const range=document.createRange();
range.selectNodeContents(node);
for(const rect of range.getClientRects()){
if(rect.height>0&&rect.height<pageHeight-2){
// Merge vertically overlapping/colliding lines into one continuous unit.
let merged=units.find(u=>Math.abs(u.start-rect.top)<2);
if(merged){
merged.end=Math.max(merged.end,rect.bottom);
}else{
units.push({type:'line',start:rect.top,end:rect.bottom});
}
}
}
}
};
// Walk DOM in document order, collecting layout units.
const walkElement=(element)=>{
const rect=element.getBoundingClientRect();
if(rect.height<=0)return;
const tag=upperTag(element);
// RULE 1: If fits on page, push atomic unit and RETURN (no recursion).
if(rect.height<=pageHeight-2){
if(tag==='H1'||tag==='H2'||tag==='H3'||tag==='H4'||tag==='H5'||tag==='H6'){
units.push({type:'heading',start:rect.top,end:rect.bottom});
}else{
units.push({type:'block',start:rect.top,end:rect.bottom});
}
return;
}
// RULE 2: Oversized blocks with children recurse children, then return.
if(tag==='TABLE'||tag==='THEAD'||tag==='TBODY'||tag==='TFOOT'||
   tag==='UL'||tag==='OL'||tag==='BLOCKQUOTE'||tag==='SECTION'||
   tag==='DIV'||tag==='ARTICLE'){
// Oversized table expands to rows; oversized paragraph/blockquote etc expands to lines.
for(const child of element.children){
walkElement(child);
}
return;
}
// RULE 3: All other oversized elements use collectLines (actual Range.getClientRects).
collectLines(element);
};
// Walk article's direct children in source order.
for(const child of article.children){
walkElement(child);
}
// Sort units by start position (source order is already document order, but sort for safety)
units.sort((a,b)=>a.start-b.start);
// Filter to unique, non-overlapping units in document order.
const filtered=[];
let lastEnd=-1;
for(const u of units){
if(u.end<=u.start||u.end<=lastEnd)continue;
if(u.start>=lastEnd){
filtered.push(u);
lastEnd=u.end;
}
}
// WALK IN SOURCE ORDER: greedy page filling.
const total=Math.max(1,Math.ceil(article.getBoundingClientRect().bottom));
const cuts=[0];
let start=0;
let i=0;
while(start+pageHeight<total){
const limit=Math.floor(start+pageHeight);
// Skip units that are fully before current page.
while(i<filtered.length&&filtered[i].end<=start)i++;
// Find where this page should end by consuming fitting units.
let cut=limit;
while(i<filtered.length){
const unit=filtered[i];
// If unit starts after current page end, we're done with this page.
if(unit.start>=cut)break;
// Check if unit fits entirely within current page.
if(unit.end<=limit){
// Unit fits entirely, skip past it.
i++;
}
else{
// Unit would overflow: cut immediately before this unit.
cut=Math.floor(unit.start);
break;
}
}
// Ensure minimum page height (32px) and positive progress.
if(cut-start<32)cut=limit;
if(cut<=start)cut=limit;
// Ensure cut is at least 1px past start.
if(cut<=start+0.5)cut=Math.max(start+1,limit);
cuts.push(cut);
start=cut;
}
cuts.push(total);
return cuts;
};
const notify=value=>{window.markerExport=value;if(window.webkit?.messageHandlers?.marker)window.webkit.messageHandlers.marker.postMessage(value);};
(async()=>{try{
mermaid.initialize({startOnLoad:false,securityLevel:'strict',theme:'${dark ? 'dark' : 'default'}',fontFamily:'MarkerExportFont,sans-serif',flowchart:{useMaxWidth:false,htmlLabels:false},sequence:{useMaxWidth:false},gantt:{useMaxWidth:false},themeVariables:{fontFamily:'MarkerExportFont,sans-serif',fontSize:'16px'}});
await Promise.all([document.fonts.load('16px MarkerExportFont','中文Aa'),document.fonts.load('700 16px MarkerExportFont','中文Aa'),document.fonts.load('16px MarkerExportMono','Aa0123')]);await document.fonts.ready;
for(const node of document.querySelectorAll('.math-inline,.math-block')){katex.render(node.textContent,node,{displayMode:node.classList.contains('math-block'),throwOnError:true,trust:false,strict:'ignore'});}
let id=0;for(const node of document.querySelectorAll('.mermaid')){
const code=node.textContent;
node.style.width='960px';node.style.maxWidth='none';
const result=await mermaid.render('markerExport'+id++,code,node);
node.innerHTML=result.svg;node.style.width='';node.style.maxWidth='';
const svg=node.querySelector('svg');if(svg){
const box=svg.viewBox.baseVal;
const natural=box&&box.width>0?box.width:960;
svg.removeAttribute('height');svg.setAttribute('width',String(Math.min(natural,960)));
svg.style.width=Math.min(natural,960)+'px';svg.style.maxWidth='100%';svg.style.height='auto';svg.style.display='block';svg.style.margin='0 auto';
}}

await Promise.all(Array.from(document.images).map(img=>img.decode()));await document.fonts.ready;
for(const node of document.querySelectorAll('.math-block')){
const formula=node.querySelector('.katex');if(!formula)continue;
const available=node.clientWidth,actual=formula.getBoundingClientRect().width;
if(actual>available&&available>0){const scale=available/actual;formula.style.display='inline-block';formula.style.transformOrigin='left top';formula.style.transform='scale('+scale+')';node.style.height=(formula.getBoundingClientRect().height+8)+'px';}
}
setTimeout(()=>notify({ready:true,width:Math.ceil(window.innerWidth),height:Math.ceil(document.getElementById('document').getBoundingClientRect().height)}),100);
}catch(e){notify({error:String(e.message||e).slice(0,800)});}})();
</script></body></html>''';
  }

  Future<String> _image(Uri uri, {required bool freezeAnimations}) async {
    Uint8List bytes;
    String mime;
    if (uri.scheme == 'data' &&
        RegExp(
          r'^data:image/(?:png|jpeg|gif|webp|svg\+xml);base64,',
        ).hasMatch(uri.toString())) {
      if (uri.toString().length > 35 * 1024 * 1024) {
        throw StateError('图片超过 25 MB / Image exceeds 25 MB');
      }
      final data = uri.data!;
      bytes = data.contentAsBytes();
      mime = data.mimeType;
    } else if (uri.scheme == 'file') {
      final file = File.fromUri(uri);
      if (await file.length() > 25 * 1024 * 1024) {
        throw StateError('图片超过 25 MB / Image exceeds 25 MB: $uri');
      }
      bytes = await file.readAsBytes();
      mime = _mime(uri.path);
    } else if (uri.scheme == 'https' || uri.scheme == 'http') {
      final downloaded = await fetchExportImage(uri);
      bytes = downloaded.bytes;
      mime = downloaded.mime?.startsWith('image/') == true
          ? downloaded.mime!
          : _mime(uri.path);
    } else {
      throw StateError(
        '图片路径无法解析，请先保存文档 / Save the document to resolve image: $uri',
      );
    }
    if (bytes.length > 25 * 1024 * 1024 || !mime.startsWith('image/')) {
      throw StateError('Unsupported image: $uri');
    }
    if (freezeAnimations &&
        (mime == 'image/gif' || mime == 'image/webp' || _animatedPng(bytes))) {
      // PDF and PNG are still formats. Freezing frame zero avoids WebKit's
      // native PDF conversion hanging on animated GIF image providers.
      final codec = await ui.instantiateImageCodec(bytes);
      try {
        final frame = await codec.getNextFrame();
        try {
          final png = await frame.image.toByteData(
            format: ui.ImageByteFormat.png,
          );
          if (png == null) throw StateError('Cannot freeze animated image');
          bytes = png.buffer.asUint8List(png.offsetInBytes, png.lengthInBytes);
          mime = 'image/png';
        } finally {
          frame.image.dispose();
        }
      } finally {
        codec.dispose();
      }
    }
    return 'data:$mime;base64,${base64Encode(bytes)}';
  }

  bool _animatedPng(Uint8List bytes) {
    if (bytes.length < 8 ||
        bytes[0] != 137 ||
        bytes[1] != 80 ||
        bytes[2] != 78 ||
        bytes[3] != 71) {
      return false;
    }
    final data = ByteData.sublistView(bytes);
    var offset = 8;
    while (offset + 12 <= bytes.length) {
      final length = data.getUint32(offset);
      final type = data.getUint32(offset + 4);
      if (type == 0x6163544c) return true; // acTL precedes animated PNG data.
      if (type == 0x49444154) {
        return false; // IDAT: remaining chunks cannot add animation.
      }
      offset += length + 12;
    }
    return false;
  }

  String _mime(String path) => switch (path.toLowerCase().split('.').last) {
    'jpg' || 'jpeg' => 'image/jpeg',
    'gif' => 'image/gif',
    'webp' => 'image/webp',
    'svg' => 'image/svg+xml',
    _ => 'image/png',
  };
}
