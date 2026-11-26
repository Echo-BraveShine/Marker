import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marker/src/widgets/mermaid_diagram.dart';
import 'package:marker/src/widgets/mermaid_preload.dart';
import 'package:marker/src/widgets/mermaid_render_scope.dart';

final _png = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAACklEQVR4nGMAAQAABQABDQottAAAAABJRU5ErkJggg==',
);
const _platforms = TargetPlatformVariant({
  TargetPlatform.macOS,
  TargetPlatform.windows,
  TargetPlatform.linux,
  TargetPlatform.iOS,
  TargetPlatform.android,
});

void main() {
  test(
    'warmup respects nested fences, deduplicates and matches CRLF preview sources',
    () {
      final diagrams = collectMermaidSources(
        '''# Notes
````markdown
```mermaid
not a diagram
```
````
```mermaid
flowchart LR
A --> B
```
> ~~~mermaid
> sequenceDiagram
> A->>B: Hello
> ~~~
```mermaid
flowchart LR
A --> B
```
'''
            .replaceAll('\n', '\r\n'),
      );
      expect(diagrams, [
        'flowchart LR\nA --> B\n',
        'sequenceDiagram\nA->>B: Hello\n',
      ]);
    },
  );
  test('warmup work is bounded for very large documents', () {
    final source = List.generate(
      100,
      (i) => '```mermaid\nflowchart LR\nA --> B$i\n```',
    ).join('\n');
    expect(collectMermaidSources(source), hasLength(24));
    expect(mermaidPngSize(_png), const Size(1, 1));
    expect(mermaidPngSize(Uint8List(2)), isNull);
  });

  testWidgets(
    'cold rendering waits for scrolling to settle on every platform',
    (tester) async {
      var calls = 0;
      final idle = Completer<void>();
      final renderer = MermaidRenderer(
        renderBackend: (_, _) async {
          calls++;
          return _png;
        },
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [mermaidRenderProvider.overrideWithValue(renderer)],
          child: CupertinoApp(
            home: MermaidRenderScope(
              waitForIdle: () => idle.future,
              child: const MermaidDiagram(
                source: 'flowchart LR\nA --> B',
                dark: false,
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(calls, 0);
      idle.complete();
      await tester.pumpAndSettle();
      expect(calls, 1);
      expect(find.byType(Image), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    },
    variant: _platforms,
  );

  testWidgets('a warm diagram uses cached geometry on its first frame', (
    tester,
  ) async {
    var calls = 0;
    final renderer = MermaidRenderer(
      renderBackend: (_, _) async {
        calls++;
        return _png;
      },
    );
    const source = 'flowchart LR\nA --> B';
    await renderer.render(source, false);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [mermaidRenderProvider.overrideWithValue(renderer)],
        child: const CupertinoApp(
          home: MermaidDiagram(source: source, dark: false),
        ),
      ),
    );
    expect(find.byType(CupertinoActivityIndicator), findsNothing);
    expect(find.byType(AspectRatio), findsOneWidget);
    await tester.pumpAndSettle();
    expect(calls, 1);
    await renderer.render(source, true);
    expect(calls, 2);
    await tester.pumpWidget(const SizedBox());
  }, variant: _platforms);

  testWidgets('both pane offsets postpone offscreen warmup until quiet', (
    tester,
  ) async {
    var calls = 0;
    final renderer = MermaidRenderer(
      renderBackend: (_, _) async {
        calls++;
        return _png;
      },
    );
    final editor = ScrollController(), preview = ScrollController();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [mermaidRenderProvider.overrideWithValue(renderer)],
        child: CupertinoApp(
          home: MermaidPreload(
            source: '```mermaid\nflowchart LR\nA --> B\n```',
            dark: false,
            enabled: true,
            controllers: [editor, preview],
            child: Row(
              children: [
                for (final controller in [editor, preview])
                  Expanded(
                    child: ListView(
                      controller: controller,
                      children: const [SizedBox(height: 2000)],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    editor.jumpTo(100);
    await tester.pump(const Duration(milliseconds: 100));
    expect(calls, 0);
    preview.jumpTo(100);
    await tester.pump(const Duration(milliseconds: 150));
    expect(calls, 0);
    await tester.pump(const Duration(milliseconds: 100));
    for (var i = 0; i < 20 && calls == 0; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pump();
    }
    expect(calls, 1);
    await tester.pumpWidget(const SizedBox());
    editor.dispose();
    preview.dispose();
  }, variant: _platforms);

  testWidgets(
    'document warmup renders diagrams without mounting their lazy widgets',
    (tester) async {
      final sources = <String>[];
      final renderer = MermaidRenderer(
        renderBackend: (source, _) async {
          sources.add(source);
          return _png;
        },
      );
      final editor = ScrollController(), preview = ScrollController();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [mermaidRenderProvider.overrideWithValue(renderer)],
          child: CupertinoApp(
            home: MermaidPreload(
              source: '```mermaid\nflowchart LR\nA --> B\n```',
              dark: false,
              enabled: true,
              controllers: [editor, preview],
              child: const Text('The diagram block is offscreen'),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 400));
      for (var i = 0; i < 20 && sources.isEmpty; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 50)),
        );
        await tester.pump();
      }
      expect(sources, ['flowchart LR\nA --> B\n']);
      await tester.pumpWidget(const SizedBox());
      editor.dispose();
      preview.dispose();
    },
  );
}
