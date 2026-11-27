part of '../../main.dart';

extension _HomePreview on _MarkerHomeState {
  double? _mapContentScroll(bool fromEditor, double offset) {
    final field = _editable();
    if (field == null ||
        !_editorScroll.hasClients ||
        !_previewScroll.hasClients) {
      return null;
    }
    final blocks = _previewAnchors.positions(_previewScroll);
    if (blocks.isEmpty) return null;
    _lineIndex.update(_controller.text);
    final points = <({double source, double target})>[(source: 0, target: 0)];
    final signature = (
      _controller.text,
      field.size,
      field.preferredLineHeight,
      _anchorLines,
    );
    if (signature != _editorAnchorSignature) {
      _editorAnchorOffsets = [
        for (final line in _anchorLines)
          field
                  .getLocalRectForCaret(
                    TextPosition(
                      offset: _lineIndex.start(
                        line.clamp(0, _lineIndex.length - 1),
                      ),
                    ),
                  )
                  .top +
              _editorScroll.offset,
      ];
      _editorAnchorSignature = signature;
    }
    for (var i = 0; i < blocks.length; i++) {
      final block = blocks[i];
      if (i >= _editorAnchorOffsets.length) continue;
      final y = _editorAnchorOffsets[i];
      final a = fromEditor ? y : block.offset;
      final b = fromEditor ? block.offset : y;
      if (a > points.last.source && b >= points.last.target) {
        points.add((source: a, target: b));
      }
    }
    final endA = fromEditor
        ? _editorScroll.position.maxScrollExtent
        : _previewScroll.position.maxScrollExtent;
    final endB = fromEditor
        ? _previewScroll.position.maxScrollExtent
        : _editorScroll.position.maxScrollExtent;
    points.removeWhere((p) => p.source >= endA || p.target >= endB);
    points.add((source: endA, target: endB));
    return interpolateScroll(offset, points);
  }

  Widget _buildPreview({
    required MarkerColors c,
    required BuildContext context,
  }) {
    if (_anchorSource != _controller.text) {
      final nodes = md.Document(
        extensionSet: md.ExtensionSet.gitHubFlavored,
        blockSyntaxes: [MermaidSyntax(), MathBlockSyntax()],
        inlineSyntaxes: [TextColorSyntax(), MathInlineSyntax()],
      ).parseLines(_controller.text.split('\n'));
      _anchorLines = markdownBlockLines(_controller.text, nodes);
      _anchorSource = _controller.text;
    }
    return LinkedScrollRegion(
      link: _linkedScroll,
      controller: _previewScroll,
      child: RepaintBoundary(
        child: ColoredBox(
          color: c.bgPreview,
          child: SizedBox.expand(
            child: AnchoredMarkdown(
              sourceLines: _anchorLines,
              anchors: _previewAnchors,
              key: const Key('preview'),
              extensionSet: md.ExtensionSet.gitHubFlavored,
              controller: _previewScroll,
              blockSyntaxes: [MermaidSyntax(), MathBlockSyntax()],
              inlineSyntaxes: [TextColorSyntax(), MathInlineSyntax()],
              builders: {
                'text-color': TextColorBuilder(),
                'math-inline': MathBuilder(),
                'math-block': MathBuilder(block: true),
                'mermaid': MermaidBuilder(
                  enabled: ref.watch(mermaidPreviewEnabledProvider),
                ),
              },
              onTapLink: (text, href, title) async {
                if (href == null) return;
                try {
                  if (href.startsWith('#')) {
                    if (_previewScroll.hasClients) {
                      _linkedScroll.takeControl(_previewScroll);
                      await _previewScroll.animateTo(
                        href.startsWith('#fnref')
                            ? 0
                            : _previewScroll.position.maxScrollExtent,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOut,
                      );
                    }
                    return;
                  }
                  final uri = resolveDocumentUri(href, _path);
                  if (![
                    'http',
                    'https',
                    'mailto',
                    'file',
                  ].contains(uri.scheme)) {
                    _toast(_l10n.message(AppMessage.unsupportedLinkType));
                    return;
                  }
                  if (!await launchUrl(
                    uri,
                    mode: LaunchMode.externalApplication,
                  )) {
                    throw LocalizedMessageError(AppMessage.cannotOpenLink);
                  }
                } catch (e) {
                  _error(e);
                }
              },
              sizedImageBuilder: (config) {
                final uri = config.uri;
                final alt = config.alt;
                final resolved = resolveResourceUri(uri.toString(), _path);
                Widget failure(
                  BuildContext context,
                  Object error,
                  StackTrace? stack,
                ) {
                  String reason;
                  if (resolved.scheme != 'file') {
                    reason = _l10n.webImageLoadFailed;
                  } else if (error is FileSystemException &&
                      [
                        1,
                        13,
                        if (Platform.isWindows) 5,
                      ].contains(error.osError?.errorCode)) {
                    reason = _l10n.message(AppMessage.cannotAccessImage);
                  } else if (error is FileSystemException &&
                      [2, 3].contains(error.osError?.errorCode)) {
                    reason = _l10n.imageNotFound;
                  } else {
                    reason = _l10n.message(
                      AppMessage.cannotDecodeImageCheckItsFormatOrIntegrity,
                    );
                  }
                  return Text(
                    '${alt ?? ''} · $reason',
                    style: TextStyle(color: c.textSecondary),
                  );
                }

                if (resolved.scheme == 'file') {
                  return _resourcePreviewTarget(
                    Image.file(
                      File.fromUri(resolved),
                      key: ValueKey((resolved.toString(), _imageEpoch, config)),
                      width: config.width,
                      height: config.height,
                      errorBuilder: (context, error, stack) => Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          failure(context, error, stack),
                          CupertinoButton(
                            minimumSize: const Size(0, 28),
                            onPressed: () => _action(
                              () => _relocateResource(uri.toString()),
                            ),
                            child: Text(_l10n.message(AppMessage.locateImage)),
                          ),
                          CupertinoButton(
                            onPressed: () => _action(() async {
                              await _authorizeResourceFolder(
                                p.dirname(File.fromUri(resolved).path),
                              );
                              await FileImage(File.fromUri(resolved)).evict();
                              _imageEpoch++;
                            }),
                            child: Text(_l10n.allowImageFolderAndRetry),
                          ),
                        ],
                      ),
                    ),
                    uri,
                    alt,
                  );
                }
                if (['http', 'https'].contains(resolved.scheme)) {
                  return _resourcePreviewTarget(
                    ResourceNetworkImage(
                      imageUrl: resolved.toString(),
                      key: ValueKey((resolved.toString(), _imageEpoch, config)),
                      retryBuilder: (context, url, error, retry) => Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          failure(context, error, null),
                          CupertinoButton(
                            minimumSize: const Size(0, 28),
                            onPressed: retry,
                            child: Text(_l10n.message(AppMessage.reloadImage)),
                          ),
                        ],
                      ),
                    ),
                    uri,
                    alt,
                  );
                }
                return Text(
                  _l10n.message(
                    AppMessage.saveTheDocumentToResolveRelativeImages,
                  ),
                );
              },
              data: _controller.text,
              selectable: true,
              padding: MarkerStyle.documentPadding,
              styleSheet: MarkerMarkdownStyle.build(context).copyWith(
                p: TextStyle(
                  fontFamily: _serif ? 'New York' : MarkerFonts.ui,
                  fontFamilyFallback: _serif
                      ? MarkerFonts.serifFallback
                      : MarkerFonts.fallback,
                  fontSize: 15,
                  height: 1.7,
                  color: c.textPrimary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
