import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import '../mobile/mobile_path_restore.dart';
import '../resources/resource_references.dart';
import '../resources/resource_service.dart' show resolveResourceUri;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
part 'workspace_provider.freezed.dart';

@freezed
abstract class OpenDocument with _$OpenDocument {
  const OpenDocument._();
  const factory OpenDocument({
    required String id,
    String? path,
    required String text,
    required String saved,
    @Default(0) int lastEdited,
  }) = _OpenDocument;
  bool get dirty => text != saved;
  String get name => path?.split(RegExp(r'[/\\]')).last ?? 'Untitled.md';
}

@freezed
abstract class WorkspaceState with _$WorkspaceState {
  const factory WorkspaceState({
    @Default([]) List<OpenDocument> documents,
    String? activeId,
  }) = _WorkspaceState;
}

final workspaceProvider = NotifierProvider<WorkspaceNotifier, WorkspaceState>(
  WorkspaceNotifier.new,
);

class WorkspaceNotifier extends Notifier<WorkspaceState> {
  Future<void> _pending = Future.value();
  @override
  WorkspaceState build() => const WorkspaceState();
  OpenDocument? get active =>
      state.documents.where((d) => d.id == state.activeId).firstOrNull;
  Future<bool> restore() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('workspaceV1');
    if (raw == null) return false;
    final data = jsonDecode(raw) as Map<String, dynamic>;
    final root = await ref.read(mobileDocumentsRootProvider);
    if (!ref.mounted) return true;
    final paths = MobilePathRestore(
      root,
      data['mobileDocumentsRoot'] as String?,
    );
    final documents = <OpenDocument>[];
    for (final item in data['documents'] as List) {
      final oldPath = item['path'] as String?;
      var doc = OpenDocument(
        id: item['id'] as String,
        path: paths.restore(
          oldPath,
          relative: item['mobileRelativePath'] as String?,
        ),
        text: item['text'] as String,
        saved: item['saved'] as String,
        lastEdited: (item['lastEdited'] as num?)?.toInt() ?? 0,
      );
      if (!doc.dirty && doc.path != null) {
        try {
          final text = await File(doc.path!).readAsString();
          doc = doc.copyWith(
            text: await paths.images(text, oldPath, doc.path),
            saved: text,
          );
        } catch (_) {
          /* Keep cached content if the file is missing or inaccessible. */
        }
      }
      doc = doc.copyWith(text: await paths.images(doc.text, oldPath, doc.path));
      documents.add(doc);
    }
    if (!ref.mounted) return true;
    final requested = data['activeId'] as String?;
    state = WorkspaceState(
      documents: _ordered(documents),
      activeId: documents.any((d) => d.id == requested)
          ? requested
          : documents.firstOrNull?.id,
    );
    await syncDeletedFiles();
    return true;
  }

  /// Only confirmed missing paths count as deletion; access errors keep tabs open.
  static Future<bool> isDeleted(String path) async {
    try {
      await File(path).length();
      return false;
    } on FileSystemException catch (error) {
      return error.osError?.errorCode == 2 || error.osError?.errorCode == 3;
    }
  }

  Future<bool> syncDeletedFiles({bool Function()? canApply}) async {
    var changed = false;
    for (final candidate in state.documents.toList()) {
      if (candidate.path == null || !await isDeleted(candidate.path!)) continue;
      if (!ref.mounted || canApply?.call() == false) return changed;
      final current = state.documents
          .where((d) => d.id == candidate.id)
          .firstOrNull;
      if (current == null || current.path != candidate.path) continue;
      if (!current.dirty) {
        remove(current.id);
      } else {
        // A detached draft must keep resolving surviving images at their old location.
        final refs = await parseResourceReferencesAsync(current.text);
        final replacements = <String, String>{};
        for (final image in refs.images) {
          try {
            final uri = resolveResourceUri(image.source, current.path);
            if (uri.scheme == 'file') {
              replacements[image.source] = uri.toString();
            }
          } catch (_) {
            /* Keep unsupported references unchanged. */
          }
        }
        if (!ref.mounted || canApply?.call() == false) return changed;
        final latest = state.documents
            .where((d) => d.id == current.id)
            .firstOrNull;
        if (latest != current) continue;
        state = state.copyWith(
          documents: [
            for (final d in state.documents)
              if (d.id == current.id)
                d.copyWith(path: null, text: refs.rewrite(d.text, replacements))
              else
                d,
          ],
        );
      }
      changed = true;
    }
    return changed;
  }

  int _timestamp() {
    var latest = DateTime.now().microsecondsSinceEpoch;
    for (final document in state.documents) {
      if (document.lastEdited >= latest) latest = document.lastEdited + 1;
    }
    return latest;
  }

  List<OpenDocument> _ordered(Iterable<OpenDocument> entries) {
    final documents = entries.toList();
    final positions = {
      for (var i = 0; i < documents.length; i++) documents[i].id: i,
    };
    return documents..sort((a, b) {
      final order = b.lastEdited.compareTo(a.lastEdited);
      return order == 0 ? positions[a.id]!.compareTo(positions[b.id]!) : order;
    });
  }

  void add({required String text, required String saved, String? path}) {
    final document = OpenDocument(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      path: path,
      text: text,
      saved: saved,
      lastEdited: _timestamp(),
    );
    state = state.copyWith(
      documents: [document, ...state.documents],
      activeId: document.id,
    );
  }

  void select(String id) {
    if (state.documents.any((d) => d.id == id)) {
      state = state.copyWith(activeId: id);
    }
  }

  void snapshot(String text, String saved, String? path) {
    state = state.copyWith(
      documents: _ordered([
        for (final d in state.documents)
          if (d.id == state.activeId)
            d.copyWith(
              text: text,
              saved: saved,
              path: path,
              lastEdited: d.text != text ? _timestamp() : d.lastEdited,
            )
          else
            d,
      ]),
    );
  }

  bool refreshSaved(String id, String path, String baseline, String disk) {
    var changed = false;
    final documents = [
      for (final d in state.documents)
        if (d.id == id &&
            d.path == path &&
            !d.dirty &&
            d.saved == baseline &&
            d.text != disk)
          (() {
            changed = true;
            return d.copyWith(text: disk, saved: disk);
          })()
        else
          d,
    ];
    if (changed) state = state.copyWith(documents: documents);
    return changed;
  }

  void acknowledgeSaved(String id, String path, String text) {
    state = state.copyWith(
      documents: [
        for (final d in state.documents)
          if (d.id == id && d.path == path) d.copyWith(saved: text) else d,
      ],
    );
  }

  void remove(String id) {
    final index = state.documents.indexWhere((d) => d.id == id);
    final documents = state.documents.where((d) => d.id != id).toList();
    state = state.copyWith(
      documents: documents,
      activeId: state.activeId == id
          ? (documents.isEmpty
                ? null
                : documents[index.clamp(0, documents.length - 1)].id)
          : state.activeId,
    );
  }

  Future<void> persist() {
    final raw = jsonEncode({
      'activeId': state.activeId,
      'documents': [
        for (final d in state.documents)
          {
            'id': d.id,
            'path': d.path,
            'text': d.text,
            'saved': d.saved,
            'lastEdited': d.lastEdited,
          },
      ],
    });
    final rootFuture = ref.read(mobileDocumentsRootProvider);
    return _pending = _pending.catchError((Object _) {}).then((_) async {
      final root = await rootFuture;
      final data = jsonDecode(raw) as Map<String, dynamic>;
      if (root != null) {
        data['mobileDocumentsRoot'] = root;
        for (final item in data['documents'] as List) {
          final path = item['path'] as String?;
          if (path != null && p.isWithin(root, path)) {
            item['mobileRelativePath'] = p.relative(path, from: root);
          }
        }
      }
      final prefs = await SharedPreferences.getInstance();
      if (!await prefs.setString('workspaceV1', jsonEncode(data))) {
        throw StateError('无法保存文档列表');
      }
    });
  }
}
