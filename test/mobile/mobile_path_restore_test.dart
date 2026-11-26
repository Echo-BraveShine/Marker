import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:marker/src/mobile/mobile_path_restore.dart';
import 'package:marker/src/providers/workspace_provider.dart';
import 'package:marker/src/providers/autosave_provider.dart';
import 'package:marker/src/resources/resource_service.dart';
import 'package:marker/src/resources/resource_references.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test(
    'detached drafts rebase photos inside their previous documents root',
    () async {
      final root = await Directory.systemTemp.createTemp('marker-detached-');
      const old = '/var/mobile/Containers/Data/Application/OLD-UUID/Documents';
      final image = File(p.join(root.path, 'note.assets', 'photo.png'));
      await image.parent.create();
      await image.writeAsBytes([1, 2, 3]);
      final text = '![photo](<${Uri.file('$old/note.assets/photo.png')}>)';
      SharedPreferences.setMockInitialValues({
        'workspaceV1': jsonEncode({
          'mobileDocumentsRoot': old,
          'activeId': 'a',
          'documents': [
            {'id': 'a', 'path': null, 'text': text, 'saved': 'baseline'},
          ],
        }),
      });
      final container = ProviderContainer(
        overrides: [
          mobileDocumentsRootProvider.overrideWithValue(
            Future.value(root.path),
          ),
        ],
      );
      try {
        final workspace = container.read(workspaceProvider.notifier);
        await workspace.restore();
        expect(workspace.active!.path, isNull);
        final inventory = await DocumentResourceService().scan(
          workspace.active!.text,
          null,
        );
        expect(inventory.unresolved, isEmpty);
        expect(inventory.items.single.path, image.path);
      } finally {
        container.dispose();
        await root.delete(recursive: true);
      }
    },
  );
  test(
    'restart rebases the document and keeps images when the sandbox root changes',
    () async {
      final temp = await Directory.systemTemp.createTemp('marker-sandbox-');
      final old = await Directory(p.join(temp.path, 'old-documents')).create();
      final newRoot = p.join(temp.path, 'new-documents');
      final image = File(p.join(old.path, 'note.assets', 'photo.png'));
      await image.parent.create();
      await image.writeAsBytes([1, 2, 3]);
      final doc = File(p.join(old.path, 'note.md'));
      await doc.writeAsString('![photo](note.assets/photo.png)');
      final first = ProviderContainer(
        overrides: [
          mobileDocumentsRootProvider.overrideWithValue(Future.value(old.path)),
        ],
      );
      final second = ProviderContainer(
        overrides: [
          mobileDocumentsRootProvider.overrideWithValue(Future.value(newRoot)),
        ],
      );
      try {
        first
            .read(workspaceProvider.notifier)
            .add(
              text: await doc.readAsString(),
              saved: await doc.readAsString(),
              path: doc.path,
            );
        await first.read(workspaceProvider.notifier).persist();
        await old.rename(newRoot);
        final workspace = second.read(workspaceProvider.notifier);
        await workspace.restore();
        expect(workspace.active!.path, p.join(newRoot, 'note.md'));
        final inventory = await DocumentResourceService().scan(
          workspace.active!.text,
          workspace.active!.path,
        );
        expect(inventory.unresolved, isEmpty);
        expect(await File(inventory.items.single.path!).readAsBytes(), [
          1,
          2,
          3,
        ]);
        await File(workspace.active!.path!).delete();
        await workspace.syncDeletedFiles();
        expect(second.read(workspaceProvider).documents, isEmpty);
      } finally {
        first.dispose();
        second.dispose();
        await temp.delete(recursive: true);
      }
    },
  );
  test(
    'legacy iOS absolute image paths migrate to relative references before autosave',
    () async {
      final root = await Directory.systemTemp.createTemp(
        'marker-legacy-sandbox-',
      );
      final old = '/var/mobile/Containers/Data/Application/OLD-UUID/Documents';
      final original = '![图](<${Uri.file('$old/note.assets/中文 图.png')}>)';
      final file = File(p.join(root.path, 'note.md'));
      await file.writeAsString(original);
      final image = File(p.join(root.path, 'note.assets', '中文 图.png'));
      await image.parent.create();
      await image.writeAsBytes([1, 2, 3]);
      SharedPreferences.setMockInitialValues({
        'workspaceV1': jsonEncode({
          'activeId': 'a',
          'documents': [
            {
              'id': 'a',
              'path': '$old/note.md',
              'text': original,
              'saved': original,
            },
          ],
        }),
      });
      final container = ProviderContainer(
        overrides: [
          mobileDocumentsRootProvider.overrideWithValue(
            Future.value(root.path),
          ),
        ],
      );
      try {
        final workspace = container.read(workspaceProvider.notifier);
        await workspace.restore();
        expect(workspace.active!.path, file.path);
        expect(workspace.active!.text, isNot(contains('OLD-UUID')));
        expect(workspace.active!.saved, original);
        await container.read(autosaveProvider.notifier).flush();
        final saved = await file.readAsString();
        expect(saved, isNot(contains('OLD-UUID')));
        final refs = await parseResourceReferencesAsync(saved);
        expect(
          File.fromUri(
            resolveResourceUri(refs.images.single.source, file.path),
          ).path,
          image.path,
        );
      } finally {
        container.dispose();
        await root.delete(recursive: true);
      }
    },
  );
}
