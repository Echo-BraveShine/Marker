import 'dart:io';
import 'package:flutter/services.dart';

/// Share read-only resources across diagrams instead of copying 17 MB into each page.
class MermaidAssets {
  MermaidAssets(this.directory);
  final Directory directory;
  String get scriptUri =>
      File('${directory.path}/mermaid.min.js').uri.toString();
  String get fontUri => File('${directory.path}/NotoSansSC.ttf').uri.toString();
  String get koreanFontUri =>
      File('${directory.path}/NotoSansKR.ttf').uri.toString();
  String get latinFontUri =>
      File('${directory.path}/MarkerSans-Regular.ttf').uri.toString();
  static Future<MermaidAssets>? _pending;

  static Future<MermaidAssets> load() =>
      _pending ??= _load().catchError((Object error) {
        _pending = null;
        throw error;
      });

  static Future<MermaidAssets> _load() async {
    final directory = await Directory.systemTemp.createTemp(
      'marker-mermaid-assets-',
    );
    try {
      await Future.wait([
        _write(directory, 'assets/mermaid.min.js', 'mermaid.min.js'),
        _write(directory, 'assets/fonts/NotoSansSC.ttf', 'NotoSansSC.ttf'),
        _write(directory, 'assets/fonts/NotoSansKR.ttf', 'NotoSansKR.ttf'),
        _write(
          directory,
          'assets/fonts/MarkerSans-Regular.ttf',
          'MarkerSans-Regular.ttf',
        ),
      ]);
      return MermaidAssets(directory);
    } catch (_) {
      await directory.delete(recursive: true);
      rethrow;
    }
  }

  static Future<void> _write(
    Directory directory,
    String asset,
    String name,
  ) async {
    final data = await rootBundle.load(asset);
    await File('${directory.path}/$name').writeAsBytes(
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
    );
  }
}
