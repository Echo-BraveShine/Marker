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
}
