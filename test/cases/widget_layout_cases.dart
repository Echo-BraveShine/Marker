part of '../widget_test.dart';

void _registerWidgetLayoutCases() {
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
  testWidgets('syntax toolbar adds commands on resize and fills wide windows', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1000, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [mermaidPreviewEnabledProvider.overrideWithValue(false)],
        child: const MarkerApp(),
      ),
    );
    await tester.pumpAndSettle();
    final row = find.byKey(const Key('markdown-toolbar-syntax'));
    Finder controls() =>
        find.descendant(of: row, matching: find.byType(CupertinoButton));
    final narrowCount = controls().evaluate().length;
    await tester.binding.setSurfaceSize(const Size(2800, 800));
    await tester.pumpAndSettle();
    expect(controls().evaluate().length, greaterThan(narrowCount));
    expect(find.descendant(of: row, matching: find.text('H6')), findsOneWidget);
    expect(
      tester.getRect(controls().last).right,
      closeTo(tester.getRect(row).right, .1),
    );
    await tester.binding.setSurfaceSize(const Size(3600, 800));
    await tester.pumpAndSettle();
    expect(
      tester.getRect(controls().last).right,
      closeTo(tester.getRect(row).right, .1),
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
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
    await tester.tap(find.byKey(const Key('editor')));
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('syntax-floating-panel')), findsNothing);
    expect(editor.controller!.text, contains('## 二级标题'));
    await tester.tap(find.byIcon(CupertinoIcons.chevron_down));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('syntax-panel-close')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('syntax-floating-panel')), findsNothing);
    expect(tester.getRect(find.byKey(const Key('editor'))), before);
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
    await tester.tap(
      find.descendant(
        of: find.byType(CupertinoSlidingSegmentedControl<int>),
        matching: find.text('预览'),
      ),
    );
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
    await tester.tap(
      find.descendant(
        of: find.byType(CupertinoSlidingSegmentedControl<int>),
        matching: find.text('编辑'),
      ),
    );
    await tester.pumpAndSettle();
    final edit = tester.getRect(find.byKey(const Key('editor')));
    expect(edit.width, greaterThan(1280));
    expect(
      tester
          .widget<CupertinoTextField>(find.byKey(const Key('editor')))
          .padding,
      const EdgeInsets.fromLTRB(4, 10, 4, 10),
    );
    await tester.tap(
      find.descendant(
        of: find.byType(CupertinoSlidingSegmentedControl<int>),
        matching: find.text('分屏'),
      ),
    );
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
    expect(
      tester
          .getCenter(
            find.descendant(
              of: find.byType(CupertinoSlidingSegmentedControl<int>),
              matching: find.text('分屏'),
            ),
          )
          .dy,
      closeTo(y, 1),
    );
    await tester.enterText(find.byKey(const Key('editor')), 'content');
    await tester.pumpAndSettle();
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.digit3);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('editor')), findsNothing);
    await tester.tap(
      find.descendant(
        of: find.byType(CupertinoSlidingSegmentedControl<int>),
        matching: find.text('分屏'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('editor')));
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('search-query')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
