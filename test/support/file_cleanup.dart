import 'dart:io';

/// Windows may release decoder/antivirus file handles just after disposal.
/// Retry sharing/lock violations only, and preserve any persistent error.
Future<void> withWindowsFileLockRetry(
  Future<void> Function() cleanup, {
  bool? windows,
  Duration retryDelay = const Duration(milliseconds: 50),
}) async {
  for (var attempt = 0; ; attempt++) {
    try {
      await cleanup();
      return;
    } on FileSystemException catch (error) {
      if (!(windows ?? Platform.isWindows) ||
          ![32, 33].contains(error.osError?.errorCode) ||
          attempt >= 7) {
        rethrow;
      }
      await Future<void>.delayed(retryDelay * (attempt + 1));
    }
  }
}
