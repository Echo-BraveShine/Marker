import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marker/main.dart';
import 'package:marker/src/export/document_exporter.dart';
import 'package:marker/src/widgets/markdown_extensions.dart';
import 'package:marker/src/widgets/mobile_html_renderer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Exporter extends DocumentExporter {
  DocumentExportOptions? options;
  @override
  Future<Uint8List> export({
    required String source,
    required String title,
    String? documentPath,
    required DocumentExportOptions options,
    required bool dark,
  }) async {
    this.options = options;
    return Uint8List.fromList([1, 2, 3]);
  }
}

class _Saver extends FilePickerPlatform {
  String? name, mime;
  Uint8List? data;
  @override
  Future<Uri?> saveFile({
    required String fileName,
    required Uint8List bytes,
    required String mimeType,
    String? dialogTitle,
    String? initialDirectory,
    Function(FilePickerStatus)? onFileSaving,
    WindowsOptions windowsOptions = const WindowsOptions(),
    LinuxOptions linuxOptions = const LinuxOptions(),
    WebOptions webOptions = const WebOptions(),
  }) async {
    name = fileName;
    mime = mimeType;
    data = bytes;
    return Uri.parse('content://documents/export');
  }
}

void main() {
  test(
    'long PNG tiling covers every row and oversized output can use split mode',
    () {
      final bands = mobileImageBands(960, 6412);
      expect(bands.first.top, 0);
      expect(bands.last.top + bands.last.height, 6412);
      expect(bands.fold<int>(0, (sum, b) => sum + b.height), 6412);
      for (var i = 1; i < bands.length; i++) {
        expect(bands[i].top, bands[i - 1].top + bands[i - 1].height);
      }
      expect(() => mobileImageBands(2048, 20000), throwsStateError);
      expect(
        mobileImageBands(2048, 20000, split: true).last.top +
            mobileImageBands(2048, 20000, split: true).last.height,
        20000,
      );
    },
  );
  for (final format in DocumentExportFormat.values) {
    testWidgets(
      'mobile ${format.name} export uses system save panel and shared options',
      (tester) async {
        final previous = FilePickerPlatform.instance;
        final saver = _Saver();
        FilePickerPlatform.instance = saver;
        mobileWindow = true;
        addTearDown(() {
          mobileWindow = false;
          FilePickerPlatform.instance = previous;
        });
        SharedPreferences.setMockInitialValues({});
        await tester.binding.setSurfaceSize(const Size(844, 390));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final exporter = _Exporter();
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
        await tester.tap(find.byIcon(CupertinoIcons.square_arrow_up));
        await tester.pumpAndSettle();
        await tester.tap(find.text(format.name.toUpperCase()));
        await tester.pumpAndSettle();
        if (format == DocumentExportFormat.png) {
          await tester.tap(find.byType(CupertinoSwitch).last);
          await tester.pumpAndSettle();
        }
        await tester.tap(find.text('导出'));
        await tester.pumpAndSettle();
        expect(exporter.options!.format, format);
        expect(saver.data, [1, 2, 3]);
        expect(
          saver.name,
          endsWith(
            format == DocumentExportFormat.png
                ? '-images.zip'
                : '.${format.name}',
          ),
        );
        expect(
          saver.mime,
          format == DocumentExportFormat.png
              ? 'application/zip'
              : format == DocumentExportFormat.pdf
              ? 'application/pdf'
              : 'text/html',
        );
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }
}
