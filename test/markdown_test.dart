import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marker/src/providers/editor_provider.dart';

void main() {
  test('document state is immutable and provider containers are isolated', () {
    final container = ProviderContainer();
    final other = ProviderContainer();
    addTearDown(container.dispose);
    addTearDown(other.dispose);
    final original = container.read(editorProvider);
    container.read(editorProvider.notifier).setMarkdown('changed');
    expect(container.read(editorProvider).dirty, isTrue);
    expect(original.markdown, defaultMarkdown);
    expect(other.read(editorProvider).markdown, defaultMarkdown);
    container.read(editorProvider.notifier).markSaved();
    expect(container.read(editorProvider).dirty, isFalse);
  });
}
