import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Theme, Tooltip;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/editor_provider.dart';
import '../theme/marker_colors.dart';

List<TextRange> findEditorMatches(
  String text,
  String query, {
  bool caseSensitive = false,
}) {
  if (query.isEmpty) return const [];
  return [
    for (final match in RegExp(
      RegExp.escape(query),
      caseSensitive: caseSensitive,
    ).allMatches(text))
      TextRange(start: match.start, end: match.end),
  ];
}

TextEditingValue replaceEditorMatches(
  TextEditingValue value,
  String query,
  String replacement, {
  bool caseSensitive = false,
}) {
  final matches = findEditorMatches(
    value.text,
    query,
    caseSensitive: caseSensitive,
  );
  if (matches.isEmpty) return value;
  var text = value.text;
  for (final range in matches.reversed) {
    text = text.replaceRange(range.start, range.end, replacement);
  }
  return TextEditingValue(
    text: text,
    selection: TextSelection.collapsed(
      offset: (matches.first.start + replacement.length).clamp(0, text.length),
    ),
  );
}

class EditorSearchBar extends ConsumerStatefulWidget {
  const EditorSearchBar({
    super.key,
    required this.editor,
    required this.queryFocus,
    required this.onNext,
    required this.onPrevious,
    required this.onQuery,
    required this.onReplace,
    required this.onReplaceAll,
    required this.onClose,
  });
  final TextEditingController editor;
  final FocusNode queryFocus;
  final VoidCallback onNext,
      onPrevious,
      onQuery,
      onReplace,
      onReplaceAll,
      onClose;
  @override
  ConsumerState<EditorSearchBar> createState() => _EditorSearchBarState();
}

class _EditorSearchBarState extends ConsumerState<EditorSearchBar> {
  late final TextEditingController _query, _replacement;
  @override
  void initState() {
    super.initState();
    final state = ref.read(editorProvider);
    _query = TextEditingController(text: state.searchQuery);
    _replacement = TextEditingController(text: state.replacement);
  }

  @override
  void dispose() {
    _query.dispose();
    _replacement.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(editorProvider);
    final c = Theme.of(context).extension<MarkerColors>()!;
    final zh = Localizations.localeOf(context).languageCode == 'zh';
    final matches = findEditorMatches(
      widget.editor.text,
      state.searchQuery,
      caseSensitive: state.searchCaseSensitive,
    );
    final current = matches.indexWhere(
      (m) =>
          m.start == widget.editor.selection.start &&
          m.end == widget.editor.selection.end,
    );
    Widget icon(
      IconData icon,
      String tooltip,
      VoidCallback action, {
      Key? key,
    }) => Tooltip(
      message: tooltip,
      child: CupertinoButton(
        key: key,
        minimumSize: const Size(28, 28),
        padding: const EdgeInsets.all(4),
        onPressed: action,
        child: Icon(icon, size: 15, color: c.textSecondary),
      ),
    );
    return Container(
      key: const Key('editor-search-bar'),
      color: c.bgToolbar,
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 6),
      child: Column(
        children: [
          Row(
            children: [
              icon(
                state.replaceVisible
                    ? CupertinoIcons.chevron_down
                    : CupertinoIcons.chevron_right,
                zh ? '替换' : 'Replace',
                () => ref
                    .read(editorProvider.notifier)
                    .update(
                      (s) => s.copyWith(replaceVisible: !s.replaceVisible),
                    ),
              ),
              Expanded(
                child: CupertinoTextField(
                  key: const Key('search-query'),
                  focusNode: widget.queryFocus,
                  controller: _query,
                  autofocus: true,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 6,
                  ),
                  placeholder: zh ? '查找文本' : 'Find text',
                  style: TextStyle(fontSize: 12, color: c.textPrimary),
                  onChanged: (value) {
                    ref
                        .read(editorProvider.notifier)
                        .update((s) => s.copyWith(searchQuery: value));
                    widget.onQuery();
                  },
                  onSubmitted: (_) => widget.onNext(),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${current < 0 ? 0 : current + 1}/${matches.length}',
                style: TextStyle(fontSize: 11, color: c.textSecondary),
              ),
              CupertinoButton(
                minimumSize: const Size(30, 28),
                padding: EdgeInsets.zero,
                onPressed: () {
                  ref
                      .read(editorProvider.notifier)
                      .update(
                        (s) => s.copyWith(
                          searchCaseSensitive: !s.searchCaseSensitive,
                        ),
                      );
                  widget.onQuery();
                },
                child: Text(
                  'Aa',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: state.searchCaseSensitive
                        ? FontWeight.w700
                        : FontWeight.w400,
                    color: state.searchCaseSensitive
                        ? c.textAccent
                        : c.textSecondary,
                  ),
                ),
              ),
              icon(
                CupertinoIcons.chevron_up,
                zh ? '上一个' : 'Previous',
                widget.onPrevious,
                key: const Key('search-previous'),
              ),
              icon(
                CupertinoIcons.chevron_down,
                zh ? '下一个' : 'Next',
                widget.onNext,
                key: const Key('search-next'),
              ),
              icon(
                CupertinoIcons.xmark,
                zh ? '关闭搜索' : 'Close search',
                widget.onClose,
                key: const Key('search-close'),
              ),
            ],
          ),
          if (state.replaceVisible)
            Padding(
              padding: const EdgeInsets.only(top: 5, left: 28),
              child: Row(
                children: [
                  Expanded(
                    child: CupertinoTextField(
                      key: const Key('search-replacement'),
                      controller: _replacement,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 6,
                      ),
                      placeholder: zh ? '替换为' : 'Replace with',
                      style: TextStyle(fontSize: 12, color: c.textPrimary),
                      onChanged: (value) => ref
                          .read(editorProvider.notifier)
                          .update((s) => s.copyWith(replacement: value)),
                    ),
                  ),
                  CupertinoButton(
                    key: const Key('replace-current'),
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    onPressed: matches.isEmpty ? null : widget.onReplace,
                    child: Text(
                      zh ? '替换' : 'Replace',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  CupertinoButton(
                    key: const Key('replace-all'),
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    onPressed: matches.isEmpty ? null : widget.onReplaceAll,
                    child: Text(
                      zh ? '全部替换' : 'Replace all',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
