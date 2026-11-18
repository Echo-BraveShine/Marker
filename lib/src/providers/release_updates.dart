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
  final latest = Version.parse(tag.startsWith('v') ? tag.substring(1) : tag);
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
  GitHubReleaseClient({Uri? endpoint})
    : endpoint =
          endpoint ??
          Uri.https(
            'api.github.com',
            '/repos/Echo-BraveShine/Marker/releases/latest',
          );
  final Uri endpoint;

  Future<ReleaseResult> check(String installed) async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 8);
    try {
      return await _fetch(
        client,
        installed,
      ).timeout(const Duration(seconds: 12));
    } on TimeoutException {
      throw const ReleaseException(UpdateError.network);
    } on SocketException {
      throw const ReleaseException(UpdateError.network);
    } on HandshakeException {
      throw const ReleaseException(UpdateError.network);
    } on FormatException {
      throw const ReleaseException(UpdateError.invalidData);
    } finally {
      client.close(force: true);
    }
  }

  Future<ReleaseResult> _fetch(HttpClient client, String installed) async {
    final request = await client.getUrl(endpoint);
    request.headers.set(
      HttpHeaders.acceptHeader,
      'application/vnd.github+json',
    );
    request.headers.set(HttpHeaders.userAgentHeader, 'Marker/$installed');
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
