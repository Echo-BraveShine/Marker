import '../l10n/message_catalog.dart';
import 'dart:async';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'resource_service.dart';
part 'resource_provider.freezed.dart';

@freezed
abstract class ResourceUiState with _$ResourceUiState {
  const factory ResourceUiState({
    @Default(false) bool showResources,
    @Default(false) bool busy,
    @Default(false) bool dropHover,
    @Default('') String operation,
    @Default(0) int done,
    @Default(0) int total,
    @Default(0) int revision,
  }) = _ResourceUiState;
}

final resourceServiceProvider = Provider(
  (ref) => DocumentResourceService(
    validateImage: (data) async {
      final buffer = await ui.ImmutableBuffer.fromUint8List(data);
      ui.ImageDescriptor? descriptor;
      try {
        descriptor = await ui.ImageDescriptor.encoded(buffer);
        if (descriptor.width * descriptor.height > 40000000) {
          throw const ResourceFailure.localized(
            AppMessage.imageDimensionsAreTooLarge,
          );
        }
        final codec = await descriptor.instantiateCodec();
        try {
          final frame = await codec.getNextFrame();
          frame.image.dispose();
        } finally {
          codec.dispose();
        }
      } finally {
        descriptor?.dispose();
        buffer.dispose();
      }
    },
  ),
);
final resourceUiProvider =
    NotifierProvider<ResourceController, ResourceUiState>(
      ResourceController.new,
    );
final resourceInventoryProvider = FutureProvider.autoDispose
    .family<ResourceInventory, ({String text, String? path, int revision})>((
      ref,
      input,
    ) async {
      final ready = Completer<void>();
      final timer = Timer(
        const Duration(milliseconds: 220),
        () => ready.complete(),
      );
      ref.onDispose(() {
        timer.cancel();
        if (!ready.isCompleted) ready.complete();
      });
      await ready.future;
      if (!ref.mounted) return const ResourceInventory([], []);
      return ref.read(resourceServiceProvider).scan(input.text, input.path);
    });

class ResourceController extends Notifier<ResourceUiState> {
  ResourceCancellation? _cancellation;
  @override
  ResourceUiState build() => const ResourceUiState();
  void toggle() => state = state.copyWith(showResources: !state.showResources);
  void refresh() => state = state.copyWith(revision: state.revision + 1);
  void setDropHover(bool value) {
    if (state.dropHover != value) state = state.copyWith(dropHover: value);
  }

  void cancel() {
    _cancellation?.cancelled = true;
  }

  Future<T> run<T>(
    String operation,
    Future<T> Function(ResourceCancellation, void Function(ResourceProgress))
    task,
  ) async {
    if (state.busy) {
      throw const ResourceFailure.localized(
        AppMessage.aResourceOperationIsAlreadyRunning,
      );
    }
    final token = ResourceCancellation();
    _cancellation = token;
    state = state.copyWith(busy: true, operation: operation, done: 0, total: 0);
    try {
      return await task(token, (progress) {
        if (ref.mounted) {
          state = state.copyWith(done: progress.done, total: progress.total);
        }
      });
    } finally {
      _cancellation = null;
      if (ref.mounted) {
        state = state.copyWith(
          busy: false,
          operation: '',
          done: 0,
          total: 0,
          revision: state.revision + 1,
        );
      }
    }
  }
}

class ResourcePlatform {
  static const channel = MethodChannel('marker/resources');
  Future<void> reveal(String path) =>
      channel.invokeMethod<void>('reveal', path);
  Future<void> trash(String path) async {
    if (Platform.isAndroid || Platform.isIOS) {
      final root = await getApplicationDocumentsDirectory();
      final canonical = await File(path).resolveSymbolicLinks();
      if (!p.isWithin(await root.resolveSymbolicLinks(), canonical)) {
        throw const ResourceFailure.localized(
          AppMessage.onlyFilesInsideMarkerCanBeDeleted,
        );
      }
      await File(canonical).delete();
      return;
    }
    try {
      await channel.invokeMethod<void>('trash', path);
    } on Exception {
      throw const ResourceFailure.localized(AppMessage.trashFailedFileKept);
    }
  }

  Future<String?> authorizeDirectory(
    String path, {
    bool chinese = false,
    String? languageTag,
  }) async {
    try {
      return await channel.invokeMethod<String>(
        'authorizeDirectoryWithContext',
        {
          'path': path,
          'title': messageForLanguage(
            languageTag ?? (chinese ? 'zh-Hans' : 'en'),
            AppMessage.allowFolderAccess3,
          ),
          'prompt': messageForLanguage(
            languageTag ?? (chinese ? 'zh-Hans' : 'en'),
            AppMessage.allowFolderAccess4,
          ),
          'message': messageForLanguage(
            languageTag ?? (chinese ? 'zh-Hans' : 'en'),
            AppMessage.folderAccessPurpose,
            {"p0": path},
          ),
        },
      );
    } on MissingPluginException {
      // Keep hot reload usable with a running pre-update native host.
      return channel.invokeMethod<String>('authorizeDirectory', path);
    } on PlatformException catch (error) {
      if (error.code != 'invalid-path') rethrow;
      return channel.invokeMethod<String>('authorizeDirectory', path);
    }
  }
}

final resourcePlatformProvider = Provider((ref) => ResourcePlatform());
