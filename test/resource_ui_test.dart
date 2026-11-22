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

part 'cases/resource_ui_drops_cases.dart';
part 'cases/resource_ui_imports_actions_cases.dart';

const imageData =
    'iVBORw0KGgoAAAANSUhEUgAAAAMAAAACCAIAAAASFvFNAAAAFElEQVR4nGM0qfjGAAZMEIqBgQEAHN4BptKOUnYAAAAASUVORK5CYII=';
const picker = MethodChannel('plugins.flutter.io/file_selector');
const pasteboard = MethodChannel('pasteboard');

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

void main() {
  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(picker, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pasteboard, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });
  _registerResourceUiDropsCases();
  _registerResourceUiImportsActionsCases();
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
