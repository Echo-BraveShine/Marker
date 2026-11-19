import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:marker/src/providers/workspace_provider.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test(
    'documents preserve independent drafts and restore last selection',
    () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final workspace = container.read(workspaceProvider.notifier);
      final documentPath =
          '${Directory.systemTemp.path}${Platform.pathSeparator}中文 文档.md';
      workspace.add(text: 'one', saved: 'one', path: documentPath);
      final first = workspace.active!.id;
      workspace.snapshot('modified one', 'one', documentPath);
      workspace.add(text: 'two', saved: 'two');
      final second = workspace.active!.id;
      workspace.select(first);
      expect(workspace.active!.text, 'modified one');
      await workspace.persist();
      final restored = ProviderContainer();
      addTearDown(restored.dispose);
      final reader = restored.read(workspaceProvider.notifier);
      expect(await reader.restore(), isTrue);
      expect(reader.active!.id, first);
      expect(reader.active!.text, 'modified one');
      expect(reader.active!.path, documentPath);
      reader.remove(first);
      expect(reader.active!.id, second);
      reader.remove(second);
      expect(restored.read(workspaceProvider).documents, isEmpty);
      await reader.persist();
      final empty = ProviderContainer();
      addTearDown(empty.dispose);
      expect(await empty.read(workspaceProvider.notifier).restore(), isTrue);
      expect(empty.read(workspaceProvider).documents, isEmpty);
    },
  );
  test(
    'recent content edits sort first, selection alone preserves order',
    () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(workspaceProvider.notifier);
      notifier.add(text: 'older', saved: 'older');
      final first = notifier.active!.id;
      notifier.add(text: 'newer', saved: 'newer');
      final second = notifier.active!.id;
      notifier.select(first);
      expect(container.read(workspaceProvider).documents.first.id, second);
      notifier.snapshot('edited older', 'older', null);
      expect(container.read(workspaceProvider).documents.first.id, first);
      notifier.select(second);
      notifier.snapshot('newer', 'newer', null);
      expect(container.read(workspaceProvider).documents.first.id, first);
      await notifier.persist();
      final restored = ProviderContainer();
      addTearDown(restored.dispose);
      await restored.read(workspaceProvider.notifier).restore();
      expect(restored.read(workspaceProvider).documents.first.id, first);
      expect(restored.read(workspaceProvider).activeId, second);
    },
  );
}
