part of 'resource_service.dart';

extension _ResourceImageOperations on DocumentResourceService {
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

  Future<Directory> _serviceResourceDirectory(String documentPath) async {
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

  Future<Uint8List> _serviceReadImage(ResourceInput input) async {
    Uint8List bytes;
    if (input.bytes != null) {
      bytes = input.bytes!;
    } else {
      final file = File(input.path!);
      if (await file.length() > DocumentResourceService.maxImageBytes) {
        throw const ResourceFailure(
          '图片超过 50 MB，请先缩小图片。',
          'Image exceeds 50 MB.',
        );
      }
      bytes = await file.readAsBytes();
    }
    if (bytes.length > DocumentResourceService.maxImageBytes) {
      throw const ResourceFailure('图片超过 50 MB。', 'Image exceeds 50 MB.');
    }
    _format(bytes);
    await validateImage?.call(bytes);
    return bytes;
  }

  Future<ManagedImage> _serviceImportImage(
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

  Future<void> _serviceAtomicWrite(File target, String text) async {
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
      final expected = _existingUpdates[p.normalize(target.absolute.path)];
      if (expected != null) {
        final current = await target.readAsString();
        if (current != expected && current != text) throw ResourceConflict();
      }
      await temporary.rename(target.path);
    } finally {
      if (await temporary.exists()) await temporary.delete();
    }
  }

  Future<ResourceInput> _serviceDownload(
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
        if (response.contentLength > DocumentResourceService.maxImageBytes) {
          throw const ResourceFailure('图片超过 50 MB。', 'Image exceeds 50 MB.');
        }
        final bytes = BytesBuilder(copy: false);
        await for (final chunk in response.timeout(
          const Duration(seconds: 15),
        )) {
          cancellation.check();
          if (bytes.length + chunk.length >
              DocumentResourceService.maxImageBytes) {
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
}
