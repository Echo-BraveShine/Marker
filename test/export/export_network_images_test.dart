import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:marker/src/export/export_network_images.dart';
import 'package:marker/src/export/document_html.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late HttpOverrides? previousOverrides;
  setUp(() {
    previousOverrides = HttpOverrides.current;
    HttpOverrides.global = null;
  });
  tearDown(() => HttpOverrides.global = previousOverrides);
  test(
    'network images are embedded once and HTML remains usable offline',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      var requests = 0;
      final image = base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAMAAAACCAIAAAASFvFNAAAAFElEQVR4nGM0qfjGAAZMEIqBgQEAHN4BptKOUnYAAAAASUVORK5CYII=',
      );
      final subscription = server.listen((request) async {
        requests++;
        request.response.headers.contentType = ContentType('image', 'png');
        request.response.add(image);
        await request.response.close();
      });
      try {
        final url = 'http://127.0.0.1:${server.port}/photo.png';
        final html = await ExportHtmlBuilder().build(
          source: '![one]($url)\n\n![two]($url)',
          title: 'Network test',
        );
        expect(requests, 1);
        expect(html, contains('data:image/png;base64,${base64Encode(image)}'));
        expect(html, isNot(contains('src="$url"')));
      } finally {
        await subscription.cancel();
        await server.close(force: true);
      }
    },
  );
  test(
    'failed HTTP and oversized images fail instead of producing incomplete exports',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final subscription = server.listen((request) async {
        if (request.uri.path == '/missing') {
          request.response.statusCode = 404;
        } else {
          request.response.contentLength = 1000;
          request.response.add(List.filled(1000, 1));
        }
        await request.response.close();
      });
      try {
        final base = 'http://127.0.0.1:${server.port}';
        await expectLater(
          fetchExportImage(Uri.parse('$base/missing')),
          throwsA(isA<HttpException>()),
        );
        await expectLater(
          fetchExportImage(Uri.parse('$base/large'), maxBytes: 10),
          throwsStateError,
        );
      } finally {
        await subscription.cancel();
        await server.close(force: true);
      }
    },
  );
}
