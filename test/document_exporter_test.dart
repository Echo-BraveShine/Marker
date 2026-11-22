import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marker/src/export/document_exporter.dart';

class PendingExporter extends DocumentExporter {
  final completion = Completer<Uint8List>();
  @override
  Future<Uint8List> export({
    required String source,
    required String title,
    String? documentPath,
    required DocumentExportOptions options,
    required bool dark,
  }) => completion.future;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('marker/export');
  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  for (final format in [DocumentExportFormat.pdf, DocumentExportFormat.png]) {
    test(
      '$format sends complete offline HTML and correct geometry to native renderer',
      () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
        String? input;
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (call) async {
              expect(call.method, 'render');
              final args = Map<String, dynamic>.from(call.arguments as Map);
              expect(args['format'], format.name);
              expect(
                args['width'],
                format == DocumentExportFormat.pdf ? 794 : 1600,
              );
              input = args['path'] as String;
              final html = await File(input!).readAsString();
              expect(html, contains('Unsaved content'));
              expect(html, contains('window.markerExport'));
              expect(html, contains('data:font/woff2;base64,'));
              expect(
                html,
                contains(
                  format == DocumentExportFormat.pdf
                      ? 'background:#fff'
                      : 'background:#1c1c1e',
                ),
              );
              return Uint8List.fromList([1, 2, 3]);
            });
        final bytes = await DocumentExporter().export(
          source: '# Unsaved content',
          title: 'Document',
          options: DocumentExportOptions(
            format: format,
            width: 1600,
            followTheme: true,
          ),
          dark: true,
        );
        expect(bytes, [1, 2, 3]);
        expect(await File(input!).parent.exists(), isFalse);
      },
    );
  }

  test(
    'native rendering failure removes temporary HTML and propagates error',
    () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      String? input;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            input = (call.arguments as Map)['path'] as String;
            throw PlatformException(
              code: 'export-failed',
              message: 'Invalid diagram',
            );
          });
      await expectLater(
        DocumentExporter().export(
          source: '# test',
          title: 'Test',
          options: const DocumentExportOptions(),
          dark: false,
        ),
        throwsA(isA<PlatformException>()),
      );
      expect(await File(input!).parent.exists(), isFalse);
    },
  );

  test(
    'controller prevents duplicate exports and publishes rendering failures',
    () async {
      final exporter = PendingExporter();
      final container = ProviderContainer(
        overrides: [documentExporterProvider.overrideWithValue(exporter)],
      );
      addTearDown(container.dispose);
      final controller = container.read(exportControllerProvider.notifier);
      Future<Uint8List> export() => controller.export(
        source: 'test',
        title: 'Test',
        options: const DocumentExportOptions(),
        dark: false,
      );
      final first = export();
      expect(container.read(exportControllerProvider).isLoading, isTrue);
      await expectLater(export(), throwsStateError);
      final failure = expectLater(first, throwsStateError);
      exporter.completion.completeError(StateError('render failed'));
      await failure;
      expect(container.read(exportControllerProvider).hasError, isTrue);
    },
  );
}
