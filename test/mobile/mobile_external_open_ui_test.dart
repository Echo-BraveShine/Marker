import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:marker/main.dart';
import 'package:marker/src/mobile/mobile_open_files.dart';
import 'package:marker/src/mobile/mobile_document_store.dart';
import 'package:marker/src/providers/workspace_provider.dart';
import 'package:marker/src/providers/autosave_provider.dart';
import 'package:marker/src/widgets/markdown_extensions.dart';

class _Incoming extends MobileOpenFiles {
  _Incoming(this.initial);
  final List<MobileOpenFile> initial;
  final acknowledged = <String>[];
  void Function(List<MobileOpenFile>)? receive;
  bool stopped = false;
  @override
  Future<void> connect(void Function(List<MobileOpenFile>) callback) async {
    receive = callback;
    callback(initial);
  }

  @override
  Future<void> acknowledge(String token) async {
    acknowledged.add(token);
  }

  @override
  Future<void> disconnect() async {
    stopped = true;
  }
}

Future<void> _frames(WidgetTester tester, bool Function() done) async {
  for (var i = 0; i < 150 && !done(); i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 15)),
    );
    await tester.pump(const Duration(milliseconds: 30));
  }
  expect(done(), isTrue);
}

void main() {
  testWidgets(
    'cold/warm opens queue, preserve edits, deduplicate and continue after errors',
    (tester) async {
      final root = (await tester.runAsync(
        () => Directory.systemTemp.createTemp('marker-external-ui-'),
      ))!;
      final first = File(p.join(root.path, '外部 文档.md'));
      final second = File(p.join(root.path, 'second.md'));
      await tester.runAsync(() async {
        await first.writeAsString('# External');
        await second.writeAsString('# Second');
      });
      SharedPreferences.setMockInitialValues({
        'workspaceV1': jsonEncode({
          'documents': [
            {
              'id': 'existing',
              'path': null,
              'text': '# Existing',
              'saved': '# Existing',
            },
          ],
          'activeId': 'existing',
        }),
      });
      final native = _Incoming([
        MobileOpenFile(token: 'cold', path: first.path),
        MobileOpenFile(token: 'cold', path: first.path),
      ]);
      mobileWindow = true;
      addTearDown(() => mobileWindow = false);
      try {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              mobileOpenFilesProvider.overrideWithValue(native),
              mobileDocumentStoreProvider.overrideWithValue(
                MobileDocumentStore(
                  directory: () async =>
                      Directory(p.join(root.path, 'documents')),
                ),
              ),
              mermaidPreviewEnabledProvider.overrideWithValue(false),
            ],
            child: const MarkerApp(),
          ),
        );
        await tester.pump();
        await _frames(tester, () => native.acknowledged.contains('cold'));
        final container = ProviderScope.containerOf(
          tester.element(find.byType(MarkerHome)),
        );
        expect(container.read(workspaceProvider).documents, hasLength(2));
        final imported = container
            .read(workspaceProvider.notifier)
            .active!
            .path!;
        expect(p.isWithin(p.join(root.path, 'documents'), imported), isTrue);
        await tester.enterText(find.byKey(const Key('editor')), '# My edits');
        native.receive!([MobileOpenFile(token: 'warm', path: first.path)]);
        await _frames(tester, () => native.acknowledged.contains('warm'));
        expect(container.read(workspaceProvider).documents, hasLength(2));
        expect(
          container.read(workspaceProvider.notifier).active!.text,
          '# My edits',
        );
        native.receive!([
          const MobileOpenFile(token: 'error', error: 'No file access'),
          MobileOpenFile(token: 'second', path: second.path),
        ]);
        await _frames(tester, () => native.acknowledged.contains('second'));
        expect(native.acknowledged, ['cold', 'warm', 'error', 'second']);
        expect(find.textContaining('部分文件导入失败'), findsOneWidget);
        expect(container.read(workspaceProvider).documents, hasLength(3));
        expect(
          container.read(workspaceProvider.notifier).active!.text,
          '# Second',
        );
        expect(await tester.runAsync(() => first.readAsString()), '# External');
        await tester.runAsync(
          () => container.read(autosaveProvider.notifier).flush(),
        );
        expect(tester.takeException(), isNull);
      } finally {
        await tester.pumpWidget(const SizedBox());
        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          await root.delete(recursive: true);
        });
      }
      expect(native.stopped, isTrue);
    },
    variant: TargetPlatformVariant({
      TargetPlatform.android,
      TargetPlatform.iOS,
    }),
  );
}
