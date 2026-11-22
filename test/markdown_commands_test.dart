import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:marker/src/widgets/markdown_commands.dart';

void main() {
  test(
    'all syntax commands preserve selected text and surrounding content',
    () {
      for (final command in markdownCommandGroups.values.expand((v) => v)) {
        final result = command.apply(
          const TextEditingValue(
            text: 'before selected after',
            selection: TextSelection(baseOffset: 7, extentOffset: 15),
          ),
        );
        expect(
          result.text.startsWith('before '),
          isTrue,
          reason: command.label,
        );
        expect(result.text.endsWith(' after'), isTrue, reason: command.label);
        expect(
          result.text.substring(result.selection.start, result.selection.end),
          'selected',
          reason: command.label,
        );
      }
    },
  );
  test('commands insert placeholder when no selection is available', () {
    const command = MarkdownCommand('bold', '**', '**', 'text');
    expect(
      command.apply(const TextEditingValue(text: 'prefix')).text,
      'prefix**text**',
    );
  });
  test('all syntax groups, labels and inserted templates support English', () {
    final chinese = RegExp(r'[\u3400-\u9fff]');
    for (final group in markdownCommandGroups.entries) {
      expect(chinese.hasMatch(markdownGroupLabel(group.key, false)), isFalse);
      expect(markdownGroupLabel(group.key, true), group.key);
      for (final command in group.value) {
        final english = command.forLanguage(false);
        expect(
          chinese.hasMatch(command.labelFor(false)),
          isFalse,
          reason: command.label,
        );
        expect(
          chinese.hasMatch(
            '${english.before}${english.after}${english.placeholder}',
          ),
          isFalse,
          reason: command.label,
        );
        expect(english.label, command.label); // Dispatch identity stays stable.
        expect(identical(command.forLanguage(true), command), isTrue);
        final selected = english.apply(
          const TextEditingValue(
            text: '中文原文',
            selection: TextSelection(baseOffset: 0, extentOffset: 4),
          ),
        );
        expect(
          selected.text.substring(
            selected.selection.start,
            selected.selection.end,
          ),
          '中文原文',
        );
      }
    }
  });
}
