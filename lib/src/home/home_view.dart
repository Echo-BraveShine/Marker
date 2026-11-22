part of '../../main.dart';

extension _HomeView on _MarkerHomeState {
  Widget _buildHome(BuildContext context) {
    final editorState = ref.watch(editorProvider);
    final workspace = ref.watch(workspaceProvider);
    final resourceState = ref.watch(resourceUiProvider);
    final exporting = ref.watch(exportControllerProvider).isLoading;
    final c = Theme.of(context).extension<MarkerColors>()!;
    final offset = _controller.selection.isValid
        ? _controller.selection.extentOffset
        : 0;
    _lineIndex.update(_controller.text);
    final lineIndex = _lineIndex.lineAt(offset);
    final line = lineIndex + 1;
    final column = offset - _lineIndex.start(lineIndex) + 1;
    Widget button(IconData icon, String label, VoidCallback action) => Tooltip(
      message: label,
      child: SizedBox(
        width: 34,
        height: 28,
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          onPressed: _busy ? null : action,
          child: Icon(icon, size: 16, color: c.textSecondary),
        ),
      ),
    );
    _controller.searchQuery = editorState.searchVisible
        ? editorState.searchQuery
        : '';
    _controller.searchCaseSensitive = editorState.searchCaseSensitive;
    _controller.colors = c;
    _controller.highlightStyle = ref.watch(themeProvider).highlightStyle;
    _controller.highlightEnabled = ref.watch(themeProvider).highlightEnabled;
    MarkdownCommand commandByLabel(String label) => markdownCommandGroups.values
        .expand((items) => items)
        .firstWhere((command) => command.label == label);
    Widget syntaxControl(
      Widget icon,
      String label,
      VoidCallback action, {
      Key? key,
    }) => Tooltip(
      message: label,
      child: SizedBox(
        width: double.infinity,
        height: 28,
        child: CupertinoButton(
          key: key,
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          onPressed: _busy || _restoring ? null : action,
          child: icon,
        ),
      ),
    );
    final editorStyle = TextStyle(
      fontFamily: MarkerFonts.monospace,
      fontFamilyFallback: MarkerFonts.codeFallback,
      fontSize: _fontSize,
      height: 1.6,
      color: c.textPrimary,
    );
    final rawEditor = LinkedScrollRegion(
      link: _linkedScroll,
      controller: _editorScroll,
      child: KeyedSubtree(
        key: ValueKey(workspace.activeId),
        child: ColoredBox(
          color: c.bgEditor,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final digits = _lineIndex.length.toString().length;
              final numberMeasure = TextPainter(
                text: TextSpan(text: '9' * digits, style: editorStyle),
                textDirection: TextDirection.ltr,
                textScaler: MediaQuery.textScalerOf(context),
              )..layout();
              final gutterWidth = numberMeasure.width + 8;
              numberMeasure.dispose();
              return Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LineNumberGutter(
                    key: const Key('line-numbers'),
                    controller: _controller,
                    scrollController: _editorScroll,
                    style: editorStyle,
                    index: _lineIndex,
                    editable: _editable,
                    color: c.textTertiary,
                    width: gutterWidth,
                  ),
                  Expanded(
                    child: CupertinoTextField(
                      key: const Key('editor'),
                      scrollPadding: EdgeInsets.zero,
                      controller: _controller,
                      undoController: _undo,
                      focusNode: _focus,
                      readOnly: _restoring || resourceState.busy,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      style: editorStyle,
                      strutStyle: StrutStyle.fromTextStyle(
                        editorStyle,
                        forceStrutHeight: true,
                      ),
                      scrollController: _editorScroll,
                      minLines: null,
                      decoration: null,
                      padding: const EdgeInsets.fromLTRB(4, 10, 4, 10),
                      placeholder: _l10n.startWriting,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
    final editor = Actions(
      actions: <Type, Action<Intent>>{
        PasteTextIntent: CallbackAction<PasteTextIntent>(
          onInvoke: (_) {
            _pasteResourceOrText();
            return null;
          },
        ),
      },
      child: rawEditor,
    );
    final previewSignature = (
      _controller.text,
      _path,
      _serif,
      _imageEpoch,
      Theme.of(context),
      Localizations.localeOf(context),
      ref.watch(mermaidPreviewEnabledProvider),
    );
    if (_previewSignature != previewSignature) {
      _previewSignature = previewSignature;
      _previewCache = _buildPreview(c: c, context: context);
    }
    final preview = _previewCache!;
    return CallbackShortcuts(
      bindings: _shortcutBindings(),
      child: Focus(
        autofocus: true,
        child: _resourceDropZone(
          Scaffold(
            backgroundColor: c.bgWindow,
            body: Column(
              children: [
                if (desktopWindow &&
                    defaultTargetPlatform == TargetPlatform.macOS)
                  SizedBox(
                    height: 36,
                    child: DragToMoveArea(
                      child: Center(
                        child: Text(
                          '$_name${_dirty ? ' •' : ''}',
                          style: TextStyle(
                            fontSize: 12,
                            color: c.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  child: Row(
                    children: [
                      _buildSidebar(
                        c: c,
                        button: button,
                        resourceState: resourceState,
                        workspace: workspace,
                      ),
                      if (_sidebar)
                        MouseRegion(
                          cursor: SystemMouseCursors.resizeColumn,
                          child: GestureDetector(
                            key: const Key('sidebar-resize'),
                            behavior: HitTestBehavior.opaque,
                            onHorizontalDragUpdate: (details) => ref
                                .read(themeProvider.notifier)
                                .setSidebarWidth(
                                  ref.read(themeProvider).sidebarWidth +
                                      details.delta.dx,
                                ),
                            onHorizontalDragEnd: (_) => ref
                                .read(themeProvider.notifier)
                                .persistSidebarWidth(),
                            child: SizedBox(
                              width: 5,
                              child: Center(
                                child: Container(
                                  width: 1,
                                  color: c.separatorSoft,
                                ),
                              ),
                            ),
                          ),
                        ),
                      Expanded(
                        child: Column(
                          children: [
                            _buildToolbar(
                              c: c,
                              button: button,
                              syntaxControl: syntaxControl,
                              commandByLabel: commandByLabel,
                            ),
                            if (ref.watch(editorProvider).searchVisible)
                              EditorSearchBar(
                                editor: _controller,
                                queryFocus: _searchFocus,
                                onNext: () => _findMatch(),
                                onPrevious: () => _findMatch(forward: false),
                                onQuery: () => _findMatch(fromStart: true),
                                onReplace: _replaceMatch,
                                onReplaceAll: _replaceAllMatches,
                                onClose: _closeSearch,
                              ),
                            Expanded(
                              child: LayoutBuilder(
                                builder: (context, size) {
                                  Widget buildPanes() {
                                    if (_mode == 0) {
                                      return SizedBox.expand(child: editor);
                                    }
                                    if (_mode == 2) {
                                      return SizedBox.expand(child: preview);
                                    }
                                    if (size.maxWidth < 560) {
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Expanded(child: editor),
                                          const Divider(height: 1),
                                          Expanded(child: preview),
                                        ],
                                      );
                                    }
                                    return Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        SizedBox(
                                          width: (size.maxWidth - 8) * _ratio,
                                          child: editor,
                                        ),
                                        MouseRegion(
                                          cursor:
                                              SystemMouseCursors.resizeColumn,
                                          child: GestureDetector(
                                            onDoubleTap: () =>
                                                _update(() => _ratio = .5),
                                            onHorizontalDragUpdate: (d) =>
                                                _update(
                                                  () => _ratio =
                                                      (_ratio +
                                                              d.delta.dx /
                                                                  (size.maxWidth -
                                                                      8))
                                                          .clamp(.2, .8),
                                                ),
                                            child: Container(
                                              width: 8,
                                              color: c.bgToolbar,
                                              child: Center(
                                                child: Container(
                                                  width: 1,
                                                  color: c.separator,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(child: preview),
                                      ],
                                    );
                                  }

                                  final rightSpace =
                                      _mode == 1 && size.maxWidth >= 560
                                      ? (size.maxWidth - 8) * (1 - _ratio)
                                      : size.maxWidth;
                                  return Stack(
                                    children: [
                                      Positioned.fill(child: buildPanes()),
                                      if (ref
                                          .watch(editorProvider)
                                          .toolbarExpanded)
                                        Positioned(
                                          top: 10,
                                          bottom: 10,
                                          right: 10,
                                          width: (rightSpace - 20).clamp(
                                            40.0,
                                            340.0,
                                          ),
                                          child: MarkdownSyntaxPanel(
                                            enabled: !_busy && !_restoring,
                                            onCommand: _runMarkdownCommand,
                                            onClose: () => ref
                                                .read(editorProvider.notifier)
                                                .update(
                                                  (s) => s.copyWith(
                                                    toolbarExpanded: false,
                                                  ),
                                                ),
                                          ),
                                        ),
                                    ],
                                  );
                                },
                              ),
                            ),
                            DefaultTextStyle(
                              style: TextStyle(
                                fontSize: 11,
                                color: c.textTertiary,
                              ),
                              child: Container(
                                height: 24,
                                color: c.bgToolbar,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      t(
                                        '行 $line，列 $column',
                                        'Ln $line, Col $column',
                                      ),
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                    const Spacer(),
                                    Text(
                                      resourceState.busy
                                          ? '${resourceState.operation}${resourceState.total > 0 ? ' ${resourceState.done}/${resourceState.total}' : ''}'
                                          : exporting
                                          ? _l10n.exportingDocument
                                          : '${_lineIndex.characters} ${t('字符', 'characters')} · UTF-8 · Markdown',
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                    if (resourceState.busy)
                                      CupertinoButton(
                                        key: const Key(
                                          'stop-resource-operation',
                                        ),
                                        padding: const EdgeInsets.only(left: 8),
                                        minimumSize: const Size(0, 20),
                                        onPressed: _resourceWork.cancel,
                                        child: Text(
                                          _l10n.stop,
                                          style: const TextStyle(fontSize: 11),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
