part of '../../main.dart';

extension _HomeMobileActions on _MarkerHomeState {
  Future<void> _shareExportBytes(
    Uint8List bytes,
    String name,
    String mime,
  ) async {
    if (!mounted) return;
    final box = context.findRenderObject() as RenderBox?;
    final origin = box == null
        ? null
        : box.localToGlobal(Offset.zero) & box.size;
    final result = await ref.read(exportShareProvider)(
      ShareParams(
        files: [XFile.fromData(bytes, mimeType: mime)],
        fileNameOverrides: [name],
        sharePositionOrigin: origin,
      ),
    );
    if (mounted && result.status == ShareResultStatus.success) {
      _toast(_l10n.message(AppMessage.sentToTheSelectedApp));
    }
  }

  Future<List<XFile>> _pickResourceImages({bool multiple = true}) async {
    if (!_isMobile) {
      final types = [
        XTypeGroup(
          label: _l10n.message(AppMessage.images),
          extensions: resourceImageExtensions,
          uniformTypeIdentifiers: const ['public.image'],
        ),
      ];
      if (multiple) return openFiles(acceptedTypeGroups: types);
      final image = await openFile(acceptedTypeGroups: types);
      return image == null ? [] : [image];
    }
    FocusManager.instance.primaryFocus?.unfocus();
    final source = await _resourceChoice(_l10n.message(AppMessage.addImage), [
      ('camera', _l10n.message(AppMessage.takePhoto), CupertinoIcons.camera),
      (
        'photos',
        _l10n.message(AppMessage.chooseFromPhotos),
        CupertinoIcons.photo_on_rectangle,
      ),
    ]);
    if (source == null || !mounted) return [];
    try {
      final picker = ImagePicker();
      if (source == 'photos' && multiple) {
        return await picker.pickMultiImage(requestFullMetadata: false);
      }
      final image = await picker.pickImage(
        source: source == 'camera' ? ImageSource.camera : ImageSource.gallery,
        requestFullMetadata: false,
      );
      return image == null ? [] : [image];
    } on PlatformException catch (error) {
      if (mounted) {
        if (error.code.contains('denied') ||
            error.code.contains('restricted')) {
          _toast(
            _l10n.message(
              AppMessage.allowMarkerToAccessCameraOrPhotosInSystemSettings,
            ),
          );
        } else {
          _error(error);
        }
      }
      return [];
    }
  }

  Future<FileSaveLocation?> _chooseSaveLocation({
    required String suggestedName,
    List<XTypeGroup> acceptedTypeGroups = const [],
  }) async {
    if (!_isMobile) {
      return getSaveLocation(
        suggestedName: suggestedName,
        acceptedTypeGroups: acceptedTypeGroups,
      );
    }
    final name = await _resourceText(
      _l10n.message(AppMessage.saveInMarker),
      _l10n.message(AppMessage.fileName),
      initial: suggestedName,
    );
    if (name == null || !mounted) return null;
    String path;
    try {
      path = await MobileDocumentStore().savePath(name);
    } on FormatException {
      throw const ResourceFailure.localized(
        AppMessage.enterAFileNameWithoutSlashes,
      );
    }
    if (await File(path).exists() && mounted) {
      final overwrite =
          await _resourceChoice(_l10n.message(AppMessage.fileAlreadyExists), [
            (
              'replace',
              _l10n.message(AppMessage.replaceExistingFile),
              CupertinoIcons.doc,
            ),
          ]);
      if (overwrite != 'replace') return null;
    }
    return FileSaveLocation(path);
  }

  /// Share the latest source without rewriting image paths or changing ownership.
  Future<void> _exportMobileMarkdown() async {
    if (!mounted) return;
    await _shareExportBytes(
      Uint8List.fromList(utf8.encode(_controller.text)),
      '${p.basenameWithoutExtension(_name)}.md',
      'text/markdown',
    );
  }

  Future<void> _exportMobileDocument() async {
    if (!await _ensureResourceDocument() || !mounted) return;
    final sourcePath = _path!;
    final source = _controller.text;
    final inventory = await _resources.scan(source, sourcePath);
    if (!mounted || !await _confirmResourceIssues(inventory)) return;
    final directory = await getTemporaryDirectory();
    final stage = await directory.createTemp('marker-share-');
    try {
      final zipPath = p.join(
        stage.path,
        '${p.basenameWithoutExtension(sourcePath)}.zip',
      );
      await _resources.package(
        text: source,
        sourcePath: sourcePath,
        zipPath: zipPath,
        allowIncomplete:
            inventory.unresolved.isNotEmpty || inventory.unsupported.isNotEmpty,
      );
      await _shareExportBytes(
        await File(zipPath).readAsBytes(),
        p.basename(zipPath),
        'application/zip',
      );
    } finally {
      await stage.delete(recursive: true);
    }
  }
}
