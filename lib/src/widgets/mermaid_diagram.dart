import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:path_provider/path_provider.dart';

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
  return '''<!doctype html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><meta http-equiv="Content-Security-Policy" content="default-src 'none'; script-src 'unsafe-inline'; style-src 'unsafe-inline'; img-src data:; font-src file: data:;"><style>$fontFace html,body{margin:0;background:transparent}body{padding:12px;box-sizing:border-box;color:${dark ? '#f5f5f7' : '#1d1d1f'};font:13px -apple-system,'Segoe UI','Noto Sans CJK SC',sans-serif}svg{max-width:100%;height:auto}pre{white-space:pre-wrap}</style></head><body><div id="diagram"></div><script>$script</script><script>
const notify = value => { ${linux ? 'window.webkit.messageHandlers.marker.postMessage(value);' : ''} };
(async()=>{try{
mermaid.initialize({${fontUri == null ? '' : "fontFamily:'MarkerNoto, sans-serif',"}startOnLoad:false,securityLevel:'strict',theme:'${dark ? 'dark' : 'default'}'});
const result=await mermaid.render('markerDiagram',$encoded);
document.getElementById('diagram').innerHTML=result.svg;
${fontUri == null ? '' : "await document.fonts.load('13px MarkerNoto','中文');if(!document.fonts.check('13px MarkerNoto','中文'))throw Error('Bundled CJK font failed to load');"}
await document.fonts.ready;
setTimeout(()=>notify({height:Math.ceil(document.getElementById('diagram').getBoundingClientRect().height+24)}),100);
}catch(e){const error='Mermaid: '+(e.message||String(e));document.getElementById('diagram').textContent=error;notify({error});}})();
</script></body></html>''';
}

class MermaidDiagram extends StatefulWidget {
  const MermaidDiagram({super.key, required this.source, required this.dark});
  final String source;
  final bool dark;
  static const linuxChannel = MethodChannel('marker/mermaid');
  @override
  State<MermaidDiagram> createState() => _MermaidDiagramState();
}

class _MermaidDiagramState extends State<MermaidDiagram> {
  static final Future<String> _script = rootBundle.loadString(
    'assets/mermaid.min.js',
  );
  static Future<WebViewEnvironment>? _windowsEnvironment;
  Future<Object>? _content;
  String? _request;
  final List<Directory> _pages = [];

  @override
  void dispose() {
    for (final directory in _pages) {
      unawaited(directory.delete(recursive: true).catchError((_) => directory));
    }
    super.dispose();
  }

  static Future<WebViewEnvironment> _createWindowsEnvironment() async {
    final available = await WebViewEnvironment.getAvailableVersion();
    if (available == null) {
      throw StateError(
        '需要安装 Microsoft Edge WebView2 Runtime / WebView2 Runtime is required',
      );
    }
    final support = await getApplicationSupportDirectory();
    final directory = Directory(
      '${support.path}${Platform.pathSeparator}MermaidWebView2',
    );
    await directory.create(recursive: true);
    return WebViewEnvironment.create(
      settings: WebViewEnvironmentSettings(userDataFolder: directory.path),
    );
  }

  Future<Object> _load(int width) async {
    final request = _request!;
    if (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux) {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      if (!mounted || _request != request) {
        throw StateError('Mermaid preview changed');
      }
    }
    final source = widget.source;
    final dark = widget.dark;
    final script = await _script;
    if (!mounted || _request != request) {
      throw StateError('Mermaid preview changed');
    }
    final linux = defaultTargetPlatform == TargetPlatform.linux;
    final font = File(
      '${File(Platform.resolvedExecutable).parent.path}/data/flutter_assets/assets/fonts/NotoSansSC.ttf',
    );
    final html = mermaidHtml(
      source,
      script,
      dark,
      linux: linux,
      fontUri: linux && font.existsSync() ? font.uri.toString() : null,
    );
    if (linux) {
      final bytes = await MermaidDiagram.linuxChannel.invokeMethod<Uint8List>(
        'render',
        {'html': html, 'width': width},
      );
      if (bytes == null || bytes.isEmpty) {
        throw StateError('Mermaid 返回空图片 / Empty diagram image');
      }
      return bytes;
    }
    WebViewEnvironment? environment;
    if (defaultTargetPlatform == TargetPlatform.windows) {
      try {
        environment = await (_windowsEnvironment ??=
            _createWindowsEnvironment());
      } catch (_) {
        _windowsEnvironment = null;
        rethrow;
      }
    }
    Uri? file;
    if (defaultTargetPlatform == TargetPlatform.windows) {
      // NavigateToString is limited to 2 MB; the offline Mermaid bundle is 3.3 MB.
      final directory = await Directory.systemTemp.createTemp(
        'marker-mermaid-',
      );
      final page = await File(
        '${directory.path}${Platform.pathSeparator}diagram.html',
      ).writeAsString(html);
      if (!mounted || _request != request) {
        await directory.delete(recursive: true);
        throw StateError('Mermaid preview closed');
      }
      _pages.add(directory);
      file = page.uri;
    }
    return (html: html, environment: environment, file: file, request: request);
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) return const Text('此平台暂不支持 Mermaid 预览');
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.hasBoundedWidth
            ? constraints.maxWidth.round().clamp(240, 2048)
            : 960;
        final request = '${widget.dark}:$width:${widget.source}';
        if (_request != request) {
          _request = request;
          _content = _load(width);
        }
        return FutureBuilder<Object>(
          future: _content,
          builder: (context, snapshot) {
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
            final content = snapshot.data;
            if (content == null) {
              return const SizedBox(
                height: 80,
                child: Center(child: CupertinoActivityIndicator()),
              );
            }
            if (content is Uint8List) {
              return Image.memory(
                content,
                width: width.toDouble(),
                fit: BoxFit.contain,
                alignment: Alignment.topLeft,
                semanticLabel: 'Mermaid diagram',
              );
            }
            final page =
                content
                    as ({
                      String html,
                      WebViewEnvironment? environment,
                      Uri? file,
                      String request,
                    });
            return SizedBox(
              height: 340,
              child: InAppWebView(
                key: ValueKey(page.request),
                webViewEnvironment: page.environment,
                onLoadStop: (controller, url) async {
                  // Retain only the current page; long edits must not accumulate HTML files.
                  final obsolete = _pages
                      .take(_pages.length > 1 ? _pages.length - 1 : 0)
                      .toList();
                  _pages.removeWhere(obsolete.contains);
                  for (final directory in obsolete) {
                    try {
                      await directory.delete(recursive: true);
                    } on FileSystemException catch (_) {
                      /* WebView may still release the old file. */
                    }
                  }
                },
                initialUrlRequest: page.file == null
                    ? null
                    : URLRequest(url: WebUri.uri(page.file!)),
                initialData: page.file == null
                    ? InAppWebViewInitialData(data: page.html)
                    : null,
                initialSettings: InAppWebViewSettings(
                  javaScriptEnabled: true,
                  disableContextMenu: true,
                  transparentBackground: true,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
