part of '../../main.dart';

extension _HomeDiskSync on _MarkerHomeState {
  Future<void> _syncDeletedDocuments({bool duringSave = false}) async {
    if (_syncingDisk && duringSave) {
      await _diskSyncCompletion?.future;
    }
    if (!mounted || _restoring || _syncingDisk || (!duringSave && _busy)) {
      return;
    }
    _syncingDisk = true;
    final completion = _diskSyncCompletion = Completer<void>();
    try {
      _snapshot();
      final previous = _workspace.active;
      var changed = await _workspace.syncDeletedFiles(
        canApply: () => mounted && (duringSave || !_busy),
      );
      if (!mounted) return;
      if (duringSave || !_busy) {
        changed =
            await ref.read(autosaveProvider.notifier).refreshExternal() ||
            changed;
      }
      if (!mounted || !changed) return;
      if (_workspace.active != previous) _loadActive();
      await _persist();
      if (mounted) {
        _toast(
          _l10n.message(AppMessage.diskChangesSyncedUnsavedEditsWerePreserved),
        );
      }
    } catch (error) {
      if (mounted) _error(error);
    } finally {
      _syncingDisk = false;
      completion.complete();
      _diskSyncCompletion = null;
    }
  }
}
