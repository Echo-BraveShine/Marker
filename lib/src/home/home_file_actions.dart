part of '../../main.dart';

extension _HomeFileActions on _MarkerHomeState {
  Future<bool> _save({bool as = false}) async {
    if (as) await ref.read(autosaveProvider.notifier).flush(force: true);
    final activeId = _workspace.active?.id;
    await _syncDeletedDocuments(duringSave: true);
    if (!mounted || _workspace.active?.id != activeId) return false;
    var text = _controller.text;
    if (!as && _path != null && activeId != null) {
      await ref.read(autosaveProvider.notifier).flush(force: true);
      final status = ref.read(autosaveProvider)[activeId];
      if (status == SaveStatus.conflict) return _resolveSaveConflict(activeId);
      ref.read(autosaveProvider.notifier).retry(activeId);
      var saved = await ref
          .read(autosaveProvider.notifier)
          .saveDocument(activeId);
      if (!saved &&
          mounted &&
          ref.read(autosaveProvider)[activeId] == SaveStatus.conflict) {
        return _resolveSaveConflict(activeId);
      }
      final error = ref.read(autosaveProvider.notifier).errorFor(activeId);
      if (!saved &&
          mounted &&
          defaultTargetPlatform == TargetPlatform.macOS &&
          error is FileSystemException &&
          [1, 13].contains(error.osError?.errorCode)) {
        await _authorizeResourceFolder(p.dirname(_path!));
        saved = await ref
            .read(autosaveProvider.notifier)
            .saveDocument(activeId);
      }
      if (saved) {
        await _persist();
        return true;
      }
      if (!mounted) return false;
      final choice = await _resourceChoice(
        t('保存失败', 'Save failed'),
        [
          ('retry', t('重试', 'Retry'), CupertinoIcons.arrow_clockwise),
          ('copy', _l10n.saveAs, CupertinoIcons.doc_on_doc),
        ],
        description: t(
          '编辑已保留为草稿。请检查目录权限和可用空间。',
          'Your edits are kept as a draft. Check folder access and free space.',
        ),
      );
      if (!mounted) return false;
      if (choice == 'copy') return _save(as: true);
      if (choice == 'retry') return _save();
      return false;
    }
    try {
      final sourcePath = _path;
      var path = sourcePath;
      if (as || path == null) {
        final target = await _chooseSaveLocation(suggestedName: _name);
        if (target == null) return false;
        path = target.path;
      }
      final targetPath = path;
      final duplicate = ref
          .read(workspaceProvider)
          .documents
          .where(
            (d) =>
                d.path != null &&
                p.equals(d.path!, targetPath) &&
                d.id != ref.read(workspaceProvider).activeId,
          )
          .firstOrNull;
      if (duplicate != null) {
        _toast(_l10n.pathConflict);
        return false;
      }
      final copying = sourcePath != null && !p.equals(sourcePath, targetPath);
      final references = (copying || sourcePath == null)
          ? await parseResourceReferencesAsync(text)
          : null;
      if ((copying || sourcePath == null) &&
          (references!.images.isNotEmpty ||
              references.unsupported.isNotEmpty)) {
        final inventory = await _resources.scan(text, sourcePath ?? targetPath);
        if (!mounted || !await _confirmResourceIssues(inventory)) return false;
        var download = false;
        if (inventory.items.any(
          (i) => i.availability == ResourceAvailability.remote,
        )) {
          final decision = await _resourceCollectionChoice(
            _l10n.saveAs,
            inventory,
            standalone: true,
          );
          if (decision == null) return false;
          download = decision;
        }
        final result = await _retryIncomplete(
          (allow) => _resourceWork.run(
            _l10n.saveChanges,
            (token, progress) => _withResourceAccess(
              () => _resources.saveCopy(
                text: text,
                sourcePath: sourcePath ?? targetPath,
                targetPath: targetPath,
                downloadRemote: download,
                allowIncomplete: allow,
                cancellation: token,
                onProgress: progress,
              ),
              directory: p.dirname(targetPath),
            ),
          ),
          allowIncomplete:
              inventory.unresolved.isNotEmpty ||
              inventory.unsupported.isNotEmpty,
        );

        text = result.text;
        if (result.issues.isNotEmpty && mounted) {
          await _showResourceIssues(
            result.issues.map(_resourceIssueText).toList(),
          );
        }
      } else {
        await _withResourceAccess(
          () => _resources.atomicWrite(File(targetPath), text),
          directory: p.dirname(targetPath),
        );
      }
      if (!mounted) return true;
      if (copying) {
        _snapshot();
        _workspace.add(text: text, saved: text, path: targetPath);
        _loadActive();
      } else {
        if (_workspace.active == null) {
          _workspace.add(text: text, saved: text, path: targetPath);
        }
        _path = targetPath;
        _saved = text;
        if (_controller.text != text) {
          _switchingDocument = true;
          _controller.text = text;
          _switchingDocument = false;
          _changed();
        }
      }
      await _persist();
      return true;
    } on ResourceCancelled {
      if (mounted) {
        _toast(
          t(
            '已取消保存，文档内容已保留。',
            'Save cancelled. Your document content is preserved.',
          ),
        );
      }
      return false;
    } catch (e) {
      _error(e);
      return false;
    }
  }

  Future<void> _exportDocument() async {
    if (_busy || _restoring) return;
    // Capture the unsaved document before either asynchronous dialog opens.
    final source = _controller.text, documentPath = _path, title = _name;
    final dark = Theme.of(context).brightness == Brightness.dark;
    await _action(() async {
      try {
        await ref.read(exportAppearanceProvider.notifier).ready;
        if (!mounted) return;
        final options = await showMarkerDialog<DocumentExportOptions>(
          context: context,
          builder: (context) => ExportOptionsPanel(zh: _zh, mobile: _isMobile),
        );
        if (options == null || !mounted) return;
        final basename = title.replaceFirst(
          RegExp(r'\.(md|markdown)$', caseSensitive: false),
          '',
        );
        if (_isMobile) {
          final split =
              options.format == DocumentExportFormat.png && options.splitPng;
          final extension = split ? 'zip' : options.format.name;
          final bytes = await ref
              .read(exportControllerProvider.notifier)
              .export(
                source: source,
                title: title,
                documentPath: documentPath,
                options: options,
                dark: dark,
              );
          final saved = await FilePicker.saveFile(
            fileName: split ? '$basename-images.zip' : '$basename.$extension',
            bytes: bytes,
            mimeType: split
                ? 'application/zip'
                : switch (options.format) {
                    DocumentExportFormat.pdf => 'application/pdf',
                    DocumentExportFormat.png => 'image/png',
                    DocumentExportFormat.html => 'text/html',
                  },
          );
          if (mounted && saved != null) _toast(t('导出完成。', 'Export complete.'));
          return;
        }
        final extension = options.format.name;
        final target = await _chooseSaveLocation(
          suggestedName: '$basename.$extension',
          acceptedTypeGroups: [
            XTypeGroup(label: extension.toUpperCase(), extensions: [extension]),
          ],
        );
        if (target == null || !mounted) return;
        final writer = ExportDestinationWriter();
        // Reject unsafe destinations before the expensive renderer starts.
        final destination = writer.resolvePath(
          target.path,
          extension: extension,
          sourcePath: documentPath,
        );
        Future<Uint8List> render() => ref
            .read(exportControllerProvider.notifier)
            .export(
              source: source,
              title: title,
              documentPath: documentPath,
              options: options,
              dark: dark,
            );
        final bytes = documentPath == null
            ? await render()
            : await _withResourceAccess(
                render,
                directory: p.dirname(documentPath),
              );
        if (!mounted) return;
        final savedPath = await _withResourceAccess(
          () => writer.write(
            bytes,
            selectedPath: target.path,
            extension: extension,
            sourcePath: documentPath,
          ),
          directory: p.dirname(destination),
        );
        if (mounted) _toast(t('已导出到 $savedPath', 'Exported to $savedPath'));
      } on ResourceCancelled {
        // Cancelling source-folder authorization leaves the destination intact.
        return;
      } catch (error) {
        if (!mounted) return;
        await showMarkerDialog<void>(
          context: context,
          builder: (_) => MarkerDialog(
            title: Text(_l10n.unableToExport),
            content: Text(exportFailureMessage(error, chinese: _zh)),
          ),
        );
      }
    });
  }

  Future<void> _action(Future<void> Function() action) async {
    if (_busy || _restoring) return;
    _update(() => _busy = true);
    try {
      await ref.read(autosaveProvider.notifier).waitForIdle();
      if (!mounted) return;
      await action();
    } on ResourceCancelled {
      if (mounted) _toast(t('已停止后续资源处理', 'Remaining work stopped'));
    } catch (e) {
      _error(e);
    } finally {
      if (mounted) {
        _update(() => _busy = false);
        if (_closeRequested && desktopWindow) {
          _closeRequested = false;
          scheduleMicrotask(onWindowClose);
        } else {
          _drainExternalFiles();
        }
      }
    }
  }

  Future<void> _connectExternalFiles() async {
    if (desktopWindow && defaultTargetPlatform == TargetPlatform.macOS) {
      _MarkerHomeState._filesChannel.setMethodCallHandler((call) async {
        if (call.method == 'openFiles') {
          _queueExternalFiles((call.arguments as List).cast<String>());
        }
      });
      try {
        final initial = await _MarkerHomeState._filesChannel
            .invokeListMethod<String>('start');
        if (mounted) _queueExternalFiles(initial ?? const []);
      } catch (error) {
        if (mounted) _error(error);
      }
    }
    if (mounted) _queueExternalFiles(ref.read(initialFilesProvider));
  }

  void _queueExternalFiles(Iterable<String> paths) {
    for (final path in markdownOpenPaths(paths)) {
      if (!_pendingOpenFiles.contains(path)) _pendingOpenFiles.add(path);
    }
    _drainExternalFiles();
  }

  void _drainExternalFiles() {
    if (!mounted || _restoring || _busy || _pendingOpenFiles.isEmpty) return;
    _action(() async {
      while (mounted && _pendingOpenFiles.isNotEmpty) {
        final path = _pendingOpenFiles.removeAt(0);
        try {
          await _openPath(path);
        } catch (error) {
          _error(error);
        }
      }
    });
  }

  Future<void> _newFile() async {
    final location = _isMobile
        ? FileSaveLocation(await MobileDocumentStore().newDocumentPath())
        : await _chooseSaveLocation(
            suggestedName: 'Untitled.md',
            acceptedTypeGroups: [
              const XTypeGroup(label: 'Markdown', extensions: ['md']),
            ],
          );
    if (location == null || !mounted) return;
    final existing = ref
        .read(workspaceProvider)
        .documents
        .where((d) => d.path == location.path)
        .firstOrNull;
    if (existing != null) {
      await _selectDocument(existing.id);
      _toast(t('此文件已打开', 'This file is already open'));
      return;
    }
    if (await File(location.path).exists()) {
      await _openPath(location.path);
      if (mounted) {
        _toast(
          t(
            '已打开现有文件，未覆盖原内容。',
            'Opened the existing file without overwriting it.',
          ),
        );
      }
      return;
    }
    // Keep the current document intact until creating the selected file succeeds.
    await _withResourceAccess(
      () => _resources.atomicWrite(File(location.path), ''),
      directory: p.dirname(location.path),
    );
    if (!mounted) return;
    _snapshot();
    _workspace.add(text: '', saved: '', path: location.path);
    _loadActive();
    await _persist();
    if (desktopWindow) await windowManager.setTitle(_name);
    _focus.requestFocus();
  }

  Future<void> _open() async {
    final file = await openFile(
      acceptedTypeGroups: [
        XTypeGroup(
          label: 'Markdown',
          extensions: ['md', 'markdown', 'txt', if (_isMobile) 'zip'],
          uniformTypeIdentifiers: const [
            'public.text',
            'net.daringfireball.markdown',
            'public.zip-archive',
          ],
        ),
      ],
    );
    if (file == null) return;
    final path = _isMobile
        ? await MobileDocumentStore().importDocument(file)
        : file.path;
    await _openPath(path);
    if (_isMobile && mounted) {
      _toast(
        t(
          '已导入文档副本，编辑不会修改原文件。',
          'Imported a copy. Edits will not change the original file.',
        ),
      );
    }
  }

  Future<void> _openPath(String input) async {
    final path = File(input).absolute.path;
    final existing = ref
        .read(workspaceProvider)
        .documents
        .where((d) => d.path == path)
        .firstOrNull;
    if (existing != null) {
      await _selectDocument(existing.id);
      return;
    }
    final text = await File(path).readAsString();
    if (!mounted) return;
    _snapshot();
    _workspace.add(text: text, saved: text, path: path);
    _loadActive();
    await _persist();
  }
}
