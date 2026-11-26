part of '../resource_ui_test.dart';

void _registerResourceUiDropsCases() {
  testWidgets(
    'native delayed image drops work over preview and resource sidebar',
    (tester) async {
      final root = await launch(tester, enableDesktop: true);
      final source = '${root.path}/拖入 图片.png';
      await tester.runAsync(
        () => File(source).writeAsBytes(base64Decode(imageData)),
      );
      final calls = <String>[];
      const channel = MethodChannel('desktop_drop');
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
        call,
      ) async {
        calls.add(call.method);
        return true;
      });
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          channel,
          null,
        ),
      );
      Future<void> native(String method, Object? arguments) async {
        final completed = Completer<void>();
        tester.binding.defaultBinaryMessenger.handlePlatformMessage(
          'desktop_drop',
          const StandardMethodCodec().encodeMethodCall(
            MethodCall(method, arguments),
          ),
          (_) => completed.complete(),
        );
        await completed.future;
      }

      final preview = tester.getCenter(find.byKey(const Key('preview')));
      await native('entered', [preview.dx, preview.dy]);
      await tester.pump();
      expect(find.byKey(const Key('resource-drop-hint')), findsOneWidget);
      expect(
        DefaultTextStyle.of(
          tester.element(find.text('松开以导入图片')),
        ).style.decoration,
        TextDecoration.none,
      );
      // macOS file promises may complete after native drag-exit clears the hover.
      await native('exited', null);
      await native('performOperation_macos', [
        {
          'path': source,
          'apple-bookmark': Uint8List.fromList([1, 2, 3]),
          'drop-position': [preview.dx, preview.dy],
          'isDirectory': false,
        },
      ]);
      await ioFrames(
        tester,
        () =>
            editor(tester).controller!.text.contains('.assets/') &&
            !editor(tester).readOnly,
      );
      expect(editor(tester).controller!.text, contains('.assets/'));
      expect(
        calls,
        containsAllInOrder([
          'startAccessingSecurityScopedResource',
          'stopAccessingSecurityScopedResource',
        ]),
      );
      expect(find.byKey(const Key('resource-drop-hint')), findsNothing);
      expect(await tester.runAsync(() => File(source).exists()), isTrue);
      await tester.tap(find.byIcon(CupertinoIcons.photo_on_rectangle));
      await ioFrames(tester);
      final sidebar = tester.getCenter(
        find.byKey(const Key('document-sidebar')),
      );
      final zone = tester.widget<DropTarget>(
        find.byKey(const Key('resource-drop-zone')),
      );
      zone.onDragDone!(
        DropDoneDetails(
          files: [DropItemFile(source)],
          localPosition: sidebar,
          globalPosition: sidebar,
        ),
      );
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
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
    variant: TargetPlatformVariant({TargetPlatform.macOS}),
  );
  testWidgets(
    'image drops reach preview and sidebar across desktop platform layouts',
    (tester) async {
      final windows = defaultTargetPlatform == TargetPlatform.windows;
      tester.view.devicePixelRatio = windows ? 2 : 1;
      addTearDown(tester.view.resetDevicePixelRatio);
      final root = await launch(tester, enableDesktop: true);
      final source = '${root.path}/中文 空格 #%.png';
      await tester.runAsync(
        () => File(source).writeAsBytes(base64Decode(imageData)),
      );
      Future<void> native(String method, Object? arguments) async {
        final completed = Completer<void>();
        tester.binding.defaultBinaryMessenger.handlePlatformMessage(
          'desktop_drop',
          const StandardMethodCodec().encodeMethodCall(
            MethodCall(method, arguments),
          ),
          (_) => completed.complete(),
        );
        await completed.future;
      }

      Future<void> dropAt(Offset logicalPoint) async {
        final point =
            logicalPoint * (windows ? tester.view.devicePixelRatio : 1);
        await native('exited', null);
        // Some Linux desktops deliver motion before enter; Windows sends pixels.
        await native(windows ? 'entered' : 'updated', [point.dx, point.dy]);
        await tester.pump();
        expect(find.byKey(const Key('resource-drop-hint')), findsOneWidget);
        if (!windows) await native('exited', null);
        if (!windows && Platform.isWindows) {
          // TargetPlatformVariant changes Flutter's layout, not dart:io's OS.
          // Linux's transport correctly decodes file:///C:/... to POSIX /C:/...
          // and cannot open that path on a Windows host. Test the decoded drop
          // UI with the real host file; POSIX transport is tested separately in
          // resource_drop_test.dart on every host, including Windows.
          final zone = find.byKey(const Key('resource-drop-zone'));
          tester.widget<DropTarget>(zone).onDragDone!(
            DropDoneDetails(
              files: [DropItemFile(source)],
              localPosition: logicalPoint - tester.getTopLeft(zone),
              globalPosition: logicalPoint,
            ),
          );
          return;
        }
        await native(
          windows ? 'performOperation_windows' : 'performOperation_linux',
          windows
              ? {
                  'files': [source],
                  'position': [point.dx, point.dy],
                }
              : [
                  Uri.file(source).toString(),
                  [point.dx, point.dy],
                ],
        );
      }

      await dropAt(tester.getCenter(find.byKey(const Key('preview'))));
      await ioFrames(
        tester,
        () =>
            editor(tester).controller!.text.contains('.assets/') &&
            !editor(tester).readOnly,
      );
      expect(editor(tester).controller!.text, contains('.assets/'));
      expect(editor(tester).controller!.text, contains('%23%25'));
      await tester.tap(find.byIcon(CupertinoIcons.photo_on_rectangle));
      await ioFrames(tester);
      await dropAt(tester.getCenter(find.byKey(const Key('document-sidebar'))));
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
      expect(await tester.runAsync(() => File(source).exists()), isTrue);
      expect(find.byKey(const Key('resource-drop-hint')), findsNothing);
      if (!windows) {
        final before = editor(tester).controller!.text;
        final point = tester.getCenter(find.byKey(const Key('preview')));
        tester
            .widget<DropTarget>(find.byKey(const Key('resource-drop-zone')))
            .onDragDone!(
          DropDoneDetails(
            files: const [],
            localPosition: point,
            globalPosition: point,
            rawText: 'portal-transfer-key',
          ),
        );
        await ioFrames(
          tester,
          () =>
              find.text('系统未能提供拖入文件的访问权限，请使用“导入图片”选择文件。').evaluate().isNotEmpty,
        );
        expect(find.text('系统未能提供拖入文件的访问权限，请使用“导入图片”选择文件。'), findsOneWidget);
        expect(editor(tester).controller!.text, before);
      }
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
    variant: TargetPlatformVariant({
      TargetPlatform.windows,
      TargetPlatform.linux,
    }),
  );
  testWidgets(
    'cancelling first-save after a drop releases file access and preserves text',
    (tester) async {
      final root = await launch(tester, saved: false, enableDesktop: true);
      final source = '${root.path}/拖入.png';
      await tester.runAsync(
        () => File(source).writeAsBytes(base64Decode(imageData)),
      );
      final calls = <String>[];
      const channel = MethodChannel('desktop_drop');
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
        call,
      ) async {
        calls.add(call.method);
        return true;
      });
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          channel,
          null,
        ),
      );
      final point = tester.getCenter(find.byKey(const Key('preview')));
      tester
          .widget<DropTarget>(find.byKey(const Key('resource-drop-zone')))
          .onDragDone!(
        DropDoneDetails(
          files: [
            DropItemFile(
              source,
              extraAppleBookmark: Uint8List.fromList([1, 2, 3]),
            ),
          ],
          localPosition: point,
          globalPosition: point,
        ),
      );
      await ioFrames(tester, () => find.text('先保存文档').evaluate().isNotEmpty);
      expect(find.text('先保存文档'), findsOneWidget);
      expect(
        tester
            .widget<DropTarget>(find.byKey(const Key('resource-drop-zone')))
            .enable,
        isFalse,
      );
      await tester.tap(find.byKey(const Key('dialog-close')));
      await ioFrames(tester);
      expect(editor(tester).controller!.text, '原始内容');
      expect(calls, [
        'startAccessingSecurityScopedResource',
        'stopAccessingSecurityScopedResource',
      ]);
      expect(
        await tester.runAsync(
          () => Directory('${root.path}/文档.assets').exists(),
        ),
        isFalse,
      );
      expect(find.text('处理结果'), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
    variant: TargetPlatformVariant({TargetPlatform.macOS}),
  );
  testWidgets(
    'drop permission recovery authorizes source and destination separately',
    (tester) async {
      final service = _PermissionResourceService();
      final root = await launch(
        tester,
        enableDesktop: true,
        resources: service,
      );
      final sourceFolder = Directory('${root.path}/外部图片');
      await tester.runAsync(() => sourceFolder.create());
      final source = '${sourceFolder.path}/图片.png';
      await tester.runAsync(
        () => File(source).writeAsBytes(base64Decode(imageData)),
      );
      final grants = <String>[];
      final resources = const MethodChannel('marker/resources');
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        resources,
        (call) async {
          if (call.method == 'authorizeDirectoryWithContext') {
            final context = call.arguments as Map;
            grants.add(context['path'] as String);
            expectSync(context['prompt'], '允许访问此目录');
            return context['path'];
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          resources,
          null,
        ),
      );
      final point = tester.getCenter(find.byKey(const Key('preview')));
      tester
          .widget<DropTarget>(find.byKey(const Key('resource-drop-zone')))
          .onDragDone!(
        DropDoneDetails(
          files: [DropItemFile(source)],
          localPosition: point,
          globalPosition: point,
        ),
      );
      await ioFrames(
        tester,
        () =>
            editor(tester).controller!.text.contains('.assets/') &&
            !editor(tester).readOnly,
      );
      expect(grants, [sourceFolder.path, root.path]);
      expect(
        editor(tester).controller!.text,
        contains('.assets/'),
        reason: tester
            .widgetList<Text>(find.byType(Text))
            .map((widget) => widget.data)
            .whereType<String>()
            .where((text) => text.contains('失败'))
            .join('\n'),
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
    variant: TargetPlatformVariant({TargetPlatform.macOS}),
  );
}
