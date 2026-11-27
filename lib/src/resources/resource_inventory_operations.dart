part of 'resource_service.dart';

extension _ResourceInventoryOperations on DocumentResourceService {
  Future<ResourceInventory> _serviceScan(
    String text,
    String? documentPath,
  ) async {
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

  Future<List<UnusedResource>> _serviceUnused(
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

  Future<int> _serviceTrashUnused(
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

  Future<List<ResourceIssue>> _servicePackage({
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
        throw const ResourceFailure.localized(
          AppMessage.cannotOverwriteASymbolicLink,
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
