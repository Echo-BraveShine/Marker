import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marker/src/widgets/markdown_templates.dart';
import 'package:marker/src/widgets/mermaid_diagram.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'offline page safely encodes source and notifies Linux after rendering',
    () async {
      const source = 'flowchart LR\nA["</script><script>bad()</script>"] --> B';
      final page = mermaidHtml(source, '// bundled JS', true, linux: true);
      expect(page, contains(r'\u003c/script>'));
      expect(page, isNot(contains('<script>bad()')));
      expect(page, contains("theme:'dark'"));
      expect(
        page,
        contains('window.webkit.messageHandlers.marker.postMessage(value)'),
      );
      expect(page, contains('await document.fonts.ready'));
      expect(page, contains("default-src 'none'"));
    },
  );

  testWidgets(
    'Linux renders embedded image and reports native errors',
    (tester) async {
      final calls = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(MermaidDiagram.linuxChannel, (call) async {
            calls.add(call);
            if (calls.length == 2) {
              throw PlatformException(
                code: 'mermaid-render',
                message: 'Invalid diagram syntax',
              );
            }
            return base64Decode(
              'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAACklEQVR4nGMAAQAABQABDQottAAAAABJRU5ErkJggg==',
            );
          });
      addTearDown(
        () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(MermaidDiagram.linuxChannel, null),
      );
      await tester.pumpWidget(
        ProviderScope(
          child: const CupertinoApp(
            home: MermaidDiagram(source: 'flowchart LR\nA --> B', dark: false),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 250));
      // rootBundle performs real asset IO in this test.
      await tester.runAsync(() async {
        await rootBundle.load('assets/fonts/NotoSansSC.ttf');
        await Future<void>.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();
      expect(find.byType(Image), findsOneWidget);
      expect(calls.single.method, 'render');
      expect((calls.single.arguments as Map)['width'], mermaidCanvasWidth);
      expect(
        (calls.single.arguments as Map)['html'],
        contains('data:font/ttf;base64,'),
      );
      expect(
        (calls.single.arguments as Map)['html'],
        contains("theme:'default'"),
      );
      await tester.pumpWidget(
        const ProviderScope(
          child: CupertinoApp(
            home: MermaidDiagram(source: 'bad syntax', dark: true),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pumpAndSettle();
      expect(find.textContaining('Invalid diagram syntax'), findsOneWidget);
    },
    variant: TargetPlatformVariant({TargetPlatform.linux}),
  );

  test('export native rendering fixtures when requested', () async {
    final directory = Platform.environment['MARKER_MERMAID_FIXTURES'];
    if (directory == null) return;
    Directory(directory).createSync(recursive: true);
    Directory('$directory/windows').createSync(recursive: true);
    final script = await File('assets/mermaid.min.js').readAsString();
    for (final template in mermaidTemplates) {
      for (final dark in [false, true]) {
        File(
          '$directory/${template.id}-${dark ? 'dark' : 'light'}.html',
        ).writeAsStringSync(
          mermaidHtml(
            template.source,
            script,
            dark,
            linux: true,
            fontUri: Platform.environment['MARKER_MERMAID_FONT_URI'],
          ),
        );
        File(
          '$directory/windows/${template.id}-${dark ? 'dark' : 'light'}.html',
        ).writeAsStringSync(
          mermaidHtml(
            template.source,
            script,
            dark,
            fontUri: Platform.environment['MARKER_MERMAID_FONT_URI'],
          ),
        );
      }
    }
    for (final dark in [false, true]) {
      const chinese = 'flowchart LR\n A[开始] --> B[编辑中文文档] --> C[保存]';
      File(
        '$directory/chinese-${dark ? 'dark' : 'light'}.html',
      ).writeAsStringSync(
        mermaidHtml(
          chinese,
          script,
          dark,
          linux: true,
          fontUri: Platform.environment['MARKER_MERMAID_FONT_URI'],
        ),
      );
      File(
        '$directory/windows/chinese-${dark ? 'dark' : 'light'}.html',
      ).writeAsStringSync(
        mermaidHtml(
          chinese,
          script,
          dark,
          fontUri: Platform.environment['MARKER_MERMAID_FONT_URI'],
        ),
      );
    }
    File('$directory/invalid.html').writeAsStringSync(
      mermaidHtml('not-a-diagram', script, false, linux: true),
    );
    File(
      '$directory/windows/invalid.html',
    ).writeAsStringSync(mermaidHtml('not-a-diagram', script, false));
  });
}
