part of '../../main.dart';

extension _HomePreview on _MarkerHomeState {
  Widget _buildPreview({
    required MarkerColors c,
    required BuildContext context,
  }) => LinkedScrollRegion(
    link: _linkedScroll,
    controller: _previewScroll,
    child: RepaintBoundary(
      child: ColoredBox(
        color: c.bgPreview,
        child: SizedBox.expand(
          child: Markdown(
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
                if (!['http', 'https', 'mailto', 'file'].contains(uri.scheme)) {
                  _toast(t('不支持此链接类型', 'Unsupported link type'));
                  return;
                }
                if (!await launchUrl(
                  uri,
                  mode: LaunchMode.externalApplication,
                )) {
                  throw StateError('无法打开链接');
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
                  reason = t(
                    '无法访问图片，请授权目录',
                    'Cannot access image; allow folder access',
                  );
                } else if (error is FileSystemException &&
                    [2, 3].contains(error.osError?.errorCode)) {
                  reason = _l10n.imageNotFound;
                } else {
                  reason = t(
                    '无法解析图片，请检查格式或文件是否损坏',
                    'Cannot decode image; check its format or integrity',
                  );
                }
                return Text(
                  '${alt ?? ''} · $reason',
                  style: TextStyle(color: c.textSecondary),
                );
              }

              if (resolved.scheme == 'file') {
                return Image.file(
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
                        onPressed: () =>
                            _action(() => _relocateResource(uri.toString())),
                        child: Text(t('重新定位图片', 'Locate image')),
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
                );
              }
              if (['http', 'https'].contains(resolved.scheme)) {
                return Image.network(
                  resolved.toString(),
                  key: ValueKey((resolved.toString(), _imageEpoch, config)),
                  errorBuilder: (context, error, stack) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      failure(context, error, stack),
                      CupertinoButton(
                        minimumSize: const Size(0, 28),
                        onPressed: () async {
                          await NetworkImage(resolved.toString()).evict();
                          _imageEpoch++;
                          _previewSignature = null;
                          _resourceWork.refresh();
                        },
                        child: Text(t('重新加载图片', 'Reload image')),
                      ),
                    ],
                  ),
                );
              }
              return Text(
                t(
                  '请先保存文档以加载相对路径图片',
                  'Save the document to resolve relative images',
                ),
              );
            },
            data: _controller.text,
            selectable: true,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
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
