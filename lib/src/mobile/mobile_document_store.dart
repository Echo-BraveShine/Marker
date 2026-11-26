import 'dart:io';
import 'package:archive/archive.dart';
import 'package:file_selector/file_selector.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Editable documents live outside picker caches, in the app's Files directory.
class MobileDocumentStore {
  MobileDocumentStore({Future<Directory> Function()? directory})
    : _directory = directory ?? getApplicationDocumentsDirectory;
  final Future<Directory> Function() _directory;

  static String filename(String input) {
    final name = input.trim();
    if (name.isEmpty ||
        name == '.' ||
        name == '..' ||
        RegExp(r'[\\/:\x00-\x1f]').hasMatch(name)) {
      throw const FormatException('Invalid document name');
    }
    return p.extension(name).isEmpty ? '$name.md' : name;
  }

  Future<String> newDocumentPath() async {
    for (var i = 1; i < 10000; i++) {
      final path = await savePath(i == 1 ? 'Untitled.md' : 'Untitled $i.md');
      if (!await File(path).exists()) return path;
    }
    throw const FileSystemException('No available document name');
  }

  Future<String> savePath(String name) async {
    final safe = filename(name);
    final directory = await _directory();
    await directory.create(recursive: true);
    return p.join(directory.path, safe);
  }

  Future<String> importDocument(XFile source) async {
    final root = await _directory();
    await root.create(recursive: true);
    final directory = await root.createTemp('import-');
    if (p.extension(source.name).toLowerCase() == '.zip') {
      try {
        return await _importArchive(source, directory);
      } catch (_) {
        await directory.delete(recursive: true);
        rethrow;
      }
    }
    final target = File(p.join(directory.path, filename(source.name)));
    try {
      final sink = target.openWrite();
      try {
        await sink.addStream(source.openRead());
      } finally {
        await sink.close();
      }
      return target.path;
    } catch (_) {
      await directory.delete(recursive: true);
      rethrow;
    }
  }

  Future<String> _importArchive(XFile source, Directory directory) async {
    if (await source.length() > 64 * 1024 * 1024) {
      throw const FormatException('ZIP exceeds 64 MB / 压缩包不能超过 64 MB');
    }
    final archive = ZipDecoder().decodeBytes(await source.readAsBytes());
    if (archive.length > 1000) {
      throw const FormatException('Too many files / 文件过多');
    }
    var total = 0;
    final documents = <String>[];
    final names = <String>{};
    for (final entry in archive) {
      final normalized = p.posix.normalize(entry.name);
      if (entry.isSymbolicLink ||
          normalized == '..' ||
          normalized.startsWith('../') ||
          p.posix.isAbsolute(normalized) ||
          entry.name.contains('\\') ||
          RegExp(r'^[a-zA-Z]:').hasMatch(entry.name)) {
        throw const FormatException('Unsafe ZIP path / 压缩包路径无效');
      }
      if (!entry.isFile) continue;
      total += entry.size;
      if (entry.size > 50 * 1024 * 1024 ||
          total > 200 * 1024 * 1024 ||
          !names.add(normalized.toLowerCase())) {
        throw const FormatException(
          'ZIP too large or duplicate paths / 压缩包过大或路径重复',
        );
      }
      final target = File(
        p.joinAll([directory.path, ...p.posix.split(normalized)]),
      );
      if (!p.isWithin(directory.path, target.path)) {
        throw const FormatException('Invalid path');
      }
      await target.parent.create(recursive: true);
      final bytes = entry.content;
      if (bytes.length != entry.size) {
        throw const FormatException('Invalid ZIP size');
      }
      await target.writeAsBytes(bytes, flush: true);
      if ([
        '.md',
        '.markdown',
      ].contains(p.extension(target.path).toLowerCase())) {
        documents.add(target.path);
      }
    }
    if (documents.length != 1) {
      throw const FormatException(
        'ZIP must contain one Markdown document / 压缩包需包含一份 Markdown 文档',
      );
    }
    return documents.single;
  }
}
