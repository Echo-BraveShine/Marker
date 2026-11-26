import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'sample_markdown.dart';
export 'sample_markdown.dart';
part 'editor_provider.freezed.dart';

@freezed
abstract class EditorState with _$EditorState {
  const EditorState._();
  const factory EditorState({
    @Default(defaultMarkdown) String markdown,
    @Default(defaultMarkdown) String saved,
    String? path,
    @Default(true) bool restoring,
    @Default(true) bool sidebar,
    @Default(false) bool busy,
    @Default(14) double fontSize,
    @Default(false) bool serif,
    @Default(1) int mode,
    @Default(false) bool searchVisible,
    @Default(false) bool replaceVisible,
    @Default('') String searchQuery,
    @Default('') String replacement,
    @Default(false) bool searchCaseSensitive,
    @Default(false) bool toolbarExpanded,
    @Default(0) int settingsPage,
    @Default(.5) double ratio,
    @Default(1) int cursorLine,
    @Default(1) int cursorColumn,
  }) = _EditorState;
  bool get dirty => markdown != saved;
}

final editorProvider = NotifierProvider<EditorNotifier, EditorState>(
  EditorNotifier.new,
);

class EditorNotifier extends Notifier<EditorState> {
  @override
  EditorState build() => const EditorState();
  void update(EditorState Function(EditorState) change) =>
      state = change(state);
  void setMarkdown(String text) => state = state.copyWith(markdown: text);
  void markSaved() => state = state.copyWith(saved: state.markdown);
}
