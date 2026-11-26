import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private let pdfExporter = MarkerMobilePdfExporter()

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(_ app: UIApplication, open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
    if MarkerIncomingFiles.shared.receive(url) { return true }
    return super.application(app, open: url, options: options)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "MarkerIncomingFiles") {
      MarkerIncomingFiles.shared.attach(registrar.messenger())
    }
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "MarkerPdf") {
      FlutterMethodChannel(name: "marker/mobilePdf", binaryMessenger: registrar.messenger()).setMethodCallHandler { [weak self] call, result in
        guard let self = self else { result(FlutterError(code: "unavailable", message: "Renderer unavailable", details: nil)); return }
        if call.method == "cancel" { self.pdfExporter.cancel(); result(nil); return }
        guard call.method == "render", let args = call.arguments as? [String: Any], let html = args["html"] as? String else { result(FlutterMethodNotImplemented); return }
        self.pdfExporter.render(html: html, result: result)
      }
    }
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "MarkerDisplay") {
      FlutterMethodChannel(name: "marker/display", binaryMessenger: registrar.messenger()).setMethodCallHandler { call, result in
        guard call.method == "cutoutSide" else { result(FlutterMethodNotImplemented); return }
        let scene = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first { $0.activationState == .foregroundActive }
        let insets = scene?.windows.first { $0.isKeyWindow }?.safeAreaInsets ?? .zero
        guard max(insets.left, insets.right) > 20 else { result("none"); return }
        switch scene?.interfaceOrientation {
        case .landscapeLeft: result("right")
        case .landscapeRight: result("left")
        default: result("none")
        }
      }
    }
  }
}
