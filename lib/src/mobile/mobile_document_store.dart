import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:archive/archive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_selector/file_selector.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

final mobileDocumentStoreProvider = Provider((ref) => MobileDocumentStore());

/// Editable documents live outside picker caches, in the app's Files directory.
class MobileDocumentStore {
  MobileDocumentStore({Future<Directory> Function()? directory})
    : _directory = directory ?? getApplicationDocumentsDirectory;
  final Future<Directory> Function() _directory;
  static const maxInputBytes = 64 * 1024 * 1024;
  static const maxMarkdownBytes = 16 * 1024 * 1024;

  /// Content-identical external opens select their existing copy, including edits.
  /// Store relative paths so iOS sandbox UUID changes do not invalidate the index.
  Future<({String path, bool reused})> openImportedDocument(
    XFile source, {
    String? ownedRelativePath,
  }) async {
    final name = p.posix.basename(source.name.replaceAll('\\', '/'));
    await _validateInput(source, name);
    final root = await _directory();
    if (p.extension(name).toLowerCase() != '.zip') {
      final owned = ownedRelativePath == null
          ? p.normalize(source.path)
          : p.normalize(p.join(root.path, ownedRelativePath));
      if (p.isWithin(root.path, owned) &&
          !p.isWithin(p.join(root.path, 'Inbox'), owned)) {
        if (await File(owned).exists()) return (path: owned, reused: true);
        if (ownedRelativePath != null) {
          throw FileSystemException(
            '文件已删除，未恢复缓存副本 / File was deleted; cached copy was not restored',
            owned,
          );
        }
      }
    }
    final digest = await sha256.bind(source.openRead()).first;
    final key = sha256.convert(utf8.encode('$name:$digest')).toString();
    final prefs = await SharedPreferences.getInstance();
    var index = <String, dynamic>{};
    try {
      index = Map<String, dynamic>.from(
        jsonDecode(prefs.getString('mobileImportsV1') ?? '{}') as Map,
      );
    } on FormatException {
      /* A damaged index must not prevent importing. */
    } on TypeError {
      /* Ignore obsolete index formats. */
    }
    final relative = index[key];
    if (relative is String && !p.isAbsolute(relative)) {
      final existing = p.normalize(p.join(root.path, relative));
      if (p.isWithin(root.path, existing) && await File(existing).exists()) {
        return (path: existing, reused: true);
      }
    }
    final path = await importDocument(source);
    index.remove(key);
    index[key] = p.relative(path, from: root.path);
    while (index.length > 256) {
      index.remove(index.keys.first);
    }
    if (!await prefs.setString('mobileImportsV1', jsonEncode(index))) {
      // The imported document is still valid even when deduplication cannot persist.
      return (path: path, reused: false);
    }
    return (path: path, reused: false);
  }

  Future<void> _validateInput(XFile source, String name) async {
    final extension = p.extension(name).toLowerCase();
    if (!['.md', '.markdown', '.txt', '.zip'].contains(extension)) {
      throw const FormatException(
        'Select Markdown, TXT or ZIP / 请选择 Markdown、TXT 或 ZIP 文件',
      );
    }
    final limit = extension == '.zip' ? maxInputBytes : maxMarkdownBytes;
    if (await source.length() > limit) {
      throw FormatException(
        extension == '.zip'
            ? 'ZIP exceeds 64 MB / 压缩包不能超过 64 MB'
            : 'Markdown exceeds 16 MB / 文档不能超过 16 MB',
      );
    }
  }

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
    final sourceName = p.posix.basename(source.name.replaceAll('\\', '/'));
    try {
      await _validateInput(source, sourceName);
    } catch (_) {
      await directory.delete(recursive: true);
      rethrow;
    }
    if (p.extension(sourceName).toLowerCase() == '.zip') {
      try {
        return await _importArchive(source, directory);
      } catch (_) {
        await directory.delete(recursive: true);
        rethrow;
      }
    }
    try {
      final target = File(p.join(directory.path, filename(sourceName)));
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
        if (entry.size > maxMarkdownBytes) {
          throw const FormatException('Markdown exceeds 16 MB / 文档不能超过 16 MB');
        }
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
