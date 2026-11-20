import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'offline_html_renderer.dart';

/// Shared offline page for WebView2, WKWebView and the Linux snapshot renderer.
String mermaidHtml(
  String source,
  String script,
  bool dark, {
  bool linux = false,
  String? fontUri,
}) {
  final encoded = jsonEncode(source).replaceAll('<', r'\u003c');
  final fontFace = fontUri == null
      ? ''
      : '@font-face{font-family:MarkerNoto;src:url(${jsonEncode(fontUri)});font-weight:400}';
  return '''<!doctype html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><meta http-equiv="Content-Security-Policy" content="default-src 'none'; script-src 'unsafe-inline'; style-src 'unsafe-inline'; img-src data:; font-src file: data:;"><style>$fontFace html,body{margin:0;background:${dark ? '#2b2b2d' : '#ffffff'}}body{padding:0;box-sizing:border-box;color:${dark ? '#f5f5f7' : '#1d1d1f'};font:14px MarkerNoto,-apple-system,'Segoe UI','Noto Sans CJK SC',sans-serif}#document{padding:12px;box-sizing:border-box}svg{max-width:100%;height:auto}pre{white-space:pre-wrap}</style></head><body><div id="document"></div><script>$script</script><script>
const notify = value => { window.markerExport=value.error?value:{ready:true,width:value.width,height:value.height}; ${linux ? 'window.webkit.messageHandlers.marker.postMessage(value);' : ''} };
(async()=>{try{
mermaid.initialize({${fontUri == null ? '' : "fontFamily:'MarkerNoto, sans-serif',"}startOnLoad:false,securityLevel:'strict',themeVariables:{fontSize:'14px'},theme:'${dark ? 'dark' : 'default'}'});
${fontUri == null ? '' : "await document.fonts.load('400 14px MarkerNoto','中文 ABC');"}
await document.fonts.ready;
const result=await mermaid.render('markerDiagram',$encoded);
const container=document.getElementById('document');
container.innerHTML=result.svg;
const svg=container.querySelector('svg');
if(!svg||!svg.viewBox||svg.viewBox.baseVal.width<=0||svg.viewBox.baseVal.height<=0)throw Error('Diagram has no visible bounds');
const bounds=svg.viewBox.baseVal;
const diagramWidth=Math.min(936,bounds.width);
// Explicit CSS geometry avoids different intrinsic SVG sizing in WebKit/Chromium.
svg.style.width=diagramWidth+'px';
svg.style.height=(bounds.height*diagramWidth/bounds.width)+'px';
svg.style.display='block';
container.style.width=Math.ceil(diagramWidth+24)+'px';
${fontUri == null ? '' : "await document.fonts.load('13px MarkerNoto','中文');if(!document.fonts.check('13px MarkerNoto','中文'))throw Error('Bundled CJK font failed to load');"}
await document.fonts.ready;
setTimeout(()=>notify({width:Math.ceil(container.getBoundingClientRect().width),height:Math.ceil(container.getBoundingClientRect().height)}),100);
}catch(e){const error='Mermaid: '+(e.message||String(e));document.getElementById('document').textContent=error;notify({error});}})();
</script></body></html>''';
}

class MermaidDiagram extends ConsumerStatefulWidget {
  const MermaidDiagram({super.key, required this.source, required this.dark});
  final String source;
  final bool dark;
  static const linuxChannel = MethodChannel('marker/mermaid');
  @override
  ConsumerState<MermaidDiagram> createState() => _MermaidDiagramState();
}

/// One canonical CSS canvas and bundled font make size independent of OS/DPI.
const mermaidCanvasWidth = 960;
final mermaidRenderProvider = Provider<MermaidRenderer>(
  (ref) => MermaidRenderer.shared,
);

class MermaidRenderer {
  static final shared = MermaidRenderer();
  static final _script = rootBundle.loadString('assets/mermaid.min.js');
  static final _fontUri = _loadFont();
  static Future<String> _loadFont() async {
    final data = await rootBundle.load('assets/fonts/NotoSansSC.ttf');
    return 'data:font/ttf;base64,${base64Encode(data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes))}';
  }

  final _cache = <String, Future<Uint8List>>{};
  final _sizes = <String, int>{};
  var _bytes = 0;
  Future<void> _pending = Future<void>.value();
  int get cachedEntries => _cache.length;

  Future<Uint8List> render(String source, bool dark) {
    final key = '${defaultTargetPlatform.name}:$dark:$source';
    final cached = _cache.remove(key);
    if (cached != null) {
      _cache[key] = cached;
      return cached;
    }
    final result = _pending.then((_) => _render(source, dark));
    _cache[key] = result;
    _pending = result.then<void>(
      (data) {
        if (!_cache.containsKey(key)) return;
        _sizes[key] = data.length;
        _bytes += data.length;
        while (_cache.length > 24 ||
            (_bytes > 24 * 1024 * 1024 && _cache.length > 1)) {
          final oldest = _cache.keys.first;
          _cache.remove(oldest);
          _bytes -= _sizes.remove(oldest) ?? 0;
        }
      },
      onError: (Object _, StackTrace _) {
        _cache.remove(key);
      },
    );
    return result;
  }

  Future<Uint8List> _render(String source, bool dark) async {
    final script = await _script;
    final fontUri = await _fontUri;
    final linux = defaultTargetPlatform == TargetPlatform.linux;
    final html = mermaidHtml(
      source,
      script,
      dark,
      linux: linux,
      fontUri: fontUri,
    );
    if (linux) {
      final bytes = await MermaidDiagram.linuxChannel
          .invokeMethod<Uint8List>('render', {
            'html': html,
            'width': mermaidCanvasWidth,
          })
          .timeout(const Duration(seconds: 25));
      if (bytes == null || bytes.isEmpty) {
        throw StateError('Empty diagram image');
      }
      return bytes;
    }
    final directory = await Directory.systemTemp.createTemp('marker-mermaid-');
    try {
      final file = await File(
        '${directory.path}${Platform.pathSeparator}diagram.html',
      ).writeAsString(html);
      return await OfflineHtmlRenderer().render(
        file,
        width: mermaidCanvasWidth,
      );
    } finally {
      await directory.delete(recursive: true);
    }
  }
}

class _MermaidDiagramState extends ConsumerState<MermaidDiagram> {
  Future<Uint8List>? _content;
  String? _request;
  Timer? _debounce;
  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) return const Text('此平台暂不支持 Mermaid 预览');
    final request = '${widget.dark}:${widget.source}';
    if (_request != request) {
      _request = request;
      _debounce?.cancel();
      final renderer = ref.read(mermaidRenderProvider);
      final source = widget.source, dark = widget.dark;
      final completer = Completer<Uint8List>();
      _content = completer.future;
      _debounce = Timer(const Duration(milliseconds: 240), () async {
        try {
          completer.complete(await renderer.render(source, dark));
        } catch (error, stack) {
          completer.completeError(error, stack);
        }
      });
    }
    return FutureBuilder<Uint8List>(
      future: _content,
      builder: (context, snapshot) {
        // Retain the previous image until an edited diagram finishes rendering.
        if (snapshot.hasError) {
          final error = snapshot.error;
          final message = error is PlatformException
              ? error.message ?? error.code
              : error.toString();
          return Padding(
            padding: const EdgeInsets.all(12),
            child: Text('Mermaid 加载失败 / Rendering failed\n$message'),
          );
        }
        final bytes = snapshot.data;
        if (bytes == null) {
          return const SizedBox(
            height: 80,
            child: Center(child: CupertinoActivityIndicator()),
          );
        }
        return Align(
          alignment: Alignment.topLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: RepaintBoundary(
              child: Image.memory(
                bytes,
                fit: BoxFit.contain,
                gaplessPlayback: true,
                alignment: Alignment.topLeft,
                semanticLabel: 'Mermaid diagram',
              ),
            ),
          ),
        );
      },
    );
  }
}
