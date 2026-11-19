import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:pub_semver/pub_semver.dart';

final releasePage = Uri.https(
  'github.com',
  '/Echo-BraveShine/Marker/releases/latest',
);
final repositoryPage = Uri.https('github.com', '/Echo-BraveShine/Marker');

enum ReleaseStatus { idle, checking, current, available, noRelease, error }

enum UpdateError { network, restricted, server, invalidData, version }

typedef ReleaseResult = ({ReleaseStatus status, String? latest, Uri? page});

class ReleaseException implements Exception {
  const ReleaseException(this.kind);
  final UpdateError kind;
}

ReleaseResult compareRelease(String installed, String tag) {
  final current = Version.parse(installed);
  final latest = Version.parse(tag.trim().replaceFirst(RegExp(r'^[vV]'), ''));
  final baseline = Version(
    current.major,
    current.minor,
    current.patch,
    pre: current.preRelease.isEmpty ? null : current.preRelease.join('.'),
  );
  final candidate = Version(
    latest.major,
    latest.minor,
    latest.patch,
    pre: latest.preRelease.isEmpty ? null : latest.preRelease.join('.'),
  );
  return (
    status: candidate > baseline
        ? ReleaseStatus.available
        : ReleaseStatus.current,
    latest: latest.toString(),
    page: Uri.https('github.com', '/Echo-BraveShine/Marker/releases/tag/$tag'),
  );
}

class GitHubReleaseClient {
  GitHubReleaseClient({Uri? endpoint, Uri? fallbackEndpoint})
    : endpoint =
          endpoint ??
          Uri.https(
            'api.github.com',
            '/repos/Echo-BraveShine/Marker/releases/latest',
          ),
      fallbackEndpoint =
          fallbackEndpoint ?? (endpoint == null ? releasePage : null);
  final Uri endpoint;
  final Uri? fallbackEndpoint;

  Future<ReleaseResult> check(String installed) async {
    try {
      Version.parse(installed);
    } on FormatException {
      throw const ReleaseException(UpdateError.version);
    }
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 8)
      ..findProxy = HttpClient.findProxyFromEnvironment;
    try {
      try {
        final result = await _fetch(
          client,
          installed,
        ).timeout(const Duration(seconds: 12));
        if (result.status != ReleaseStatus.noRelease ||
            fallbackEndpoint == null) {
          return result;
        }
      } catch (error) {
        if (fallbackEndpoint == null) rethrow;
        try {
          return await _webRelease(
            client,
            installed,
          ).timeout(const Duration(seconds: 12));
        } catch (_) {
          // Keep the API failure reason when neither public endpoint is reachable.
          throw error;
        }
      }
      return await _webRelease(
        client,
        installed,
      ).timeout(const Duration(seconds: 12));
    } on TimeoutException {
      throw const ReleaseException(UpdateError.network);
    } on IOException {
      throw const ReleaseException(UpdateError.network);
    } on FormatException {
      throw const ReleaseException(UpdateError.invalidData);
    } finally {
      client.close(force: true);
    }
  }

  // GitHub's public redirect is independent of the unauthenticated API quota.
  // Only a repository release tag is accepted; downloaded HTML is never parsed.
  Future<ReleaseResult> _webRelease(HttpClient client, String installed) async {
    var uri = fallbackEndpoint!;
    for (var hop = 0; hop < 5; hop++) {
      final request = await client.getUrl(uri);
      request.followRedirects = false;
      request.headers.set(HttpHeaders.userAgentHeader, 'Marker/$installed');
      final response = await request.close();
      final location = response.headers.value(HttpHeaders.locationHeader);
      final status = response.statusCode;
      // A redirect body is irrelevant and may be large.
      await response.take(0).drain<void>();
      if ([301, 302, 303, 307, 308].contains(status) && location != null) {
        final next = uri.resolve(location);
        if (next.origin != fallbackEndpoint!.origin) {
          throw const ReleaseException(UpdateError.invalidData);
        }
        final segments = next.pathSegments;
        if (segments.length == 5 &&
            segments.take(4).join('/') ==
                'Echo-BraveShine/Marker/releases/tag') {
          return compareRelease(installed, segments.last);
        }
        uri = next;
        continue;
      }
      if (status == 404 || (status == 200 && uri.path.endsWith('/releases'))) {
        return (status: ReleaseStatus.noRelease, latest: null, page: null);
      }
      throw const ReleaseException(UpdateError.server);
    }
    throw const ReleaseException(UpdateError.server);
  }

  Future<ReleaseResult> _fetch(HttpClient client, String installed) async {
    final request = await client.getUrl(endpoint);
    request.headers.set(
      HttpHeaders.acceptHeader,
      'application/vnd.github+json',
    );
    request.headers.set(HttpHeaders.userAgentHeader, 'Marker/$installed');
    request.headers.set('X-GitHub-Api-Version', '2022-11-28');
    final response = await request.close();
    if (response.statusCode == 404) {
      return (status: ReleaseStatus.noRelease, latest: null, page: null);
    }
    if (response.statusCode == 403 || response.statusCode == 429) {
      throw const ReleaseException(UpdateError.restricted);
    }
    if (response.statusCode != 200) {
      throw const ReleaseException(UpdateError.server);
    }
    final bytes = BytesBuilder(copy: false);
    await for (final chunk in response) {
      if (bytes.length + chunk.length > 2 * 1024 * 1024) {
        throw const ReleaseException(UpdateError.invalidData);
      }
      bytes.add(chunk);
    }
    final data = jsonDecode(utf8.decode(bytes.takeBytes()));
    if (data is! Map<String, dynamic> || data['tag_name'] is! String) {
      throw const FormatException('Missing release tag');
    }
    if (data['draft'] == true || data['prerelease'] == true) {
      return (status: ReleaseStatus.noRelease, latest: null, page: null);
    }
    return compareRelease(installed, data['tag_name'] as String);
  }
}
