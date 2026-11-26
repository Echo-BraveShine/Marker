part of '../../main.dart';

// Resource menu and operation handlers
extension _ResourceMenuActions on _MarkerHomeState {
  Future<void> _resourceMenu() async {
    final choice = await _resourceChoice(t('文档资源', 'Document resources'), [
      (
        'import',
        t('导入图片（复制原图）', 'Import images (copy originals)'),
        CupertinoIcons.photo,
      ),
      if (!_isMobile)
        (
          'reference',
          t('引用原位置…', 'Link original location…'),
          CupertinoIcons.link,
        ),
      ('paste', t('粘贴截图或图片', 'Paste image'), CupertinoIcons.doc_on_clipboard),
      ('network', t('插入网络图片…', 'Insert web image…'), CupertinoIcons.globe),
      (
        'collect',
        t('整理文档图片…', 'Organize document images…'),
        CupertinoIcons.folder_badge_plus,
      ),
      (
        'cleanup',
        t('清理未使用资源…', 'Clean unused resources…'),
        CupertinoIcons.trash,
      ),
      if (!_isMobile)
        (
          'authorize',
          t('授权资源目录…', 'Allow folder access…'),
          CupertinoIcons.lock_open,
        ),
      if (!_isMobile)
        (
          'folder',
          t('新建文档文件夹…', 'New document folder…'),
          CupertinoIcons.folder,
        ),
      if (_path != null)
        ('rename', t('重命名文档…', 'Rename document…'), CupertinoIcons.pencil),
      if (resourcePackageExportEnabled || _isMobile)
        (
          'package',
          t('打包文档与图片…', 'Package document and images…'),
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
        await _action(_isMobile ? _exportMobileDocument : _packageResources);
    }
  }

  Future<void> _organizeResources() async {
    if (!await _ensureResourceDocument() || !mounted) return;
    final inventory = await _resources.scan(_controller.text, _path);
    final download = await _resourceCollectionChoice(
      t('整理文档图片', 'Organize document images'),
      inventory,
    );
    if (download == null || !mounted) return;
    final result = await _resourceWork.run(
      t('整理图片', 'Organizing images'),
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
            ? t('图片已整理，原文件已保留。', 'Images organized. Original files kept.')
            : t(
                '图片已整理到编辑内容，请保存文档。',
                'Images organized in the editor. Save the document.',
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
      item.alt.isEmpty ? t('图片', 'Image') : item.alt,
      [
        if ([
          ResourceAvailability.local,
          ResourceAvailability.remote,
        ].contains(item.availability))
          ('insert', t('插入到光标位置', 'Insert at cursor'), CupertinoIcons.plus),
        if ([
          ResourceAvailability.local,
          ResourceAvailability.remote,
        ].contains(item.availability))
          (
            'open',
            _isMobile ? t('查看图片', 'View image') : t('打开原图', 'Open image'),
            CupertinoIcons.arrow_up_right_square,
          ),
        if (item.path != null && !_isMobile)
          (
            'reveal',
            t('在文件管理器中显示', 'Show in file manager'),
            CupertinoIcons.folder,
          ),
        ('copy', t('复制引用路径', 'Copy reference path'), CupertinoIcons.doc_on_doc),
        ('locate', t('重新定位图片…', 'Locate image…'), CupertinoIcons.search),
        (
          'replace',
          t('替换为导入的图片…', 'Replace with imported image…'),
          CupertinoIcons.arrow_2_squarepath,
        ),
        if (item.availability == ResourceAvailability.remote)
          (
            'download',
            t('下载到文档资源', 'Download to document assets'),
            CupertinoIcons.arrow_down_to_line,
          ),
        ('refresh', t('重新加载', 'Reload'), CupertinoIcons.refresh),
      ],
      description: item.source,
    );
    if (!mounted) return;
    switch (choice) {
      case 'insert':
        _insertResourceText(imageMarkdown(item.alt, item.source));
      case 'copy':
        await Clipboard.setData(ClipboardData(text: item.source));
        _toast(t('引用路径已复制', 'Reference copied'));
      case 'open':
        await _action(() async {
          final uri = resolveResourceUri(item.source, _path);
          if (_isMobile && uri.scheme == 'file') {
            await _previewMobileImage(File.fromUri(uri).path);
            return;
          }
          if (!['file', 'http', 'https'].contains(uri.scheme) ||
              !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
            throw const ResourceFailure('无法打开图片。', 'Cannot open image.');
          }
        });
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
          await NetworkImage(item.source).evict();
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
    final newReference = await _resourceWork.run(t('更新图片', 'Updating image'), (
      token,
      progress,
    ) async {
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
    });
    _setResourceText(
      parseResourceReferences(
        _controller.text,
      ).rewrite(_controller.text, {source: newReference}),
    );
    _focus.requestFocus();
  }

  Future<void> _downloadResource(String source) async {
    if (!await _ensureResourceDocument()) return;
    final image = await _resourceWork.run(t('下载图片', 'Downloading image'), (
      token,
      progress,
    ) async {
      final input = await _resources.download(source, token);
      token.check();
      return _withResourceAccess(() => _resources.importImage(_path!, input));
    });
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
        t(
          '没有可安全清理的资源。已保存或其他文档引用的图片会保留。',
          'No safe cleanup candidates. Saved and shared references are protected.',
        ),
      );
      return;
    }
    final confirmed = await showMarkerDialog<bool>(
      context: context,
      builder: (context) => MarkerDialog(
        width: 520,
        title: Text(t('移到废纸篓？', 'Move to Trash?')),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              t(
                '以下图片由 Marker 导入，且未被当前内容、保存版本或已知文档引用。请确认其他工具也不再使用。',
                'These imported images are not referenced by current content, saved versions or known documents. Confirm that other tools no longer use them.',
              ),
            ),
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
            child: Text(t('移到废纸篓', 'Move to Trash')),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final moved = await _resourceWork.run(t('清理资源', 'Cleaning resources'), (
      token,
      progress,
    ) async {
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
    });
    _toast(
      t(
        '已将 $moved 张图片移到废纸篓；仍被引用或已修改的资源会保留。',
        '$moved images moved to Trash. Referenced or modified resources are kept.',
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
                _path == null ? Directory.current.path : p.dirname(_path!),
              )
        : await getDirectoryPath(
            confirmButtonText: t('选择存放位置', 'Choose location'),
          );
    if (parent == null || !mounted) return;
    final name = await _resourceText(
      t('新建文档文件夹', 'New document folder'),
      t('文件夹名称', 'Folder name'),
    );
    if (name == null || !mounted) return;
    if (p.basename(name) != name ||
        name == '.' ||
        name == '..' ||
        RegExp(r'[<>:"/\\|?*]').hasMatch(name)) {
      throw const ResourceFailure('请输入有效的文件夹名称。', 'Enter a valid folder name.');
    }
    final directory = Directory(p.join(parent, name));
    if (await directory.exists()) {
      throw const ResourceFailure(
        '文件夹已存在，请使用其他名称。',
        'The folder already exists. Choose another name.',
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
      t('重命名文档', 'Rename document'),
      t('文档名称', 'Document name'),
      initial: p.basename(_path!),
    );
    if (name == null || !mounted) return;
    if (p.basename(name) != name ||
        RegExp(r'[<>:"/\\|?*]').hasMatch(name) ||
        name == '.' ||
        name == '..') {
      throw const ResourceFailure('文档名称无效。', 'Invalid document name.');
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
        title: Text(t('保存并重命名？', 'Save and rename?')),
        content: Text(
          t(
            '将保存当前内容并重命名文档。同时重命名资源目录并更新本文中的图片引用。其他文档如引用此资源目录，需要同步修改。',
            'Current content will be saved. The asset folder and image references in this document will also be renamed. References from other documents need updating separately.',
          ),
        ),
        actions: [
          MarkerDialogButton(
            primary: true,
            onPressed: () => Navigator.pop(context, true),
            child: Text(t('重命名', 'Rename')),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    final result = await _resourceWork.run(
      t('重命名文档', 'Renaming document'),
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
      t('打包文档与图片', 'Package document and images'),
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
        t('打包文档', 'Packaging document'),
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
        t(
          '已生成副本，部分引用仍需修复。',
          'Package created with references that still need repair.',
        ),
      );
      return;
    }
    _toast(t('已打包当前编辑内容与图片。', 'Current document and images packaged.'));
  }
}
