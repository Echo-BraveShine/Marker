part of 'resource_service.dart';

extension _ResourceDocumentOperations on DocumentResourceService {
  Future<ResourceResult> _serviceCollect({
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
        (s) => ResourceIssue.localized(s, AppMessage.unsupportedSyntaxKept),
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
            throw const ResourceFailure.localized(AppMessage.imageNotFound);
          }
          input = ResourceInput(name: p.basename(file.path), path: file.path);
        } else {
          throw const ResourceFailure.localized(
            AppMessage.unsupportedImageAddress,
          );
        }
        final image = await importImage(documentPath, input);
        images.add(image);
        replacements[source] = image.reference;
      } on ResourceCancelled {
        await rollbackImports(documentPath, images);
        rethrow;
      } catch (e) {
        issues.add(
          e is ResourceFailure && e._message != null
              ? ResourceIssue.localized(source, e._message, e._arguments)
              : ResourceIssue.localized(
                  source,
                  AppMessage.cannotReadOrCopyImage,
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

  Future<void> _serviceRollbackImports(
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

  Future<String> _serviceRenameDocument({
    required String sourcePath,
    required String targetPath,
    required String text,
  }) async {
    if (p.dirname(p.absolute(sourcePath)) !=
        p.dirname(p.absolute(targetPath))) {
      throw const ResourceFailure.localized(
        AppMessage.useSaveAsToMoveTheDocumentToAnotherFolder,
      );
    }
    if (sourcePath == targetPath) return text;
    if (await FileSystemEntity.type(targetPath, followLinks: false) !=
        FileSystemEntityType.notFound) {
      throw const ResourceFailure.localized(
        AppMessage.aFileWithThisNameAlreadyExists,
      );
    }
    if (await FileSystemEntity.type(sourcePath, followLinks: false) !=
        FileSystemEntityType.file) {
      throw const ResourceFailure.localized(
        AppMessage.theSourceDocumentIsUnavailable,
      );
    }
    final parent = p.dirname(p.absolute(sourcePath));
    final conventional = p.join(parent, '${_stem(sourcePath)}.assets');
    final owned = <({Directory directory, Map<String, dynamic>? manifest})>[];
    await for (final entity in Directory(parent).list(followLinks: false)) {
      if (entity is! Directory) continue;
      final record = await _readManifest(entity);
      if (record?['owner'] == p.basename(sourcePath) ||
          (p.equals(entity.path, conventional) &&
              record == null &&
              !await File(p.join(entity.path, _manifestName)).exists())) {
        owned.add((directory: entity, manifest: record));
      }
    }
    owned.sort((a, b) {
      if (p.equals(a.directory.path, conventional)) return -1;
      if (p.equals(b.directory.path, conventional)) return 1;
      return a.directory.path.compareTo(b.directory.path);
    });
    final moves =
        <
          ({Directory source, Directory target, Map<String, dynamic>? manifest})
        >[];
    for (var i = 0; i < owned.length; i++) {
      final destination = Directory(
        p.join(
          parent,
          '${_stem(targetPath)}.assets${i == 0 ? '' : '-${i + 1}'}',
        ),
      );
      if (!p.equals(owned[i].directory.path, destination.path) &&
          await FileSystemEntity.type(destination.path, followLinks: false) !=
              FileSystemEntityType.notFound) {
        throw const ResourceFailure.localized(
          AppMessage.anAssetFolderWithTheNewNameAlreadyExistsNothingWasRenamed,
        );
      }
      moves.add((
        source: owned[i].directory,
        target: destination,
        manifest: owned[i].manifest,
      ));
    }
    final references = await parseResourceReferencesAsync(text);
    final replacements = <String, String>{};
    for (final image in references.images) {
      final uri = resolveResourceUri(image.source, sourcePath);
      if (uri.scheme != 'file') continue;
      final imagePath = p.absolute(File.fromUri(uri).path);
      for (final move in moves) {
        if (p.isWithin(move.source.absolute.path, imagePath)) {
          replacements[image.source] = resourceReference(
            p.join(
              move.target.path,
              p.relative(imagePath, from: move.source.absolute.path),
            ),
            targetPath,
          );
          break;
        }
      }
    }
    final updated = references.rewrite(text, replacements);
    final moved = <int>[];
    var published = false;
    try {
      for (var i = 0; i < moves.length; i++) {
        final move = moves[i];
        if (!p.equals(move.source.path, move.target.path)) {
          await move.source.rename(move.target.path);
        }
        moved.add(i);
        if (move.manifest != null) {
          await atomicWrite(
            File(p.join(move.target.path, _manifestName)),
            jsonEncode({...move.manifest!, 'owner': p.basename(targetPath)}),
          );
        }
      }
      await atomicWrite(File(targetPath), updated);
      published = true;
      await File(sourcePath).delete();
      _directoryCache.clear();
      return updated;
    } catch (_) {
      if (published &&
          await File(targetPath).exists() &&
          await File(targetPath).readAsString() == updated) {
        await File(targetPath).delete();
      }
      for (final index in moved.reversed) {
        final move = moves[index];
        if (move.manifest != null) {
          await atomicWrite(
            File(p.join(move.target.path, _manifestName)),
            jsonEncode(move.manifest),
          );
        }
        if (!p.equals(move.source.path, move.target.path)) {
          await move.target.rename(move.source.path);
        }
      }
      _directoryCache.clear();
      rethrow;
    }
  }

  /// Stages a standalone copy. The destination document is published last.
  Future<ResourceResult> _serviceSaveCopy({
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
      throw const ResourceFailure.localized(
        AppMessage.resolveImagesBeforeExport,
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
}
