import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

/// A total deadline prevents slow streaming servers from keeping exports alive indefinitely.
Future<({Uint8List bytes, String? mime})> fetchExportImage(
  Uri uri, {
  Duration timeout = const Duration(seconds: 30),
  int maxBytes = 25 * 1024 * 1024,
}) async {
  if (!['http', 'https'].contains(uri.scheme)) {
    throw ArgumentError('HTTP image required');
  }
  final client = HttpClient()..connectionTimeout = timeout;
  try {
    return await (() async {
      final request = await client.getUrl(uri);
      final response = await request.close();
      if (response.statusCode != HttpStatus.ok) {
        throw HttpException('Image HTTP ${response.statusCode}', uri: uri);
      }
      if (response.contentLength > maxBytes) {
        throw StateError('Image exceeds 25 MB: $uri');
      }
      final builder = BytesBuilder();
      await for (final chunk in response) {
        builder.add(chunk);
        if (builder.length > maxBytes) {
          throw StateError('Image exceeds 25 MB: $uri');
        }
      }
      return (
        bytes: builder.takeBytes(),
        mime: response.headers.contentType?.mimeType,
      );
    })().timeout(timeout);
  } finally {
    client.close(force: true);
  }
}
