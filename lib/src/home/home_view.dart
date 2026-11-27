part of '../../main.dart';

extension _HomeView on _MarkerHomeState {
  Widget _buildHome(BuildContext context) {
    ref.watch(autosaveProvider);
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
                      onTapOutside: _isMobile ? (_) => _focus.unfocus() : null,
                      readOnly: _busy || _restoring || resourceState.busy,
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
                      padding: MarkerStyle.documentPadding,
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
    final editor = KeyedSubtree(
      key: _editorMountKey,
      child: Actions(
        actions: <Type, Action<Intent>>{
          PasteTextIntent: CallbackAction<PasteTextIntent>(
            onInvoke: (_) {
              _pasteResourceOrText();
              return null;
            },
          ),
        },
        child: Padding(
          padding: EdgeInsets.only(
            right: _isMobile && _mode != 1
                ? MobileCutoutArea.insetsOf(context).right
                : 0,
          ),
          child: rawEditor,
        ),
      ),
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
    final preview = Padding(
      padding: EdgeInsets.only(
        right: _isMobile ? MobileCutoutArea.insetsOf(context).right : 0,
      ),
      child: MermaidPreload(
        source: _controller.text,
        dark: Theme.of(context).brightness == Brightness.dark,
        enabled: _mode != 0 && ref.watch(mermaidPreviewEnabledProvider),
        controllers: [_editorScroll, _previewScroll],
        child: _previewCache!,
      ),
    );
    return CallbackShortcuts(
      bindings: _shortcutBindings(),
      child: Focus(
        autofocus: true,
        child: _resourceDropZone(
          MobileWorkbenchSurface(
            enabled: _isMobile,
            colors: c,
            editorOnly: _mode == 0,
            child: SafeArea(
              left: !_isMobile,
              right: !_isMobile,
              top: !_isMobile,
              bottom: !_isMobile,
              minimum: _isMobile
                  ? const EdgeInsets.symmetric(horizontal: 16)
                  : EdgeInsets.zero,
              // Android 系统栏已在缩放视口外避让；移动端此处仅保留圆角边距。
              maintainBottomViewPadding: true,
              child: Scaffold(
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
                          if (_sidebar && !_isMobile)
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
                                    onPrevious: () =>
                                        _findMatch(forward: false),
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
                                          return Stack(
                                            fit: StackFit.expand,
                                            children: [
                                              Offstage(
                                                child: ExcludeFocus(
                                                  child: editor,
                                                ),
                                              ),
                                              preview,
                                            ],
                                          );
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
                                              width:
                                                  (size.maxWidth - 8) * _ratio,
                                              child: editor,
                                            ),
                                            MouseRegion(
                                              cursor: SystemMouseCursors
                                                  .resizeColumn,
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
                                                    .read(
                                                      editorProvider.notifier,
                                                    )
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
                                    key: const Key('document-status-bar'),
                                    height: 24,
                                    color: c.bgToolbar,
                                    padding: EdgeInsets.fromLTRB(
                                      16,
                                      0,
                                      16 +
                                          (_isMobile
                                              ? MobileCutoutArea.controlsOf(
                                                  context,
                                                ).right
                                              : 0),
                                      0,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            _l10n.message(
                                              AppMessage.lnValueColValue,
                                              {"p0": line, "p1": column},
                                            ),
                                            style: const TextStyle(
                                              fontSize: 11,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Flexible(
                                          flex: 3,
                                          child: CupertinoButton(
                                            key: const Key('save-status'),
                                            minimumSize: Size.zero,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                            ),
                                            onPressed: _busy
                                                ? null
                                                : () => _action(() async {
                                                    await _save();
                                                  }),
                                            child: Text(
                                              _saveStatusText(),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: c.textSecondary,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 5,
                                          child: Text(
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.right,
                                            key: const Key(
                                              'document-statistics',
                                            ),
                                            resourceState.busy
                                                ? '${resourceState.operation}${resourceState.total > 0 ? ' ${resourceState.done}/${resourceState.total}' : ''}'
                                                : exporting
                                                ? _l10n.exportingDocument
                                                : '${_lineIndex.characters} ${_l10n.message(AppMessage.characters)} · UTF-8 · Markdown',
                                            style: const TextStyle(
                                              fontSize: 11,
                                            ),
                                          ),
                                        ),
                                        if (resourceState.busy)
                                          CupertinoButton(
                                            key: const Key(
                                              'stop-resource-operation',
                                            ),
                                            padding: const EdgeInsets.only(
                                              left: 8,
                                            ),
                                            minimumSize: const Size(0, 20),
                                            onPressed: _resourceWork.cancel,
                                            child: Text(
                                              _l10n.stop,
                                              style: const TextStyle(
                                                fontSize: 11,
                                              ),
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
        ),
      ),
    );
  }
}
