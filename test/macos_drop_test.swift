import Cocoa
import FlutterMacOS

final class TestMessenger: NSObject, FlutterBinaryMessenger {
  var handlers = Set<String>()
  var calls: [FlutterMethodCall] = []
  func send(onChannel channel: String, message: Data?) {
    if let message = message { calls.append(FlutterStandardMethodCodec.sharedInstance().decodeMethodCall(message)) }
  }
  func send(onChannel channel: String, message: Data?, binaryReply callback: FlutterBinaryReply?) { send(onChannel: channel, message: message); callback?(nil) }
  func setMessageHandlerOnChannel(_ channel: String, binaryMessageHandler handler: FlutterBinaryMessageHandler?) -> FlutterBinaryMessengerConnection {
    if handler != nil { handlers.insert(channel) }
    return 1
  }
  func cleanUpConnection(_ connection: FlutterBinaryMessengerConnection) {}
}

final class TestRegistrar: NSObject, FlutterPluginRegistrar {
  let recorder = TestMessenger()
  var messenger: FlutterBinaryMessenger { recorder }
  var textures: FlutterTextureRegistry { fatalError("Textures are not used by desktop_drop") }
  var view: NSView?
  var viewController: NSViewController? { nil }
  var delegateRegistered = false
  init(view: NSView?) { self.view = view }
  func addMethodCallDelegate(_ delegate: FlutterPlugin, channel: FlutterMethodChannel) { delegateRegistered = true }
  func addApplicationDelegate(_ delegate: FlutterAppLifecycleDelegate) {}
  func register(_ factory: FlutterPlatformViewFactory, withId factoryId: String) {}
  func publish(_ value: NSObject) {}
  func lookupKey(forAsset asset: String) -> String { asset }
  func lookupKey(forAsset asset: String, fromPackage package: String) -> String { asset }
}

final class TestDragInfo: NSObject, NSDraggingInfo {
  var draggingDestinationWindow: NSWindow? { nil }
  var draggingSourceOperationMask: NSDragOperation { .copy }
  var draggingLocation: NSPoint { NSPoint(x: 100, y: 120) }
  var draggedImageLocation: NSPoint { draggingLocation }
  var draggedImage: NSImage? { nil }
  let draggingPasteboard = NSPasteboard(name: .init("marker-drop-test-" + UUID().uuidString))
  var draggingSource: Any? { nil }
  var draggingSequenceNumber: Int { 1 }
  var draggingFormation: NSDraggingFormation = .none
  var animatesToDestination = false
  var numberOfValidItemsForDrop = 1
  var springLoadingHighlight: NSSpringLoadingHighlight { .none }
  func slideDraggedImage(to screenPoint: NSPoint) {}
  override func namesOfPromisedFilesDropped(atDestination dropDestination: URL) -> [String]? { nil }
  func resetSpringLoading() {}
  func enumerateDraggingItems(options: NSDraggingItemEnumerationOptions, for view: NSView?, classes: [AnyClass], searchOptions: [NSPasteboard.ReadingOptionKey: Any], using block: (NSDraggingItem, Int, UnsafeMutablePointer<ObjCBool>) -> Void) {}
}

@main
struct DropRegression {
  static func main() {
    let view = NSView(frame: NSRect(x: 0, y: 0, width: 1200, height: 800))
    precondition(view.window == nil)
    let registrar = TestRegistrar(view: view)
    DesktopDropPlugin.register(with: registrar)
    precondition(registrar.delegateRegistered, "Drop plugin skipped registration before window attachment")
    precondition(registrar.recorder.handlers.contains("desktop_drop"))
    guard let target = view.subviews.first as? DropTarget else { fatalError("No native drop target") }
    precondition(target.registeredDraggedTypes.contains(.fileURL))
    view.setFrameSize(NSSize(width: 900, height: 600))
    precondition(target.frame == view.bounds, "Drop target does not track the Flutter view")
    let drag = TestDragInfo()
    let file = FileManager.default.temporaryDirectory.appendingPathComponent("marker-drop-中文.png")
    precondition(drag.draggingPasteboard.writeObjects([file as NSURL]))
    precondition(target.draggingEntered(drag) == .copy)
    precondition(target.prepareForDragOperation(drag))
    precondition(target.performDragOperation(drag))
    let deadline = Date().addingTimeInterval(3)
    while !registrar.recorder.calls.contains(where: { $0.method == "performOperation_macos" }) && Date() < deadline {
      RunLoop.current.run(until: Date().addingTimeInterval(0.01))
    }
    let operation = registrar.recorder.calls.first(where: { $0.method == "performOperation_macos" })!
    let items = operation.arguments as! [[String: Any]]
    precondition(items.count == 1 && items[0]["path"] as? String == file.path)
    precondition((items[0]["drop-position"] as? [Double]) == [100, 480])
    drag.draggingPasteboard.releaseGlobally()
    let headless = TestRegistrar(view: nil)
    DesktopDropPlugin.register(with: headless)
    precondition(!headless.delegateRegistered)
    let bookmark = Data([1, 2, 3])
    let codec = FlutterStandardMessageCodec.sharedInstance()
    let encoded = codec.encode(["apple-bookmark": FlutterStandardTypedData(bytes: bookmark)])!
    let decoded = codec.decode(encoded) as! [String: Any]
    precondition((decoded["apple-bookmark"] as! FlutterStandardTypedData).data == bookmark)
    print("macOS early registration, resize, native file delivery, coordinates and bookmark codec checks passed")
  }
}
