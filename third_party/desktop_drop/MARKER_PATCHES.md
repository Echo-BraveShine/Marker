Based on desktop_drop 0.8.4 from pub.dev, Apache-2.0 (see LICENSE).
Only runtime sources are included; example and upstream tests are omitted.

Marker changes:
- Encode macOS security-scoped bookmark Data as FlutterStandardTypedData, the
  type accepted by StandardMessageCodec and expected by Dart Uint8List.
- Attach the macOS drop target directly to the registrar's Flutter view. Do not
  require a window or controller to exist yet during plugin registration.
- Attach the actual drop position to the macOS operation payload, so delayed
  file promises remain positioned correctly even after a drag-exit event.
- Create a UUID-named temporary destination only for promised files, avoiding
  unused directories on normal Finder drops and collisions between transfers.
- Convert window drag coordinates to the native target view's coordinates.
- Accept an in-bounds drop completion after native drag-exit (file promises).
- Remove the upstream monorepo workspace resolution setting for local use.
- Windows: query full Unicode path lengths, pass the HDROP handle correctly,
  use the final drop point, negotiate copy-only file drops and balance OLE
  registration/initialization on shutdown. Native extraction test runs in CI.
- Linux: return gboolean from drag-motion so GTK default negotiation runs;
  reject empty selection data, trim URI-list lines and ignore comments, preserve
  POSIX paths independently of the test host, trim portal transfer keys.
- Convert Windows physical coordinates using Flutter's effective platform and
  display scale; synthesize drag-enter when the first event is a motion event.

Regression coverage lives in Marker/test/resource_drop_test.dart and
Marker/test/resource_ui_test.dart, with native Windows path extraction in
Marker/test/windows_drop_test.cpp and early macOS registration in
Marker/test/macos_drop_test.swift. Keep this patch when upgrading the plugin.
