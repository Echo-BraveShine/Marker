part of '../widget_test.dart';

void _registerWidgetEditorSettingsCases() {
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
}
