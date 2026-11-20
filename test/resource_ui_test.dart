import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marker/main.dart';
import 'package:marker/src/providers/workspace_provider.dart';
import 'package:marker/src/providers/theme_provider.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:desktop_drop/desktop_drop.dart';
import 'package:marker/src/resources/resource_provider.dart';
import 'package:marker/src/resources/resource_service.dart';
import 'package:marker/src/widgets/markdown_extensions.dart';
import 'package:marker/src/theme/marker_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'support/file_cleanup.dart';

const imageData =
    'iVBORw0KGgoAAAANSUhEUgAAAAMAAAACCAIAAAASFvFNAAAAFElEQVR4nGM0qfjGAAZMEIqBgQEAHN4BptKOUnYAAAAASUVORK5CYII=';
const picker = MethodChannel('plugins.flutter.io/file_selector');
const pasteboard = MethodChannel('pasteboard');
void main() {
  Future<void> ioFrames(WidgetTester tester, [bool Function()? done]) async {
    for (var i = 0; i < (done == null ? 45 : 150); i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 15)),
      );
      await tester.pump(const Duration(milliseconds: 30));
      if (done?.call() == true) break;
    }
  }

  CupertinoTextField editor(WidgetTester tester) =>
      tester.widget<CupertinoTextField>(find.byKey(const Key('editor')));
  Future<Directory> launch(
    WidgetTester tester, {
    bool saved = true,
    bool enableDesktop = false,
    DocumentResourceService? resources,
    GlobalKey? boundary,
  }) async {
    if (enableDesktop) {
      desktopWindow = true;
      addTearDown(() => desktopWindow = false);
      for (final name in [
        'window_manager',
        'marker/appearance',
        'marker/files',
      ]) {
        final channel = MethodChannel(name);
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          channel,
          (call) async => name == 'marker/files' ? <String>[] : null,
        );
        addTearDown(
          () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
            channel,
            null,
          ),
        );
      }
    }
    final root = (await tester.runAsync(
      () => Directory.systemTemp.createTemp('marker-resource-ui-'),
    ))!;
    addTearDown(() async {
      try {
        // Also runs when an assertion fails before the test's own unmount.
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
      } finally {
        // FileImage uses native file-backed buffers. Unmounting alone leaves
        // cached codecs alive, which can block deletion on Windows.
        tester.binding.imageCache.clear();
        tester.binding.imageCache.clearLiveImages();
        // Cache eviction releases keep-alive handles in a post-frame callback.
        // Run that frame before attempting to remove the backing files.
        await tester.pump();
        await tester.runAsync(
          () => withWindowsFileLockRetry(() async {
            if (await root.exists()) await root.delete(recursive: true);
          }),
        );
      }
    });
    final doc = '${root.path}/文档.md';
    await tester.runAsync(() => File(doc).writeAsString('原始内容'));
    SharedPreferences.setMockInitialValues({
      'workspaceV1': jsonEncode({
        'documents': [
          {
            'id': 'doc',
            'path': saved ? doc : null,
            'text': '原始内容',
            'saved': saved ? '原始内容' : '',
            'lastEdited': 1,
          },
        ],
        'activeId': 'doc',
      }),
    });
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      RepaintBoundary(
        key: boundary,
        child: ProviderScope(
          overrides: [
            mermaidPreviewEnabledProvider.overrideWithValue(false),
            if (resources != null)
              resourceServiceProvider.overrideWithValue(resources),
          ],
          child: const MarkerApp(),
        ),
      ),
    );
    await ioFrames(
      tester,
      () =>
          find.byKey(const Key('editor')).evaluate().isNotEmpty &&
          editor(tester).controller!.text == '原始内容' &&
          !editor(tester).readOnly,
    );
    return root;
  }

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(picker, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pasteboard, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });
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
        await tester.pump();
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

class _PermissionResourceService extends DocumentResourceService {
  bool denySource = true, denyDestination = true;
  @override
  Future<Uint8List> readImage(ResourceInput input) async {
    if (input.path != null && denySource) {
      denySource = false;
      throw FileSystemException(
        'Permission denied',
        input.path,
        const OSError('Permission denied', 13),
      );
    }
    return super.readImage(input);
  }

  @override
  Future<ManagedImage> importImage(
    String documentPath,
    ResourceInput input,
  ) async {
    if (denyDestination) {
      denyDestination = false;
      throw FileSystemException(
        'Permission denied',
        documentPath,
        const OSError('Permission denied', 13),
      );
    }
    return super.importImage(documentPath, input);
  }
}
