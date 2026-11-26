import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../resources/resource_references.dart';
import '../resources/resource_service.dart';

final mobileDocumentsRootProvider = Provider<Future<String?>>(
  (ref) async => Platform.isIOS || Platform.isAndroid
      ? (await getApplicationDocumentsDirectory()).path
      : null,
);

class MobilePathRestore {
  MobilePathRestore(this.currentRoot, this.previousRoot);
  final String? currentRoot, previousRoot;
  String? oldRoot(String? path) {
    if (currentRoot == null || path == null) return null;
    if (previousRoot != null && p.isWithin(previousRoot!, path)) {
      return previousRoot;
    }
    final match = RegExp(
      r'^(.*/Containers/Data/Application/[^/]+/Documents)/',
    ).firstMatch(path);
    return match?.group(1);
  }

  String? restore(String? path, {String? relative}) {
    if (currentRoot == null) return path;
    if (relative != null && !p.isAbsolute(relative)) {
      final target = p.normalize(p.join(currentRoot!, relative));
      if (p.isWithin(currentRoot!, target)) return target;
    }
    final root = oldRoot(path);
    return root == null
        ? path
        : p.join(currentRoot!, p.relative(path!, from: root));
  }

  Future<String> images(
    String text,
    String? oldDocument,
    String? newDocument,
  ) async {
    final root = oldRoot(oldDocument) ?? previousRoot;
    if (root == null || currentRoot == null) return text;
    if (!text.contains('file:') && !text.contains(root)) return text;
    final refs = await parseResourceReferencesAsync(text);
    final replacements = <String, String>{};
    for (final image in refs.images) {
      try {
        final uri = resolveResourceUri(image.source, oldDocument);
        if (uri.scheme != 'file') continue;
        final original = File.fromUri(uri).path;
        if (p.isWithin(root, original) &&
            (Uri.tryParse(image.source)?.hasScheme == true ||
                p.isAbsolute(image.source))) {
          final path = p.join(currentRoot!, p.relative(original, from: root));
          replacements[image.source] = newDocument == null
              ? File(path).uri.toString()
              : resourceReference(path, newDocument);
        }
      } catch (_) {
        /* Preserve unsupported references. */
      }
    }
    return refs.rewrite(text, replacements);
  }
}
