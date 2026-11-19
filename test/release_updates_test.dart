import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:marker/src/providers/release_updates.dart';

void main() {
  test(
    'compares semantic versions without treating build numbers as releases',
    () {
      expect(compareRelease('1.0.0+8', 'v1.0.0').status, ReleaseStatus.current);
      expect(
        compareRelease('1.0.0', 'v1.10.0').status,
        ReleaseStatus.available,
      );
      expect(compareRelease('2.0.0', 'v1.9.0').status, ReleaseStatus.current);
      expect(
        compareRelease('1.1.0-beta.1', 'v1.1.0').status,
        ReleaseStatus.available,
      );
      expect(
        compareRelease('1.0.0', 'v1.1.0').page.toString(),
        'https://github.com/Echo-BraveShine/Marker/releases/tag/v1.1.0',
      );
    },
  );

  Future<GitHubReleaseClient> server(int status, Object body) async {
    final http = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() => http.close(force: true));
    http.listen((request) async {
      expect(
        request.headers.value(HttpHeaders.userAgentHeader),
        startsWith('Marker/'),
      );
      request.response.statusCode = status;
      request.response.headers.contentType = ContentType.json;
      request.response.write(jsonEncode(body));
      await request.response.close();
    });
    return GitHubReleaseClient(
      endpoint: Uri.parse('http://127.0.0.1:${http.port}/latest'),
    );
  }

  test(
    'reads a release and constructs a trusted repository download page',
    () async {
      final client = await server(200, {
        'tag_name': 'v1.2.0',
        'html_url': 'https://untrusted.test',
      });
      final result = await client.check('1.0.0');
      expect(result.status, ReleaseStatus.available);
      expect(result.page!.host, 'github.com');
    },
  );
  test('empty release history is a normal no-release result', () async {
    expect(
      (await (await server(404, {})).check('1.0.0')).status,
      ReleaseStatus.noRelease,
    );
  });
  test('draft and prerelease responses are not offered', () async {
    for (final flag in ['draft', 'prerelease']) {
      final client = await server(200, {'tag_name': 'v2.0.0-beta', flag: true});
      expect((await client.check('1.0.0')).status, ReleaseStatus.noRelease);
    }
  });
  test(
    'restricted, server and malformed responses report useful errors',
    () async {
      for (final (status, body, kind) in [
        (403, <String, dynamic>{}, UpdateError.restricted),
        (429, <String, dynamic>{}, UpdateError.restricted),
        (500, <String, dynamic>{}, UpdateError.server),
        (200, <String, dynamic>{'tag_name': 12}, UpdateError.invalidData),
        (200, <String, dynamic>{'tag_name': 'wrong'}, UpdateError.invalidData),
      ]) {
        final client = await server(status, body);
        await expectLater(
          client.check('1.0.0'),
          throwsA(isA<ReleaseException>().having((e) => e.kind, 'kind', kind)),
        );
      }
    },
  );
  test(
    'API rate limits fall back to the trusted public release redirect',
    () async {
      final http = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(() => http.close(force: true));
      final paths = <String>[];
      http.listen((request) async {
        paths.add(request.uri.path);
        if (request.uri.path == '/api') {
          request.response.statusCode = 403;
        } else {
          request.response.statusCode = 302;
          request.response.headers.set(
            HttpHeaders.locationHeader,
            '/Echo-BraveShine/Marker/releases/tag/v1.3.0',
          );
        }
        await request.response.close();
      });
      final origin = 'http://127.0.0.1:${http.port}';
      final client = GitHubReleaseClient(
        endpoint: Uri.parse('$origin/api'),
        fallbackEndpoint: Uri.parse('$origin/latest'),
      );
      final result = await client.check('1.2.0');
      expect(result.status, ReleaseStatus.available);
      expect(result.latest, '1.3.0');
      expect(result.page!.host, 'github.com');
      expect(paths, ['/api', '/latest']);
    },
  );

  test('bad installed version is distinct from bad release data', () async {
    await expectLater(
      GitHubReleaseClient().check('unknown'),
      throwsA(
        isA<ReleaseException>().having(
          (e) => e.kind,
          'kind',
          UpdateError.version,
        ),
      ),
    );
  });

  test('fallback refuses a redirect outside the repository', () async {
    final http = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() => http.close(force: true));
    http.listen((request) async {
      request.response.statusCode = request.uri.path == '/api' ? 429 : 302;
      request.response.headers.set(
        HttpHeaders.locationHeader,
        'https://untrusted.test/releases/tag/v9.0.0',
      );
      await request.response.close();
    });
    final origin = 'http://127.0.0.1:${http.port}';
    await expectLater(
      GitHubReleaseClient(
        endpoint: Uri.parse('$origin/api'),
        fallbackEndpoint: Uri.parse('$origin/latest'),
      ).check('1.0.0'),
      throwsA(
        isA<ReleaseException>().having(
          (e) => e.kind,
          'kind',
          UpdateError.restricted,
        ),
      ),
    );
  });
}
