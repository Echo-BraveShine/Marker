import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  // 首次 orderFront 后立即隐藏，既让 FlutterViewController 触发 viewWillAppear
  // 启动引擎，又避免在首帧渲染前向用户露出空白窗口。
  private var hasHiddenAtLaunch = false
  private var appearanceChannel: FlutterMethodChannel?

  override func order(_ place: NSWindow.OrderingMode, relativeTo otherWin: Int) {
    super.order(place, relativeTo: otherWin)
    if !hasHiddenAtLaunch && place != .out {
      setIsVisible(false)
      hasHiddenAtLaunch = true
    }
  }

  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    let dark = effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
    let background = NSColor(srgbRed: (dark ? 43 : 245) / 255.0, green: (dark ? 43 : 245) / 255.0, blue: (dark ? 45 : 247) / 255.0, alpha: 1)
    self.backgroundColor = background
    flutterViewController.backgroundColor = background
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: false)

    RegisterGeneratedPlugins(registry: flutterViewController)
    (NSApp.delegate as? AppDelegate)?.configureFileEvents(messenger: flutterViewController.engine.binaryMessenger)
    let channel = FlutterMethodChannel(name: "marker/lifecycle", binaryMessenger: flutterViewController.engine.binaryMessenger)
    channel.setMethodCallHandler { call, result in
      if call.method == "quit" {
        (NSApp.delegate as? AppDelegate)?.allowTermination = true
        result(nil)
        NSApp.terminate(nil)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }

    let appearance = FlutterMethodChannel(name: "marker/appearance", binaryMessenger: flutterViewController.engine.binaryMessenger)
    appearanceChannel = appearance
    appearance.setMethodCallHandler { call, result in
      guard call.method == "setDark" else { result(FlutterMethodNotImplemented); return }
      guard let dark = call.arguments as? Bool else {
        result(FlutterError(code: "invalid-arguments", message: "Expected dark appearance boolean", details: nil)); return
      }
      guard let image = NSImage(named: dark ? "MarkerIconDark" : "MarkerIconLight") else {
        result(FlutterError(code: "missing-icon", message: "Appearance icon asset not found", details: nil)); return
      }
      NSApp.applicationIconImage = image
      NSApp.dockTile.display()
      result(nil)
    }

    super.awakeFromNib()
  }
}
