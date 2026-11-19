import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'release_updates.dart';
part 'update_provider.freezed.dart';

final packageInfoProvider = FutureProvider((ref) => PackageInfo.fromPlatform());
final releaseClientProvider = Provider((ref) => GitHubReleaseClient());

@freezed
abstract class UpdateState with _$UpdateState {
  const factory UpdateState({
    @Default(ReleaseStatus.idle) ReleaseStatus status,
    String? latest,
    Uri? page,
    UpdateError? error,
  }) = _UpdateState;
}

final updateProvider = NotifierProvider<UpdateNotifier, UpdateState>(
  UpdateNotifier.new,
);

class UpdateNotifier extends Notifier<UpdateState> {
  @override
  UpdateState build() => const UpdateState();

  Future<void> check() async {
    if (state.status == ReleaseStatus.checking) return;
    state = const UpdateState(status: ReleaseStatus.checking);
    try {
      final info = await ref
          .read(packageInfoProvider.future)
          .timeout(const Duration(seconds: 6));
      final result = await ref.read(releaseClientProvider).check(info.version);
      if (ref.mounted) {
        state = UpdateState(
          status: result.status,
          latest: result.latest,
          page: result.page,
        );
      }
    } on TimeoutException {
      if (ref.mounted) {
        state = const UpdateState(
          status: ReleaseStatus.error,
          error: UpdateError.version,
        );
      }
    } on ReleaseException catch (error) {
      if (ref.mounted) {
        state = UpdateState(status: ReleaseStatus.error, error: error.kind);
      }
    } catch (_) {
      if (ref.mounted) {
        state = const UpdateState(
          status: ReleaseStatus.error,
          error: UpdateError.version,
        );
      }
    }
  }
}
