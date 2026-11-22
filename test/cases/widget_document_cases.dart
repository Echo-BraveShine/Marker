part of '../widget_test.dart';

void _registerWidgetDocumentCases() {
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
