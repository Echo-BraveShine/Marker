import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as p;

class ExportDestinationException implements Exception {
  const ExportDestinationException(this.zh, this.en);
  final String zh, en;
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
      throw const ExportDestinationException(
        '不支持的导出格式',
        'Unsupported export format',
      );
    }
    if (selectedPath.trim().isEmpty) {
      throw const ExportDestinationException(
        '请选择导出路径',
        'Please select an export path',
      );
    }
    final selected = p.normalize(p.absolute(selectedPath));
    if (Directory(selected).existsSync()) {
      throw const ExportDestinationException(
        '请选择文件而不是目录',
        'Please select a file instead of a directory',
      );
    }
    if (const [
      '.md',
      '.markdown',
    ].contains(p.extension(selected).toLowerCase())) {
      throw const ExportDestinationException(
        'Markdown 文件不能作为导出目标',
        'Markdown files cannot be used as export destination',
      );
    }
    final target = p.setExtension(selected, '.$ext');
    if (sourcePath != null &&
        (_sameFile(selected, sourcePath) || _sameFile(target, sourcePath))) {
      throw const ExportDestinationException(
        '导出路径不能与源文件相同',
        'Export path cannot be the same as source file',
      );
    }
    if (Directory(target).existsSync()) {
      throw const ExportDestinationException(
        '导出位置是目录，请选择其他文件名',
        'The destination is a directory. Choose another filename.',
      );
    }
    // A changed extension must not overwrite a file the chooser did not confirm.
    if (File(target).existsSync() && !_sameFile(selected, target)) {
      throw ExportDestinationException(
        '目标文件已存在，请在保存窗口直接选择 $target。',
        'The output already exists. Select $target directly in the save dialog.',
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
      throw const ExportDestinationException(
        '导出数据不能为空',
        'Export data cannot be empty',
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
