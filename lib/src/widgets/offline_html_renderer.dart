import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:path_provider/path_provider.dart';

/// Serial hidden rendering shared by document export and diagram previews.
class OfflineHtmlRenderer {
  static const channel = MethodChannel('marker/export');
  static Future<void> _pending = Future<void>.value();
  static Future<WebViewEnvironment>? _environment;

  Future<Uint8List> render(File file, {required int width, bool pdf = false}) {
    final result = _pending.then((_) async {
      if (defaultTargetPlatform == TargetPlatform.windows) {
        return _windows(file, width, pdf);
      }
      final bytes = await channel
          .invokeMethod<Uint8List>('render', {
            'path': file.path,
            'width': width,
            'format': pdf ? 'pdf' : 'png',
          })
          .timeout(const Duration(seconds: 90));
      if (bytes == null || bytes.isEmpty) {
        throw StateError('Empty render result');
      }
      return bytes;
    });
    _pending = result.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return result;
  }

  Future<Uint8List> _windows(File file, int width, bool pdf) async {
    if (await WebViewEnvironment.getAvailableVersion() == null) {
      throw StateError(
        '请安装 Microsoft Edge WebView2 Runtime / WebView2 Runtime is required',
      );
    }
    final support = await getApplicationSupportDirectory();
    final profile = Directory(
      '${support.path}${Platform.pathSeparator}ExportWebView2',
    );
    await profile.create(recursive: true);
    final environment = await (_environment ??=
        WebViewEnvironment.create(
          settings: WebViewEnvironmentSettings(userDataFolder: profile.path),
        ).catchError((Object error) {
          _environment = null;
          throw error;
        }));
    final ready = Completer<InAppWebViewController>();
    var closed = false;
    var polling = false;
    Future<void> poll(InAppWebViewController controller) async {
      if (polling || closed || ready.isCompleted) return;
      polling = true;
      try {
        while (!closed && !ready.isCompleted) {
          final status = await controller.evaluateJavascript(
            source: 'window.markerExport',
          );
          if (status is Map && status['error'] != null) {
            throw StateError(status['error'].toString());
          }
          if (status is Map && status['ready'] == true) {
            ready.complete(controller);
            return;
          }
          await Future<void>.delayed(const Duration(milliseconds: 80));
        }
      } catch (error, stack) {
        if (!ready.isCompleted) ready.completeError(error, stack);
      }
    }

    final view = HeadlessInAppWebView(
      webViewEnvironment: environment,
      initialSize: Size(width.toDouble(), 800),
      initialUrlRequest: URLRequest(url: WebUri('about:blank')),
      onWebViewCreated: (controller) async {
        try {
          // Set CSS geometry before Mermaid lays out width-dependent diagrams.
          await controller.callDevToolsProtocolMethod(
            methodName: 'Emulation.setDeviceMetricsOverride',
            parameters: {
              'width': width,
              'height': 800,
              'deviceScaleFactor': 1,
              'mobile': false,
            },
          );
          await controller.loadUrl(
            urlRequest: URLRequest(url: WebUri.uri(file.uri)),
          );
        } catch (error, stack) {
          if (!ready.isCompleted) ready.completeError(error, stack);
        }
      },
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
        disableContextMenu: true,
        transparentBackground: true,
      ),
      onLoadStop: (controller, url) async {
        if (url?.scheme == 'file') await poll(controller);
      },
      onReceivedError: (controller, request, error) {
        if (request.isForMainFrame != false && !ready.isCompleted) {
          ready.completeError(StateError(error.description));
        }
      },
    );
    try {
      await view.run().timeout(const Duration(seconds: 30));
      final controller = await ready.future.timeout(
        const Duration(seconds: 75),
      );
      dynamic result;
      if (pdf) {
        result = await controller
            .callDevToolsProtocolMethod(
              methodName: 'Page.printToPDF',
              parameters: {
                'printBackground': true,
                'displayHeaderFooter': false,
                'preferCSSPageSize': true,
                'paperWidth': 8.2677165354,
                'paperHeight': 11.6929133858,
                'marginTop': .70866,
                'marginBottom': .70866,
                'marginLeft': .70866,
                'marginRight': .70866,
              },
            )
            .timeout(const Duration(seconds: 30));
      } else {
        final value = await controller.evaluateJavascript(
          source:
              '({width:Math.ceil(window.markerExport.width||document.getElementById("document").getBoundingClientRect().width),height:Math.ceil(document.getElementById("document").getBoundingClientRect().height)})',
        );
        final height = ((value as Map)['height'] as num).ceil();
        final imageWidth = (value['width'] as num).ceil().clamp(1, width);
        if (height < 1 || height > 32768) {
          throw StateError(
            '文档过长，请选择 PDF / Document is too tall for PNG; choose PDF',
          );
        }
        result = await controller
            .callDevToolsProtocolMethod(
              methodName: 'Page.captureScreenshot',
              parameters: {
                'format': 'png',
                'captureBeyondViewport': true,
                'clip': {
                  'x': 0,
                  'y': 0,
                  'width': imageWidth,
                  'height': height,
                  'scale': 1,
                },
              },
            )
            .timeout(const Duration(seconds: 30));
      }
      if (result is! Map || result['data'] is! String) {
        throw StateError('Export data missing');
      }
      final bytes = base64Decode(result['data'] as String);
      if (bytes.isEmpty) throw StateError('Empty export result');
      return bytes;
    } finally {
      closed = true;
      await view.dispose();
    }
  }
}
