import 'package:marker/src/providers/theme_provider.dart';
import 'package:marker/src/theme/highlight_style.dart';
import 'package:marker/src/widgets/markdown_editing_controller.dart';
import 'package:marker/src/providers/external_files.dart';
import 'package:marker/src/widgets/marker_dialog.dart';
import 'package:flutter/gestures.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:marker/src/widgets/markdown_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:marker/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });
  testWidgets('typing updates preview and marks document unsaved', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [mermaidPreviewEnabledProvider.overrideWithValue(false)],
        child: const MarkerApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.enterText(find.byKey(const Key('editor')), '# Unique heading');
    await tester.pumpAndSettle();
    expect(find.text('Unique heading'), findsOneWidget);
    expect(find.text('Untitled.md •'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('theme switch rebuilds application', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [mermaidPreviewEnabledProvider.overrideWithValue(false)],
        child: const MarkerApp(),
      ),
    );
    await tester.pumpAndSettle();
    final before = Theme.of(tester.element(find.byType(Scaffold))).brightness;
    expect(find.byIcon(Icons.brightness_6_outlined), findsNothing);
    expect(find.byIcon(Icons.translate), findsNothing);
    await tester.tap(find.byIcon(CupertinoIcons.gear));
    await tester.pumpAndSettle();
    await tester.tap(find.text(before == Brightness.dark ? '浅色' : '深色').last);
    await tester.pumpAndSettle();
    expect(
      Theme.of(tester.element(find.byType(Scaffold))).brightness,
      isNot(before),
    );
  });
  testWidgets('draft restores unsaved document and close can be cancelled', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'documentDraft':
          '{"text":"# Recovered draft","saved":"original","path":null}',
    });
    await tester.binding.setSurfaceSize(const Size(900, 600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [mermaidPreviewEnabledProvider.overrideWithValue(false)],
        child: const MarkerApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Recovered draft'), findsOneWidget);
    expect(find.text('Untitled.md •'), findsOneWidget);
    await tester.tap(
      find.text('Untitled.md •'),
      buttons: kSecondaryMouseButton,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('关闭文档'));
    await tester.pumpAndSettle();
    expect(find.byType(MarkerDialog), findsOneWidget);
    await tester.tap(find.byKey(const Key('dialog-close')));
    await tester.pumpAndSettle();
    expect(find.text('Recovered draft'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('editor')), '新的草稿');
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('documentDraft'), contains('新的草稿'));
    expect(tester.takeException(), isNull);
  });
  testWidgets('split editor fills pane and gutter follows text scroll', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [mermaidPreviewEnabledProvider.overrideWithValue(false)],
        child: const MarkerApp(),
      ),
    );
    await tester.pumpAndSettle();
    final fieldFinder = find.byKey(const Key('editor'));
    final gutterFinder = find.byKey(const Key('line-numbers'));
    final fieldRect = tester.getRect(fieldFinder);
    expect(fieldRect.height, greaterThan(600));
    expect(tester.getRect(gutterFinder).height, fieldRect.height);
    await tester.enterText(
      fieldFinder,
      List.generate(100, (i) => 'Line $i with text').join('\n'),
    );
    await tester.pumpAndSettle();
    final field = tester.widget<CupertinoTextField>(fieldFinder);
    expect(field.scrollController!.hasClients, isTrue);
    field.scrollController!.jumpTo(240);
    await tester.pump();
    expect(field.scrollController!.offset, 240);
    await tester.binding.setSurfaceSize(const Size(900, 600));
    await tester.pumpAndSettle();
    expect(tester.getRect(fieldFinder).height, greaterThan(450));
    expect(
      tester.getRect(fieldFinder).right,
      lessThan(tester.getRect(find.byKey(const Key('preview'))).left),
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets('sidebar toggle remains valid throughout animation', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(900, 600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [mermaidPreviewEnabledProvider.overrideWithValue(false)],
        child: const MarkerApp(),
      ),
    );
    await tester.pumpAndSettle();
    for (var i = 0; i < 4; i++) {
      await tester.tap(find.byIcon(CupertinoIcons.sidebar_left));
      for (var frame = 0; frame < 6; frame++) {
        await tester.pump(const Duration(milliseconds: 45));
        expect(tester.takeException(), isNull);
      }
    }
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('editor')), findsOneWidget);
  });
  testWidgets('expanded toolbar exposes syntax insertion commands', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [mermaidPreviewEnabledProvider.overrideWithValue(false)],
        child: const MarkerApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('editor')), 'content');
    await tester.pumpAndSettle();
    final before = tester.getRect(find.byKey(const Key('editor')));
    await tester.tap(find.byIcon(CupertinoIcons.chevron_down));
    await tester.pumpAndSettle();
    expect(tester.getRect(find.byKey(const Key('editor'))), before);
    final panel = tester.getRect(
      find.byKey(const Key('syntax-floating-panel')),
    );
    expect(panel.left, greaterThanOrEqualTo(before.right));
    final command = find.byKey(const ValueKey('md-command-H2'));
    expect(command, findsOneWidget);
    await tester.tap(command);
    await tester.pumpAndSettle();
    final editor = tester.widget<CupertinoTextField>(
      find.byKey(const Key('editor')),
    );
    expect(editor.controller!.text, contains('## 二级标题'));
    expect(find.byKey(const ValueKey('md-command-Mermaid')), findsOneWidget);
    await tester.tap(find.byKey(const Key('syntax-panel-close')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('syntax-floating-panel')), findsNothing);
    expect(tester.getRect(find.byKey(const Key('editor'))), before);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'new creates a file and cancellation preserves current document',
    (tester) async {
      final directory = (await tester.runAsync(
        () => Directory.systemTemp.createTemp('marker-new-'),
      ))!;
      addTearDown(() => directory.delete(recursive: true));
      const channel = MethodChannel('plugins.flutter.io/file_selector');
      String? savePath;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        (call) async => call.method == 'getSavePath' ? savePath : null,
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          channel,
          null,
        ),
      );
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [mermaidPreviewEnabledProvider.overrideWithValue(false)],
          child: const MarkerApp(),
        ),
      );
      await tester.pumpAndSettle();
      final original = tester
          .widget<CupertinoTextField>(find.byKey(const Key('editor')))
          .controller!
          .text;
      await tester.tap(find.byIcon(CupertinoIcons.doc_append));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<CupertinoTextField>(find.byKey(const Key('editor')))
            .controller!
            .text,
        original,
      );
      savePath = '${directory.path}/新文档.md';
      await tester.tap(find.byIcon(CupertinoIcons.doc_append));
      for (var attempt = 0; attempt < 40; attempt++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 15)),
        );
        await tester.pumpAndSettle();
        final current = tester
            .widget<CupertinoTextField>(find.byKey(const Key('editor')))
            .controller!
            .text;
        if (current.isEmpty &&
            (await tester.runAsync(() => File(savePath!).exists()))!) {
          break;
        }
      }
      expect(await tester.runAsync(() => File(savePath!).exists()), isTrue);
      expect(await tester.runAsync(() => File(savePath!).readAsString()), '');
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();
      expect(find.text('新文档.md'), findsWidgets);
      expect(
        tester
            .widget<CupertinoTextField>(find.byKey(const Key('editor')))
            .controller!
            .text,
        '',
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('document-sidebar')),
          matching: find.byIcon(CupertinoIcons.doc_text),
        ),
        findsNWidgets(2),
      );
      await tester.tap(find.text('Untitled.md'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<CupertinoTextField>(find.byKey(const Key('editor')))
            .controller!
            .text,
        original,
      );
      await tester.tap(find.text('新文档.md'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<CupertinoTextField>(find.byKey(const Key('editor')))
            .controller!
            .text,
        '',
      );
      await tester.tap(find.text('新文档.md'), buttons: kSecondaryMouseButton);
      await tester.pumpAndSettle();
      await tester.tap(find.text('关闭文档'));
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byKey(const Key('document-sidebar')),
          matching: find.byIcon(CupertinoIcons.doc_text),
        ),
        findsOneWidget,
      );
      expect(await tester.runAsync(() => File(savePath!).exists()), isTrue);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'text color picker wraps selected text and preserves surrounding text',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [mermaidPreviewEnabledProvider.overrideWithValue(false)],
          child: const MarkerApp(),
        ),
      );
      await tester.pumpAndSettle();
      final finder = find.byKey(const Key('editor'));
      await tester.enterText(finder, 'hello world');
      final controller = tester.widget<CupertinoTextField>(finder).controller!;
      controller.selection = const TextSelection(
        baseOffset: 0,
        extentOffset: 5,
      );
      await tester.tap(find.byKey(const Key('text-color-toolbar')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('text-color-#E53935')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('应用颜色'));
      await tester.pumpAndSettle();
      expect(controller.text, '<span style="color:#E53935">hello</span> world');
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('template menus insert equations and Mermaid samples', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [mermaidPreviewEnabledProvider.overrideWithValue(false)],
        child: const MarkerApp(),
      ),
    );
    await tester.pumpAndSettle();
    final editor = find.byKey(const Key('editor'));
    await tester.enterText(editor, '');
    await tester.tap(find.byIcon(CupertinoIcons.function));
    await tester.pumpAndSettle();
    final integral = find.byKey(const ValueKey('template-math-integral'));
    await tester.ensureVisible(integral);
    await tester.pumpAndSettle();
    expect(
      tester.getRect(find.text('积分')).left - tester.getRect(integral).left,
      closeTo(12, 1),
    );
    await tester.tap(integral);
    await tester.pumpAndSettle();
    expect(
      tester.widget<CupertinoTextField>(editor).controller!.text,
      contains(r'\int_0^1'),
    );
    await tester.enterText(editor, '');
    await tester.tap(find.byIcon(CupertinoIcons.flowchart));
    await tester.pumpAndSettle();
    final sequence = find.byKey(const ValueKey('template-mermaid-sequence'));
    await tester.ensureVisible(sequence);
    await tester.pumpAndSettle();
    expect(
      tester.getRect(find.text('时序图')).left - tester.getRect(sequence).left,
      closeTo(12, 1),
    );
    await tester.tap(sequence);
    await tester.pumpAndSettle();
    expect(
      tester.widget<CupertinoTextField>(editor).controller!.text,
      contains('```mermaid\nsequenceDiagram'),
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets('all view modes fill available width with compact insets', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1600, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [mermaidPreviewEnabledProvider.overrideWithValue(false)],
        child: const MarkerApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('editor')),
      'Wide preview content',
    );
    await tester.tap(find.text('预览'));
    await tester.pumpAndSettle();
    final preview = tester.getRect(find.byKey(const Key('preview')));
    expect(
      preview.width,
      closeTo(
        1600 -
            tester.getSize(find.byKey(const Key('document-sidebar'))).width -
            5,
        1,
      ),
    );
    final paragraph = tester.getRect(
      find.descendant(
        of: find.byKey(const Key('preview')),
        matching: find.text('Wide preview content'),
      ),
    );
    expect(paragraph.left - preview.left, closeTo(8, 1));
    await tester.tap(find.text('编辑'));
    await tester.pumpAndSettle();
    final edit = tester.getRect(find.byKey(const Key('editor')));
    expect(edit.width, greaterThan(1280));
    expect(
      tester
          .widget<CupertinoTextField>(find.byKey(const Key('editor')))
          .padding,
      const EdgeInsets.fromLTRB(4, 10, 4, 10),
    );
    await tester.tap(find.text('分屏'));
    await tester.pumpAndSettle();
    final split = tester.getRect(find.byKey(const Key('preview')));
    expect(split.width, closeTo((preview.width - 8) / 2, 1));
    expect(
      tester
              .getRect(
                find.descendant(
                  of: find.byKey(const Key('preview')),
                  matching: find.text('Wide preview content'),
                ),
              )
              .left -
          split.left,
      closeTo(8, 1),
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets('search shortcuts navigate and replace document text', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [mermaidPreviewEnabledProvider.overrideWithValue(false)],
        child: const MarkerApp(),
      ),
    );
    await tester.pumpAndSettle();
    final field = find.byKey(const Key('editor'));
    await tester.enterText(field, 'apple Apple pineapple');
    await tester.pumpAndSettle();
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyH);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('search-query')), findsOneWidget);
    await tester.enterText(find.byKey(const Key('search-query')), 'apple');
    await tester.pumpAndSettle();
    final source = tester.widget<CupertinoTextField>(field).controller!;
    expect(
      source.selection,
      const TextSelection(baseOffset: 0, extentOffset: 5),
    );
    expect(find.text('1/3'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.f3);
    await tester.pumpAndSettle();
    expect(source.selection.start, 6);
    await tester.enterText(find.byKey(const Key('search-replacement')), 'pear');
    await tester.tap(find.byKey(const Key('replace-current')));
    await tester.pumpAndSettle();
    expect(source.text, 'apple pear pineapple');
    await tester.tap(find.byKey(const Key('replace-all')));
    await tester.pumpAndSettle();
    expect(source.text, 'pear pear pinepear');
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('editor-search-bar')), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'highlight settings apply immediately without changing text or selection',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(900, 600));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [mermaidPreviewEnabledProvider.overrideWithValue(false)],
          child: const MarkerApp(),
        ),
      );
      await tester.pumpAndSettle();
      final source =
          tester
                  .widget<CupertinoTextField>(find.byKey(const Key('editor')))
                  .controller!
              as MarkdownEditingController;
      source.value = const TextEditingValue(
        text: '# Title\n**bold** and `code`',
        selection: TextSelection.collapsed(offset: 4),
      );
      await tester.pumpAndSettle();
      final before = source.value;
      await tester.tap(find.byIcon(CupertinoIcons.gear));
      await tester.pumpAndSettle();
      await tester.tap(find.text('编辑与预览'));
      await tester.pumpAndSettle();
      expect(source.highlightEnabled, isFalse);
      expect(find.byKey(const Key('settings-highlight-style')), findsNothing);
      await tester.tap(find.byKey(const Key('settings-highlight-enabled')));
      await tester.pumpAndSettle();
      expect(source.highlightEnabled, isTrue);
      expect(find.byKey(const Key('settings-highlight-style')), findsOneWidget);
      await tester.tap(find.text('Solarized'));
      await tester.pumpAndSettle();
      expect(source.highlightStyle, EditorHighlightStyle.solarized);
      expect(source.value, before);
      expect(
        (await SharedPreferences.getInstance()).getString(
          'editorHighlightStyle',
        ),
        'solarized',
      );
      await tester.tap(find.byKey(const Key('settings-highlight-enabled')));
      await tester.pumpAndSettle();
      expect(source.highlightEnabled, isFalse);
      expect(source.value, before);
      expect(find.byKey(const Key('settings-highlight-style')), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'sidebar resizing is bounded and saved; settings closes from header',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(900, 600));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [mermaidPreviewEnabledProvider.overrideWithValue(false)],
          child: const MarkerApp(),
        ),
      );
      await tester.pumpAndSettle();
      final container = ProviderScope.containerOf(
        tester.element(find.byType(Scaffold)),
      );
      expect(
        tester.getSize(find.byKey(const Key('document-sidebar'))).width,
        220,
      );
      await tester.drag(
        find.byKey(const Key('sidebar-resize')),
        const Offset(500, 0),
      );
      await tester.pumpAndSettle();
      expect(container.read(themeProvider).sidebarWidth, 320);
      expect(
        tester.getSize(find.byKey(const Key('document-sidebar'))).width,
        320,
      );
      expect(
        (await SharedPreferences.getInstance()).getDouble('sidebarWidth'),
        320,
      );
      await tester.drag(
        find.byKey(const Key('sidebar-resize')),
        const Offset(-500, 0),
      );
      await tester.pumpAndSettle();
      expect(container.read(themeProvider).sidebarWidth, 180);
      await tester.tap(find.byIcon(CupertinoIcons.gear));
      await tester.pumpAndSettle();
      expect(find.text('完成'), findsNothing);
      expect(find.byKey(const Key('dialog-close')), findsOneWidget);
      await tester.tap(find.text('编辑与预览'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('settings-highlight-enabled')));
      await tester.pumpAndSettle();
      for (final style in EditorHighlightStyle.values) {
        expect(find.byKey(ValueKey('highlight-${style.name}')), findsOneWidget);
      }
      await tester.tap(find.byKey(const Key('dialog-close')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('dialog-close')), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('search reveals matches and settings lists shortcuts', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [mermaidPreviewEnabledProvider.overrideWithValue(false)],
        child: const MarkerApp(),
      ),
    );
    await tester.pumpAndSettle();
    final field = find.byKey(const Key('editor'));
    await tester.enterText(
      field,
      List.generate(200, (i) => 'line $i').join('\n'),
    );
    await tester.pumpAndSettle();
    final scroll = tester.widget<CupertinoTextField>(field).scrollController!;
    scroll.jumpTo(0);
    await tester.pump();
    await tester.tap(find.byIcon(CupertinoIcons.search));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('search-query')), 'line 199');
    await tester.pumpAndSettle();
    expect(scroll.offset, greaterThan(0));
    await tester.tap(find.byKey(const Key('search-close')));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(CupertinoIcons.gear));
    await tester.pumpAndSettle();
    await tester.tap(find.text('快捷键'));
    await tester.pumpAndSettle();
    expect(find.text('查找与替换'), findsOneWidget);
    expect(find.text('Ctrl+H'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('compact toolbar stays on one row and shortcuts switch modes', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(900, 600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [mermaidPreviewEnabledProvider.overrideWithValue(false)],
        child: const MarkerApp(),
      ),
    );
    await tester.pumpAndSettle();
    final y = tester.getCenter(find.byIcon(CupertinoIcons.doc_append)).dy;
    expect(tester.getCenter(find.text('H1')).dy, closeTo(y, 1));
    expect(tester.getCenter(find.text('分屏')).dy, closeTo(y, 1));
    await tester.enterText(find.byKey(const Key('editor')), 'content');
    await tester.pumpAndSettle();
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.digit3);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('editor')), findsNothing);
    await tester.tap(find.text('分屏'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('editor')));
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('search-query')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('file manager launch paths open actual documents in sidebar', (
    tester,
  ) async {
    final directory = (await tester.runAsync(
      () => Directory.systemTemp.createTemp('marker-external-'),
    ))!;
    addTearDown(() => directory.delete(recursive: true));
    final file = File('${directory.path}/外部文档.md');
    await tester.runAsync(() => file.writeAsString('# External file'));
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          mermaidPreviewEnabledProvider.overrideWithValue(false),
          initialFilesProvider.overrideWithValue([file.path]),
        ],
        child: const MarkerApp(),
      ),
    );
    await tester.pumpAndSettle();
    for (var attempt = 0; attempt < 20; attempt++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 15)),
      );
      await tester.pumpAndSettle();
      if (tester
              .widget<CupertinoTextField>(find.byKey(const Key('editor')))
              .controller!
              .text ==
          '# External file') {
        break;
      }
    }
    expect(
      tester
          .widget<CupertinoTextField>(find.byKey(const Key('editor')))
          .controller!
          .text,
      '# External file',
    );
    expect(find.text('外部文档.md'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('app shortcuts work before the editor receives focus', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [mermaidPreviewEnabledProvider.overrideWithValue(false)],
        child: const MarkerApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.comma);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pumpAndSettle();
    expect(find.byType(MarkerDialog), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
