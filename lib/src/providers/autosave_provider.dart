import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'editor_provider.dart';
import 'workspace_provider.dart';
import '../resources/resource_provider.dart';
import '../resources/resource_service.dart' show ResourceConflict;

enum SaveStatus { pending, saving, saved, failed, conflict, deleted }

final autosaveProvider =
    NotifierProvider<AutosaveController, Map<String, SaveStatus>>(
      AutosaveController.new,
    );

/// All disk writes use captured document identities and a serialized queue.
class AutosaveController extends Notifier<Map<String, SaveStatus>> {
  Timer? _debounce, _deadline;
  final _errors = <String, Object>{};
  Object? errorFor(String id) => _errors[id];
  final _stats = <String, ({DateTime modified, int size})>{};
  Future<void> _queue = Future.value();
  @override
  Map<String, SaveStatus> build() {
    ref.onDispose(() {
      _debounce?.cancel();
      _deadline?.cancel();
    });
    ref.listen(workspaceProvider, (previous, next) {
      if (next.documents.any(
        (d) =>
            d.path != null &&
            d.dirty &&
            previous?.documents
                    .where(
                      (old) =>
                          old.id == d.id &&
                          old.text == d.text &&
                          old.path == d.path,
                    )
                    .isEmpty !=
                false,
      )) {
        for (final d in next.documents.where(
          (d) => d.path != null && d.dirty,
        )) {
          if (state[d.id] != SaveStatus.conflict &&
              state[d.id] != SaveStatus.failed) {
            state = {...state, d.id: SaveStatus.pending};
          }
        }
        _debounce?.cancel();
        _debounce = Timer(
          const Duration(milliseconds: 800),
          () => unawaited(flush()),
        );
        _deadline ??= Timer(
          const Duration(seconds: 5),
          () => unawaited(flush()),
        );
      }
    });
    ref.listen(editorProvider.select((s) => s.busy), (previous, next) {
      if (previous == true && !next) unawaited(flush());
    });
    return {};
  }

  bool get _busy =>
      ref.read(editorProvider).busy || ref.read(resourceUiProvider).busy;
  void _status(String id, SaveStatus value) {
    if (ref.mounted) state = {...state, id: value};
  }

  Future<void> waitForIdle() => _queue;

  Future<void> flush({bool force = false}) {
    _debounce?.cancel();
    _deadline?.cancel();
    _deadline = null;
    _queue = _queue.catchError((Object _) {}).then((_) async {
      if (!ref.mounted ||
          (ref.read(resourceUiProvider).busy || (!force && _busy))) {
        return;
      }
      final ids = ref
          .read(workspaceProvider)
          .documents
          .where((d) => d.path != null && d.dirty)
          .map((d) => d.id)
          .toList();
      for (final id in ids) {
        if (!ref.mounted ||
            (ref.read(resourceUiProvider).busy || (!force && _busy))) {
          return;
        }
        if ([
          SaveStatus.conflict,
          SaveStatus.failed,
          SaveStatus.deleted,
        ].contains(state[id])) {
          continue;
        }
        await _writeDocument(id);
      }
    });
    return _queue;
  }

  Future<bool> saveDocument(String id, {bool overwrite = false}) {
    final result = _queue
        .catchError((Object _) {})
        .then((_) => _writeDocument(id, overwrite: overwrite));
    _queue = result.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return result;
  }

  Future<bool> _writeDocument(String id, {bool overwrite = false}) async {
    final workspace = ref.read(workspaceProvider.notifier);
    final doc = ref
        .read(workspaceProvider)
        .documents
        .where((d) => d.id == id)
        .firstOrNull;
    if (doc == null || doc.path == null) return false;
    if (!doc.dirty && !overwrite) {
      _status(id, SaveStatus.saved);
      return true;
    }
    _errors.remove(id);
    _status(id, SaveStatus.saving);
    try {
      final file = File(doc.path!);
      final disk = await file.readAsString();
      if (!ref.mounted) return false;
      if (!overwrite && disk != doc.saved && disk != doc.text) {
        _status(id, SaveStatus.conflict);
        return false;
      }
      final current = ref
          .read(workspaceProvider)
          .documents
          .where((d) => d.id == id)
          .firstOrNull;
      if (current == null || current.path != doc.path) return false;
      if (disk != doc.text) {
        await ref
            .read(resourceServiceProvider)
            .updateExistingDocument(file, doc.text, disk);
      }
      if (!ref.mounted) return false;
      workspace.acknowledgeSaved(id, doc.path!, doc.text);
      final latest = ref
          .read(workspaceProvider)
          .documents
          .where((d) => d.id == id)
          .firstOrNull;
      _status(
        id,
        latest?.dirty == true ? SaveStatus.pending : SaveStatus.saved,
      );
      await workspace.persist();
      return true;
    } on ResourceConflict {
      _status(id, SaveStatus.conflict);
    } on FileSystemException catch (error) {
      _errors[id] = error;
      _status(
        id,
        [2, 3].contains(error.osError?.errorCode)
            ? SaveStatus.deleted
            : SaveStatus.failed,
      );
    } catch (error) {
      _errors[id] = error;
      _status(id, SaveStatus.failed);
    }
    return false;
  }

  Future<bool> refreshExternal() async {
    var changed = false;
    for (final doc in ref.read(workspaceProvider).documents.toList()) {
      if (doc.path == null || doc.dirty) continue;
      try {
        final file = File(doc.path!);
        final stat = await file.stat();
        final signature = (modified: stat.modified, size: stat.size);
        if (stat.type != FileSystemEntityType.file ||
            _stats[doc.path] == signature) {
          continue;
        }
        _stats[doc.path!] = signature;
        final disk = await file.readAsString();
        if (!ref.mounted) return changed;
        final refreshed = ref
            .read(workspaceProvider.notifier)
            .refreshSaved(doc.id, doc.path!, doc.saved, disk);
        if (refreshed) _status(doc.id, SaveStatus.saved);
        changed = refreshed || changed;
      } on FileSystemException {
        /* Missing files are handled by deletion sync. */
      } on FormatException {
        _status(doc.id, SaveStatus.failed);
      }
    }
    return changed;
  }

  void retry(String id) {
    _status(id, SaveStatus.pending);
  }
}
