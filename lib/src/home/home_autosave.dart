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
    if (_path == null) return _l10n.message(AppMessage.draftNotSavedToFile);
    final status = ref.read(autosaveProvider)[_workspace.active?.id];
    return switch (status) {
      SaveStatus.saving => _l10n.message(AppMessage.saving),
      SaveStatus.failed => _l10n.message(AppMessage.saveFailedRetry),
      SaveStatus.conflict => _l10n.message(AppMessage.fileChangedResolve),
      SaveStatus.deleted => _l10n.message(AppMessage.fileDeleted),
      _ =>
        _dirty
            ? _l10n.message(AppMessage.pendingSave)
            : _l10n.message(AppMessage.saved),
    };
  }

  Future<bool> _resolveSaveConflict(String id) async {
    final choice = await _resourceChoice(
      _l10n.message(AppMessage.fileChangedOnDisk),
      [
        (
          'load',
          _l10n.message(AppMessage.loadDiskVersion),
          CupertinoIcons.arrow_clockwise,
        ),
        (
          'mine',
          _l10n.message(AppMessage.overwriteWithMyVersion),
          CupertinoIcons.square_arrow_down,
        ),
        ('copy', _l10n.saveAs, CupertinoIcons.doc_on_doc),
      ],
      description: _l10n.message(
        AppMessage.autosavePausedYourEditsArePreservedAsADraft,
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
