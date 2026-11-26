part of '../../main.dart';

extension _HomeAutosave on _MarkerHomeState {
  Future<void> _flushAutosave({bool force = false}) async {
    if (!mounted || _restoring) return;
    _snapshot();
    await ref.read(autosaveProvider.notifier).flush(force: force);
    if (mounted) await _syncDeletedDocuments(duringSave: true);
  }

  void _handleAutosaveLifecycle(AppLifecycleState state) {
    if (!mounted || _restoring) return;
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      unawaited(
        _flushAutosave(force: true)
            .then((_) async {
              if (mounted) await _persist();
            })
            .catchError((Object error) {
              if (mounted) _error(error);
            }),
      );
    }
  }

  String _saveStatusText() {
    if (_path == null) return t('草稿 · 尚未保存到文件', 'Draft · Not saved to file');
    final status = ref.read(autosaveProvider)[_workspace.active?.id];
    return switch (status) {
      SaveStatus.saving => t('正在保存…', 'Saving…'),
      SaveStatus.failed => t('保存失败 · 点击重试', 'Save failed · Retry'),
      SaveStatus.conflict => t('磁盘内容已变更 · 点击处理', 'File changed · Resolve'),
      SaveStatus.deleted => t('文件已删除', 'File deleted'),
      _ => _dirty ? t('等待保存…', 'Pending save…') : t('已保存', 'Saved'),
    };
  }

  Future<bool> _resolveSaveConflict(String id) async {
    final choice = await _resourceChoice(
      t('磁盘文件已被修改', 'File changed on disk'),
      [
        (
          'load',
          t('加载磁盘版本', 'Load disk version'),
          CupertinoIcons.arrow_clockwise,
        ),
        (
          'mine',
          t('使用我的版本覆盖', 'Overwrite with my version'),
          CupertinoIcons.square_arrow_down,
        ),
        ('copy', _l10n.saveAs, CupertinoIcons.doc_on_doc),
      ],
      description: t(
        '自动保存已暂停，你的编辑已保留在草稿中。',
        'Autosave paused. Your edits are preserved as a draft.',
      ),
    );
    if (!mounted || _workspace.active?.id != id) return false;
    if (choice == 'copy') return _save(as: true);
    if (choice == 'mine') {
      final ok = await ref
          .read(autosaveProvider.notifier)
          .saveDocument(id, overwrite: true);
      if (ok) await _persist();
      return ok;
    }
    if (choice == 'load' && _path != null) {
      final text = await File(_path!).readAsString();
      _workspace.snapshot(text, text, _path);
      ref.read(autosaveProvider.notifier).retry(id);
      _loadActive();
      await _persist();
      return true;
    }
    return false;
  }
}
