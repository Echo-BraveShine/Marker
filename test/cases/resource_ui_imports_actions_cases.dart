part of '../resource_ui_test.dart';

void _registerResourceUiImportsActionsCases() {
  testWidgets(
    'cancelling folder access stops import without retry or error dialog',
    (tester) async {
      final service = _PermissionResourceService()..denySource = false;
      final root = await launch(
        tester,
        enableDesktop: true,
        resources: service,
      );
      final source = '${root.path}/原图.png';
      await tester.runAsync(
        () => File(source).writeAsBytes(base64Decode(imageData)),
      );
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        picker,
        (call) async => call.method == 'openFile' ? [source] : null,
      );
      final calls = <MethodCall>[];
      const resources = MethodChannel('marker/resources');
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        resources,
        (call) async {
          calls.add(call);
          return null; // User cancels the OS folder permission panel.
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          resources,
          null,
        ),
      );
      await tester.tap(find.byIcon(CupertinoIcons.photo_on_rectangle));
      await ioFrames(tester);
      await tester.tap(find.byKey(const Key('resource-import')));
      await ioFrames(tester);
      expect(calls.single.method, 'authorizeDirectoryWithContext');
      expect((calls.single.arguments as Map)['path'], root.path);
      expect(editor(tester).controller!.text, '原始内容');
      expect(
        await tester.runAsync(
          () => Directory('${root.path}/文档.assets').exists(),
        ),
        isFalse,
      );
      expect(find.text('处理结果'), findsNothing);
      expect(find.text('已取消导入，原图未修改。'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
    variant: TargetPlatformVariant({TargetPlatform.macOS}),
  );
  testWidgets('image read failures identify the source path and OS error', (
    tester,
  ) async {
    final root = await launch(tester);
    final missing = '${root.path}/不存在.png';
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      picker,
      (call) async => call.method == 'openFile' ? [missing] : null,
    );
    await tester.tap(find.byIcon(CupertinoIcons.photo_on_rectangle));
    await ioFrames(tester);
    await tester.tap(find.byKey(const Key('resource-import')));
    await ioFrames(tester);
    expect(find.textContaining('读取原图失败'), findsOneWidget);
    expect(find.textContaining(missing), findsOneWidget);
    expect(find.textContaining('错误码 2'), findsOneWidget);
    expect(editor(tester).controller!.text, '原始内容');
    await tester.tap(find.byKey(const Key('dialog-close')));
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets(
    'resource sidebar imports images and editor paste accepts screenshots',
    (tester) async {
      final root = await launch(tester);
      final source = '${root.path}/原图 #1.png';
      await tester.runAsync(
        () => File(source).writeAsBytes(base64Decode(imageData)),
      );
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(picker, (
        call,
      ) async {
        if (call.method == 'openFile') return [source];
        return null;
      });
      await tester.tap(find.byIcon(CupertinoIcons.photo_on_rectangle));
      await ioFrames(
        tester,
        () => find.byKey(const Key('resource-import')).evaluate().isNotEmpty,
      );
      await tester.tap(find.byKey(const Key('resource-import')));
      await ioFrames(
        tester,
        () =>
            editor(tester).controller!.text.contains('.assets/') &&
            !editor(tester).readOnly,
      );
      final first = editor(tester).controller!.text;
      expect(first, contains('.assets/'));
      expect(first, contains('%23'));
      expect(await tester.runAsync(() => File(source).exists()), isTrue);
      expect(
        await tester.runAsync(
          () => Directory('${root.path}/文档.assets').exists(),
        ),
        isTrue,
      );
      await ioFrames(tester);
      expect(find.text('本地图片'), findsOneWidget);
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.getData') return {'text': ''};
          return null;
        },
      );
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        pasteboard,
        (call) async {
          if (call.method == 'files') return <String>[];
          if (call.method == 'image') {
            if (Platform.isWindows) {
              final temporary = '${root.path}/clipboard-image.png';
              await File(temporary).writeAsBytes(base64Decode(imageData));
              return temporary;
            }
            return base64Decode(imageData);
          }
          return null;
        },
      );
      await tester.tap(find.byKey(const Key('editor')));
      final modifier = defaultTargetPlatform == TargetPlatform.macOS
          ? LogicalKeyboardKey.metaLeft
          : LogicalKeyboardKey.controlLeft;
      await tester.sendKeyDownEvent(modifier);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyV);
      await tester.sendKeyUpEvent(modifier);
      await ioFrames(
        tester,
        () =>
            RegExp(r'!\[').allMatches(editor(tester).controller!.text).length ==
                2 &&
            !editor(tester).readOnly,
      );
      expect(
        RegExp(r'!\[').allMatches(editor(tester).controller!.text).length,
        2,
      );
      // Duplicate content is reused even when it arrived through the clipboard.
      final images = await tester.runAsync(
        () async => await Directory(
          '${root.path}/文档.assets',
        ).list().where((f) => f.path.endsWith('.png')).length,
      );
      expect(images, 1);
      final copyPath = '${root.path}/副本.md';
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        picker,
        (call) async => call.method == 'getSavePath' ? copyPath : null,
      );
      await tester.tap(find.byIcon(CupertinoIcons.square_arrow_down_on_square));
      await ioFrames(
        tester,
        () => ProviderScope.containerOf(
          tester.element(find.byType(MarkerApp)),
          listen: false,
        ).read(workspaceProvider).documents.any((doc) => doc.path == copyPath),
      );
      expect(
        await tester.runAsync(() => File(copyPath).exists()),
        isTrue,
        reason:
            '${ProviderScope.containerOf(tester.element(find.byType(MarkerApp)), listen: false).read(resourceUiProvider)} ${tester.widgetList<Text>(find.byType(Text)).map((w) => w.data).whereType<String>().where((s) => s.contains('失败') || s.contains('failed')).join(' | ')}',
      );
      expect(
        await tester.runAsync(() => File('${root.path}/文档.md').readAsString()),
        '原始内容',
      );
      expect(
        editor(tester).controller!.text,
        contains('%E5%89%AF%E6%9C%AC.assets/'),
      );
      expect(
        ProviderScope.containerOf(
          tester.element(find.byType(MarkerApp)),
          listen: false,
        ).read(workspaceProvider).documents.length,
        2,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
    variant: TargetPlatformVariant({
      TargetPlatform.macOS,
      TargetPlatform.windows,
      TargetPlatform.linux,
    }),
  );

  testWidgets(
    'cancelling first save keeps editor and creates no image directory',
    (tester) async {
      final root = await launch(tester, saved: false);
      final source = '${root.path}/image.png';
      await tester.runAsync(
        () => File(source).writeAsBytes(base64Decode(imageData)),
      );
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        picker,
        (call) async => call.method == 'openFile' ? [source] : null,
      );
      await tester.tap(find.byIcon(CupertinoIcons.photo_on_rectangle));
      await ioFrames(tester);
      await tester.tap(find.byKey(const Key('resource-import')));
      await tester.pumpAndSettle();
      expect(find.text('先保存文档'), findsOneWidget);
      await tester.tap(find.byKey(const Key('dialog-close')));
      await tester.pumpAndSettle();
      expect(editor(tester).controller!.text, '原始内容');
      expect(
        await tester.runAsync(
          () => Directory('${root.path}/文档.assets').exists(),
        ),
        isFalse,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'new document folder creates only a Markdown file and preserves the current document',
    (tester) async {
      final root = await launch(tester);
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        picker,
        (call) async => call.method == 'getDirectoryPath' ? root.path : null,
      );
      await tester.tap(find.byIcon(CupertinoIcons.photo_on_rectangle));
      await ioFrames(tester);
      await tester.tap(find.byKey(const Key('resource-menu')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('新建文档文件夹…'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('resource-text-input')),
        '新项目',
      );
      await tester.tap(find.text('确定'));
      await tester.pump(const Duration(milliseconds: 250));
      final path = '${root.path}/新项目/新项目.md';
      await ioFrames(
        tester,
        () => ProviderScope.containerOf(
          tester.element(find.byType(MarkerApp)),
          listen: false,
        ).read(workspaceProvider).documents.any((doc) => doc.path == path),
      );
      expect(await tester.runAsync(() => File(path).exists()), isTrue);
      expect(
        await tester.runAsync(
          () => Directory('${root.path}/新项目/新项目.assets').exists(),
        ),
        isFalse,
      );
      expect(
        await tester.runAsync(() => File('${root.path}/文档.md').readAsString()),
        '原始内容',
      );
      expect(editor(tester).controller!.text, '');
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'resource panel preserves shared Apple dialog style in both appearances',
    (tester) async {
      final key = GlobalKey();
      final root = await launch(tester, boundary: key);
      final font = await tester.runAsync(() async {
        final bytes = await rootBundle.load('assets/fonts/NotoSansSC.ttf');
        await ui.loadFontFromList(
          bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
          fontFamily: MarkerFonts.cjkFamily,
        );
        final icons = await rootBundle.load(
          'packages/cupertino_icons/assets/CupertinoIcons.ttf',
        );
        await ui.loadFontFromList(
          icons.buffer.asUint8List(icons.offsetInBytes, icons.lengthInBytes),
          fontFamily: 'packages/cupertino_icons/CupertinoIcons',
        );
        return true;
      });
      expect(font, isTrue);
      final input = '${root.path}/示意图.png';
      await tester.runAsync(
        () => File(input).writeAsBytes(base64Decode(imageData)),
      );
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        picker,
        (call) async => call.method == 'openFile' ? [input] : null,
      );
      await tester.tap(find.byIcon(CupertinoIcons.photo_on_rectangle));
      await ioFrames(tester);
      await tester.tap(find.byKey(const Key('resource-import')));
      await ioFrames(
        tester,
        () =>
            editor(tester).controller!.text.contains('.assets/') &&
            find.text('本地图片').evaluate().isNotEmpty,
      );
      await tester.tap(find.byKey(const Key('resource-menu')));
      await tester.pumpAndSettle();
      expect(find.text('文档资源'), findsOneWidget);
      expect(find.text('打包文档与图片…'), findsNothing); // Export remains hidden.
      expect(tester.takeException(), isNull);
      final out = Platform.environment['MARKER_RESOURCE_SCREENSHOTS'];
      if (out != null) {
        await tester.runAsync(() async {
          await Directory(out).create(recursive: true);
          final image =
              await (key.currentContext!.findRenderObject()!
                      as RenderRepaintBoundary)
                  .toImage(pixelRatio: 1);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          await File(
            '$out/resource-panel-light.png',
          ).writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
      }
      await tester.tap(find.byKey(const Key('dialog-close')));
      await tester.pumpAndSettle();
      final container = ProviderScope.containerOf(
        tester.element(find.byType(MarkerApp)),
        listen: false,
      );
      await container.read(themeProvider.notifier).setThemeMode(ThemeMode.dark);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('resource-menu')));
      await tester.pumpAndSettle();
      if (out != null) {
        await tester.runAsync(() async {
          final image =
              await (key.currentContext!.findRenderObject()!
                      as RenderRepaintBoundary)
                  .toImage(pixelRatio: 1);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          await File(
            '$out/resource-panel-dark.png',
          ).writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
      }
      expect(tester.takeException(), isNull);
      await tester.tap(find.byKey(const Key('dialog-close')));
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox());
    },
    variant: TargetPlatformVariant({TargetPlatform.linux}),
  );
}
