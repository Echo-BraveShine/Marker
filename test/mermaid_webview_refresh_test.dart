import 'dart:io';

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marker/src/widgets/mermaid_diagram.dart';
import 'package:marker/src/widgets/offline_html_renderer.dart';

void main() {
  testWidgets(
    'cached snapshots survive remount/resize and debounce rapid edits',
    (tester) async {
      final pages = <String>[];
      final widths = <int>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(OfflineHtmlRenderer.channel, (call) async {
            final args = call.arguments as Map;
            pages.add(await File(args['path'] as String).readAsString());
            widths.add(args['width'] as int);
            return base64Decode(
              'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAACklEQVR4nGMAAQAABQABDQottAAAAABJRU5ErkJggg==',
            );
          });
      addTearDown(
        () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(OfflineHtmlRenderer.channel, null),
      );
      final renderer = MermaidRenderer();
      Widget host(String source, bool dark, double width) => ProviderScope(
        overrides: [mermaidRenderProvider.overrideWithValue(renderer)],
        child: CupertinoApp(
          home: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: width,
              child: MermaidDiagram(source: source, dark: dark),
            ),
          ),
        ),
      );
      Future<void> finish() async {
        await tester.pump(const Duration(milliseconds: 250));
        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 300));
        });
        await tester.pumpAndSettle();
      }

      await tester.runAsync(
        () => renderer.render('flowchart LR\nA --> B', false),
      );
      await tester.pumpWidget(host('flowchart LR\nA --> B', false, 500));
      await finish();
      expect(pages.length, 1);
      expect(find.byType(Image), findsOneWidget);
      expect(widths.single, mermaidCanvasWidth);
      expect(pages.single, contains('NotoSansSC.ttf'));
      expect(pages.single, contains('<script src="file:'));
      expect(pages.single.length, lessThan(12000));
      expect(pages.single, isNot(contains('base64,')));
      expect(
        pages.single.indexOf("await document.fonts.load('400"),
        lessThan(pages.single.indexOf("await mermaid.render(")),
      );
      await tester.pumpWidget(host('flowchart LR\nA --> B', false, 320));
      await finish();
      expect(pages.length, 1);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(host('flowchart LR\nA --> B', false, 500));
      await finish();
      expect(pages.length, 1);
      await tester.pumpWidget(
        host('flowchart LR\nA --> intermediate', false, 500),
      );
      await tester.pump(const Duration(milliseconds: 100));
      await tester.runAsync(
        () => renderer.render('flowchart LR\nA --> C', true),
      );
      await tester.pumpWidget(host('flowchart LR\nA --> C', true, 500));
      await finish();
      expect(pages.length, 2);
      expect(pages.last, contains('A --> C'));
      expect(pages.last, contains("theme:'dark'"));
      expect(pages.last, isNot(contains('A --> intermediate')));
      expect(tester.takeException(), isNull);
    },
    variant: TargetPlatformVariant({TargetPlatform.macOS}),
  );
}
