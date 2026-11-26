import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Installed by the executable; embedded previews can omit filesystem access.
final sampleDocumentStoreProvider = Provider<SampleDocumentStore?>(
  (ref) => null,
);

class SampleDocumentStore {
  SampleDocumentStore({Future<Directory> Function()? directory})
    : _directory = directory ?? getApplicationDocumentsDirectory;
  final Future<Directory> Function() _directory;
  static const initializedKey = 'sampleDocumentInitializedV1';

  Future<String?> initialize(String content) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(initializedKey) == true) return null;
    return open(content);
  }

  /// Explicit reopening recreates a missing example, never overwrites edits.
  Future<String> open(String content) async {
    final root = await _directory();
    final file = File(p.join(root.path, 'Marker Examples', 'Welcome.md'));
    await file.parent.create(recursive: true);
    if (!await file.exists()) {
      await file.writeAsString(content, flush: true);
    }
    final prefs = await SharedPreferences.getInstance();
    if (!await prefs.setBool(initializedKey, true)) {
      throw StateError('Could not persist example initialization');
    }
    return file.path;
  }
}
