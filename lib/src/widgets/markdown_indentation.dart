import 'package:flutter/services.dart';

/// Four-space tab stops; selected lines indent together without losing content.
TextEditingValue indentMarkdownSelection(
  TextEditingValue value, {
  bool outdent = false,
}) {
  if (value.composing.isValid && !value.composing.isCollapsed) return value;
  final text = value.text;
  final selection = value.selection.isValid
      ? value.selection
      : TextSelection.collapsed(offset: text.length);
  if (selection.end > text.length) return value;
  final start = selection.start, end = selection.end;
  final lineStart = start == 0 ? 0 : text.lastIndexOf('\n', start - 1) + 1;
  if (selection.isCollapsed && !outdent) {
    var column = 0;
    for (final rune in text.substring(lineStart, start).runes) {
      column += rune == 9 ? 4 - column % 4 : 1;
    }
    final spaces = ' ' * (4 - column % 4);
    return value.copyWith(
      text: text.replaceRange(start, end, spaces),
      selection: TextSelection.collapsed(offset: start + spaces.length),
      composing: TextRange.empty,
    );
  }
  // A selection ending at the next line's start does not include that line.
  final last =
      !selection.isCollapsed && end > 0 && text.codeUnitAt(end - 1) == 10
      ? end - 1
      : end;
  final newline = text.indexOf('\n', last);
  final lineEnd = newline < 0 ? text.length : newline;
  final changes = <({int offset, int removed, String inserted})>[];
  var offset = lineStart;
  for (final line in text.substring(lineStart, lineEnd).split('\n')) {
    var removed = 0;
    if (outdent) {
      if (line.startsWith('\t')) {
        removed = 1;
      } else {
        while (removed < 4 && removed < line.length && line[removed] == ' ') {
          removed++;
        }
      }
    }
    if (!outdent || removed > 0) {
      changes.add((
        offset: offset,
        removed: removed,
        inserted: outdent ? '' : '    ',
      ));
    }
    offset += line.length + 1;
  }
  if (changes.isEmpty) return value;
  final buffer = StringBuffer();
  var cursor = 0;
  for (final change in changes) {
    buffer.write(text.substring(cursor, change.offset));
    buffer.write(change.inserted);
    cursor = change.offset + change.removed;
  }
  buffer.write(text.substring(cursor));
  int remap(int position) {
    var delta = 0;
    for (final change in changes) {
      if (position < change.offset) break;
      if (position <= change.offset + change.removed) {
        return change.offset + delta + change.inserted.length;
      }
      delta += change.inserted.length - change.removed;
    }
    return position + delta;
  }

  return value.copyWith(
    text: buffer.toString(),
    selection: selection.copyWith(
      baseOffset: remap(selection.baseOffset),
      extentOffset: remap(selection.extentOffset),
    ),
    composing: TextRange.empty,
  );
}
