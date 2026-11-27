part of '../../main.dart';

extension _HomeEditorActions on _MarkerHomeState {
  void _openSearch({bool replace = false}) {
    ref
        .read(editorProvider.notifier)
        .update(
          (s) => s.copyWith(
            searchVisible: true,
            replaceVisible: replace,
            mode: s.mode == 2 ? 1 : s.mode,
          ),
        );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _searchFocus.requestFocus();
    });
  }

  void _closeSearch() {
    ref
        .read(editorProvider.notifier)
        .update((s) => s.copyWith(searchVisible: false));
    _focus.requestFocus();
  }

  void _findMatch({bool forward = true, bool fromStart = false}) {
    final state = ref.read(editorProvider);
    final matches = findEditorMatches(
      _controller.text,
      state.searchQuery,
      caseSensitive: state.searchCaseSensitive,
    );
    if (matches.isEmpty) return;
    final selection = _controller.selection;
    final position = selection.isValid
        ? (forward ? selection.end : selection.start)
        : 0;
    final match = fromStart
        ? matches.first
        : forward
        ? matches.where((m) => m.start >= position).firstOrNull ?? matches.first
        : matches.where((m) => m.end <= position).lastOrNull ?? matches.last;
    _linkedScroll.takeEditorControl();
    _controller.selection = TextSelection(
      baseOffset: match.start,
      extentOffset: match.end,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _focus.context
          ?.findAncestorStateOfType<EditableTextState>()
          ?.bringIntoView(TextPosition(offset: match.start));
    });
  }

  void _replaceMatch() {
    if (_busy || _restoring) return;
    final state = ref.read(editorProvider);
    final matches = findEditorMatches(
      _controller.text,
      state.searchQuery,
      caseSensitive: state.searchCaseSensitive,
    );
    final selection = _controller.selection;
    if (!matches.any(
      (m) => m.start == selection.start && m.end == selection.end,
    )) {
      _findMatch(fromStart: true);
      return;
    }
    _controller.value = TextEditingValue(
      text: _controller.text.replaceRange(
        selection.start,
        selection.end,
        state.replacement,
      ),
      selection: TextSelection.collapsed(
        offset: selection.start + state.replacement.length,
      ),
    );
    _findMatch();
  }

  void _replaceAllMatches() {
    if (_busy || _restoring) return;
    final state = ref.read(editorProvider);
    _controller.value = replaceEditorMatches(
      _controller.value,
      state.searchQuery,
      state.replacement,
      caseSensitive: state.searchCaseSensitive,
    );
  }

  Map<ShortcutActivator, VoidCallback> _shortcutBindings() {
    void command(String label) => _runMarkdownCommand(
      markdownCommandGroups.values
          .expand((items) => items)
          .firstWhere((c) => c.label == label),
    );
    final actions = <String, VoidCallback>{
      'new': () => _action(_newFile),
      'open': () => _action(_open),
      'save': () => _action(() async {
        await _save();
      }),
      if (documentExportEnabled) 'export': _exportDocument,
      'saveAs': () => _action(() async {
        await _save(as: true);
      }),
      'close': () {
        final id = ref.read(workspaceProvider).activeId;
        if (id != null) _action(() => _closeDocument(id));
      },
      'find': () => _openSearch(),
      'replace': () => _openSearch(replace: true),
      'next': () => _findMatch(),
      'previous': () => _findMatch(forward: false),
      'bold': () => command('粗体'),
      'italic': () => command('斜体'),
      'code': () => command('行内代码'),
      'strike': () => command('删除线'),
      'editor': () => _mode = 0,
      'split': () => _mode = 1,
      'preview': () => _mode = 2,
      'sidebar': () => _sidebar = !_sidebar,
      'syntax': () => ref
          .read(editorProvider.notifier)
          .update((s) => s.copyWith(toolbarExpanded: !s.toolbarExpanded)),
      'settings': _settings,
      'quit': () {
        if (desktopWindow) onWindowClose();
      },
    };
    return {
      for (final shortcut in appShortcuts.where((s) => !s.native))
        shortcut.activator(defaultTargetPlatform): actions[shortcut.id]!,
      const SingleActivator(LogicalKeyboardKey.escape): () {
        if (ref.read(editorProvider).searchVisible) {
          _closeSearch();
        } else {
          ref
              .read(editorProvider.notifier)
              .update((s) => s.copyWith(toolbarExpanded: false));
        }
      },
    };
  }

  void _insertCommand(MarkdownCommand command) {
    if (_busy || _restoring) return;
    _controller.value = command.apply(_controller.value);
    _focus.requestFocus();
  }

  void _runMarkdownCommand(MarkdownCommand command) {
    if (command.label == 'Mermaid') {
      _chooseTemplate(math: false);
    } else if (command.label == '行内公式' || command.label == '块公式') {
      _chooseTemplate(math: true);
    } else if (command.label == '图片') {
      _importPictures();
    } else if (command.label == '文字颜色') {
      _chooseTextColor();
    } else {
      _insertCommand(command);
    }
  }

  Future<void> _chooseTextColor() async {
    if (_busy || _restoring) return;
    final original = _controller.value;
    final color = await showMarkerDialog<String>(
      context: context,
      builder: (_) => const TextColorPicker(),
    );
    if (!mounted || color == null) return;
    _controller.value = MarkdownCommand(
      '文字颜色',
      '<span style="color:$color">',
      '</span>',
      _l10n.textColor,
    ).apply(original);
    _focus.requestFocus();
  }

  Future<void> _chooseTemplate({required bool math}) async {
    if (_busy || _restoring) return;
    final original = _controller.value;
    final templates = math ? mathTemplates : mermaidTemplates;
    final template = await showMarkerDialog<MarkdownTemplate>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        final c = Theme.of(context).extension<MarkerColors>()!;
        return MarkerDialog(
          title: Text(math ? _l10n.equationTemplates : _l10n.mermaidTemplates),
          width: 560,
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _l10n.message(
                  AppMessage
                      .chooseATemplateToInsertSelectedTextReplacesTheSample,
                ),
                style: TextStyle(fontSize: 12, color: c.textSecondary),
              ),
              const SizedBox(height: 12),
              for (final item in templates)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: c.bgEditor,
                      border: Border.all(color: c.separatorSoft),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: CupertinoButton(
                      key: ValueKey('template-${item.id}'),
                      alignment: Alignment.centerLeft,
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.all(12),
                      onPressed: () => Navigator.pop(context, item),
                      child: SizedBox(
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.labelFor(_languageTag),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: c.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              item.source,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: MarkerFonts.monospace,
                                fontFamilyFallback: MarkerFonts.codeFallback,
                                fontSize: 11,
                                color: c.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          actions: [],
        );
      },
    );
    if (!mounted || template == null) return;
    _controller.value = template.command.apply(original);
    _focus.requestFocus();
  }
}
