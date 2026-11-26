part of '../../main.dart';

extension _HomeExternalFiles on _MarkerHomeState {
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
    if (_isMobile) {
      _mobileOpenFiles = ref.read(mobileOpenFilesProvider);
      try {
        await _mobileOpenFiles!.connect(_queueMobileFiles);
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

  void _queueMobileFiles(List<MobileOpenFile> files) {
    if (!mounted) return;
    for (final file in files) {
      if (_receivedMobileTokens.add(file.token)) _pendingMobileFiles.add(file);
    }
    while (_receivedMobileTokens.length > 256) {
      _receivedMobileTokens.remove(_receivedMobileTokens.first);
    }
    _drainExternalFiles();
  }

  void _drainExternalFiles() {
    if (!mounted ||
        _restoring ||
        _busy ||
        (_pendingOpenFiles.isEmpty && _pendingMobileFiles.isEmpty)) {
      return;
    }
    _action(() async {
      var opened = 0, failed = 0;
      while (mounted &&
          (_pendingOpenFiles.isNotEmpty || _pendingMobileFiles.isNotEmpty)) {
        if (_pendingMobileFiles.isNotEmpty) {
          final file = _pendingMobileFiles.removeAt(0);
          try {
            if (file.error != null) {
              throw ResourceFailure(
                '无法导入文件：${file.error}',
                'Cannot import file: ${file.error}',
              );
            }
            await _importMobileFile(
              XFile(file.path!),
              ownedRelativePath: file.ownedRelativePath,
            );
            opened++;
          } catch (error) {
            failed++;
            _error(error);
          } finally {
            try {
              await _mobileOpenFiles?.acknowledge(file.token);
            } catch (error) {
              debugPrint('Incoming file cleanup failed: $error');
            }
          }
        } else {
          final path = _pendingOpenFiles.removeAt(0);
          try {
            await _openPath(path);
          } catch (error) {
            _error(error);
          }
        }
      }
      if (mounted && opened > 0 && failed > 0) {
        _toast(
          t(
            '部分文件导入失败（$failed 份），其余文档已打开。',
            '$failed file(s) could not be imported. The other documents are open.',
          ),
        );
      }
    });
  }

  Future<void> _importMobileFile(
    XFile file, {
    String? ownedRelativePath,
  }) async {
    _focus.unfocus();
    final imported = await ref
        .read(mobileDocumentStoreProvider)
        .openImportedDocument(file, ownedRelativePath: ownedRelativePath);
    if (!mounted) return;
    await _openPath(imported.path);
    if (!mounted) return;
    final inventory = await _resources.scan(_controller.text, imported.path);
    if (!mounted) return;
    if (inventory.unresolved.isNotEmpty) {
      _toast(
        t(
          '文档已打开，部分图片缺失。请导入包含文档与图片的 ZIP。',
          'Document opened with missing images. Import a ZIP containing the document and images.',
        ),
      );
    } else {
      _toast(
        imported.reused
            ? t('已打开 Marker 中的文档副本。', 'Opened the existing copy in Marker.')
            : t(
                '已导入文档副本，编辑不会修改原文件。',
                'Imported a copy. Edits will not change the original file.',
              ),
      );
    }
  }
}
