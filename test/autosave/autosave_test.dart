import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:marker/src/providers/autosave_provider.dart';
import 'package:marker/src/providers/workspace_provider.dart';
import 'package:marker/src/resources/resource_provider.dart';
import 'package:marker/src/resources/resource_service.dart';

class ControlledWriter extends DocumentResourceService {
  Completer<void>? gate;
  final entered = Completer<void>();
  bool fail = false;
  int writes = 0;
  @override
  Future<void> atomicWrite(File file, String text) async {
    writes++;
    if (!entered.isCompleted) entered.complete();
    await gate?.future;
    if (fail) {
      throw FileSystemException(
        'Denied',
        file.path,
        const OSError('Denied', 13),
      );
    }
    return super.atomicWrite(file, text);
  }
}

void main() {
  late Directory root;
  late File file;
  late ProviderContainer container;
  late WorkspaceNotifier workspace;
  late AutosaveController autosave;
  late ControlledWriter writer;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    root = await Directory.systemTemp.createTemp('marker-autosave-');
    file = File('${root.path}/note.md');
    await file.writeAsString('original');
    writer = ControlledWriter();
    container = ProviderContainer(
      overrides: [resourceServiceProvider.overrideWithValue(writer)],
    );
    autosave = container.read(autosaveProvider.notifier);
    workspace = container.read(workspaceProvider.notifier);
    workspace.add(text: 'original', saved: 'original', path: file.path);
  });
  tearDown(() async {
    container.dispose();
    await root.delete(recursive: true);
  });

  test('debounced edits reach disk and acknowledge saved content', () async {
    workspace.snapshot('edited', 'original', file.path);
    await Future<void>.delayed(const Duration(milliseconds: 1100));
    await autosave.flush();
    expect(await file.readAsString(), 'edited');
    expect(workspace.active!.dirty, isFalse);
    expect(
      container.read(autosaveProvider)[workspace.active!.id],
      SaveStatus.saved,
    );
  });
  test('continuous edits are flushed by the five-second deadline', () async {
    for (var i = 0; i < 18; i++) {
      workspace.snapshot('edit $i', workspace.active!.saved, file.path);
      await Future<void>.delayed(const Duration(milliseconds: 300));
    }
    expect(writer.writes, greaterThanOrEqualTo(1));
    await autosave.flush();
    expect(await file.readAsString(), 'edit 17');
  });
  test(
    'typing and changing tabs during a write never acknowledge newer text',
    () async {
      final first = workspace.active!.id;
      workspace.snapshot('first version', 'original', file.path);
      writer.gate = Completer<void>();
      final pending = autosave.flush();
      await writer.entered.future;
      workspace.snapshot('second version', 'original', file.path);
      workspace.add(text: 'other', saved: 'other');
      final second = workspace.active!.id;
      writer.gate!.complete();
      await pending;
      final doc = container
          .read(workspaceProvider)
          .documents
          .singleWhere((d) => d.id == first);
      expect(doc.text, 'second version');
      expect(doc.saved, 'first version');
      expect(workspace.active!.id, second);
      await autosave.flush();
      expect(await file.readAsString(), 'second version');
      expect(workspace.active!.text, 'other');
    },
  );
  for (final deleted in [false, true]) {
    test(
      'external changes during staging are protected (deleted: $deleted)',
      () async {
        workspace.snapshot('mine', 'original', file.path);
        writer.gate = Completer<void>();
        final pending = autosave.flush();
        await writer.entered.future;
        if (deleted) {
          await file.delete();
        } else {
          await file.writeAsString('external');
        }
        writer.gate!.complete();
        await pending;
        expect(
          container.read(autosaveProvider)[workspace.active!.id],
          deleted ? SaveStatus.deleted : SaveStatus.conflict,
        );
        if (deleted) {
          expect(await file.exists(), isFalse);
        } else {
          expect(await file.readAsString(), 'external');
        }
        expect(workspace.active!.text, 'mine');
      },
    );
  }
  test('external changes pause autosave until explicit overwrite', () async {
    workspace.snapshot('mine', 'original', file.path);
    await file.writeAsString('external');
    await autosave.flush();
    final id = workspace.active!.id;
    expect(container.read(autosaveProvider)[id], SaveStatus.conflict);
    expect(await file.readAsString(), 'external');
    expect(workspace.active!.dirty, isTrue);
    expect(await autosave.saveDocument(id, overwrite: true), isTrue);
    expect(await file.readAsString(), 'mine');
  });
  test(
    'deleted files are never recreated and edits survive as detached drafts',
    () async {
      workspace.snapshot('mine', 'original', file.path);
      await file.delete();
      await autosave.flush();
      expect(await file.exists(), isFalse);
      expect(
        container.read(autosaveProvider)[workspace.active!.id],
        SaveStatus.deleted,
      );
      await workspace.syncDeletedFiles();
      expect(workspace.active!.path, isNull);
      expect(workspace.active!.text, 'mine');
    },
  );
  test('write failures preserve drafts and wait for explicit retry', () async {
    writer.fail = true;
    workspace.snapshot('mine', 'original', file.path);
    await autosave.flush();
    final id = workspace.active!.id;
    expect(container.read(autosaveProvider)[id], SaveStatus.failed);
    expect(await file.readAsString(), 'original');
    await autosave.flush();
    expect(writer.writes, 1);
    writer.fail = false;
    autosave.retry(id);
    await autosave.flush();
    expect(await file.readAsString(), 'mine');
    expect(workspace.active!.dirty, isFalse);
  });
  test(
    'external clean changes refresh without overwriting dirty edits',
    () async {
      await file.writeAsString('external');
      expect(await autosave.refreshExternal(), isTrue);
      expect(workspace.active!.text, 'external');
      workspace.snapshot('mine', 'external', file.path);
      await file.writeAsString('external again');
      await autosave.refreshExternal();
      expect(workspace.active!.text, 'mine');
    },
  );
}
