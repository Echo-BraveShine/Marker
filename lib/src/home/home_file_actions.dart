part of '../../main.dart';

extension _HomeFileActions on _MarkerHomeState {
  Future<bool> _save({bool as = false}) async {
    var text = _controller.text;
    try {
      final sourcePath = _path;
      var path = sourcePath;
      if (as || path == null) {
        final target = await getSaveLocation(suggestedName: _name);
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
      final references = copying
          ? await parseResourceReferencesAsync(text)
          : null;
      if (copying &&
          (references!.images.isNotEmpty ||
              references.unsupported.isNotEmpty)) {
        final inventory = await _resources.scan(text, sourcePath);
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
                sourcePath: sourcePath,
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
          builder: (context) => ExportOptionsPanel(zh: _zh),
        );
        if (options == null || !mounted) return;
        final basename = title.replaceFirst(
          RegExp(r'\.(md|markdown)$', caseSensitive: false),
          '',
        );
        final extension = options.format.name;
        final target = await getSaveLocation(
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
      await action();
    } on ResourceCancelled {
      if (mounted) _toast(t('已停止后续资源处理', 'Remaining work stopped'));
    } catch (e) {
      _error(e);
    } finally {
      if (mounted) {
        _update(() => _busy = false);
        _drainExternalFiles();
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
    final location = await getSaveLocation(
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
    await XFile.fromData(
      Uint8List(0),
      mimeType: 'text/markdown',
    ).saveTo(location.path);
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
        const XTypeGroup(
          label: 'Markdown',
          extensions: ['md', 'markdown', 'txt'],
        ),
      ],
    );
    if (file == null) return;
    await _openPath(file.path);
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
