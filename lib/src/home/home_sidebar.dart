part of '../../main.dart';

extension _HomeSidebar on _MarkerHomeState {
  Widget _buildSidebar({
    required MarkerColors c,
    required Widget Function(IconData, String, void Function()) button,
    required ResourceUiState resourceState,
    required WorkspaceState workspace,
  }) => Container(
    key: const Key('document-sidebar'),
    width:
        (_sidebar
            ? (_isMobile ? 160.0 : ref.watch(themeProvider).sidebarWidth)
            : (_isMobile ? 48.0 : 56.0)) +
        (_isMobile ? MobileCutoutArea.controlsOf(context).left : 0),
    clipBehavior: Clip.hardEdge,
    decoration: BoxDecoration(color: c.bgSidebar),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final expanded = _sidebar;
        return Column(
          children: [
            Container(
              height: 44,
              padding: EdgeInsets.only(
                left: _isMobile ? MobileCutoutArea.controlsOf(context).left : 0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Tooltip(
                      message: _l10n.toggleSidebar,
                      child: CupertinoButton(
                        key: const Key('sidebar-files-toggle'),
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        onPressed: _busy
                            ? null
                            : () => _update(() => _sidebar = !_sidebar),
                        child: SizedBox(
                          height: 44,
                          child: Row(
                            children: [
                              SizedBox(
                                width: 34,
                                child: Icon(
                                  CupertinoIcons.sidebar_left,
                                  size: 16,
                                  color: c.textSecondary,
                                ),
                              ),
                              if (expanded)
                                Expanded(
                                  child: Text(
                                    resourceState.showResources
                                        ? _l10n.resources
                                        : _l10n.files,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: c.textSecondary,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (expanded)
                    button(
                      resourceState.showResources
                          ? CupertinoIcons.doc_text
                          : CupertinoIcons.photo_on_rectangle,
                      resourceState.showResources
                          ? _l10n.documents
                          : _l10n.documentResources,
                      _resourceWork.toggle,
                    ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  left: _isMobile ? MobileCutoutArea.insetsOf(context).left : 0,
                ),
                child: resourceState.showResources && expanded
                    ? ResourceSidebar(
                        mobile: _isMobile,
                        text: _controller.text,
                        path: _path,
                        zh: _zh,
                        onImport: () => _importPictures(),
                        onMenu: _resourceMenu,
                        onItem: _resourceItemMenu,
                        onLocate: _locateResourceInEditor,
                        onPreview: _previewResourceImage,
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        itemCount: workspace.documents.length,
                        itemBuilder: (context, index) {
                          final document = workspace.documents[index];
                          return GestureDetector(
                            onSecondaryTapUp: _busy
                                ? null
                                : (details) => _documentMenu(
                                    document,
                                    details.globalPosition,
                                  ),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Container(
                                height: _isMobile ? 44 : 32,
                                decoration: BoxDecoration(
                                  color: document.id == workspace.activeId
                                      ? c.bgSelected
                                      : null,
                                  borderRadius: BorderRadius.circular(7),
                                ),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(
                                        right:
                                            expanded &&
                                                document.id ==
                                                    workspace.activeId
                                            ? 40
                                            : 0,
                                      ),
                                      child: Tooltip(
                                        message: document.path ?? document.name,
                                        child: CupertinoButton(
                                          key: ValueKey(
                                            'document-${document.id}',
                                          ),
                                          minimumSize: Size.zero,
                                          onLongPress: _isMobile && !_busy
                                              ? () => _documentMenu(
                                                  document,
                                                  Offset.zero,
                                                )
                                              : null,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                          ),
                                          onPressed: _busy
                                              ? null
                                              : () async {
                                                  try {
                                                    await _selectDocument(
                                                      document.id,
                                                    );
                                                  } catch (error) {
                                                    _error(error);
                                                  }
                                                },
                                          child: Row(
                                            children: [
                                              Icon(
                                                CupertinoIcons.doc_text,
                                                size: 16,
                                                color:
                                                    document.id ==
                                                        workspace.activeId
                                                    ? c.textAccent
                                                    : c.textSecondary,
                                              ),
                                              if (expanded) ...[
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    '${document.name}${document.dirty ? ' •' : ''}',
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: c.textPrimary,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (expanded &&
                                        document.id == workspace.activeId)
                                      Positioned(
                                        right: 0,
                                        top: 0,
                                        bottom: 0,
                                        child: Builder(
                                          builder: (anchor) => CupertinoButton(
                                            key: ValueKey(
                                              'document-more-${document.id}',
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                            ),
                                            minimumSize: const Size(40, 44),
                                            onPressed: _busy
                                                ? null
                                                : () => _documentMenu(
                                                    document,
                                                    (anchor.findRenderObject()
                                                            as RenderBox)
                                                        .localToGlobal(
                                                          Offset.zero,
                                                        ),
                                                  ),
                                            child: Icon(
                                              CupertinoIcons.ellipsis,
                                              size: 18,
                                              color: c.textSecondary,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
            CupertinoButton(
              key: const Key('sidebar-settings'),
              minimumSize: const Size(44, 24),
              padding: EdgeInsets.only(
                left:
                    12 +
                    (_isMobile ? MobileCutoutArea.controlsOf(context).left : 0),
                right: 12,
              ),
              alignment: Alignment.centerLeft,
              onPressed: _settings,
              child: Row(
                children: [
                  Icon(CupertinoIcons.gear, size: 18, color: c.textSecondary),
                  if (expanded) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _l10n.settings,
                        style: TextStyle(fontSize: 12, color: c.textSecondary),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    ),
  );
}
