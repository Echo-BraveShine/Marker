import 'dart:async';

/// An invisible native surface may suppress rasterization indefinitely. A frame
/// wait must be bounded; sizing and theming happen before this reveal sequence.
Future<void> revealDesktopWindow({
  required Future<void> firstFrame,
  required Future<void> Function() show,
  required Future<void> Function() focus,
  Duration maximumFrameWait = const Duration(milliseconds: 500),
}) async {
  await firstFrame.timeout(maximumFrameWait, onTimeout: () {});
  await show();
  await focus();
}
