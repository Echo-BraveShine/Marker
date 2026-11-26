part of '../../main.dart';

extension _HomeMobileActions on _MarkerHomeState {
  Future<void> _previewMobileImage(String path) => showMarkerDialog<void>(
    context: context,
    builder: (_) => MarkerDialog(
      title: Text(t('查看图片', 'View image')),
      width: 720,
      height: 460,
      scrollable: false,
      content: InteractiveViewer(
        minScale: .5,
        maxScale: 4,
        child: Center(
          child: Image.file(
            File(path),
            cacheWidth: 1600,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => Text(
              t(
                '无法读取图片，请重新定位或导入。',
                'Cannot read image. Locate or import it again.',
              ),
            ),
          ),
        ),
      ),
    ),
  );

  Future<List<XFile>> _pickResourceImages({bool multiple = true}) async {
    if (!_isMobile) {
      final types = [
        XTypeGroup(
          label: t('图片', 'Images'),
          extensions: resourceImageExtensions,
          uniformTypeIdentifiers: const ['public.image'],
        ),
      ];
      if (multiple) return openFiles(acceptedTypeGroups: types);
      final image = await openFile(acceptedTypeGroups: types);
      return image == null ? [] : [image];
    }
    FocusManager.instance.primaryFocus?.unfocus();
    final source = await _resourceChoice(t('添加图片', 'Add image'), [
      ('camera', t('拍照', 'Take photo'), CupertinoIcons.camera),
      (
        'photos',
        t('从相册选择', 'Choose from Photos'),
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
            t(
              '请在系统设置中允许 Marker 访问相机或相册。',
              'Allow Marker to access Camera or Photos in system settings.',
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
      t('保存到 Marker', 'Save in Marker'),
      t('文件名', 'File name'),
      initial: suggestedName,
    );
    if (name == null || !mounted) return null;
    String path;
    try {
      path = await MobileDocumentStore().savePath(name);
    } on FormatException {
      throw const ResourceFailure(
        '文件名不能为空，且不能包含斜杠。',
        'Enter a file name without slashes.',
      );
    }
    if (await File(path).exists() && mounted) {
      final overwrite = await _resourceChoice(
        t('文件已存在', 'File already exists'),
        [('replace', t('替换现有文件', 'Replace existing file'), CupertinoIcons.doc)],
      );
      if (overwrite != 'replace') return null;
    }
    return FileSaveLocation(path);
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
      final saved = await FilePicker.saveFile(
        fileName: p.basename(zipPath),
        mimeType: 'application/zip',
        bytes: await File(zipPath).readAsBytes(),
      );
      if (mounted && saved != null) {
        _toast(t('已导出文档与图片。', 'Document and images exported.'));
      }
    } finally {
      await stage.delete(recursive: true);
    }
  }
}
