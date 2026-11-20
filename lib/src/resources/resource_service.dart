import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';
import 'package:archive/archive_io.dart';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'resource_references.dart';

const resourceImageExtensions = ['png', 'jpg', 'jpeg', 'gif', 'webp', 'bmp'];
const _manifestName = '.marker-resources.json';

class ResourceCancelled implements Exception {}

class ResourceFailure implements Exception {
  const ResourceFailure(this.zh, this.en);
  final String zh, en;
  @override
  String toString() => en;
}

class ResourceCancellation {
  bool _cancelled = false;
  final _listeners = <void Function()>[];
  bool get cancelled => _cancelled;
  set cancelled(bool value) {
    if (_cancelled || !value) return;
    _cancelled = true;
    for (final listener in _listeners.toList()) {
      listener();
    }
  }

  void listen(void Function() listener) {
    _listeners.add(listener);
    if (_cancelled) listener();
  }

  void unlisten(void Function() listener) => _listeners.remove(listener);
  void check() {
    if (_cancelled) throw ResourceCancelled();
  }
}

class ResourceProgress {
  const ResourceProgress(this.done, this.total, this.name);
  final int done, total;
  final String name;
}

class ResourceInput {
  const ResourceInput({required this.name, this.path, this.bytes});
  final String name;
  final String? path;
  final Uint8List? bytes;
}

class ManagedImage {
  const ManagedImage(this.path, this.reference, this.name, this.created);
  final String path, reference, name;
  final bool created;
}

enum ResourceAvailability { local, remote, missing, denied, unsupported }

class ResourceItem {
  const ResourceItem(
    this.source,
    this.alt,
    this.availability, {
    this.path,
    this.size = 0,
    this.managed = false,
  });
  final String source, alt;
  final ResourceAvailability availability;
  final String? path;
  final int size;
  final bool managed;
}

class ResourceInventory {
  const ResourceInventory(this.items, this.unsupported);
  final List<ResourceItem> items;
  final List<String> unsupported;
  int get totalBytes => items.fold(0, (sum, item) => sum + item.size);
  List<ResourceItem> get unresolved => items
      .where(
        (i) => ![
          ResourceAvailability.local,
          ResourceAvailability.remote,
        ].contains(i.availability),
      )
      .toList();
}

class ResourceIssue {
  const ResourceIssue(this.source, this.reason, {this.chinese});
  final String source, reason;
  final String? chinese;
}

class ResourceIncomplete extends ResourceFailure {
  ResourceIncomplete(this.issues)
    : super(
        '部分图片无法复制，原文件保持不变。',
        'Some images could not be copied. Original files were kept.',
      );
  final List<ResourceIssue> issues;
}

class ResourceResult {
  const ResourceResult(this.text, this.images, this.issues);
  final String text;
  final List<ManagedImage> images;
  final List<ResourceIssue> issues;
}

class ResourceDraft {
  const ResourceDraft(this.path, this.text);
  final String? path;
  final String text;
}

class UnusedResource {
  const UnusedResource(this.path, this.name, this.size, this.digest);
  final String path, name, digest;
  final int size;
}

Uri resolveResourceUri(
  String source,
  String? documentPath, {
  bool preserveDecorations = false,
}) {
  var decoded = source;
  try {
    decoded = Uri.decodeFull(source);
  } catch (_) {}
  if (RegExp(r'^[a-zA-Z]:[\\/]').hasMatch(decoded) ||
      decoded.startsWith(r'\\')) {
    return Uri.file(decoded, windows: true);
  }
  var uri = Uri.parse(source);
  if (!uri.hasScheme && documentPath != null) {
    uri = File(documentPath).absolute.uri.resolveUri(uri);
  }
  if (uri.scheme == 'file' && !preserveDecorations) {
    uri = Uri(scheme: 'file', host: uri.host, path: uri.path);
  }
  return uri;
}

String resourceReference(String filePath, String documentPath) {
  final relative = p.relative(filePath, from: p.dirname(documentPath));
  if (p.isAbsolute(relative)) return File(filePath).uri.toString();
  return Uri(pathSegments: p.split(relative)).toString();
}

String imageMarkdown(String alt, String source) =>
    '![${alt.replaceAll(r'\', r'\\').replaceAll('[', r'\[').replaceAll(']', r'\]')}](<$source>)';

class DocumentResourceService {
  DocumentResourceService({this.validateImage});
  final Future<void> Function(Uint8List)? validateImage;
  final _directoryCache =
      <String, ({int modified, int size, Directory directory})>{};
  Future<Directory> _rememberDirectory(
    String key,
    FileStat stat,
    Directory directory,
  ) async {
    _directoryCache.remove(key);
    _directoryCache[key] = (
      modified: stat.modified.microsecondsSinceEpoch,
      size: stat.size,
      directory: directory,
    );
    if (_directoryCache.length > 64) {
      _directoryCache.remove(_directoryCache.keys.first);
    }
    return directory;
  }

  static const maxImageBytes = 50 * 1024 * 1024;
  String _token() =>
      '${DateTime.now().microsecondsSinceEpoch}-${Random.secure().nextInt(1 << 30)}';
  String _stem(String path) => p.basenameWithoutExtension(path);
  String _safeName(String input) {
    var name = p
        .basename(input)
        .replaceAll(RegExp(r'[\x00-\x1f<>:"/\\|?*]'), '-')
        .trim()
        .replaceAll(RegExp(r'[. ]+$'), '');
    if (name.isEmpty ||
        RegExp(
          r'^(con|prn|aux|nul|com\d|lpt\d)(?:\.|$)',
          caseSensitive: false,
        ).hasMatch(name)) {
      name = 'image-$name';
    }
    if (name.length > 100) {
      name =
          '${String.fromCharCodes(p.basenameWithoutExtension(name).runes.take(48))}${p.extension(name)}';
    }
    return name;
  }

  Future<String> _digest(File file) async =>
      (await sha256.bind(file.openRead()).first).toString();

  Future<void> _plainDirectory(Directory directory) async {
    final type = await FileSystemEntity.type(
      directory.path,
      followLinks: false,
    );
    if (type == FileSystemEntityType.link ||
        (type != FileSystemEntityType.notFound &&
            type != FileSystemEntityType.directory)) {
      throw const ResourceFailure(
        '资源目录不可用，请选择其他保存位置。',
        'The resource directory is not a regular directory.',
      );
    }
  }

  Future<Map<String, dynamic>?> _readManifest(Directory directory) async {
    final file = File(p.join(directory.path, _manifestName));
    if (await FileSystemEntity.type(file.path, followLinks: false) !=
        FileSystemEntityType.file) {
      return null;
    }
    try {
      final data =
          jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      if (data['schema'] != 1 ||
          data['files'] is! Map ||
          data['owner'] is! String) {
        return null;
      }
      return data;
    } catch (_) {
      return null;
    }
  }

  Future<Directory> resourceDirectory(String documentPath) async {
    final key = p.absolute(documentPath);
    final stat = await File(documentPath).stat();
    final cached = _directoryCache[key];
    if (cached != null &&
        cached.modified == stat.modified.microsecondsSinceEpoch &&
        cached.size == stat.size) {
      await _plainDirectory(cached.directory);
      final record = await _readManifest(cached.directory);
      if (!await cached.directory.exists() ||
          record?['owner'] == p.basename(documentPath)) {
        return cached.directory;
      }
    }
    final parent = p.dirname(p.absolute(documentPath));
    // A renamed document or an overwritten standalone copy may already refer
    // to an owned directory whose name differs from its current stem.
    try {
      final saved = await File(documentPath).readAsString();
      for (final image in (await parseResourceReferencesAsync(saved)).images) {
        final uri = resolveResourceUri(image.source, documentPath);
        if (uri.scheme != 'file') continue;
        final directory = File.fromUri(uri).parent;
        if (!p.equals(p.dirname(directory.absolute.path), parent)) continue;
        await _plainDirectory(directory);
        final record = await _readManifest(directory);
        if (record?['owner'] == p.basename(documentPath)) {
          return _rememberDirectory(key, stat, directory);
        }
      }
    } catch (_) {
      /* Missing documents have no prior resource location. */
    }

    for (var i = 1; i < 10000; i++) {
      final candidate = Directory(
        p.join(parent, '${_stem(documentPath)}.assets${i == 1 ? '' : '-$i'}'),
      );
      await _plainDirectory(candidate);
      if (!await candidate.exists()) {
        return _rememberDirectory(key, stat, candidate);
      }
      final record = await _readManifest(candidate);
      if ((record == null &&
              !await File(p.join(candidate.path, _manifestName)).exists()) ||
          record?['owner'] == p.basename(documentPath)) {
        return _rememberDirectory(key, stat, candidate);
      }
    }
    throw const ResourceFailure(
      '找不到可用的资源目录名称。',
      'No available resource directory name.',
    );
  }

  Future<File> _uniqueFile(Directory directory, String name) async {
    final existing = {
      await for (final entity in directory.list())
        p.basename(entity.path).toLowerCase(),
    };
    final stem = p.basenameWithoutExtension(name), ext = p.extension(name);
    for (var i = 1; i < 10000; i++) {
      final filename = i == 1 ? name : '$stem-$i$ext';
      if (!existing.contains(filename.toLowerCase())) {
        final file = File(p.join(directory.path, filename));
        try {
          return await file.create(exclusive: true);
        } on FileSystemException {
          if (await file.exists()) continue;
          rethrow;
        }
      }
    }
    throw const ResourceFailure(
      '图片重名过多，请更改名称。',
      'Too many image name conflicts.',
    );
  }

  String _format(Uint8List data) {
    bool starts(List<int> magic) =>
        data.length >= magic.length &&
        List.generate(magic.length, (i) => data[i] == magic[i]).every((v) => v);
    if (starts([137, 80, 78, 71, 13, 10, 26, 10])) return '.png';
    if (starts([255, 216, 255])) return '.jpg';
    if (starts([71, 73, 70, 56])) return '.gif';
    if (starts([66, 77])) return '.bmp';
    if (starts([82, 73, 70, 70]) &&
        data.length > 12 &&
        ascii.decode(data.sublist(8, 12)) == 'WEBP') {
      return '.webp';
    }
    throw const ResourceFailure(
      '图片损坏或格式不支持，请使用 PNG、JPEG、GIF、WebP 或 BMP。',
      'Invalid image; use PNG, JPEG, GIF, WebP or BMP.',
    );
  }

  Future<Uint8List> readImage(ResourceInput input) async {
    Uint8List bytes;
    if (input.bytes != null) {
      bytes = input.bytes!;
    } else {
      final file = File(input.path!);
      if (await file.length() > maxImageBytes) {
        throw const ResourceFailure(
          '图片超过 50 MB，请先缩小图片。',
          'Image exceeds 50 MB.',
        );
      }
      bytes = await file.readAsBytes();
    }
    if (bytes.length > maxImageBytes) {
      throw const ResourceFailure('图片超过 50 MB。', 'Image exceeds 50 MB.');
    }
    _format(bytes);
    await validateImage?.call(bytes);
    return bytes;
  }

  Future<ManagedImage> importImage(
    String documentPath,
    ResourceInput input,
  ) async {
    final bytes = await readImage(input);
    final ext = _format(bytes);
    final directory = await resourceDirectory(documentPath);
    final existed = await directory.exists();
    await directory.create();
    final old = await _readManifest(directory);
    final manifest =
        old ??
        {
          'schema': 1,
          'createdDirectory': !existed,
          'owner': p.basename(documentPath),
          'files': <String, dynamic>{},
        };
    final files = Map<String, dynamic>.from(manifest['files'] as Map);
    final digest = await _resourceBytesDigest(bytes);
    for (final entry in files.entries) {
      if (p.basename(entry.key) != entry.key ||
          entry.value is! Map ||
          entry.value['sha256'] != digest) {
        continue;
      }
      final candidate = File(p.join(directory.path, entry.key));
      if (await FileSystemEntity.type(candidate.path, followLinks: false) ==
              FileSystemEntityType.file &&
          await _digest(candidate) == digest) {
        return ManagedImage(
          candidate.path,
          resourceReference(candidate.path, documentPath),
          entry.key,
          false,
        );
      }
    }
    final requested = _safeName(input.name);
    final name = '${p.basenameWithoutExtension(requested)}$ext';
    File? created;
    try {
      final file = await _uniqueFile(directory, name);
      created = file;
      await file.writeAsBytes(bytes, flush: true);
      files[p.basename(file.path)] = {
        'sha256': digest,
        'size': bytes.length,
        'originalName': input.name,
      };
      await atomicWrite(
        File(p.join(directory.path, _manifestName)),
        jsonEncode({...manifest, 'files': files}),
      );
      return ManagedImage(
        file.path,
        resourceReference(file.path, documentPath),
        p.basename(file.path),
        true,
      );
    } catch (_) {
      if (created != null && await created.exists()) await created.delete();
      if (!existed && await directory.list().isEmpty) await directory.delete();
      rethrow;
    }
  }

  Future<void> atomicWrite(File target, String text) async {
    if (await FileSystemEntity.type(target.path, followLinks: false) ==
        FileSystemEntityType.link) {
      throw const ResourceFailure(
        '不能覆盖符号链接文件。',
        'Cannot overwrite a symbolic link.',
      );
    }
    final temporary = File('${target.path}.marker-${_token()}.tmp');
    try {
      await temporary.create(exclusive: true);
      await temporary.writeAsString(text, flush: true);
      await temporary.rename(target.path);
    } finally {
      if (await temporary.exists()) await temporary.delete();
    }
  }

  Future<ResourceInventory> scan(String text, String? documentPath) async {
    final references = await parseResourceReferencesAsync(text);
    final items = <ResourceItem>[];
    final seen = <String>{};
    for (final ref in references.images) {
      if (!seen.add(ref.source)) continue;
      if (ref.network) {
        items.add(
          ResourceItem(ref.source, ref.alt, ResourceAvailability.remote),
        );
        continue;
      }
      try {
        final uri = resolveResourceUri(ref.source, documentPath);
        if (uri.scheme != 'file') {
          items.add(
            ResourceItem(ref.source, ref.alt, ResourceAvailability.unsupported),
          );
          continue;
        }
        final file = File.fromUri(uri);
        final stat = await file.stat();
        if (stat.type == FileSystemEntityType.notFound) {
          items.add(
            ResourceItem(
              ref.source,
              ref.alt,
              ResourceAvailability.missing,
              path: file.path,
            ),
          );
          continue;
        }
        final record = await _readManifest(file.parent);
        final managed =
            record?['owner'] ==
                (documentPath == null ? null : p.basename(documentPath)) &&
            (record?['files'] as Map?)?.containsKey(p.basename(file.path)) ==
                true;
        items.add(
          ResourceItem(
            ref.source,
            ref.alt,
            ResourceAvailability.local,
            path: file.path,
            size: stat.size,
            managed: managed,
          ),
        );
      } on FileSystemException {
        items.add(
          ResourceItem(ref.source, ref.alt, ResourceAvailability.denied),
        );
      } catch (_) {
        items.add(
          ResourceItem(ref.source, ref.alt, ResourceAvailability.unsupported),
        );
      }
    }
    return ResourceInventory(items, references.unsupported);
  }

  Future<ResourceInput> download(
    String source,
    ResourceCancellation cancellation,
  ) async {
    var uri = Uri.parse(source);
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 8)
      ..findProxy = HttpClient.findProxyFromEnvironment;
    void abort() => client.close(force: true);
    cancellation.listen(abort);
    try {
      for (var hop = 0; hop < 6; hop++) {
        cancellation.check();
        if (!['http', 'https'].contains(uri.scheme) ||
            uri.userInfo.isNotEmpty) {
          throw const ResourceFailure('图片地址不受支持。', 'Unsupported image URL.');
        }
        final request = await client
            .getUrl(uri)
            .timeout(const Duration(seconds: 12));
        request.followRedirects = false;
        final response = await request.close().timeout(
          const Duration(seconds: 15),
        );
        if (response.isRedirect &&
            response.headers.value(HttpHeaders.locationHeader) != null) {
          uri = uri.resolve(
            response.headers.value(HttpHeaders.locationHeader)!,
          );
          await response.take(0).drain<void>();
          continue;
        }
        if (response.statusCode != 200) {
          throw ResourceFailure(
            '下载失败：HTTP ${response.statusCode}',
            'Download failed: HTTP ${response.statusCode}',
          );
        }
        if (response.contentLength > maxImageBytes) {
          throw const ResourceFailure('图片超过 50 MB。', 'Image exceeds 50 MB.');
        }
        final bytes = BytesBuilder(copy: false);
        await for (final chunk in response.timeout(
          const Duration(seconds: 15),
        )) {
          cancellation.check();
          if (bytes.length + chunk.length > maxImageBytes) {
            throw const ResourceFailure('图片超过 50 MB。', 'Image exceeds 50 MB.');
          }
          bytes.add(chunk);
        }
        final data = bytes.takeBytes();
        _format(data);
        return ResourceInput(
          name: uri.pathSegments.lastOrNull ?? 'image',
          bytes: data,
        );
      }
      throw const ResourceFailure('图片重定向次数过多。', 'Too many image redirects.');
    } catch (_) {
      cancellation.check();
      rethrow;
    } finally {
      cancellation.unlisten(abort);
      client.close(force: true);
    }
  }

  Future<ResourceResult> collect({
    required String text,
    required String documentPath,
    bool downloadRemote = false,
    ResourceCancellation? cancellation,
    void Function(ResourceProgress)? onProgress,
  }) async {
    final token = cancellation ?? ResourceCancellation();
    final refs = await parseResourceReferencesAsync(text);
    final sources = refs.images.map((r) => r.source).toSet().toList();
    final replacements = <String, String>{},
        images = <ManagedImage>[],
        issues = <ResourceIssue>[];
    issues.addAll(
      refs.unsupported.map(
        (s) => ResourceIssue(
          s,
          'Unsupported syntax; left unchanged.',
          chinese: '特殊语法保持原样。',
        ),
      ),
    );
    for (var i = 0; i < sources.length; i++) {
      if (token.cancelled) {
        await rollbackImports(documentPath, images);
        token.check();
      }
      final source = sources[i];
      onProgress?.call(ResourceProgress(i, sources.length, source));
      if (token.cancelled) {
        await rollbackImports(documentPath, images);
        token.check();
      }
      try {
        final uri = resolveResourceUri(source, documentPath);
        ResourceInput input;
        if (['http', 'https'].contains(uri.scheme)) {
          if (!downloadRemote) continue;
          input = await download(source, token);
        } else if (uri.scheme == 'file') {
          final file = File.fromUri(uri);
          if (!await file.exists()) {
            throw const ResourceFailure('图片未找到', 'Image not found');
          }
          input = ResourceInput(name: p.basename(file.path), path: file.path);
        } else {
          throw const ResourceFailure('图片地址不受支持', 'Unsupported image address');
        }
        final image = await importImage(documentPath, input);
        images.add(image);
        replacements[source] = image.reference;
      } on ResourceCancelled {
        await rollbackImports(documentPath, images);
        rethrow;
      } catch (e) {
        issues.add(
          ResourceIssue(
            source,
            e is ResourceFailure ? e.en : 'Cannot read or copy this image.',
            chinese: e is ResourceFailure ? e.zh : '无法读取或复制图片，请检查权限和剩余空间。',
          ),
        );
      }
    }
    if (token.cancelled) {
      await rollbackImports(documentPath, images);
      token.check();
    }
    onProgress?.call(ResourceProgress(sources.length, sources.length, ''));
    return ResourceResult(refs.rewrite(text, replacements), images, issues);
  }

  Future<void> rollbackImports(
    String documentPath,
    Iterable<ManagedImage> images,
  ) async {
    for (final image
        in images.where((image) => image.created).toList().reversed) {
      final file = File(image.path);
      final record = await _readManifest(file.parent);
      if (record == null || record['owner'] != p.basename(documentPath)) {
        continue;
      }
      final files = Map<String, dynamic>.from(record['files'] as Map);
      final entry = files[p.basename(file.path)];
      if (entry is! Map ||
          await FileSystemEntity.type(file.path, followLinks: false) !=
              FileSystemEntityType.file) {
        continue;
      }
      if (await _digest(file) != entry['sha256']) continue;
      await file.delete();
      files.remove(p.basename(file.path));
      await atomicWrite(
        File(p.join(file.parent.path, _manifestName)),
        jsonEncode({...record, 'files': files}),
      );
    }
    for (final path
        in images
            .where((image) => image.created)
            .map((image) => p.dirname(image.path))
            .toSet()) {
      final directory = Directory(path);
      if (await FileSystemEntity.type(path, followLinks: false) !=
          FileSystemEntityType.directory) {
        continue;
      }
      final record = await _readManifest(directory);
      if (record?['owner'] != p.basename(documentPath) ||
          record?['createdDirectory'] != true ||
          (record?['files'] as Map?)?.isEmpty != true) {
        continue;
      }
      final entries = await directory.list(followLinks: false).toList();
      if (entries.length == 1 &&
          p.basename(entries.single.path) == _manifestName) {
        await File(p.join(path, _manifestName)).delete();
        await directory.delete();
      }
    }
  }

  Future<String> renameDocument({
    required String sourcePath,
    required String targetPath,
    required String text,
  }) async {
    if (p.dirname(p.absolute(sourcePath)) !=
        p.dirname(p.absolute(targetPath))) {
      throw const ResourceFailure(
        '重命名只能在当前目录进行，请使用另存为移动文档。',
        'Use Save As to move the document to another folder.',
      );
    }
    if (sourcePath == targetPath) return text;
    if (await FileSystemEntity.type(targetPath, followLinks: false) !=
        FileSystemEntityType.notFound) {
      throw const ResourceFailure(
        '同名文件已存在，请换一个名称。',
        'A file with this name already exists.',
      );
    }
    if (await FileSystemEntity.type(sourcePath, followLinks: false) !=
        FileSystemEntityType.file) {
      throw const ResourceFailure(
        '原文档不可访问，未执行重命名。',
        'The source document is unavailable.',
      );
    }
    final directory = await resourceDirectory(sourcePath);
    final manifest = await _readManifest(directory);
    final original = await File(sourcePath).readAsString();
    var published = false;
    try {
      await atomicWrite(File(targetPath), text);
      published = true;
      if (manifest?['owner'] == p.basename(sourcePath)) {
        await atomicWrite(
          File(p.join(directory.path, _manifestName)),
          jsonEncode({...manifest!, 'owner': p.basename(targetPath)}),
        );
      }
      await File(sourcePath).delete();
      return text;
    } catch (_) {
      if (published) {
        if (!await File(sourcePath).exists()) {
          await atomicWrite(File(sourcePath), original);
        }
        if (await File(targetPath).exists() &&
            await File(targetPath).readAsString() == text) {
          await File(targetPath).delete();
        }
        if (manifest != null) {
          await atomicWrite(
            File(p.join(directory.path, _manifestName)),
            jsonEncode(manifest),
          );
        }
      }
      rethrow;
    }
  }

  /// Stages a standalone copy. The destination document is published last.
  Future<ResourceResult> saveCopy({
    required String text,
    required String sourcePath,
    required String targetPath,
    bool downloadRemote = false,
    bool allowIncomplete = false,
    ResourceCancellation? cancellation,
    void Function(ResourceProgress)? onProgress,
  }) async {
    final token = cancellation ?? ResourceCancellation();
    final inventory = await scan(text, sourcePath);
    if (!allowIncomplete &&
        (inventory.unresolved.isNotEmpty || inventory.unsupported.isNotEmpty)) {
      throw const ResourceFailure(
        '仍有无法读取的图片，请先修复或明确选择保留原引用。',
        'Resolve unavailable images or explicitly keep their original references.',
      );
    }
    final stage = await Directory(
      p.dirname(targetPath),
    ).createTemp('.marker-copy-');
    try {
      // Resolve original local references before collecting into the new folder.
      final refs = await parseResourceReferencesAsync(text);
      final absolute = <String, String>{};
      for (final image in refs.images) {
        try {
          final uri = resolveResourceUri(image.source, sourcePath);
          if (uri.scheme == 'file') absolute[image.source] = uri.toString();
        } catch (_) {}
      }
      final stagedPath = p.join(stage.path, p.basename(targetPath));
      final collected = await collect(
        text: refs.rewrite(text, absolute),
        documentPath: stagedPath,
        downloadRemote: downloadRemote,
        cancellation: token,
        onProgress: onProgress,
      );
      if (collected.issues.isNotEmpty && !allowIncomplete) {
        throw ResourceIncomplete(collected.issues);
      }
      token.check();
      var newText = collected.text;
      final stagedAssets = await resourceDirectory(stagedPath);
      Directory? publishedAssets;
      if (await stagedAssets.exists()) {
        // Never merge/overwrite an unrelated destination resource directory.
        var n = 1;
        var destination = Directory(
          p.join(p.dirname(targetPath), '${_stem(targetPath)}.assets'),
        );
        while (await FileSystemEntity.type(
              destination.path,
              followLinks: false,
            ) !=
            FileSystemEntityType.notFound) {
          destination = Directory(
            p.join(p.dirname(targetPath), '${_stem(targetPath)}.assets-${++n}'),
          );
        }
        final map = <String, String>{};
        for (final image in (await parseResourceReferencesAsync(
          newText,
        )).images) {
          final uri = resolveResourceUri(image.source, stagedPath);
          if (uri.scheme == 'file' &&
              p.isWithin(stagedAssets.path, File.fromUri(uri).path)) {
            map[image.source] = resourceReference(
              p.join(destination.path, p.basename(File.fromUri(uri).path)),
              targetPath,
            );
          }
        }
        newText = (await parseResourceReferencesAsync(
          newText,
        )).rewrite(newText, map);
        publishedAssets = await stagedAssets.rename(destination.path);
      }
      try {
        token.check();
        await atomicWrite(File(targetPath), newText);
      } catch (_) {
        if (publishedAssets != null) {
          await rollbackImports(targetPath, [
            for (final image in collected.images)
              ManagedImage(
                p.join(publishedAssets.path, image.name),
                image.reference,
                image.name,
                image.created,
              ),
          ]);
        }
        rethrow;
      }
      return ResourceResult(newText, [
        if (publishedAssets != null)
          for (final image in collected.images)
            ManagedImage(
              p.join(publishedAssets.path, image.name),
              resourceReference(
                p.join(publishedAssets.path, image.name),
                targetPath,
              ),
              image.name,
              image.created,
            ),
      ], collected.issues);
    } finally {
      if (await stage.exists()) await stage.delete(recursive: true);
    }
  }

  Future<List<UnusedResource>> unused(
    String documentPath,
    Iterable<ResourceDraft> drafts,
  ) async {
    final owned = <Directory, Map<String, dynamic>>{};
    await for (final entity in Directory(
      p.dirname(documentPath),
    ).list(followLinks: false)) {
      if (entity is! Directory) continue;
      final record = await _readManifest(entity);
      if (record?['owner'] == p.basename(documentPath)) owned[entity] = record!;
    }
    if (owned.isEmpty) return [];
    final used = <String>{};
    final all = <ResourceDraft>[...drafts];
    // Include the saved document and adjacent Markdown files, not just open tabs.
    await for (final entity in Directory(
      p.dirname(documentPath),
    ).list(followLinks: false)) {
      if (entity is File &&
          [
            '.md',
            '.markdown',
          ].contains(p.extension(entity.path).toLowerCase())) {
        try {
          all.add(ResourceDraft(entity.path, await entity.readAsString()));
        } catch (_) {
          return [];
        } // Unreadable neighbours make ownership uncertain.
      }
    }
    for (final draft in all) {
      final refs = await parseResourceReferencesAsync(draft.text);
      if (refs.unsupported.isNotEmpty) return [];
      for (final source in [
        ...refs.images.map((image) => image.source),
        ...refs.links,
      ]) {
        try {
          final uri = resolveResourceUri(source, draft.path);
          if (uri.scheme == 'file') {
            used.add(_resourcePathKey(File.fromUri(uri).absolute.path));
            try {
              used.add(
                _resourcePathKey(
                  await File.fromUri(uri).resolveSymbolicLinks(),
                ),
              );
            } on FileSystemException {
              /* Missing references cannot gain a new target. */
            }
          }
        } catch (_) {
          return [];
        }
      }
    }
    final result = <UnusedResource>[];
    for (final ownedDirectory in owned.entries) {
      final directory = ownedDirectory.key, record = ownedDirectory.value;
      for (final entry in (record['files'] as Map).entries) {
        final name = entry.key as String;
        if (p.basename(name) != name || entry.value is! Map) continue;
        final file = File(p.join(directory.path, name));
        if (used.contains(_resourcePathKey(file.absolute.path))) continue;
        if (await FileSystemEntity.type(file.path, followLinks: false) !=
            FileSystemEntityType.file) {
          continue;
        }
        final digest = await _digest(file);
        if (digest != entry.value['sha256']) continue;
        result.add(
          UnusedResource(file.path, name, await file.length(), digest),
        );
      }
    }
    return result;
  }

  Future<int> trashUnused(
    String documentPath,
    List<UnusedResource> selected,
    Iterable<ResourceDraft> drafts,
    Future<void> Function(String) trash,
  ) async {
    final candidates = {
      for (final item in await unused(documentPath, drafts)) item.path: item,
    };
    var moved = 0;
    for (final item in selected) {
      final current = candidates[item.path];
      if (current == null || current.digest != item.digest) continue;
      final directory = File(item.path).parent;
      final record = await _readManifest(directory);
      if (record == null || record['owner'] != p.basename(documentPath)) {
        continue;
      }
      final files = Map<String, dynamic>.from(record['files'] as Map);
      await trash(item.path); // Never fall back to permanent deletion.
      files.remove(item.name);
      moved++;
      await atomicWrite(
        File(p.join(directory.path, _manifestName)),
        jsonEncode({...record, 'files': files}),
      );
    }
    return moved;
  }

  Future<List<ResourceIssue>> package({
    required String text,
    required String sourcePath,
    required String zipPath,
    bool downloadRemote = false,
    bool allowIncomplete = false,
    ResourceCancellation? cancellation,
    void Function(ResourceProgress)? onProgress,
  }) async {
    final stage = await Directory.systemTemp.createTemp('marker-package-');
    final temporaryZip = '${p.absolute(zipPath)}.marker-${_token()}.tmp';
    try {
      final root = Directory(p.join(stage.path, _safeName(_stem(sourcePath))));
      await root.create();
      final collected = await saveCopy(
        text: text,
        sourcePath: sourcePath,
        targetPath: p.join(root.path, p.basename(sourcePath)),
        downloadRemote: downloadRemote,
        allowIncomplete: allowIncomplete,
        cancellation: cancellation,
        onProgress: onProgress,
      );
      // Management records are portable but no unrelated/unused images are copied.
      cancellation?.check();
      await _resourceZip(stage.path, temporaryZip);
      cancellation?.check();
      if (await FileSystemEntity.type(zipPath, followLinks: false) ==
          FileSystemEntityType.link) {
        throw const ResourceFailure(
          '不能覆盖符号链接。',
          'Cannot overwrite a symbolic link.',
        );
      }
      await File(temporaryZip).rename(zipPath);
      return collected.issues;
    } finally {
      if (await File(temporaryZip).exists()) await File(temporaryZip).delete();
      if (await stage.exists()) await stage.delete(recursive: true);
    }
  }
}

Future<String> _resourceBytesDigest(Uint8List bytes) =>
    Isolate.run(() => sha256.convert(bytes).toString());

String _resourcePathKey(String value) {
  final path = p.normalize(p.absolute(value));
  return Platform.isLinux ? path : path.toLowerCase();
}

Future<void> _resourceZip(String directory, String destination) =>
    Isolate.run(() async {
      await ZipFileEncoder().zipDirectory(
        Directory(directory),
        filename: destination,
        followLinks: false,
      );
    });
