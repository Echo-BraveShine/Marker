import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Writes are serialized so an older edit cannot overwrite a newer snapshot.
class DraftStore {
  Future<void> _pending = Future.value();
  Future<Map<String, dynamic>?> read() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('documentDraft');
    if (raw == null) return null;
    final data = jsonDecode(raw) as Map<String, dynamic>;
    if (data['text'] is! String || data['saved'] is! String) return null;
    return data;
  }

  Future<void> write(String text, String saved, String? path) {
    final root = Platform.isIOS || Platform.isAndroid
        ? getApplicationDocumentsDirectory().then<String?>((d) => d.path)
        : Future<String?>.value(null);
    return _pending = _pending.catchError((Object _) {}).then((_) async {
      final directory = await root;
      final data = <String, String?>{
        'text': text,
        'saved': saved,
        'path': path,
      };
      if (directory != null) data['mobileDocumentsRoot'] = directory;
      final snapshot = jsonEncode(data);
      final prefs = await SharedPreferences.getInstance();
      if (!await prefs.setString('documentDraft', snapshot)) {
        throw StateError('Unable to store draft');
      }
    });
  }
}
