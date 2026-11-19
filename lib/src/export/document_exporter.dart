import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/offline_html_renderer.dart';
import 'document_html.dart';

enum DocumentExportFormat { pdf, png, html }

class DocumentExportOptions {
  const DocumentExportOptions({
    this.format = DocumentExportFormat.pdf,
    this.followTheme = false,
    this.width = 1280,
  });
  final DocumentExportFormat format;
  final bool followTheme;
  final int width;
}

final documentExporterProvider = Provider((ref) => DocumentExporter());
final exportControllerProvider =
    NotifierProvider<ExportController, AsyncValue<void>>(ExportController.new);

class ExportController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);
  Future<Uint8List> export({
    required String source,
    required String title,
    String? documentPath,
    required DocumentExportOptions options,
    required bool dark,
  }) async {
    if (state.isLoading) throw StateError('An export is already running');
    state = const AsyncLoading();
    try {
      final bytes = await ref
          .read(documentExporterProvider)
          .export(
            source: source,
            title: title,
            documentPath: documentPath,
            options: options,
            dark: dark,
          );
      state = const AsyncData(null);
      return bytes;
    } catch (error, stack) {
      state = AsyncError(error, stack);
      rethrow;
    }
  }
}

class DocumentExporter {
  static const channel = MethodChannel('marker/export');
  Future<Uint8List> export({
    required String source,
    required String title,
    String? documentPath,
    required DocumentExportOptions options,
    required bool dark,
  }) async {
    final html = await ExportHtmlBuilder().build(
      source: source,
      title: title,
      documentPath: documentPath,
      dark:
          options.format != DocumentExportFormat.pdf &&
          options.followTheme &&
          dark,
    );
    if (options.format == DocumentExportFormat.html) return utf8.encode(html);
    final temporary = await Directory.systemTemp.createTemp('marker-export-');
    try {
      final file = await File(
        '${temporary.path}${Platform.pathSeparator}document.html',
      ).writeAsString(html);
      final width = options.format == DocumentExportFormat.pdf
          ? 794
          : options.width;
      return await OfflineHtmlRenderer().render(
        file,
        width: width,
        pdf: options.format == DocumentExportFormat.pdf,
      );
    } finally {
      await temporary.delete(recursive: true);
    }
  }
}
