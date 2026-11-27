part of '../../main.dart';

// Resource menu and operation handlers
extension _ResourceMenuActions on _MarkerHomeState {
  Future<void> _resourceMenu() async {
    final choice =
        await _resourceChoice(_l10n.message(AppMessage.documentResources), [
          (
            'import',
            _l10n.message(AppMessage.importImagesCopyOriginals),
            CupertinoIcons.photo,
          ),
          if (!_isMobile)
            (
              'reference',
              _l10n.message(AppMessage.linkOriginalLocation),
              CupertinoIcons.link,
            ),
          (
            'paste',
            _l10n.message(AppMessage.pasteImage),
            CupertinoIcons.doc_on_clipboard,
          ),
          (
            'network',
            _l10n.message(AppMessage.insertWebImage),
            CupertinoIcons.globe,
          ),
          (
            'collect',
            _l10n.message(AppMessage.organizeDocumentImages),
            CupertinoIcons.folder_badge_plus,
          ),
          (
            'cleanup',
            _l10n.message(AppMessage.cleanUnusedResources),
            CupertinoIcons.trash,
          ),
          if (!_isMobile)
            (
              'authorize',
              _l10n.message(AppMessage.allowFolderAccess),
              CupertinoIcons.lock_open,
            ),
          if (!_isMobile)
            (
              'folder',
              _l10n.message(AppMessage.newDocumentFolder),
              CupertinoIcons.folder,
            ),
          if (_path != null)
            (
              'rename',
              _l10n.message(AppMessage.renameDocument),
              CupertinoIcons.pencil,
            ),
          if (resourcePackageExportEnabled && !_isMobile)
            (
              'package',
              _l10n.message(AppMessage.packageDocumentAndImages),
              CupertinoIcons.archivebox,
            ),
        ]);
    if (!mounted) return;
    switch (choice) {
      case 'import':
        await _importPictures();
      case 'reference':
        await _importPictures(referenceOnly: true);
      case 'paste':
        await _pasteResourceOrText(preferImage: true);
      case 'network':
        await _insertNetworkImage();
      case 'collect':
        await _action(_organizeResources);
      case 'cleanup':
        await _action(_cleanResources);
      case 'authorize':
        await _action(() => _authorizeResourceFolder());
      case 'folder':
        await _action(_newDocumentFolder);
      case 'rename':
        await _action(_renameResourceDocument);
      case 'package':
        await _action(_packageResources);
    }
  }

  Future<void> _organizeResources() async {
    if (!await _ensureResourceDocument() || !mounted) return;
    final inventory = await _resources.scan(_controller.text, _path);
    final download = await _resourceCollectionChoice(
      _l10n.message(AppMessage.organizeDocumentImages2),
      inventory,
    );
    if (download == null || !mounted) return;
    final result = await _resourceWork.run(
      _l10n.message(AppMessage.organizingImages),
      (token, progress) => _withResourceAccess(
        () => _resources.collect(
          text: _controller.text,
          documentPath: _path!,
          downloadRemote: download,
          cancellation: token,
          onProgress: progress,
        ),
      ),
    );
    if (!mounted) return;
    _setResourceText(result.text);
    final saved = await _save();
    if (result.issues.isNotEmpty) {
      await _showResourceIssues(result.issues.map(_resourceIssueText).toList());
    } else {
      _toast(
        saved
            ? _l10n.message(AppMessage.imagesOrganizedOriginalFilesKept)
            : _l10n.message(
                AppMessage.imagesOrganizedInTheEditorSaveTheDocument,
              ),
      );
    }
  }

  void _setResourceText(String text) {
    final selection = _controller.selection;
    _controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(
        offset: selection.isValid
            ? selection.extentOffset.clamp(0, text.length)
            : 0,
      ),
    );
    _imageEpoch++;
    _resourceWork.refresh();
  }

  Future<void> _resourceItemMenu(ResourceItem item) async {
    final choice = await _resourceChoice(
      item.alt.isEmpty ? _l10n.message(AppMessage.image) : item.alt,
      [
        (
          'find',
          _l10n.message(AppMessage.locateInEditor),
          CupertinoIcons.search,
        ),
        if ([
          ResourceAvailability.local,
          ResourceAvailability.remote,
        ].contains(item.availability))
          (
            'insert',
            _l10n.message(AppMessage.insertAtCursor),
            CupertinoIcons.plus,
          ),
        if ([
          ResourceAvailability.local,
          ResourceAvailability.remote,
        ].contains(item.availability))
          (
            'open',
            _isMobile
                ? _l10n.message(AppMessage.viewImage)
                : _l10n.message(AppMessage.openImage),
            CupertinoIcons.arrow_up_right_square,
          ),
        if (item.path != null && !_isMobile)
          (
            'reveal',
            _l10n.message(AppMessage.showInFileManager),
            CupertinoIcons.folder,
          ),
        (
          'copy',
          _l10n.message(AppMessage.copyReferencePath),
          CupertinoIcons.doc_on_doc,
        ),
        (
          'locate',
          _l10n.message(AppMessage.locateImage2),
          CupertinoIcons.search,
        ),
        (
          'replace',
          _l10n.message(AppMessage.replaceWithImportedImage),
          CupertinoIcons.arrow_2_squarepath,
        ),
        if (item.availability == ResourceAvailability.remote)
          (
            'download',
            _l10n.message(AppMessage.downloadToDocumentAssets),
            CupertinoIcons.arrow_down_to_line,
          ),
        ('refresh', _l10n.message(AppMessage.reload), CupertinoIcons.refresh),
      ],
      description: item.source,
    );
    if (!mounted) return;
    switch (choice) {
      case 'find':
        _locateResourceInEditor(item);
      case 'insert':
        _insertResourceText(imageMarkdown(item.alt, item.source));
      case 'copy':
        await Clipboard.setData(ClipboardData(text: item.source));
        _toast(_l10n.message(AppMessage.referenceCopied));
      case 'open':
        await _previewResourceImage(item);
      case 'reveal':
        if (item.path != null) {
          await _action(
            () => ref.read(resourcePlatformProvider).reveal(item.path!),
          );
        }
      case 'locate':
        await _action(() => _relocateResource(item.source));
      case 'replace':
        await _action(() => _relocateResource(item.source, copy: true));
      case 'download':
        await _action(() => _downloadResource(item.source));
      case 'refresh':
        if (item.path != null) {
          await FileImage(File(item.path!)).evict();
        } else {
          await ResourceNetworkImage.evict(item.source);
        }
        _imageEpoch++;
        _previewSignature = null;
        _resourceWork.refresh();
    }
  }
}

// Resource relocation, download, and cleanup operations
extension _ResourceRelocateActions on _MarkerHomeState {
  Future<void> _relocateResource(String source, {bool copy = false}) async {
    final images = await _pickResourceImages(multiple: false);
    final image = images.firstOrNull;
    if (_isMobile) copy = true;
    if (image == null || !mounted) return;
    if (!await _ensureResourceDocument()) return;
    final newReference = await _resourceWork.run(
      _l10n.message(AppMessage.updatingImage),
      (token, progress) async {
        if (copy) {
          return (await _withResourceAccess(
            () async => _resources.importImage(
              _path!,
              ResourceInput(
                name: image.name,
                path: _isMobile ? null : image.path,
                bytes: _isMobile ? await image.readAsBytes() : null,
              ),
            ),
          )).reference;
        }
        await _resources.readImage(
          ResourceInput(
            name: image.name,
            path: _isMobile ? null : image.path,
            bytes: _isMobile ? await image.readAsBytes() : null,
          ),
        );
        return resourceReference(image.path, _path!);
      },
    );
    _setResourceText(
      parseResourceReferences(
        _controller.text,
      ).rewrite(_controller.text, {source: newReference}),
    );
    _focus.requestFocus();
  }

  Future<void> _downloadResource(String source) async {
    if (!await _ensureResourceDocument()) return;
    final image = await _resourceWork.run(
      _l10n.message(AppMessage.downloadingImage),
      (token, progress) async {
        final input = await _resources.download(source, token);
        token.check();
        return _withResourceAccess(() => _resources.importImage(_path!, input));
      },
    );
    _setResourceText(
      parseResourceReferences(
        _controller.text,
      ).rewrite(_controller.text, {source: image.reference}),
    );
  }

  Future<void> _cleanResources() async {
    if (_path == null) return;
    final candidates = await _resources.unused(_path!, _resourceDrafts);
    if (!mounted) return;
    if (candidates.isEmpty) {
      _toast(
        _l10n.message(
          AppMessage
              .noSafeCleanupCandidatesSavedAndSharedReferencesAreProtected,
        ),
      );
      return;
    }
    final confirmed = await showMarkerDialog<bool>(
      context: context,
      builder: (context) => MarkerDialog(
        width: 520,
        title: Text(_l10n.message(AppMessage.moveToTrash2)),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_l10n.message(AppMessage.unreferencedImagesDescription)),
            const SizedBox(height: 12),
            for (final item in candidates)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    SizedBox(
                      width: 36,
                      height: 36,
                      child: Image.file(
                        File(item.path),
                        fit: BoxFit.cover,
                        cacheWidth: 80,
                        errorBuilder: (_, _, _) =>
                            const Icon(CupertinoIcons.photo),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${item.name} · ${(item.size / 1024).ceil()} KB',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        actions: [
          MarkerDialogButton(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(context, true),
            child: Text(_l10n.message(AppMessage.moveToTrash3)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final moved = await _resourceWork.run(
      _l10n.message(AppMessage.cleaningResources),
      (token, progress) async {
        var moved = 0;
        for (var i = 0; i < candidates.length; i++) {
          token.check();
          progress(ResourceProgress(i, candidates.length, candidates[i].name));
          moved += await _resources.trashUnused(
            _path!,
            [candidates[i]],
            _resourceDrafts,
            ref.read(resourcePlatformProvider).trash,
          );
        }
        return moved;
      },
    );
    _toast(
      _l10n.message(
        AppMessage.valueImagesMovedToTrashReferencedOrModifiedResourcesAreKept,
        {"p0": moved},
      ),
    );
  }
}

// New folder and rename document operations
extension _ResourceCleanupActions on _MarkerHomeState {
  Future<void> _newDocumentFolder() async {
    final parent =
        desktopWindow && defaultTargetPlatform == TargetPlatform.macOS
        ? await ref
              .read(resourcePlatformProvider)
              .authorizeDirectory(
                languageTag: _languageTag,
                _path == null ? Directory.current.path : p.dirname(_path!),
              )
        : await getDirectoryPath(
            confirmButtonText: _l10n.message(AppMessage.chooseLocation),
          );
    if (parent == null || !mounted) return;
    final name = await _resourceText(
      _l10n.message(AppMessage.newDocumentFolder2),
      _l10n.message(AppMessage.folderName),
    );
    if (name == null || !mounted) return;
    if (p.basename(name) != name ||
        name == '.' ||
        name == '..' ||
        RegExp(r'[<>:"/\\|?*]').hasMatch(name)) {
      throw const ResourceFailure.localized(AppMessage.enterAValidFolderName);
    }
    final directory = Directory(p.join(parent, name));
    if (await directory.exists()) {
      throw const ResourceFailure.localized(
        AppMessage.theFolderAlreadyExistsChooseAnotherName,
      );
    }
    await directory.create();
    final path = p.join(directory.path, '$name.md');
    try {
      await _resources.atomicWrite(File(path), '');
    } catch (_) {
      if (await directory.list().isEmpty) await directory.delete();
      rethrow;
    }
    _snapshot();
    _workspace.add(text: '', saved: '', path: path);
    _loadActive();
    await _persist();
    _focus.requestFocus();
  }

  Future<void> _renameResourceDocument() async {
    if (_path == null) return;
    final name = await _resourceText(
      _l10n.message(AppMessage.renameDocument2),
      _l10n.message(AppMessage.documentName),
      initial: p.basename(_path!),
    );
    if (name == null || !mounted) return;
    if (p.basename(name) != name ||
        RegExp(r'[<>:"/\\|?*]').hasMatch(name) ||
        name == '.' ||
        name == '..') {
      throw const ResourceFailure.localized(AppMessage.invalidDocumentName);
    }
    final filename =
        RegExp(r'\.(md|markdown)$', caseSensitive: false).hasMatch(name)
        ? name
        : '$name.md';
    final target = p.join(p.dirname(_path!), filename);
    if (target == _path) return;
    final confirm = await showMarkerDialog<bool>(
      context: context,
      builder: (context) => MarkerDialog(
        title: Text(_l10n.message(AppMessage.saveAndRename)),
        content: Text(
          _l10n.message(AppMessage.renameDocumentResourcesDescription),
        ),
        actions: [
          MarkerDialogButton(
            primary: true,
            onPressed: () => Navigator.pop(context, true),
            child: Text(_l10n.message(AppMessage.rename2)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    final result = await _resourceWork.run(
      _l10n.message(AppMessage.renamingDocument),
      (token, progress) => _withResourceAccess(
        () => _resources.renameDocument(
          sourcePath: _path!,
          targetPath: target,
          text: _controller.text,
        ),
      ),
    );
    _path = target;
    _saved = result;
    _setResourceText(result);
    await _persist();
    if (desktopWindow) await windowManager.setTitle(_name);
  }
}

// Package document and images into ZIP
extension _ResourcePackageActions on _MarkerHomeState {
  Future<void> _packageResources() async {
    if (!await _ensureResourceDocument() || !mounted) return;
    final inventory = await _resources.scan(_controller.text, _path);
    final download = await _resourceCollectionChoice(
      _l10n.message(AppMessage.packageDocumentAndImages2),
      inventory,
      standalone: true,
    );
    if (download == null ||
        !await _confirmResourceIssues(inventory) ||
        !mounted) {
      return;
    }
    final target = await _chooseSaveLocation(
      suggestedName: '${p.basenameWithoutExtension(_path!)}.zip',
      acceptedTypeGroups: [
        const XTypeGroup(label: 'ZIP', extensions: ['zip']),
      ],
    );
    if (target == null) return;
    final issues = await _retryIncomplete(
      (allow) => _resourceWork.run(
        _l10n.message(AppMessage.packagingDocument),
        (token, progress) => _resources.package(
          text: _controller.text,
          sourcePath: _path!,
          zipPath: target.path,
          downloadRemote: download,
          allowIncomplete: allow,
          cancellation: token,
          onProgress: progress,
        ),
      ),
      allowIncomplete:
          inventory.unresolved.isNotEmpty || inventory.unsupported.isNotEmpty,
    );
    if (issues.isNotEmpty) {
      await _showResourceIssues(issues.map(_resourceIssueText).toList());
      _toast(
        _l10n.message(
          AppMessage.packageCreatedWithReferencesThatStillNeedRepair,
        ),
      );
      return;
    }
    _toast(_l10n.message(AppMessage.currentDocumentAndImagesPackaged));
  }
}
