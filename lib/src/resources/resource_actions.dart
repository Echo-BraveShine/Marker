part of '../../main.dart';

extension _ResourceActions on _MarkerHomeState {
  Widget _resourceDropZone(Widget child) {
    if (!desktopWindow) return child;
    final state = ref.watch(resourceUiProvider);
    final colors = Theme.of(context).extension<MarkerColors>()!;
    return DropTarget(
      key: const Key('resource-drop-zone'),
      enable:
          !_busy &&
          !_restoring &&
          !state.busy &&
          (ModalRoute.of(context)?.isCurrent ?? true),
      onDragEntered: (_) => _resourceWork.setDropHover(true),
      onDragExited: (_) => scheduleMicrotask(() {
        // DropTarget also emits exit while disabling itself during a rebuild.
        if (mounted) _resourceWork.setDropHover(false);
      }),
      onDragDone: _dropResourceFiles,
      child: Stack(
        fit: StackFit.expand,
        children: [
          child,
          if (state.dropHover)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  key: const Key('resource-drop-hint'),
                  margin: const EdgeInsets.all(10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colors.bgWindow.withValues(alpha: .9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colors.textAccent, width: 2),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        CupertinoIcons.photo_on_rectangle,
                        size: 32,
                        color: colors.textAccent,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        t('松开以导入图片', 'Drop to import images'),
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        t(
                          '复制到文档资源目录，保留原图',
                          'Copy to document assets. Originals are kept.',
                        ),
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  DocumentResourceService get _resources => ref.read(resourceServiceProvider);
  ResourceController get _resourceWork => ref.read(resourceUiProvider.notifier);
  Iterable<ResourceDraft> get _resourceDrafts => ref
      .read(workspaceProvider)
      .documents
      .expand(
        (doc) => [
          ResourceDraft(
            doc.path,
            doc.id == ref.read(workspaceProvider).activeId
                ? _controller.text
                : doc.text,
          ),
          ResourceDraft(doc.path, doc.saved),
        ],
      );

  Future<String?> _resourceChoice(
    String title,
    List<(String, String, IconData)> entries, {
    String? description,
  }) => showMarkerDialog<String>(
    context: context,
    barrierDismissible: true,
    builder: (context) => MarkerDialog(
      width: 460,
      title: Text(title),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (description != null) ...[
            Text(
              description,
              style: const TextStyle(fontSize: 12, height: 1.6),
            ),
            const SizedBox(height: 12),
          ],
          for (final entry in entries)
            CupertinoButton(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              alignment: Alignment.centerLeft,
              onPressed: () => Navigator.pop(context, entry.$1),
              child: Row(
                children: [
                  Icon(
                    entry.$3,
                    size: 17,
                    color: Theme.of(
                      context,
                    ).extension<MarkerColors>()!.textSecondary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      entry.$2,
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(
                          context,
                        ).extension<MarkerColors>()!.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    ),
  );

  Future<String?> _resourceText(
    String title,
    String placeholder, {
    String initial = '',
  }) => showMarkerDialog<String>(
    context: context,
    builder: (context) => ResourceTextDialog(
      title: title,
      placeholder: placeholder,
      initial: initial,
      confirm: t('确定', 'Continue'),
    ),
  );

  Future<bool> _confirmResourceIssues(ResourceInventory inventory) async {
    if (inventory.unresolved.isEmpty && inventory.unsupported.isEmpty) {
      return true;
    }
    if (!mounted) return false;
    return await showMarkerDialog<bool>(
          context: context,
          builder: (context) => MarkerDialog(
            width: 520,
            title: Text(t('部分图片需要处理', 'Some images need attention')),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  t(
                    '以下引用无法完整复制。可以先修复，或继续并保留其原始地址。',
                    'These references cannot be fully copied. Repair them first, or continue keeping their original addresses.',
                  ),
                ),
                const SizedBox(height: 12),
                for (final item in inventory.unresolved)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Text(
                      item.source,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                for (final item in inventory.unsupported)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Text(
                      '${t('特殊语法', 'Custom syntax')}: $item',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
              ],
            ),
            actions: [
              MarkerDialogButton(
                primary: true,
                onPressed: () => Navigator.pop(context, true),
                child: Text(t('继续并保留原地址', 'Continue with original addresses')),
              ),
            ],
          ),
        ) ==
        true;
  }

  Future<bool?> _resourceCollectionChoice(
    String title,
    ResourceInventory inventory, {
    bool standalone = false,
  }) async {
    final local = inventory.items
        .where((i) => i.availability == ResourceAvailability.local)
        .length;
    final remote = inventory.items
        .where((i) => i.availability == ResourceAvailability.remote)
        .length;
    final managed = inventory.items.where((i) => i.managed).length;
    final copying = standalone ? local : local - managed;
    final size = (inventory.totalBytes / 1024 / 1024).toStringAsFixed(1);
    return showMarkerDialog<bool>(
      context: context,
      builder: (context) => MarkerDialog(
        width: 480,
        title: Text(title),
        content: Text(
          t(
            '本地图片 $local 张（已托管 $managed 张），网络图片 $remote 张。\n需复制 $copying 张，本地图片总大小 $size MB。\n${standalone ? '副本使用当前编辑内容，原文档保持不变。' : '整理完成后会保存当前编辑内容；所有原图保留。'}${inventory.unresolved.isNotEmpty ? '\n无法读取的图片将保持原引用。' : ''}',
            '$local local images ($managed managed), $remote web images.\n$copying images to copy; $size MB of local images.\n${standalone ? 'Uses current editor content; the original document is unchanged.' : 'Organizing saves current editor content; all original images are kept.'}${inventory.unresolved.isNotEmpty ? '\nUnavailable images keep their original references.' : ''}',
          ),
        ),
        actions: [
          if (remote > 0)
            MarkerDialogButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(t('同时下载网络图片', 'Also download web images')),
            ),
          MarkerDialogButton(
            primary: true,
            onPressed: () => Navigator.pop(context, false),
            child: Text(t('仅复制本地图片', 'Copy local images')),
          ),
        ],
      ),
    );
  }

  Future<bool> _ensureResourceDocument() async {
    if (_path != null) return true;
    if (!mounted) return false;
    final confirm = await showMarkerDialog<bool>(
      context: context,
      builder: (context) => MarkerDialog(
        title: Text(t('先保存文档', 'Save the document first')),
        content: Text(
          t(
            '保存后就能把图片放在文档旁边，并使用可随文档移动的相对路径。',
            'Save first so images can be stored beside the document using portable relative paths.',
          ),
        ),
        actions: [
          MarkerDialogButton(
            primary: true,
            onPressed: () => Navigator.pop(context, true),
            child: Text(t('保存并继续', 'Save and continue')),
          ),
        ],
      ),
    );
    return confirm == true && await _save();
  }

  Future<void> _authorizeResourceFolder([String? requiredPath]) async {
    final expected = requiredPath ?? (_path == null ? null : p.dirname(_path!));
    if (expected == null) return;
    String? selected;
    if (desktopWindow && defaultTargetPlatform == TargetPlatform.macOS) {
      selected = await ref
          .read(resourcePlatformProvider)
          .authorizeDirectory(expected, chinese: _zh);
    } else {
      selected = await getDirectoryPath(
        initialDirectory: expected,
        confirmButtonText: t('允许访问目录', 'Allow folder access'),
      );
    }
    if (selected == null) throw ResourceCancelled();
    if (!p.equals(p.normalize(selected), p.normalize(expected)) &&
        !p.isWithin(selected, expected)) {
      throw const ResourceFailure(
        '请选择图片或文档所在目录，或其上级目录。',
        'Choose the containing folder or one of its parent folders.',
      );
    }
    _imageEpoch++;
    _previewSignature = null;
    _resourceWork.refresh();
    if (mounted) {
      _toast(t('已获得目录访问权限。', 'Folder access granted.'));
    }
  }

  Future<T> _withResourceAccess<T>(
    Future<T> Function() operation, {
    String? directory,
  }) async {
    try {
      return await operation();
    } on FileSystemException catch (error) {
      if (defaultTargetPlatform != TargetPlatform.macOS ||
          ![1, 13].contains(error.osError?.errorCode) ||
          (_path == null && directory == null)) {
        rethrow;
      }
      await _authorizeResourceFolder(directory ?? p.dirname(_path!));
      return operation();
    }
  }

  Future<void> _importPictures({bool referenceOnly = false}) async {
    if (_busy || _restoring) return;
    final owner = ref.read(workspaceProvider).activeId;
    final files = await openFiles(
      acceptedTypeGroups: [
        XTypeGroup(
          label: t('图片', 'Images'),
          extensions: resourceImageExtensions,
        ),
      ],
    );
    if (files.isEmpty || !mounted) return;
    if (ref.read(workspaceProvider).activeId != owner) {
      _toast(
        t('文档已切换，请重新导入图片。', 'The document changed. Import the images again.'),
      );
      return;
    }
    await _action(
      () => _importResourceInputs([
        for (final file in files)
          ResourceInput(name: file.name, path: file.path),
      ], referenceOnly: referenceOnly),
    );
  }

  Future<void> _importResourceInputs(
    List<ResourceInput> inputs, {
    bool referenceOnly = false,
  }) async {
    if (!await _ensureResourceDocument() || !mounted) return;
    final path = _path!, documentId = ref.read(workspaceProvider).activeId;
    final original = _controller.value;
    final markdown = <String>[], failures = <String>[];
    var cancelled = false;
    await _resourceWork.run(t('导入图片', 'Importing images'), (
      token,
      progress,
    ) async {
      for (var i = 0; i < inputs.length; i++) {
        if (token.cancelled) break;
        final input = inputs[i];
        var readingSource = true;
        progress(ResourceProgress(i, inputs.length, input.name));
        try {
          // Distinguish source-file access from destination-folder access.
          // A dropped file grant does not grant its parent or the MD folder.
          final bytes = await _withResourceAccess(
            () => _resources.readImage(input),
            directory: input.path == null ? null : p.dirname(input.path!),
          );
          if (referenceOnly && input.path != null) {
            // Validate without taking ownership of the original file.
            markdown.add(
              imageMarkdown(
                p.basenameWithoutExtension(input.name),
                resourceReference(input.path!, path),
              ),
            );
          } else {
            readingSource = false;
            final image = await _withResourceAccess(
              () => _resources.importImage(
                path,
                ResourceInput(name: input.name, bytes: bytes),
              ),
            );
            markdown.add(
              imageMarkdown(
                p.basenameWithoutExtension(input.name),
                image.reference,
              ),
            );
          }
        } on ResourceCancelled {
          token.cancelled = true;
          break;
        } catch (e, stack) {
          if (kDebugMode) debugPrint('Image import failed: $e\n$stack');
          failures.add(
            '${input.name}\n${t(readingSource ? '读取原图失败' : '写入图片资源失败', readingSource ? 'Cannot read original image' : 'Cannot write image assets')}\n${_resourceMessage(e)}',
          );
        }
      }
      cancelled = token.cancelled;
      progress(ResourceProgress(markdown.length, inputs.length, ''));
      if (markdown.isNotEmpty &&
          mounted &&
          ref.read(workspaceProvider).activeId == documentId) {
        final current = _controller.value;
        final selection = current.text == original.text
            ? original.selection
            : current.selection;
        _insertResourceText(markdown.join('\n'), selection: selection);
      }
    });
    if (failures.isNotEmpty && mounted) {
      await _showResourceIssues(failures);
    } else if (cancelled && mounted) {
      _toast(
        t(
          markdown.isEmpty
              ? '已取消导入，原图未修改。'
              : '已停止导入，已插入 ${markdown.length} 张图片。',
          markdown.isEmpty
              ? 'Import cancelled. Original images are unchanged.'
              : 'Import stopped. ${markdown.length} images inserted.',
        ),
      );
    } else if (markdown.isNotEmpty && mounted) {
      _toast(
        t(
          referenceOnly
              ? '已插入原位置引用；移动原图后可能失效。'
              : '已插入 ${markdown.length} 张图片，原图已保留。',
          '${markdown.length} images inserted. Originals kept.',
        ),
      );
    }
  }

  void _insertResourceText(String text, {TextSelection? selection}) {
    final value = _controller.value;
    final active = selection ?? value.selection;
    final start = active.isValid
        ? active.start.clamp(0, value.text.length)
        : value.text.length;
    final end = active.isValid
        ? active.end.clamp(start, value.text.length)
        : start;
    _controller.value = TextEditingValue(
      text: value.text.replaceRange(start, end, text),
      selection: TextSelection.collapsed(offset: start + text.length),
    );
    _focus.requestFocus();
  }

  String _resourceMessage(Object error) {
    if (error is ResourceFailure) return t(error.zh, error.en);
    if (error is FileSystemException) {
      final code = error.osError?.errorCode;
      final windows = Platform.isWindows;
      final reason = (windows ? code == 5 : code == 1 || code == 13)
          ? t(
              '尚未获得此位置的访问权限，请授权对应目录后重试。',
              'Folder access is required. Allow access to this location and retry.',
            )
          : (windows ? code == 2 || code == 3 : code == 2)
          ? t(
              '文件或目录不存在，可能已移动或尚未下载到本地。',
              'The file or folder is missing, moved, or not downloaded locally.',
            )
          : (windows ? code == 112 : code == 28)
          ? t(
              '磁盘剩余空间不足，请释放空间后重试。',
              'The disk is full. Free some space and retry.',
            )
          : (windows ? code == 19 : code == 30)
          ? t(
              '此位置为只读，请选择可写入的保存目录。',
              'This location is read-only. Choose a writable folder.',
            )
          : t(
              '文件操作失败，请查看下方位置和系统信息。',
              'File operation failed. Check the location and system details below.',
            );
      return '$reason\n${t('位置', 'Location')}：${error.path ?? t('未知', 'unknown')}\n${error.osError?.message ?? error.message}${code == null ? '' : ' (${t('错误码', 'error')} $code)'}';
    }
    return t(
      '无法处理图片，请检查格式或网络后重试。',
      'Unable to process the image. Check its format or connection and retry.',
    );
  }

  String _resourceIssueText(ResourceIssue issue) =>
      '${issue.source}\n${_zh ? issue.chinese ?? '无法处理此图片，请检查后重试。' : issue.reason}';

  Future<T> _retryIncomplete<T>(
    Future<T> Function(bool allow) operation, {
    bool allowIncomplete = false,
  }) async {
    try {
      return await operation(allowIncomplete);
    } on ResourceIncomplete catch (error) {
      if (allowIncomplete || !mounted) rethrow;
      final proceed = await showMarkerDialog<bool>(
        context: context,
        builder: (context) => MarkerDialog(
          title: Text(t('部分图片未能复制', 'Some images could not be copied')),
          content: Text(
            '${t('原文件未被改动。可以先修复，或保留这些地址继续生成副本。', 'Original files are unchanged. Repair these images, or keep their addresses and continue.')}\n\n${error.issues.map(_resourceIssueText).join('\n\n')}',
          ),
          actions: [
            MarkerDialogButton(
              primary: true,
              onPressed: () => Navigator.pop(context, true),
              child: Text(t('保留原地址并继续', 'Keep addresses and continue')),
            ),
          ],
        ),
      );
      if (proceed != true) throw ResourceCancelled();
      return operation(true);
    }
  }

  Future<void> _showResourceIssues(List<String> issues) async {
    if (!mounted) return;
    await showMarkerDialog<void>(
      context: context,
      builder: (context) => MarkerDialog(
        width: 540,
        title: Text(t('处理结果', 'Operation result')),
        content: Text(
          issues.join('\n\n'),
          style: const TextStyle(fontSize: 12, height: 1.6),
        ),
      ),
    );
  }

  Future<void> _pasteResourceOrText({bool preferImage = false}) async {
    if (_busy || _restoring) return;
    final plain = await Clipboard.getData(Clipboard.kTextPlain);
    try {
      List<String> files = const [];
      try {
        files = await Pasteboard.files();
      } on MissingPluginException {
        /* Plain text still works. */
      }
      final images = files
          .where(
            (path) => resourceImageExtensions.contains(
              p.extension(path).toLowerCase().replaceFirst('.', ''),
            ),
          )
          .toList();
      if (images.isNotEmpty) {
        await _action(
          () => _importResourceInputs([
            for (final path in images)
              ResourceInput(name: p.basename(path), path: path),
          ]),
        );
        return;
      }
      if (!preferImage && plain?.text?.isNotEmpty == true) {
        if (mounted) _insertResourceText(plain!.text!);
        return;
      }
      final image = await Pasteboard.image;
      if (image != null && image.isNotEmpty && mounted) {
        final name =
            'Screenshot-${DateTime.now().toIso8601String().replaceAll(RegExp(r'[:.]'), '-')}.png';
        await _action(
          () =>
              _importResourceInputs([ResourceInput(name: name, bytes: image)]),
        );
      } else if (plain?.text?.isNotEmpty == true) {
        if (mounted) _insertResourceText(plain!.text!);
      } else if (mounted) {
        _toast(t('剪贴板中没有可插入的文本或图片。', 'No text or image to paste.'));
      }
    } on MissingPluginException {
      if (plain?.text?.isNotEmpty == true && mounted) {
        _insertResourceText(plain!.text!);
      } else if (mounted) {
        _toast(
          t(
            '当前环境无法读取剪贴板图片。',
            'Clipboard images are unavailable in this environment.',
          ),
        );
      }
    } catch (e) {
      if (mounted) _error(e);
    }
  }

  Future<void> _dropResourceFiles(DropDoneDetails details) async {
    _resourceWork.setDropHover(false);
    if (_busy ||
        _restoring ||
        ref.read(resourceUiProvider).busy ||
        !(ModalRoute.of(context)?.isCurrent ?? true)) {
      return;
    }
    final editable = _editable();
    if (editable != null &&
        (editable.localToGlobal(Offset.zero) & editable.size).contains(
          details.globalPosition,
        )) {
      final position = editable.getPositionForPoint(details.globalPosition);
      _controller.selection = TextSelection.collapsed(
        offset: position.offset.clamp(0, _controller.text.length),
      );
    }
    await _action(() async {
      final owner = ref.read(workspaceProvider).activeId;
      final access = <Uint8List>[];
      try {
        final inputs = <ResourceInput>[];
        for (final item in details.files.whereType<DropItemFile>()) {
          final bookmark = item.extraAppleBookmark;
          if (bookmark != null &&
              bookmark.isNotEmpty &&
              defaultTargetPlatform == TargetPlatform.macOS) {
            try {
              if (await DesktopDrop.instance
                  .startAccessingSecurityScopedResource(bookmark: bookmark)) {
                access.add(bookmark);
              }
            } on PlatformException catch (error) {
              // The OS may already have granted read access through the drag.
              // Try reading; only request a folder if that actually fails.
              debugPrint('Dropped file bookmark unavailable: ${error.code}');
            }
          }
          if (!resourceImageExtensions.contains(
            p.extension(item.name).toLowerCase().replaceFirst('.', ''),
          )) {
            continue;
          }
          inputs.add(
            item.path.isEmpty
                ? ResourceInput(
                    name: item.name,
                    bytes: await item.readAsBytes(),
                  )
                : ResourceInput(name: item.name, path: item.path),
          );
        }
        if (inputs.isEmpty) {
          final raw = details.rawText?.trim() ?? '';
          final portalDenied =
              details.files.isEmpty &&
              raw.isNotEmpty &&
              !raw.contains('\n') &&
              !raw.startsWith('#') &&
              !(Uri.tryParse(raw)?.hasScheme ?? false);
          _toast(
            portalDenied
                ? t(
                    '系统未能提供拖入文件的访问权限，请使用“导入图片”选择文件。',
                    'The system could not grant access to the dropped files. Use Import images to select them.',
                  )
                : t(
                    '请拖入 PNG、JPEG、GIF、WebP 或 BMP 图片。',
                    'Drop PNG, JPEG, GIF, WebP or BMP images.',
                  ),
          );
          return;
        }
        if (!mounted || ref.read(workspaceProvider).activeId != owner) return;
        await _importResourceInputs(inputs);
      } finally {
        for (final bookmark in access) {
          try {
            await DesktopDrop.instance.stopAccessingSecurityScopedResource(
              bookmark: bookmark,
            );
          } on PlatformException catch (error) {
            debugPrint('Dropped file bookmark release failed: ${error.code}');
          }
        }
      }
    });
  }

  Future<void> _insertNetworkImage() async {
    final address = await _resourceText(
      t('插入网络图片', 'Insert web image'),
      'https://…',
    );
    if (address == null || !mounted) return;
    final uri = Uri.tryParse(address);
    if (uri == null ||
        !['http', 'https'].contains(uri.scheme) ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty) {
      _error(
        const ResourceFailure(
          '请输入有效的 HTTP 或 HTTPS 图片地址。',
          'Enter a valid HTTP or HTTPS image URL.',
        ),
      );
      return;
    }
    _insertResourceText(
      imageMarkdown(t('图片说明', 'Image description'), uri.toString()),
    );
  }

  Future<void> _resourceMenu() async {
    final choice = await _resourceChoice(t('文档资源', 'Document resources'), [
      (
        'import',
        t('导入图片（复制原图）', 'Import images (copy originals)'),
        CupertinoIcons.photo,
      ),
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
      (
        'authorize',
        t('授权资源目录…', 'Allow folder access…'),
        CupertinoIcons.lock_open,
      ),
      ('folder', t('新建文档文件夹…', 'New document folder…'), CupertinoIcons.folder),
      if (_path != null)
        ('rename', t('重命名文档…', 'Rename document…'), CupertinoIcons.pencil),
      if (documentExportEnabled)
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
        await _action(_packageResources);
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
            t('打开原图', 'Open image'),
            CupertinoIcons.arrow_up_right_square,
          ),
        if (item.path != null)
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

  Future<void> _relocateResource(String source, {bool copy = false}) async {
    final image = await openFile(
      acceptedTypeGroups: [
        XTypeGroup(
          label: t('图片', 'Images'),
          extensions: resourceImageExtensions,
        ),
      ],
    );
    if (image == null || !mounted) return;
    if (!await _ensureResourceDocument()) return;
    final newReference = await _resourceWork.run(t('更新图片', 'Updating image'), (
      token,
      progress,
    ) async {
      if (copy) {
        return (await _withResourceAccess(
          () => _resources.importImage(
            _path!,
            ResourceInput(name: image.name, path: image.path),
          ),
        )).reference;
      }
      await _resources.readImage(
        ResourceInput(name: image.name, path: image.path),
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
            '将保存当前内容并重命名文档。为兼容其他工具的引用，资源目录保留原名称。',
            'Current content will be saved. The asset folder keeps its name to preserve references from other tools.',
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
    final target = await getSaveLocation(
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
