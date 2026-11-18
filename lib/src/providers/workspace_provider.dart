import 'dart:convert';
import 'dart:io';
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
    final documents = <OpenDocument>[];
    for (final item in data['documents'] as List) {
      var doc = OpenDocument(
        id: item['id'] as String,
        path: item['path'] as String?,
        text: item['text'] as String,
        saved: item['saved'] as String,
        lastEdited: (item['lastEdited'] as num?)?.toInt() ?? 0,
      );
      if (!doc.dirty && doc.path != null) {
        try {
          final text = await File(doc.path!).readAsString();
          doc = doc.copyWith(text: text, saved: text);
        } catch (_) {
          /* Keep cached content if the file is missing or inaccessible. */
        }
      }
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
    return true;
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
    return _pending = _pending.catchError((Object _) {}).then((_) async {
      final prefs = await SharedPreferences.getInstance();
      if (!await prefs.setString('workspaceV1', raw)) {
        throw StateError('无法保存文档列表');
      }
    });
  }
}
