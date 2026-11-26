import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marker/main.dart';
import 'package:marker/src/widgets/markdown_extensions.dart';
import 'package:marker/src/widgets/markdown_indentation.dart';
import 'package:marker/src/widgets/app_shortcuts.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test(
    'Tab inserts to the next four-space stop and preserves surrounding text',
    () {
      final result = indentMarkdownSelection(
        const TextEditingValue(
          text: 'ab',
          selection: TextSelection.collapsed(offset: 1),
        ),
      );
      expect(result.text, 'a   b');
      expect(result.selection.extentOffset, 4);
    },
  );
  test(
    'block indentation preserves reversed selections and CRLF boundaries',
    () {
      const original = TextEditingValue(
        text: 'a\r\nb\r\nc',
        selection: TextSelection(baseOffset: 6, extentOffset: 0),
      );
      final indented = indentMarkdownSelection(original);
      expect(indented.text, '    a\r\n    b\r\nc');
      expect(indented.selection.baseOffset, 14);
      expect(indented.selection.extentOffset, 4);
      final restored = indentMarkdownSelection(indented, outdent: true);
      expect(restored.text, original.text);
      expect(restored.selection, original.selection);
    },
  );
  test(
    'outdent handles tabs, partial spaces, and a caret inside indentation',
    () {
      final result = indentMarkdownSelection(
        const TextEditingValue(
          text: '  a\n\tb\nc',
          selection: TextSelection(baseOffset: 0, extentOffset: 8),
        ),
        outdent: true,
      );
      expect(result.text, 'a\nb\nc');
      final caret = indentMarkdownSelection(
        const TextEditingValue(
          text: '    a',
          selection: TextSelection.collapsed(offset: 2),
        ),
        outdent: true,
      );
      expect(caret.text, 'a');
      expect(caret.selection.extentOffset, 0);
    },
  );
  test('active IME composition is preserved', () {
    const value = TextEditingValue(
      text: '拼音',
      selection: TextSelection.collapsed(offset: 2),
      composing: TextRange(start: 0, end: 2),
    );
    expect(indentMarkdownSelection(value), value);
    expect(indentMarkdownSelection(value, outdent: true), value);
  });
  test('settings describe editor-only Tab without a primary modifier', () {
    final indent = appShortcuts.firstWhere((s) => s.id == 'indent');
    expect(indent.display(TargetPlatform.macOS), 'TAB');
    expect(indent.display(TargetPlatform.windows), 'TAB');
    expect(indent.activator(TargetPlatform.macOS).meta, isFalse);
  });
  testWidgets(
    'Tab edits only the focused document and Shift+Tab reverses it',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        'workspaceV1': jsonEncode({
          'documents': [
            {
              'id': 'tab-doc',
              'path': null,
              'text': 'abc\ndef',
              'saved': 'abc\ndef',
            },
          ],
          'activeId': 'tab-doc',
        }),
      });
      await tester.pumpWidget(
        ProviderScope(
          overrides: [mermaidPreviewEnabledProvider.overrideWithValue(false)],
          child: const MarkerApp(),
        ),
      );
      await tester.pumpAndSettle();
      final field = tester.widget<CupertinoTextField>(
        find.byKey(const Key('editor')),
      );
      await tester.tap(find.byKey(const Key('editor')));
      field.controller!.selection = const TextSelection.collapsed(offset: 1);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      expect(field.controller!.text, 'a   bc\ndef');
      expect(field.focusNode!.hasFocus, isTrue);
      field.controller!.selection = TextSelection(
        baseOffset: 0,
        extentOffset: field.controller!.text.length,
      );
      final before = field.controller!.text;
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      expect(field.controller!.text, '    a   bc\n    def');
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pumpAndSettle();
      expect(field.controller!.text, before);
      await tester.tap(find.byIcon(CupertinoIcons.search));
      await tester.pumpAndSettle();
      final query = tester.widget<CupertinoTextField>(
        find.byKey(const Key('search-query')),
      );
      expect(query.focusNode!.hasFocus, isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      expect(field.controller!.text, before);
      expect(query.focusNode!.hasFocus, isFalse);
      await tester.pumpWidget(const SizedBox());
    },
    variant: TargetPlatformVariant({
      TargetPlatform.macOS,
      TargetPlatform.windows,
      TargetPlatform.linux,
      TargetPlatform.iOS,
      TargetPlatform.android,
    }),
  );
}
