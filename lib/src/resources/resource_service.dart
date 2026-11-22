import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';
import 'package:archive/archive_io.dart';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'resource_references.dart';

part 'resource_image_operations.dart';
part 'resource_document_operations.dart';
part 'resource_inventory_operations.dart';

const resourceImageExtensions = ['png', 'jpg', 'jpeg', 'gif', 'webp', 'bmp'];
const _manifestName = '.marker-resources.json';

class ResourceCancelled implements Exception {}

class ResourceFailure implements Exception {
  const ResourceFailure(this.zh, this.en);
  final String zh, en;
  @override
  String toString() => en;
}

class ResourceCancellation {
  bool _cancelled = false;
  final _listeners = <void Function()>[];
  bool get cancelled => _cancelled;
  set cancelled(bool value) {
    if (_cancelled || !value) return;
    _cancelled = true;
    for (final listener in _listeners.toList()) {
      listener();
    }
  }

  void listen(void Function() listener) {
    _listeners.add(listener);
    if (_cancelled) listener();
  }

  void unlisten(void Function() listener) => _listeners.remove(listener);
  void check() {
    if (_cancelled) throw ResourceCancelled();
  }
}

class ResourceProgress {
  const ResourceProgress(this.done, this.total, this.name);
  final int done, total;
  final String name;
}

class ResourceInput {
  const ResourceInput({required this.name, this.path, this.bytes});
  final String name;
  final String? path;
  final Uint8List? bytes;
}

class ManagedImage {
  const ManagedImage(this.path, this.reference, this.name, this.created);
  final String path, reference, name;
  final bool created;
}

enum ResourceAvailability { local, remote, missing, denied, unsupported }

class ResourceItem {
  const ResourceItem(
    this.source,
    this.alt,
    this.availability, {
    this.path,
    this.size = 0,
    this.managed = false,
  });
  final String source, alt;
  final ResourceAvailability availability;
  final String? path;
  final int size;
  final bool managed;
}

class ResourceInventory {
  const ResourceInventory(this.items, this.unsupported);
  final List<ResourceItem> items;
  final List<String> unsupported;
  int get totalBytes => items.fold(0, (sum, item) => sum + item.size);
  List<ResourceItem> get unresolved => items
      .where(
        (i) => ![
          ResourceAvailability.local,
          ResourceAvailability.remote,
        ].contains(i.availability),
      )
      .toList();
}

class ResourceIssue {
  const ResourceIssue(this.source, this.reason, {this.chinese});
  final String source, reason;
  final String? chinese;
}

class ResourceIncomplete extends ResourceFailure {
  ResourceIncomplete(this.issues)
    : super(
        '部分图片无法复制，原文件保持不变。',
        'Some images could not be copied. Original files were kept.',
      );
  final List<ResourceIssue> issues;
}

class ResourceResult {
  const ResourceResult(this.text, this.images, this.issues);
  final String text;
  final List<ManagedImage> images;
  final List<ResourceIssue> issues;
}

class ResourceDraft {
  const ResourceDraft(this.path, this.text);
  final String? path;
  final String text;
}

class UnusedResource {
  const UnusedResource(this.path, this.name, this.size, this.digest);
  final String path, name, digest;
  final int size;
}

Uri resolveResourceUri(
  String source,
  String? documentPath, {
  bool preserveDecorations = false,
}) {
  var decoded = source;
  try {
    decoded = Uri.decodeFull(source);
  } catch (_) {}
  if (RegExp(r'^[a-zA-Z]:[\\/]').hasMatch(decoded) ||
      decoded.startsWith(r'\\')) {
    return Uri.file(decoded, windows: true);
  }
  var uri = Uri.parse(source);
  if (!uri.hasScheme && documentPath != null) {
    uri = File(documentPath).absolute.uri.resolveUri(uri);
  }
  if (uri.scheme == 'file' && !preserveDecorations) {
    uri = Uri(scheme: 'file', host: uri.host, path: uri.path);
  }
  return uri;
}

String resourceReference(String filePath, String documentPath) {
  final relative = p.relative(filePath, from: p.dirname(documentPath));
  if (p.isAbsolute(relative)) return File(filePath).uri.toString();
  return Uri(pathSegments: p.split(relative)).toString();
}

String imageMarkdown(String alt, String source) =>
    '![${alt.replaceAll(r'\', r'\\').replaceAll('[', r'\[').replaceAll(']', r'\]')}](<$source>)';

/// Public entry points stay on the class so subclass overrides keep working.
/// Implementation details are grouped in the operation parts above.
class DocumentResourceService {
  DocumentResourceService({this.validateImage});

  final Future<void> Function(Uint8List)? validateImage;

  final _directoryCache =
      <String, ({int modified, int size, Directory directory})>{};

  static const maxImageBytes = 50 * 1024 * 1024;

  Future<Directory> resourceDirectory(String documentPath) =>
      _serviceResourceDirectory(documentPath);

  Future<Uint8List> readImage(ResourceInput input) => _serviceReadImage(input);

  Future<ManagedImage> importImage(String documentPath, ResourceInput input) =>
      _serviceImportImage(documentPath, input);

  Future<void> atomicWrite(File target, String text) =>
      _serviceAtomicWrite(target, text);

  Future<ResourceInventory> scan(String text, String? documentPath) =>
      _serviceScan(text, documentPath);

  Future<ResourceInput> download(
    String source,
    ResourceCancellation cancellation,
  ) => _serviceDownload(source, cancellation);

  Future<ResourceResult> collect({
    required String text,
    required String documentPath,
    bool downloadRemote = false,
    ResourceCancellation? cancellation,
    void Function(ResourceProgress)? onProgress,
  }) => _serviceCollect(
    text: text,
    documentPath: documentPath,
    downloadRemote: downloadRemote,
    cancellation: cancellation,
    onProgress: onProgress,
  );

  Future<void> rollbackImports(
    String documentPath,
    Iterable<ManagedImage> images,
  ) => _serviceRollbackImports(documentPath, images);

  Future<String> renameDocument({
    required String sourcePath,
    required String targetPath,
    required String text,
  }) => _serviceRenameDocument(
    sourcePath: sourcePath,
    targetPath: targetPath,
    text: text,
  );

  /// Stages a standalone copy. The destination document is published last.
  Future<ResourceResult> saveCopy({
    required String text,
    required String sourcePath,
    required String targetPath,
    bool downloadRemote = false,
    bool allowIncomplete = false,
    ResourceCancellation? cancellation,
    void Function(ResourceProgress)? onProgress,
  }) => _serviceSaveCopy(
    text: text,
    sourcePath: sourcePath,
    targetPath: targetPath,
    downloadRemote: downloadRemote,
    allowIncomplete: allowIncomplete,
    cancellation: cancellation,
    onProgress: onProgress,
  );

  Future<List<UnusedResource>> unused(
    String documentPath,
    Iterable<ResourceDraft> drafts,
  ) => _serviceUnused(documentPath, drafts);

  Future<int> trashUnused(
    String documentPath,
    List<UnusedResource> selected,
    Iterable<ResourceDraft> drafts,
    Future<void> Function(String) trash,
  ) => _serviceTrashUnused(documentPath, selected, drafts, trash);

  Future<List<ResourceIssue>> package({
    required String text,
    required String sourcePath,
    required String zipPath,
    bool downloadRemote = false,
    bool allowIncomplete = false,
    ResourceCancellation? cancellation,
    void Function(ResourceProgress)? onProgress,
  }) => _servicePackage(
    text: text,
    sourcePath: sourcePath,
    zipPath: zipPath,
    downloadRemote: downloadRemote,
    allowIncomplete: allowIncomplete,
    cancellation: cancellation,
    onProgress: onProgress,
  );
}

Future<String> _resourceBytesDigest(Uint8List bytes) =>
    Isolate.run(() => sha256.convert(bytes).toString());

String _resourcePathKey(String value) {
  final path = p.normalize(p.absolute(value));
  return Platform.isLinux ? path : path.toLowerCase();
}

Future<void> _resourceZip(String directory, String destination) =>
    Isolate.run(() async {
      await ZipFileEncoder().zipDirectory(
        Directory(directory),
        filename: destination,
        followLinks: false,
      );
    });
