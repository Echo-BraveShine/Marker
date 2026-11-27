import '../l10n/message_catalog.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as p;

class ExportDestinationException implements Exception {
  const ExportDestinationException(String zh, String en)
    : _zh = zh,
      _en = en,
      _message = null,
      _arguments = const {};
  const ExportDestinationException.localized(
    this._message, [
    this._arguments = const {},
  ]) : _zh = null,
       _en = null;
  final String? _zh, _en;
  final AppMessage? _message;
  final Map<String, Object?> _arguments;
  String get zh =>
      _message == null ? _zh! : localizedMessage('zh', _message, _arguments);
  String get en =>
      _message == null ? _en! : localizedMessage('en', _message, _arguments);
  String localize(String languageCode) => _message == null
      ? (normalizeLanguageTag(languageCode).startsWith('zh') ? _zh! : _en!)
      : localizedMessage(languageCode, _message, _arguments);
  @override
  String toString() => '$zh ($en)';
}

/// Validates the chosen output and replaces it only after writing is complete.
class ExportDestinationWriter {
  String resolvePath(
    String selectedPath, {
    required String extension,
    String? sourcePath,
  }) {
    final ext = extension.toLowerCase();
    if (!const ['pdf', 'png', 'html'].contains(ext)) {
      throw const ExportDestinationException.localized(
        AppMessage.unsupportedExportFormat,
      );
    }
    if (selectedPath.trim().isEmpty) {
      throw const ExportDestinationException.localized(
        AppMessage.pleaseSelectAnExportPath,
      );
    }
    final selected = p.normalize(p.absolute(selectedPath));
    if (Directory(selected).existsSync()) {
      throw const ExportDestinationException.localized(
        AppMessage.pleaseSelectAFileInsteadOfADirectory,
      );
    }
    if (const [
      '.md',
      '.markdown',
    ].contains(p.extension(selected).toLowerCase())) {
      throw const ExportDestinationException.localized(
        AppMessage.markdownFilesCannotBeUsedAsExportDestination,
      );
    }
    final target = p.setExtension(selected, '.$ext');
    if (sourcePath != null &&
        (_sameFile(selected, sourcePath) || _sameFile(target, sourcePath))) {
      throw const ExportDestinationException.localized(
        AppMessage.exportPathCannotBeTheSameAsSourceFile,
      );
    }
    if (Directory(target).existsSync()) {
      throw const ExportDestinationException.localized(
        AppMessage.theDestinationIsADirectoryChooseAnotherFilename,
      );
    }
    // A changed extension must not overwrite a file the chooser did not confirm.
    if (File(target).existsSync() && !_sameFile(selected, target)) {
      throw ExportDestinationException.localized(
        AppMessage.theOutputAlreadyExistsSelectValueDirectlyInTheSaveDialog,
        {"p0": target},
      );
    }
    return target;
  }

  Future<String> write(
    Uint8List bytes, {
    required String selectedPath,
    required String extension,
    String? sourcePath,
  }) async {
    if (bytes.isEmpty) {
      throw const ExportDestinationException.localized(
        AppMessage.exportDataCannotBeEmpty,
      );
    }
    final target = resolvePath(
      selectedPath,
      extension: extension,
      sourcePath: sourcePath,
    );
    // Same directory means the rename stays on one filesystem, even on mounts.
    final temporary = await Directory(
      p.dirname(target),
    ).createTemp('.marker-export-');
    try {
      final staging = await File(
        p.join(temporary.path, 'output'),
      ).writeAsBytes(bytes, flush: true);
      resolvePath(selectedPath, extension: extension, sourcePath: sourcePath);
      await staging.rename(target);
      return target;
    } finally {
      // Only this invocation owns this unique directory; cleanup cannot hide an
      // original read/write error or turn a successful export into a failure.
      try {
        await temporary.delete(recursive: true);
      } on FileSystemException {
        // Antivirus can temporarily retain handles on Windows.
      }
    }
  }

  bool _sameFile(String first, String second) {
    String normalize(String value) {
      final absolute = p.normalize(p.absolute(value));
      return Platform.isWindows ? absolute.toLowerCase() : absolute;
    }

    if (normalize(first) == normalize(second)) return true;
    try {
      if (FileSystemEntity.identicalSync(first, second)) return true;
      return normalize(File(first).resolveSymbolicLinksSync()) ==
          normalize(File(second).resolveSymbolicLinksSync());
    } on FileSystemException {
      return false;
    }
  }
}
