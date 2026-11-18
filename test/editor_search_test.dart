import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marker/src/widgets/editor_search.dart';
import 'package:marker/src/widgets/app_shortcuts.dart';

void main() {
  test(
    'literal search supports case, Unicode, empty text and special characters',
    () {
      expect(findEditorMatches('Apple apple', 'apple').length, 2);
      expect(
        findEditorMatches('Apple apple', 'apple', caseSensitive: true).length,
        1,
      );
      expect(findEditorMatches('a.b a?b', '.').single.start, 1);
      expect(findEditorMatches('中文 中文', '中文').length, 2);
      expect(findEditorMatches('text', ''), isEmpty);
    },
  );
  test(
    'replace all uses original ranges and preserves literal replacement characters',
    () {
      const input = TextEditingValue(text: 'a a A');
      expect(replaceEditorMatches(input, 'a', r'$x').text, r'$x $x $x');
      expect(
        replaceEditorMatches(input, 'a', 'aa', caseSensitive: true).text,
        'aa aa A',
      );
      expect(replaceEditorMatches(input, 'missing', 'b'), input);
      expect(replaceEditorMatches(input, 'a', '').text, '  ');
    },
  );
  test('desktop shortcut mappings are unique and use platform modifiers', () {
    for (final platform in [
      TargetPlatform.macOS,
      TargetPlatform.windows,
      TargetPlatform.linux,
    ]) {
      final keys = appShortcuts
          .where((s) => !s.native)
          .map((s) => s.activator(platform))
          .toList();
      expect(keys.toSet().length, keys.length);
      final find = appShortcuts
          .firstWhere((s) => s.id == 'find')
          .activator(platform);
      expect(find.meta, platform == TargetPlatform.macOS);
      expect(find.control, platform != TargetPlatform.macOS);
      expect(appShortcuts.every((s) => s.display(platform).isNotEmpty), isTrue);
    }
  });
}
