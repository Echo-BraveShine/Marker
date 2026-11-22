import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marker/main.dart';
import 'package:marker/src/providers/editor_provider.dart';
import 'package:marker/src/widgets/markdown_extensions.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final source = List.generate(
    200,
    (i) =>
        'Paragraph $i **bold** with enough editable content to wrap across several lines in the split view. 中文正文。',
  ).join('\n\n');
  Future<void> launch(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'workspaceV1': jsonEncode({
        'documents': [
          {
            'id': 'scroll-doc',
            'text': source,
            'saved': source,
            'path': null,
            'lastEdited': 1,
          },
        ],
        'activeId': 'scroll-doc',
      }),
    });
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
      await tester.binding.setSurfaceSize(null);
    });
    await tester.pumpWidget(
      ProviderScope(
        overrides: [mermaidPreviewEnabledProvider.overrideWithValue(false)],
        child: const MarkerApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<CupertinoTextField>(find.byKey(const Key('editor')))
          .scrollController!
          .position
          .maxScrollExtent,
      greaterThan(0),
    );
  }

  Future<void> wheelPreview(WidgetTester tester) async {
    await tester.sendEventToBinding(
      PointerScrollEvent(
        position: tester.getCenter(find.byKey(const Key('preview'))),
        scrollDelta: const Offset(0, 500),
      ),
    );
    await tester.pump();
    await tester.pumpAndSettle();
  }

  testWidgets(
    'real app selection and IME update status without taking preview ownership',
    (tester) async {
      await launch(tester);
      final field = tester.widget<CupertinoTextField>(
        find.byKey(const Key('editor')),
      );
      await tester.tap(find.byKey(const Key('editor')));
      await tester.pumpAndSettle();
      await wheelPreview(tester);
      final markdown = tester.widget<Markdown>(
        find.byKey(const Key('preview')),
      );
      final preview = markdown.controller!;
      expect(preview.offset, greaterThan(0));
      final before = preview.offset;
      final offset = source.indexOf('Paragraph 50');
      field.controller!.selection = TextSelection.collapsed(offset: offset);
      await tester.pumpAndSettle();
      final container = ProviderScope.containerOf(
        tester.element(find.byType(MarkerHome)),
      );
      expect(container.read(editorProvider).cursorLine, 101);
      expect(container.read(editorProvider).cursorColumn, 1);
      expect(preview.offset, before);
      expect(
        identical(
          markdown,
          tester.widget<Markdown>(find.byKey(const Key('preview'))),
        ),
        isTrue,
      );
      field.controller!.value = field.controller!.value.copyWith(
        composing: TextRange(start: offset, end: offset + 4),
      );
      await tester.pumpAndSettle();
      field.scrollController!.jumpTo(100);
      await tester.pump();
      expect(preview.offset, before);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
    },
  );

  testWidgets(
    'real navigation keys and typing transfer control without consuming arrows',
    (tester) async {
      await launch(tester);
      final finder = find.byKey(const Key('editor'));
      final field = tester.widget<CupertinoTextField>(finder);
      await tester.tap(finder);
      field.controller!.selection = const TextSelection.collapsed(offset: 0);
      await tester.pumpAndSettle();
      await wheelPreview(tester);
      final preview = tester
          .widget<Markdown>(find.byKey(const Key('preview')))
          .controller!;
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expect(field.controller!.selection.extentOffset, 1);
      final beforeNavigationScroll = preview.offset;
      field.scrollController!.jumpTo(
        field.scrollController!.position.maxScrollExtent * .4,
      );
      await tester.pump();
      expect((preview.offset - beforeNavigationScroll).abs(), greaterThan(1));
      await wheelPreview(tester);
      await tester.enterText(finder, '$source\n\nNew typed paragraph');
      await tester.pumpAndSettle();
      final afterTyping = preview.offset;
      field.scrollController!.jumpTo(
        field.scrollController!.position.maxScrollExtent * .2,
      );
      await tester.pump();
      expect((preview.offset - afterTyping).abs(), greaterThan(1));
      expect(field.controller!.text, endsWith('New typed paragraph'));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
    },
  );
}
