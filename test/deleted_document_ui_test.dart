import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marker/main.dart';
import 'package:marker/src/providers/workspace_provider.dart';
import 'package:marker/src/widgets/markdown_extensions.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  for (final dirty in [false, true]) {
    testWidgets('external deletion syncs sidebar and editor (dirty: $dirty)', (
      tester,
    ) async {
      final directory = (await tester.runAsync(
        () => Directory.systemTemp.createTemp('marker-delete-ui-'),
      ))!;
      final file = File('${directory.path}/external.md');
      await tester.runAsync(() => file.writeAsString('Original'));
      SharedPreferences.setMockInitialValues({
        'workspaceV1': jsonEncode({
          'activeId': 'document',
          'documents': [
            {
              'id': 'document',
              'path': file.path,
              'text': 'Original',
              'saved': 'Original',
            },
          ],
        }),
      });
      final container = ProviderContainer(
        overrides: [mermaidPreviewEnabledProvider.overrideWithValue(false)],
      );
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      try {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MarkerApp(),
          ),
        );
        for (var i = 0; i < 10; i++) {
          await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 20)),
          );
          await tester.pump();
        }
        expect(
          container.read(workspaceProvider).documents.single.path,
          file.path,
        );
        if (dirty) {
          await tester.enterText(
            find.byKey(const Key('editor')),
            'Unsaved changes',
          );
          await tester.pump();
        }
        await tester.runAsync(() => file.delete());
        await tester.pump(const Duration(seconds: 3));
        for (var i = 0; i < 10; i++) {
          await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 20)),
          );
          await tester.pump();
        }
        final docs = container.read(workspaceProvider).documents;
        final editor = tester.widget<CupertinoTextField>(
          find.byKey(const Key('editor')),
        );
        if (dirty) {
          expect(docs.single.path, isNull);
          expect(editor.controller!.text, 'Unsaved changes');
        } else {
          expect(docs, isEmpty);
          expect(editor.controller!.text, isEmpty);
        }
        expect(await tester.runAsync(() => file.exists()), isFalse);
        expect(tester.takeException(), isNull);
      } finally {
        await tester.pumpWidget(const SizedBox.shrink());
        container.dispose();
        await tester.binding.setSurfaceSize(null);
        await tester.runAsync(() => directory.delete(recursive: true));
      }
    });
  }
}
