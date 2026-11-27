import '../l10n/message_catalog.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/offline_html_renderer.dart';
import 'document_html.dart';
import 'export_destination.dart';

part 'document_exporter.freezed.dart';

enum DocumentExportFormat { pdf, png, html }

@freezed
abstract class DocumentExportOptions with _$DocumentExportOptions {
  const factory DocumentExportOptions({
    @Default(DocumentExportFormat.pdf) DocumentExportFormat format,
    @Default(false) bool followTheme,
    @Default(false) bool splitPng,
    @Default(1280) int width,
  }) = _DocumentExportOptions;
}

/// SharedPreferences restores this preference after a full application restart.
final exportAppearanceProvider =
    NotifierProvider<ExportAppearanceNotifier, bool>(
      ExportAppearanceNotifier.new,
    );

class ExportAppearanceNotifier extends Notifier<bool> {
  int _revision = 0;
  late Future<void> ready;
  Future<void> _writes = Future<void>.value();

  @override
  bool build() {
    final revision = ++_revision;
    ready = Future<void>.microtask(() async {
      final prefs = await SharedPreferences.getInstance();
      if (ref.mounted && revision == _revision) {
        state = prefs.getBool('exportFollowTheme') ?? false;
      }
    });
    return false;
  }

  Future<void> setFollowTheme(bool value) {
    // Even an explicit false before initialization must override a stored true.
    _revision++;
    state = value;
    final write = _writes.catchError((Object _) {}).then((_) async {
      final prefs = await SharedPreferences.getInstance();
      if (!await prefs.setBool('exportFollowTheme', value)) {
        throw StateError('Could not save export appearance');
      }
    });
    _writes = write;
    return write;
  }

  Future<void> get saved => _writes;
}

final documentExportOptionsProvider =
    NotifierProvider.autoDispose<
      ExportOptionsController,
      DocumentExportOptions
    >(ExportOptionsController.new);

class ExportOptionsController extends Notifier<DocumentExportOptions> {
  @override
  DocumentExportOptions build() {
    final appearance = ref.read(exportAppearanceProvider);
    // Listening updates only the persisted field, preserving format and width.
    ref.listen(exportAppearanceProvider, (_, followTheme) {
      state = state.copyWith(followTheme: followTheme);
    });
    return DocumentExportOptions(followTheme: appearance);
  }

  Future<void> update(
    DocumentExportOptions Function(DocumentExportOptions) change,
  ) async {
    final previous = state;
    state = change(state);
    if (previous.followTheme != state.followTheme) {
      await ref
          .read(exportAppearanceProvider.notifier)
          .setFollowTheme(state.followTheme);
    }
  }
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
      if (ref.mounted) state = const AsyncData(null);
      return bytes;
    } catch (error, stack) {
      if (ref.mounted) state = AsyncError(error, stack);
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
    if (options.width < 240 || options.width > 2048) {
      throw ArgumentError('PNG width must be between 240 and 2048 pixels');
    }
    final html = await ExportHtmlBuilder().build(
      source: source,
      title: title,
      documentPath: documentPath,
      freezeAnimations: options.format != DocumentExportFormat.html,
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
        splitPng:
            options.format == DocumentExportFormat.png && options.splitPng,
      );
    } finally {
      await temporary.delete(recursive: true);
    }
  }
}

/// Actionable messages use the same shared panel as other app errors.
String exportFailureMessage(
  Object error, {
  bool chinese = false,
  String? languageTag,
}) {
  final language = languageTag ?? (chinese ? 'zh-Hans' : 'en');
  if (error is LocalizedMessageError) {
    return error.localize(language);
  }
  if (error is ExportDestinationException) {
    return error.localize(language);
  }
  if (error is TimeoutException) {
    return messageForLanguage(
      language,
      AppMessage.exportTimedOutTryReducingTheNumberOfImagesOrDiagrams,
    );
  }
  if (error is FileSystemException) {
    return messageForLanguage(chinese, AppMessage.exportFileAccessFailed, {
      "p0": error.path ?? '',
    });
  }
  if (error is HttpException || error is SocketException) {
    return messageForLanguage(chinese, AppMessage.exportNetworkImageFailed);
  }
  final detail = error is PlatformException
      ? error.message ?? error.code
      : error.toString();
  return messageForLanguage(chinese, AppMessage.exportIncomplete, {
    "p0": detail,
  });
}
