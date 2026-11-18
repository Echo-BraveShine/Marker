import 'package:flutter_riverpod/flutter_riverpod.dart';

final initialFilesProvider = Provider<List<String>>((ref) => const []);

List<String> markdownOpenPaths(Iterable<String> arguments) {
  final result = <String>[];
  for (final argument in arguments) {
    if (argument.startsWith('-')) continue;
    var path = argument;
    if (argument.startsWith('file:')) {
      try {
        path = Uri.parse(argument).toFilePath();
      } catch (_) {
        continue;
      }
    }
    if (RegExp(r'\.(md|markdown|txt)$', caseSensitive: false).hasMatch(path) &&
        !result.contains(path)) {
      result.add(path);
    }
  }
  return result;
}
