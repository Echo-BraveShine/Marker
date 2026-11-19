import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'document_html.dart';

enum DocumentExportFormat { pdf, png, html }

class DocumentExportOptions {
  const DocumentExportOptions({
    this.format = DocumentExportFormat.pdf,
    this.followTheme = false,
    this.width = 1280,
  });
  final DocumentExportFormat format;
  final bool followTheme;
  final int width;
}

final documentExporterProvider = Provider((ref) => DocumentExporter());
final exportControllerProvider =
    NotifierProvider<ExportController, AsyncValue<void>>(ExportController.new);

class ExportController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);
  Future<Uint8List> export({
    required String source,
    required String title,
    String? documentPath,
    required DocumentExportOptions options,
    required bool dark,
  }) async {
    if (state.isLoading) throw StateError('An export is already running');
    state = const AsyncLoading();
    try {
      final bytes = await ref
          .read(documentExporterProvider)
          .export(
            source: source,
            title: title,
            documentPath: documentPath,
            options: options,
            dark: dark,
          );
      state = const AsyncData(null);
      return bytes;
    } catch (error, stack) {
      state = AsyncError(error, stack);
      rethrow;
    }
  }
}

class DocumentExporter {
  static const channel = MethodChannel('marker/export');
  Future<Uint8List> export({
    required String source,
    required String title,
    String? documentPath,
    required DocumentExportOptions options,
    required bool dark,
  }) async {
    final html = await ExportHtmlBuilder().build(
      source: source,
      title: title,
      documentPath: documentPath,
      dark:
          options.format != DocumentExportFormat.pdf &&
          options.followTheme &&
          dark,
    );
    if (options.format == DocumentExportFormat.html) return utf8.encode(html);
    final temporary = await Directory.systemTemp.createTemp('marker-export-');
    try {
      final file = await File(
        '${temporary.path}${Platform.pathSeparator}document.html',
      ).writeAsString(html);
      final width = options.format == DocumentExportFormat.pdf
          ? 794
          : options.width;
      if (defaultTargetPlatform == TargetPlatform.windows) {
        return await _windows(file, width, options.format);
      }
      final bytes = await channel
          .invokeMethod<Uint8List>('render', {
            'path': file.path,
            'width': width,
            'format': options.format.name,
          })
          .timeout(const Duration(seconds: 90));
      if (bytes == null || bytes.isEmpty) {
        throw StateError('Empty export result');
      }
      return bytes;
    } finally {
      await temporary.delete(recursive: true);
    }
  }

  Future<Uint8List> _windows(
    File file,
    int width,
    DocumentExportFormat format,
  ) async {
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
    final environment = await WebViewEnvironment.create(
      settings: WebViewEnvironmentSettings(userDataFolder: profile.path),
    );
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
      initialUrlRequest: URLRequest(url: WebUri.uri(file.uri)),
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
        disableContextMenu: true,
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
      await view.run();
      final controller = await ready.future.timeout(
        const Duration(seconds: 75),
      );
      dynamic result;
      if (format == DocumentExportFormat.pdf) {
        result = await controller.callDevToolsProtocolMethod(
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
        );
      } else {
        await controller.callDevToolsProtocolMethod(
          methodName: 'Emulation.setDeviceMetricsOverride',
          parameters: {
            'width': width,
            'height': 800,
            'deviceScaleFactor': 1,
            'mobile': false,
          },
        );
        final value = await controller.evaluateJavascript(
          source:
              'Math.ceil(document.getElementById("document").getBoundingClientRect().height)',
        );
        final height = (value as num).ceil();
        if (height < 1 || height > 32768) {
          throw StateError(
            '文档过长，请选择 PDF / Document is too tall for PNG; choose PDF',
          );
        }
        result = await controller.callDevToolsProtocolMethod(
          methodName: 'Page.captureScreenshot',
          parameters: {
            'format': 'png',
            'captureBeyondViewport': true,
            'clip': {
              'x': 0,
              'y': 0,
              'width': width,
              'height': height,
              'scale': 1,
            },
          },
        );
      }
      if (result is! Map || result['data'] is! String) {
        throw StateError('Export data missing');
      }
      return base64Decode(result['data'] as String);
    } finally {
      closed = true;
      await view.dispose();
      await environment.dispose();
    }
  }
}
