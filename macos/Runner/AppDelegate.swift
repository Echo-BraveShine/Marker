import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  var allowTermination = false
  private var fileChannel: FlutterMethodChannel?
  private var pendingFiles: [String] = []
  private var fileEventsReady = false

  func configureFileEvents(messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: "marker/files", binaryMessenger: messenger)
    fileChannel = channel
    channel.setMethodCallHandler { [weak self] call, result in
      guard let self else { result([]); return }
      if call.method == "start" {
        self.fileEventsReady = true
        let files = self.pendingFiles
        self.pendingFiles.removeAll()
        result(files)
      } else { result(FlutterMethodNotImplemented) }
    }
  }

  override func application(_ sender: NSApplication, open urls: [URL]) {
    let files = urls.filter { $0.isFileURL }
    for url in files { _ = url.startAccessingSecurityScopedResource() }
    pendingFiles.append(contentsOf: files.map { $0.path })
    if fileEventsReady {
      fileChannel?.invokeMethod("openFiles", arguments: pendingFiles)
      pendingFiles.removeAll()
    }
    if let window = mainFlutterWindow, window.isVisible || window.isMiniaturized { window.deminiaturize(nil); window.makeKeyAndOrderFront(nil); sender.activate(ignoringOtherApps: true) }
  }

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
    if allowTermination { return .terminateNow }
    // Route Cmd-Q and the application menu through the protected window close.
    if let window = mainFlutterWindow {
      window.performClose(nil)
      return .terminateCancel
    }
    return .terminateNow
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
}
