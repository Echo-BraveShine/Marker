part of '../../main.dart';

extension _ResourceImageActions on _MarkerHomeState {
  void _locateResourceInEditor(ResourceItem item) {
    final references = parseResourceReferences(_controller.text).images
        .where(
          (image) =>
              image.source == item.source ||
              resolveResourceUri(image.source, _path) ==
                  resolveResourceUri(item.source, _path),
        )
        .toList();
    if (references.isEmpty) {
      _toast(_l10n.message(AppMessage.thisImageIsNotReferencedInTheDocument));
      return;
    }
    final current = _controller.selection;
    final reference =
        references.where((image) => image.start > current.start).firstOrNull ??
        references.first;
    if (_mode == 2) _mode = 1;
    _linkedScroll.takeEditorControl();
    _controller.selection = TextSelection(
      baseOffset: reference.start,
      extentOffset: reference.end,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!_isMobile) _focus.requestFocus();
      _focus.context
          ?.findAncestorStateOfType<EditableTextState>()
          ?.bringIntoView(TextPosition(offset: reference.start));
    });
  }

  Widget _resourcePreviewTarget(Widget image, Uri uri, String? alt) =>
      GestureDetector(
        onTap: () => _previewResourceImage(
          ResourceItem(
            uri.toString(),
            alt ?? '',
            ['http', 'https'].contains(uri.scheme)
                ? ResourceAvailability.remote
                : ResourceAvailability.local,
            path: uri.scheme == 'file' ? File.fromUri(uri).path : null,
          ),
        ),
        child: image,
      );

  Future<void> _previewResourceImage(ResourceItem item) =>
      showMarkerDialog<void>(
        context: context,
        builder: (dialogContext) {
          final uri = resolveResourceUri(item.source, _path);
          Widget error() => Center(
            child: Text(
              _l10n.message(
                AppMessage.cannotLoadImageRetryOrCheckNetworkAndFileAccess,
              ),
            ),
          );
          return MarkerDialog(
            title: Text(
              item.alt.isEmpty ? _l10n.message(AppMessage.viewImage) : item.alt,
            ),
            width: 760,
            height: 520,
            scrollable: false,
            content: InteractiveViewer(
              minScale: .25,
              maxScale: 5,
              child: Center(
                child: ['http', 'https'].contains(uri.scheme)
                    ? ResourceNetworkImage(
                        imageUrl: uri.toString(),
                        fit: BoxFit.contain,
                        placeholder: (_, _) =>
                            const CupertinoActivityIndicator(animating: false),
                        errorWidget: (_, _, _) => error(),
                      )
                    : uri.scheme == 'file'
                    ? Image.file(
                        File.fromUri(uri),
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => error(),
                      )
                    : error(),
              ),
            ),
            actions: [
              MarkerDialogButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  _locateResourceInEditor(item);
                },
                child: Text(_l10n.message(AppMessage.locateInEditor)),
              ),
              MarkerDialogButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  _resourceItemMenu(item);
                },
                child: Text(_l10n.message(AppMessage.more)),
              ),
            ],
          );
        },
      );
}
