import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:marker/main.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:marker/src/widgets/markdown_scroll_anchors.dart';
import 'package:marker/src/widgets/markdown_extensions.dart';
import 'package:marker/src/providers/sample_markdown.dart';

void main() {
  test('parsed blocks map to source lines without altering syntax', () {
    const source =
        '# Title\n\nParagraph **bold**.\n\n```dart\nfinal x = 1;\n```\n\nSetext\n---\n';
    final nodes = md.Document(
      extensionSet: md.ExtensionSet.gitHubFlavored,
    ).parseLines(source.split('\n'));
    expect(markdownBlockLines(source, nodes), [0, 2, 4, 8]);
    final sample = md.Document(
      extensionSet: md.ExtensionSet.gitHubFlavored,
      blockSyntaxes: [MermaidSyntax(), MathBlockSyntax()],
      inlineSyntaxes: [TextColorSyntax(), MathInlineSyntax()],
    ).parseLines(defaultMarkdown.split('\n'));
    final starts = markdownBlockLines(defaultMarkdown, sample);
    expect(starts.length, sample.length);
    expect(starts, orderedEquals(starts.toList()..sort()));
  });
  testWidgets(
    'offscreen blocks expose stable document positions across scrolling',
    (tester) async {
      final source =
          '# Start\n\n```text\n${List.generate(40, (i) => 'Line $i').join('\n')}\n```\n\n## End\n\nFinal paragraph';
      final nodes = md.Document().parseLines(source.split('\n'));
      final lines = markdownBlockLines(source, nodes);
      final anchors = MarkdownScrollAnchors();
      final controller = ScrollController();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 600,
              height: 260,
              child: AnchoredMarkdown(
                data: source,
                sourceLines: lines,
                anchors: anchors,
                controller: controller,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final before = anchors.positions(controller);
      expect(before.length, nodes.length);
      expect(before[2].offset - before[1].offset, greaterThan(500));
      controller.jumpTo(300);
      await tester.pump();
      final after = anchors.positions(controller);
      for (var i = 0; i < before.length; i++) {
        expect(after[i].line, before[i].line);
        expect(after[i].offset, closeTo(before[i].offset, .1));
      }
      await tester.pumpWidget(const SizedBox.shrink());
      controller.dispose();
    },
  );
  testWidgets('split view maps editor heading to matching preview block', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(1600, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [mermaidPreviewEnabledProvider.overrideWithValue(false)],
        child: const MarkerApp(),
      ),
    );
    await tester.pumpAndSettle();
    final source =
        '# Start\n\n```text\n${List.generate(90, (i) => 'Code $i').join('\n')}\n```\n\n## Target\n\n${List.generate(80, (i) => 'Paragraph $i: explanatory content for a long document.\n').join('\n')}';
    await tester.enterText(find.byKey(const Key('editor')), source);
    await tester.pumpAndSettle();
    final editor = tester
        .widget<CupertinoTextField>(find.byKey(const Key('editor')))
        .scrollController!;
    final preview = tester.widget<AnchoredMarkdown>(
      find.byKey(const Key('preview')),
    );
    final editable = tester
        .state<EditableTextState>(
          find.descendant(
            of: find.byKey(const Key('editor')),
            matching: find.byType(EditableText),
          ),
        )
        .renderEditable;
    final offset =
        editable
            .getLocalRectForCaret(
              TextPosition(offset: source.indexOf('## Target')),
            )
            .top +
        editor.offset;
    final index = preview.sourceLines.indexOf(
      source.substring(0, source.indexOf('## Target')).split('\n').length - 1,
    );
    expect(index, greaterThanOrEqualTo(0));
    final destination = preview.anchors
        .positions(preview.controller!)[index]
        .offset;
    editor.jumpTo(offset);
    await tester.pumpAndSettle();
    expect(preview.controller!.offset, closeTo(destination, 2));
    await tester.pumpWidget(const SizedBox.shrink());
  });
  test(
    'content-block mapping accounts for large diagram height in both directions',
    () {
      const forward = [
        (source: 0.0, target: 0.0),
        (source: 100.0, target: 100.0),
        (source: 200.0, target: 900.0),
        (source: 500.0, target: 1200.0),
      ];
      expect(interpolateScroll(200, forward), 900);
      expect(interpolateScroll(150, forward), 500);
      final reverse = forward
          .map((p) => (source: p.target, target: p.source))
          .toList();
      expect(interpolateScroll(900, reverse), 200);
      expect(interpolateScroll(500, reverse), 150);
    },
  );
}
