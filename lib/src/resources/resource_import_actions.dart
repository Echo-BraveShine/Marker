part of '../../main.dart';

// Drop zone handling for desktop drag-and-drop
extension _ResourceDropZoneActions on _MarkerHomeState {
  Widget _resourceDropZone(Widget child) {
    if (!desktopWindow) return child;
    final state = ref.watch(resourceUiProvider);
    final colors = Theme.of(context).extension<MarkerColors>()!;
    return DropTarget(
      key: const Key('resource-drop-zone'),
      enable:
          !_busy &&
          !_restoring &&
          !state.busy &&
          (ModalRoute.of(context)?.isCurrent ?? true),
      onDragEntered: (_) => _resourceWork.setDropHover(true),
      onDragExited: (_) => scheduleMicrotask(() {
        // DropTarget also emits exit while disabling itself during a rebuild.
        if (mounted) _resourceWork.setDropHover(false);
      }),
      onDragDone: _dropResourceFiles,
      child: Stack(
        fit: StackFit.expand,
        children: [
          child,
          if (state.dropHover)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  key: const Key('resource-drop-hint'),
                  margin: const EdgeInsets.all(10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colors.bgWindow.withValues(alpha: .9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colors.textAccent, width: 2),
                  ),
                  child: DefaultTextStyle.merge(
                    style: TextStyle(
                      fontFamily: MarkerFonts.ui,
                      decoration: TextDecoration.none,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          CupertinoIcons.photo_on_rectangle,
                          size: 32,
                          color: colors.textAccent,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          t('松开以导入图片', 'Drop to import images'),
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          t(
                            '复制到文档资源目录，保留原图',
                            'Copy to document assets. Originals are kept.',
                          ),
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: 12,
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
    );
  }
}

// Resource access helpers and properties
extension _ResourceAccessHelpers on _MarkerHomeState {
  DocumentResourceService get _resources => ref.read(resourceServiceProvider);
  ResourceController get _resourceWork => ref.read(resourceUiProvider.notifier);

  Iterable<ResourceDraft> get _resourceDrafts => ref
      .read(workspaceProvider)
      .documents
      .expand(
        (doc) => [
          ResourceDraft(
            doc.path,
            doc.id == ref.read(workspaceProvider).activeId
                ? _controller.text
                : doc.text,
          ),
          ResourceDraft(doc.path, doc.saved),
        ],
      );

  Future<bool> _ensureResourceDocument() async {
    if (_path != null) return true;
    if (!mounted) return false;
    final confirm = await showMarkerDialog<bool>(
      context: context,
      builder: (context) => MarkerDialog(
        title: Text(t('先保存文档', 'Save the document first')),
        content: Text(
          t(
            '保存后就能把图片放在文档旁边，并使用可随文档移动的相对路径。',
            'Save first so images can be stored beside the document using portable relative paths.',
          ),
        ),
        actions: [
          MarkerDialogButton(
            primary: true,
            onPressed: () => Navigator.pop(context, true),
            child: Text(t('保存并继续', 'Save and continue')),
          ),
        ],
      ),
    );
    return confirm == true && await _save();
  }

  Future<void> _authorizeResourceFolder([String? requiredPath]) async {
    final expected = requiredPath ?? (_path == null ? null : p.dirname(_path!));
    if (expected == null) return;
    String? selected;
    if (desktopWindow && defaultTargetPlatform == TargetPlatform.macOS) {
      selected = await ref
          .read(resourcePlatformProvider)
          .authorizeDirectory(expected, chinese: _zh);
    } else {
      selected = await getDirectoryPath(
        initialDirectory: expected,
        confirmButtonText: t('允许访问目录', 'Allow folder access'),
      );
    }
    if (selected == null) throw ResourceCancelled();
    if (!p.equals(p.normalize(selected), p.normalize(expected)) &&
        !p.isWithin(selected, expected)) {
      throw const ResourceFailure(
        '请选择图片或文档所在目录，或其上级目录。',
        'Choose the containing folder or one of its parent folders.',
      );
    }
    _imageEpoch++;
    _previewSignature = null;
    _resourceWork.refresh();
    if (mounted) {
      _toast(t('已获得目录访问权限。', 'Folder access granted.'));
    }
  }

  Future<T> _withResourceAccess<T>(
    Future<T> Function() operation, {
    String? directory,
  }) async {
    try {
      return await operation();
    } on FileSystemException catch (error) {
      if (defaultTargetPlatform != TargetPlatform.macOS ||
          ![1, 13].contains(error.osError?.errorCode) ||
          (_path == null && directory == null)) {
        rethrow;
      }
      await _authorizeResourceFolder(directory ?? p.dirname(_path!));
      return operation();
    }
  }
}

// Resource import operations: file selection, clipboard, drag-and-drop
extension _ResourceImportActions on _MarkerHomeState {
  Future<void> _importPictures({bool referenceOnly = false}) async {
    if (_busy || _restoring) return;
    final owner = ref.read(workspaceProvider).activeId;
    final files = await _pickResourceImages();
    if (files.isEmpty || !mounted) return;
    if (ref.read(workspaceProvider).activeId != owner) {
      _toast(
        t('文档已切换，请重新导入图片。', 'The document changed. Import the images again.'),
      );
      return;
    }
    await _action(
      () async => _importResourceInputs([
        for (final file in files)
          if (_isMobile)
            ResourceInput(name: file.name, bytes: await file.readAsBytes())
          else
            ResourceInput(name: file.name, path: file.path),
      ], referenceOnly: referenceOnly),
    );
  }

  Future<void> _importResourceInputs(
    List<ResourceInput> inputs, {
    bool referenceOnly = false,
  }) async {
    if (!await _ensureResourceDocument() || !mounted) return;
    final path = _path!, documentId = ref.read(workspaceProvider).activeId;
    final original = _controller.value;
    final markdown = <String>[], failures = <String>[];
    var cancelled = false;
    await _resourceWork.run(t('导入图片', 'Importing images'), (
      token,
      progress,
    ) async {
      for (var i = 0; i < inputs.length; i++) {
        if (token.cancelled) break;
        final input = inputs[i];
        var readingSource = true;
        progress(ResourceProgress(i, inputs.length, input.name));
        try {
          // Distinguish source-file access from destination-folder access.
          // A dropped file grant does not grant its parent or the MD folder.
          final bytes = await _withResourceAccess(
            () => _resources.readImage(input),
            directory: input.path == null ? null : p.dirname(input.path!),
          );
          if (referenceOnly && input.path != null) {
            // Validate without taking ownership of the original file.
            markdown.add(
              imageMarkdown(
                p.basenameWithoutExtension(input.name),
                resourceReference(input.path!, path),
              ),
            );
          } else {
            readingSource = false;
            final image = await _withResourceAccess(
              () => _resources.importImage(
                path,
                ResourceInput(name: input.name, bytes: bytes),
              ),
            );
            markdown.add(
              imageMarkdown(
                p.basenameWithoutExtension(input.name),
                image.reference,
              ),
            );
          }
        } on ResourceCancelled {
          token.cancelled = true;
          break;
        } catch (e, stack) {
          if (kDebugMode) debugPrint('Image import failed: $e\n$stack');
          failures.add(
            '${input.name}\n${t(readingSource ? '读取原图失败' : '写入图片资源失败', readingSource ? 'Cannot read original image' : 'Cannot write image assets')}\n${_resourceMessage(e)}',
          );
        }
      }
      cancelled = token.cancelled;
      progress(ResourceProgress(markdown.length, inputs.length, ''));
      if (markdown.isNotEmpty &&
          mounted &&
          ref.read(workspaceProvider).activeId == documentId) {
        final current = _controller.value;
        final selection = current.text == original.text
            ? original.selection
            : current.selection;
        _insertResourceText(markdown.join('\n'), selection: selection);
      }
    });
    if (markdown.isNotEmpty && mounted) {
      // Persist the Markdown reference before reporting successful photo import.
      await _persist();
      await ref.read(autosaveProvider.notifier).flush(force: true);
    }
    if (failures.isNotEmpty && mounted) {
      await _showResourceIssues(failures);
    } else if (cancelled && mounted) {
      _toast(
        t(
          markdown.isEmpty
              ? '已取消导入，原图未修改。'
              : '已停止导入，已插入 ${markdown.length} 张图片。',
          markdown.isEmpty
              ? 'Import cancelled. Original images are unchanged.'
              : 'Import stopped. ${markdown.length} images inserted.',
        ),
      );
    } else if (markdown.isNotEmpty && mounted) {
      _toast(
        t(
          referenceOnly
              ? '已插入原位置引用；移动原图后可能失效。'
              : '已插入 ${markdown.length} 张图片，原图已保留。',
          '${markdown.length} images inserted. Originals kept.',
        ),
      );
    }
  }

  void _insertResourceText(String text, {TextSelection? selection}) {
    final value = _controller.value;
    final active = selection ?? value.selection;
    final start = active.isValid
        ? active.start.clamp(0, value.text.length)
        : value.text.length;
    final end = active.isValid
        ? active.end.clamp(start, value.text.length)
        : start;
    _controller.value = TextEditingValue(
      text: value.text.replaceRange(start, end, text),
      selection: TextSelection.collapsed(offset: start + text.length),
    );
    _focus.requestFocus();
  }

  Future<void> _pasteResourceOrText({bool preferImage = false}) async {
    if (_busy || _restoring) return;
    final plain = await Clipboard.getData(Clipboard.kTextPlain);
    try {
      List<String> files = const [];
      try {
        files = await Pasteboard.files();
      } on MissingPluginException {
        /* Plain text still works. */
      }
      final images = files
          .where(
            (path) => resourceImageExtensions.contains(
              p.extension(path).toLowerCase().replaceFirst('.', ''),
            ),
          )
          .toList();
      if (images.isNotEmpty) {
        await _action(
          () => _importResourceInputs([
            for (final path in images)
              ResourceInput(name: p.basename(path), path: path),
          ]),
        );
        return;
      }
      if (!preferImage && plain?.text?.isNotEmpty == true) {
        if (mounted) _insertResourceText(plain!.text!);
        return;
      }
      final image = await Pasteboard.image;
      if (image != null && image.isNotEmpty && mounted) {
        final name =
            'Screenshot-${DateTime.now().toIso8601String().replaceAll(RegExp(r'[:.]'), '-')}.png';
        await _action(
          () =>
              _importResourceInputs([ResourceInput(name: name, bytes: image)]),
        );
      } else if (plain?.text?.isNotEmpty == true) {
        if (mounted) _insertResourceText(plain!.text!);
      } else if (mounted) {
        _toast(t('剪贴板中没有可插入的文本或图片。', 'No text or image to paste.'));
      }
    } on MissingPluginException {
      if (plain?.text?.isNotEmpty == true && mounted) {
        _insertResourceText(plain!.text!);
      } else if (mounted) {
        _toast(
          t(
            '当前环境无法读取剪贴板图片。',
            'Clipboard images are unavailable in this environment.',
          ),
        );
      }
    } catch (e) {
      if (mounted) _error(e);
    }
  }

  Future<void> _dropResourceFiles(DropDoneDetails details) async {
    _resourceWork.setDropHover(false);
    if (_busy ||
        _restoring ||
        ref.read(resourceUiProvider).busy ||
        !(ModalRoute.of(context)?.isCurrent ?? true)) {
      return;
    }
    final editable = _editable();
    if (editable != null &&
        (editable.localToGlobal(Offset.zero) & editable.size).contains(
          details.globalPosition,
        )) {
      final position = editable.getPositionForPoint(details.globalPosition);
      _controller.selection = TextSelection.collapsed(
        offset: position.offset.clamp(0, _controller.text.length),
      );
    }
    await _action(() async {
      final owner = ref.read(workspaceProvider).activeId;
      final access = <Uint8List>[];
      try {
        final inputs = <ResourceInput>[];
        for (final item in details.files.whereType<DropItemFile>()) {
          final bookmark = item.extraAppleBookmark;
          if (bookmark != null &&
              bookmark.isNotEmpty &&
              defaultTargetPlatform == TargetPlatform.macOS) {
            try {
              if (await DesktopDrop.instance
                  .startAccessingSecurityScopedResource(bookmark: bookmark)) {
                access.add(bookmark);
              }
            } on PlatformException catch (error) {
              // The OS may already have granted read access through the drag.
              // Try reading; only request a folder if that actually fails.
              debugPrint('Dropped file bookmark unavailable: ${error.code}');
            }
          }
          if (!resourceImageExtensions.contains(
            p.extension(item.name).toLowerCase().replaceFirst('.', ''),
          )) {
            continue;
          }
          inputs.add(
            item.path.isEmpty
                ? ResourceInput(
                    name: item.name,
                    bytes: await item.readAsBytes(),
                  )
                : ResourceInput(name: item.name, path: item.path),
          );
        }
        if (inputs.isEmpty) {
          final raw = details.rawText?.trim() ?? '';
          final portalDenied =
              details.files.isEmpty &&
              raw.isNotEmpty &&
              !raw.contains('\n') &&
              !raw.startsWith('#') &&
              !(Uri.tryParse(raw)?.hasScheme ?? false);
          _toast(
            portalDenied
                ? t(
                    '系统未能提供拖入文件的访问权限，请使用“导入图片”选择文件。',
                    'The system could not grant access to the dropped files. Use Import images to select them.',
                  )
                : t(
                    '请拖入 PNG、JPEG、GIF、WebP 或 BMP 图片。',
                    'Drop PNG, JPEG, GIF, WebP or BMP images.',
                  ),
          );
          return;
        }
        if (!mounted || ref.read(workspaceProvider).activeId != owner) return;
        await _importResourceInputs(inputs);
      } finally {
        for (final bookmark in access) {
          try {
            await DesktopDrop.instance.stopAccessingSecurityScopedResource(
              bookmark: bookmark,
            );
          } on PlatformException catch (error) {
            debugPrint('Dropped file bookmark release failed: ${error.code}');
          }
        }
      }
    });
  }

  Future<void> _insertNetworkImage() async {
    final address = await _resourceText(
      t('插入网络图片', 'Insert web image'),
      'https://…',
    );
    if (address == null || !mounted) return;
    final uri = Uri.tryParse(address);
    if (uri == null ||
        !['http', 'https'].contains(uri.scheme) ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty) {
      _error(
        const ResourceFailure(
          '请输入有效的 HTTP 或 HTTPS 图片地址。',
          'Enter a valid HTTP or HTTPS image URL.',
        ),
      );
      return;
    }
    _insertResourceText(
      imageMarkdown(t('图片说明', 'Image description'), uri.toString()),
    );
  }
}
