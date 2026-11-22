import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marker/main.dart';
import 'package:marker/src/export/document_exporter.dart';
import 'package:marker/src/providers/editor_provider.dart';
import 'package:marker/src/widgets/markdown_extensions.dart';
import 'package:marker/src/widgets/marker_dialog.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'support/file_cleanup.dart';

class RecordingExporter extends DocumentExporter {
  String? source;
  DocumentExportOptions? options;
  Object? failure;
  @override
  Future<Uint8List> export({
    required String source,
    required String title,
    String? documentPath,
    required DocumentExportOptions options,
    required bool dark,
  }) async {
    this.source = source;
    this.options = options;
    if (failure != null) throw failure!;
    return Uint8List.fromList(utf8.encode('exported snapshot'));
  }
}

void main() {
  const picker = MethodChannel('plugins.flutter.io/file_selector');
  late RecordingExporter exporter;
  late Directory folder;
  String? destination;

  Future<void> settleIO(WidgetTester tester) async {
    for (var i = 0; i < 30; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 10)),
      );
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  Future<void> launch(WidgetTester tester) async {
    exporter = RecordingExporter();
    folder = (await tester.runAsync(
      () => Directory.systemTemp.createTemp('marker-export-ui-'),
    ))!;
    destination = null;
    SharedPreferences.setMockInitialValues({
      'documentDraft': jsonEncode({
        'text': '# Unsaved snapshot',
        'saved': '',
        'path': null,
      }),
    });
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      picker,
      (call) async => call.method == 'getSavePath' ? destination : null,
    );
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        picker,
        null,
      );
      await tester.binding.setSurfaceSize(null);
      await tester.runAsync(
        () => withWindowsFileLockRetry(() => folder.delete(recursive: true)),
      );
    });
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          documentExporterProvider.overrideWithValue(exporter),
          mermaidPreviewEnabledProvider.overrideWithValue(false),
        ],
        child: const MarkerApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> open(WidgetTester tester) async {
    await tester.tap(find.byIcon(CupertinoIcons.square_arrow_up));
    await tester.pumpAndSettle();
    expect(find.text('导出文档'), findsOneWidget);
  }

  testWidgets(
    'options and native save cancellation leave the document unchanged',
    (tester) async {
      await launch(tester);
      await open(tester);
      await tester.tap(find.text('PNG'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('dialog-close')));
      await tester.pumpAndSettle();
      await open(tester);
      expect(find.textContaining('A4 自动分页'), findsOneWidget);
      await tester.tap(find.text('导出'));
      await settleIO(tester);
      expect(exporter.source, isNull);
      expect(
        tester
            .widget<CupertinoTextField>(find.byKey(const Key('editor')))
            .controller!
            .text,
        '# Unsaved snapshot',
      );
      final container = ProviderScope.containerOf(
        tester.element(find.byType(MarkerHome)),
      );
      expect(container.read(editorProvider).busy, isFalse);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('export uses the snapshot captured before the options dialog', (
    tester,
  ) async {
    await launch(tester);
    destination = p.join(folder.path, '中文 导出.png');
    await open(tester);
    tester
            .widget<CupertinoTextField>(find.byKey(const Key('editor')))
            .controller!
            .text =
        '# Edited behind dialog';
    await tester.tap(find.text('PNG'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('1600'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('导出'));
    await settleIO(tester);
    expect(exporter.source, '# Unsaved snapshot');
    expect(exporter.options!.format, DocumentExportFormat.png);
    expect(exporter.options!.width, 1600);
    expect(
      await tester.runAsync(() => File(destination!).readAsString()),
      'exported snapshot',
    );
    expect(find.byType(MarkerDialog), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'renderer failure keeps the old destination and uses shared error panel',
    (tester) async {
      await launch(tester);
      destination = p.join(folder.path, 'existing.pdf');
      await tester.runAsync(
        () => File(destination!).writeAsString('original output'),
      );
      exporter.failure = PlatformException(
        code: 'export-failed',
        message: 'Invalid Mermaid',
      );
      await open(tester);
      await tester.tap(find.text('导出'));
      await settleIO(tester);
      expect(find.text('无法导出文档'), findsOneWidget);
      expect(find.byType(MarkerDialog), findsOneWidget);
      expect(find.textContaining('Invalid Mermaid'), findsOneWidget);
      expect(
        await tester.runAsync(() => File(destination!).readAsString()),
        'original output',
      );
      await tester.tap(find.byKey(const Key('dialog-close')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Markdown save target is rejected before rendering', (
    tester,
  ) async {
    await launch(tester);
    destination = p.join(folder.path, 'source.MD');
    await tester.runAsync(
      () => File(destination!).writeAsString('source content'),
    );
    await open(tester);
    await tester.tap(find.text('导出'));
    await settleIO(tester);
    expect(exporter.source, isNull);
    expect(find.text('无法导出文档'), findsOneWidget);
    expect(
      await tester.runAsync(() => File(destination!).readAsString()),
      'source content',
    );
    await tester.tap(find.byKey(const Key('dialog-close')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
