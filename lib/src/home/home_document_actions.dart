part of '../../main.dart';

extension _HomeDocumentActions on _MarkerHomeState {
  Future<void> _selectDocument(String id) async {
    _snapshot();
    _workspace.select(id);
    _loadActive();
    unawaited(ref.read(autosaveProvider.notifier).flush());
    await _workspace.persist();
  }

  Future<void> _documentMenu(OpenDocument document, Offset position) async {
    if (_isMobile) _focus.unfocus();
    final entries = [
      ('save', t('立即保存', 'Save now'), CupertinoIcons.square_arrow_down),
      ('saveAs', _l10n.saveAs, CupertinoIcons.doc_on_doc),
      ('close', _l10n.closeDocument, CupertinoIcons.xmark),
      if (document.path != null)
        ('rename', _l10n.rename, CupertinoIcons.pencil),
      if (document.path != null)
        (
          'delete',
          _isMobile ? t('删除文档', 'Delete document') : _l10n.moveToTrash,
          CupertinoIcons.trash,
        ),
    ];
    final c = Theme.of(context).extension<MarkerColors>()!;
    final size = MediaQuery.sizeOf(context);
    final overlay = Overlay.of(context).context.findRenderObject();
    final menuPosition = overlay is RenderBox
        ? overlay.globalToLocal(position)
        : position;
    final action = _isMobile
        ? await _resourceChoice(document.name, entries)
        : await showGeneralDialog<String>(
            context: context,
            barrierLabel: _l10n.closeDocument,
            barrierDismissible: true,
            barrierColor: c.bgWindow.withValues(alpha: 0),
            transitionDuration: const Duration(milliseconds: 100),
            pageBuilder: (context, animation, secondary) => Stack(
              children: [
                Positioned(
                  left: menuPosition.dx.clamp(
                    8,
                    (size.width - 224).clamp(8, double.infinity),
                  ),
                  top: menuPosition.dy.clamp(
                    8,
                    (size.height - (document.path == null ? 172 : 244)).clamp(
                      8,
                      double.infinity,
                    ),
                  ),
                  child: MarkerFloatingSurface(
                    width: 216,
                    padding: const EdgeInsets.all(6),
                    child: DefaultTextStyle(
                      style: TextStyle(
                        fontFamily: MarkerFonts.ui,
                        fontFamilyFallback: MarkerFonts.fallback,
                        fontSize: 13,
                        height: 1.38,
                        color: c.textPrimary,
                        decoration: TextDecoration.none,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (final entry in entries)
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (entry.$1 == 'delete')
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    child: Container(
                                      height: 1,
                                      color: c.separatorSoft,
                                    ),
                                  ),
                                CupertinoButton(
                                  minimumSize: Size.zero,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 8,
                                  ),
                                  onPressed: () =>
                                      Navigator.pop(context, entry.$1),
                                  child: Row(
                                    children: [
                                      Icon(
                                        entry.$3,
                                        size: 16,
                                        color: entry.$1 == 'delete'
                                            ? CupertinoColors.systemRed
                                            : c.textSecondary,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        entry.$2,
                                        style: TextStyle(
                                          fontFamily: MarkerFonts.ui,
                                          fontFamilyFallback:
                                              MarkerFonts.fallback,
                                          fontSize: 13,
                                          color: entry.$1 == 'delete'
                                              ? CupertinoColors.systemRed
                                              : c.textPrimary,
                                          decoration: TextDecoration.none,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
    if (!mounted ||
        action == null ||
        !ref
            .read(workspaceProvider)
            .documents
            .any((d) => d.id == document.id)) {
      return;
    }
    await _action(() async {
      if (action == 'save' || action == 'saveAs') {
        await _selectDocument(document.id);
        await _save(as: action == 'saveAs');
      } else if (action == 'rename') {
        await _selectDocument(document.id);
        await _renameResourceDocument();
      } else {
        await _closeDocument(document.id, delete: action == 'delete');
      }
    });
  }

  Future<void> _closeDocument(String id, {bool delete = false}) async {
    await _selectDocument(id);
    if (!mounted) return;
    final document = _workspace.active;
    if (document == null) return;
    if (delete && document.path != null) {
      final confirmed = await showMarkerDialog<bool>(
        context: context,
        builder: (context) => MarkerDialog(
          title: Text(
            _isMobile
                ? t('删除文档？', 'Delete document?')
                : _l10n.moveToTrashPrompt,
          ),
          content: Text(
            '${document.path}\n\n${_isMobile ? t('将永久删除 Marker 内的文档，图片资源保留。未保存的编辑也将关闭。', 'Permanently delete this document from Marker. Images are kept. Unsaved edits will also be closed.') : _l10n.moveToTrashContent}',
          ),
          actions: [
            MarkerDialogButton(
              isDestructiveAction: true,
              onPressed: () => Navigator.pop(context, true),
              child: Text(_isMobile ? t('删除', 'Delete') : _l10n.moveToTrash),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
      await ref.read(resourcePlatformProvider).trash(document.path!);
    } else if (!await _confirm()) {
      return;
    }
    if (!mounted) return;
    _draftTimer?.cancel();
    _workspace.remove(id);
    _loadActive();
    await _workspace.persist();
  }

  void _toast(String message) {
    _toastTimer?.cancel();
    _toastEntry?.remove();
    _toastEntry?.dispose();
    final overlay = Overlay.of(context);
    final colors = Theme.of(context).extension<MarkerColors>()!;
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => Positioned(
        bottom: 48,
        left: 32,
        right: 32,
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 560),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: colors.textPrimary,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              message,
              style: TextStyle(
                fontFamily: MarkerFonts.ui,
                fontFamilyFallback: MarkerFonts.fallback,
                fontSize: 13,
                color: colors.bgEditor,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ),
      ),
    );
    overlay.insert(entry);
    _toastEntry = entry;
    _toastTimer = Timer(const Duration(seconds: 3), () {
      entry.remove();
      entry.dispose();
      _toastEntry = null;
    });
  }

  void _error(Object e) {
    if (mounted) {
      _toast(
        e is ResourceFailure
            ? t(e.zh, e.en)
            : t('文件操作失败：$e', 'File operation failed: $e'),
      );
    }
  }

  Future<bool> _confirm() async {
    if (!_dirty) return true;
    await _flushAutosave(force: true);
    if (!mounted) return false;
    if (!_dirty) return true;
    final answer = await showMarkerDialog<int>(
      context: context,
      builder: (context) => MarkerDialog(
        title: Text(t('保存更改？', 'Save changes?')),
        content: Text(t('\$_name 有未保存的内容。', '$_name has unsaved changes.')),
        actions: [
          MarkerDialogButton(
            onPressed: () => Navigator.pop(context, 1),
            child: Text(t('不保存', 'Discard')),
          ),
          MarkerDialogButton(
            primary: true,
            onPressed: () => Navigator.pop(context, 2),
            child: Text(t('保存', 'Save')),
          ),
        ],
      ),
    );
    return answer == 1 || (answer == 2 && await _save());
  }
}
