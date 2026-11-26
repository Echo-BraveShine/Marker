import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:archive/archive.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

const mobilePdfChannel = MethodChannel('marker/mobilePdf');

/// Mobile rendering waits for the same fonts/images/Mermaid readiness as desktop.
Future<Uint8List> renderMobileHtml(
  File file,
  int width, {
  bool pdf = false,
  bool splitPng = false,
}) async {
  final ready = Completer<PlatformInAppWebViewController>();
  // Observe early native failures even if view.run() has not returned yet.
  unawaited(
    ready.future.then<void>((_) {}, onError: (Object _, StackTrace _) {}),
  );
  var closed = false, disposed = false, polling = false;
  final params = PlatformHeadlessInAppWebViewCreationParams(
    initialSize: Size(width.toDouble(), 1024),
    initialUrlRequest: URLRequest(url: WebUri.uri(file.uri)),
    initialSettings: InAppWebViewSettings(
      javaScriptEnabled: true,
      transparentBackground: true,
      allowFileAccess: true,
      allowFileAccessFromFileURLs: true,
      allowingReadAccessTo: WebUri.uri(file.parent.uri),
    ),
    onLoadStop: (controller, url) async {
      if (polling || closed) return;
      polling = true;
      try {
        while (!closed && !ready.isCompleted) {
          final value = await controller.evaluateJavascript(
            source: 'window.markerExport',
          );
          if (value is Map && value['error'] != null) {
            throw StateError(value['error'].toString());
          }
          if (value is Map && value['ready'] == true) {
            ready.complete(controller);
            break;
          }
          await Future<void>.delayed(const Duration(milliseconds: 100));
        }
      } catch (error, stack) {
        if (!ready.isCompleted) ready.completeError(error, stack);
      }
    },
    onReceivedError: (controller, request, error) {
      if (request.isForMainFrame != false && !ready.isCompleted) {
        ready.completeError(StateError(error.description));
      }
    },
  );
  final view = PlatformHeadlessInAppWebView(params);
  try {
    await view.run().timeout(const Duration(seconds: 20));
    final controller = await ready.future.timeout(const Duration(seconds: 90));
    if (pdf) {
      final html = await controller.evaluateJavascript(
        source:
            '''(()=>{const root=document.documentElement.cloneNode(true);root.querySelectorAll('script').forEach(n=>n.remove());const style=document.createElement('style');style.textContent='@page{size:A4;margin:${Platform.isAndroid ? '18mm' : '0'}!important}html{-webkit-print-color-adjust:exact;print-color-adjust:exact}';root.querySelector('head').appendChild(style);return '<!doctype html>'+root.outerHTML;})()''',
      );
      if (html is! String || html.isEmpty) {
        throw StateError('Missing printable document');
      }
      closed = true;
      await view.dispose();
      disposed = true;
      try {
        final bytes = await mobilePdfChannel
            .invokeMethod<Uint8List>('render', {'html': html})
            .timeout(const Duration(seconds: 95));
        if (bytes == null || bytes.isEmpty) throw StateError('Empty PDF');
        return bytes;
      } finally {
        await mobilePdfChannel.invokeMethod<void>('cancel');
      }
    }
    final dimensions = await controller.evaluateJavascript(
      source:
          '''(()=>{const d=document.getElementById('document'),r=d.getBoundingClientRect();return {width:d.tagName==='ARTICLE'?window.innerWidth:Math.ceil(r.width),height:Math.ceil(r.bottom+window.scrollY)};})()''',
    );
    if (dimensions is! Map) throw StateError('Missing render dimensions');
    final height = (dimensions['height'] as num).ceil();
    final imageWidth = (dimensions['width'] as num).ceil().clamp(1, width);
    final bands = mobileImageBands(imageWidth, height, split: splitPng);
    final archive = Archive();
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    final images = <ui.Image>[];
    var compressedSize = 0;
    try {
      for (var i = 0; i < bands.length; i++) {
        final band = bands[i];
        await controller.evaluateJavascript(
          source: 'window.scrollTo(0,${band.top});',
        );
        await Future<void>.delayed(const Duration(milliseconds: 80));
        final scroll = await controller.evaluateJavascript(
          source: 'window.scrollY',
        );
        final offset = band.top - (scroll as num).toDouble();
        final bytes = await controller
            .takeScreenshot(
              screenshotConfiguration: ScreenshotConfiguration(
                rect: InAppWebViewRect(
                  x: 0,
                  // Android Canvas uses document coordinates; WKWebView uses viewport coordinates.
                  y: Platform.isAndroid ? band.top.toDouble() : offset,
                  width: imageWidth.toDouble(),
                  height: band.height.toDouble(),
                ),
                snapshotWidth: imageWidth.toDouble(),
              ),
            )
            .timeout(const Duration(seconds: 20));
        if (bytes == null || bytes.isEmpty) {
          throw StateError('Empty image tile');
        }
        final codec = await ui.instantiateImageCodec(
          bytes,
          targetWidth: imageWidth,
          targetHeight: band.height,
        );
        late ui.FrameInfo frame;
        try {
          frame = await codec.getNextFrame();
        } finally {
          codec.dispose();
        }
        if (splitPng) {
          late Uint8List tile;
          try {
            final data = await frame.image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            if (data == null) throw StateError('Cannot encode image tile');
            tile = data.buffer.asUint8List(
              data.offsetInBytes,
              data.lengthInBytes,
            );
          } finally {
            frame.image.dispose();
          }
          compressedSize += tile.length;
          if (compressedSize > 64 * 1024 * 1024) {
            throw StateError('Split images exceed 64 MB / 分图总量超过 64 MB');
          }
          archive.addFile(
            ArchiveFile(
              'page-${(i + 1).toString().padLeft(3, '0')}.png',
              tile.length,
              tile,
            ),
          );
        } else {
          images.add(frame.image);
          canvas.drawImageRect(
            frame.image,
            ui.Rect.fromLTWH(
              0,
              0,
              frame.image.width.toDouble(),
              frame.image.height.toDouble(),
            ),
            ui.Rect.fromLTWH(
              0,
              band.top.toDouble(),
              imageWidth.toDouble(),
              band.height.toDouble(),
            ),
            ui.Paint(),
          );
        }
      }
      if (splitPng) return Uint8List.fromList(ZipEncoder().encode(archive));
      final picture = recorder.endRecording();
      try {
        final image = await picture.toImage(imageWidth, height);
        try {
          final data = await image.toByteData(format: ui.ImageByteFormat.png);
          if (data == null) throw StateError('Cannot encode PNG');
          return data.buffer.asUint8List(
            data.offsetInBytes,
            data.lengthInBytes,
          );
        } finally {
          image.dispose();
        }
      } finally {
        picture.dispose();
      }
    } finally {
      if (recorder.isRecording) recorder.endRecording().dispose();
      for (final image in images) {
        image.dispose();
      }
    }
  } finally {
    closed = true;
    if (!disposed) await view.dispose();
  }
}

/// Fixed viewport-sized tiles avoid allocating an enormous native WebView.
List<({int top, int height})> mobileImageBands(
  int width,
  int height, {
  bool split = false,
}) {
  if (width < 1 || height < 1 || height > 200000) {
    throw StateError('Invalid image size / 文档过长');
  }
  if (!split && (height > 32768 || width * height > 16000000)) {
    throw StateError(
      'Document too large for one PNG. Enable Split images (ZIP) / 文档过长，请选择分图导出（ZIP）',
    );
  }
  return [
    for (var top = 0; top < height; top += 1024)
      (top: top, height: (height - top).clamp(1, 1024)),
  ];
}
