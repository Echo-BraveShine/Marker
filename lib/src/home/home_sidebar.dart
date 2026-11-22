part of '../../main.dart';

extension _HomeSidebar on _MarkerHomeState {
  Widget _buildSidebar({
    required MarkerColors c,
    required Widget Function(IconData, String, void Function()) button,
    required ResourceUiState resourceState,
    required WorkspaceState workspace,
  }) => Container(
    key: const Key('document-sidebar'),
    width: _sidebar ? ref.watch(themeProvider).sidebarWidth : 56,
    clipBehavior: Clip.hardEdge,
    decoration: BoxDecoration(color: c.bgSidebar),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final expanded = constraints.maxWidth >= 170;
        return Column(
          children: [
            SizedBox(
              height: 44,
              child: Row(
                children: [
                  button(
                    CupertinoIcons.sidebar_left,
                    _l10n.toggleSidebar,
                    () => _update(() => _sidebar = !_sidebar),
                  ),
                  if (expanded)
                    Expanded(
                      child: Text(
                        resourceState.showResources
                            ? _l10n.resources
                            : _l10n.files,
                        style: TextStyle(fontSize: 12, color: c.textSecondary),
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
              child: resourceState.showResources && expanded
                  ? ResourceSidebar(
                      text: _controller.text,
                      path: _path,
                      zh: _zh,
                      onImport: () => _importPictures(),
                      onMenu: _resourceMenu,
                      onItem: _resourceItemMenu,
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
                              height: 32,
                              decoration: BoxDecoration(
                                color: document.id == workspace.activeId
                                    ? c.bgSelected
                                    : null,
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: Tooltip(
                                message: document.path ?? document.name,
                                child: CupertinoButton(
                                  key: ValueKey('document-${document.id}'),
                                  minimumSize: Size.zero,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  onPressed: _busy
                                      ? null
                                      : () => _action(
                                          () => _selectDocument(document.id),
                                        ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        CupertinoIcons.doc_text,
                                        size: 16,
                                        color: document.id == workspace.activeId
                                            ? c.textAccent
                                            : c.textSecondary,
                                      ),
                                      if (expanded) ...[
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            '${document.name}${document.dirty ? ' •' : ''}',
                                            overflow: TextOverflow.ellipsis,
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
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  button(CupertinoIcons.gear, _l10n.settings, _settings),
                  if (expanded)
                    Text(
                      _l10n.settings,
                      style: TextStyle(fontSize: 12, color: c.textSecondary),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    ),
  );
}
