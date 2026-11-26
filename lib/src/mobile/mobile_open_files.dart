import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final mobileOpenFilesProvider = Provider((ref) => MobileOpenFiles());

class MobileOpenFile {
  const MobileOpenFile({
    required this.token,
    this.path,
    this.error,
    this.ownedRelativePath,
  });
  final String token;
  final String? path, error, ownedRelativePath;
  static List<MobileOpenFile> decode(dynamic value) {
    if (value is! List) return [];
    return [
      for (final item in value)
        if (item is Map &&
            item['token'] is String &&
            (item['path'] is String || item['error'] is String))
          MobileOpenFile(
            token: item['token'] as String,
            path: item['path'] is String ? item['path'] as String : null,
            error: item['error'] is String ? item['error'] as String : null,
            ownedRelativePath: item['ownedRelativePath'] is String
                ? item['ownedRelativePath'] as String
                : null,
          ),
    ];
  }
}

/// Native code copies authorized URLs/URIs into private staging before delivery.
/// Acknowledgement releases only that native staging file, never the source.
class MobileOpenFiles {
  static const channel = MethodChannel('marker/mobileFiles');
  bool _connected = false;
  Future<void> connect(void Function(List<MobileOpenFile>) receive) async {
    _connected = true;
    channel.setMethodCallHandler((call) async {
      if (_connected && call.method == 'openFiles') {
        receive(MobileOpenFile.decode(call.arguments));
      }
    });
    try {
      final files = await channel.invokeMethod<dynamic>('start');
      if (_connected) receive(MobileOpenFile.decode(files));
    } on MissingPluginException {
      // Embedded widget previews have no native activity or scene.
    }
  }

  Future<void> acknowledge(String token) =>
      channel.invokeMethod<void>('ack', token);
  Future<void> disconnect() async {
    _connected = false;
    channel.setMethodCallHandler(null);
    try {
      await channel.invokeMethod<void>('stop');
    } on MissingPluginException {
      /* No native scene in widget previews. */
    } on PlatformException {
      /* The activity/engine may already have stopped. */
    }
  }
}
