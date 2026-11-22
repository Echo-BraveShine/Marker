import Cocoa
import FlutterMacOS
import WebKit

class MainFlutterWindow: NSWindow {
  // 首次 orderFront 后立即隐藏，既让 FlutterViewController 触发 viewWillAppear
  // 启动引擎，又避免在首帧渲染前向用户露出空白窗口。
  private var hasHiddenAtLaunch = false
  private var appearanceChannel: FlutterMethodChannel?
  private var resourceChannel: FlutterMethodChannel?
  private var resourceGrants: [URL] = []
  private var exportChannel: FlutterMethodChannel?
  private let documentExporter = DocumentExportRenderer()

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

    let exporter = FlutterMethodChannel(name: "marker/export", binaryMessenger: flutterViewController.engine.binaryMessenger)
    exportChannel = exporter
    let renderer = documentExporter
    exporter.setMethodCallHandler { call, result in
      guard call.method == "render" else { result(FlutterMethodNotImplemented); return }
      renderer.render(call.arguments, result: result)
    }

    restoreResourceGrants()
    let resources = FlutterMethodChannel(name: "marker/resources", binaryMessenger: flutterViewController.engine.binaryMessenger)
    resourceChannel = resources
    resources.setMethodCallHandler { [weak self] call, result in
      let context = call.arguments as? [String: Any]
      guard let self = self, let path = (call.arguments as? String) ?? (context?["path"] as? String) else {
        result(FlutterError(code: "invalid-path", message: "Expected a file path", details: nil)); return
      }
      let url = URL(fileURLWithPath: path)
      switch call.method {
      case "authorizeDirectory", "authorizeDirectoryWithContext":
        let panel = NSOpenPanel()
        panel.title = context?["title"] as? String ?? "Allow folder access"
        panel.prompt = context?["prompt"] as? String ?? "Allow folder access"
        panel.message = context?["message"] as? String ?? "Select this folder to let Marker read images and create document assets. Cancel to stop this operation.\n\(path)"
        panel.canCreateDirectories = false
        panel.canChooseDirectories = true; panel.canChooseFiles = false
        panel.allowsMultipleSelection = false; panel.directoryURL = url
        panel.beginSheetModal(for: self) { response in
          guard response == .OK, let selected = panel.url else { result(nil); return }
          do {
            _ = selected.startAccessingSecurityScopedResource()
            self.resourceGrants.append(selected)
            let bookmark = try selected.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
            var records = UserDefaults.standard.dictionary(forKey: "marker.resourceGrants") as? [String: Data] ?? [:]
            records[selected.path] = bookmark
            UserDefaults.standard.set(records, forKey: "marker.resourceGrants")
            result(selected.path)
          } catch { result(FlutterError(code: "directory-access", message: error.localizedDescription, details: nil)) }
        }
      case "reveal":
        NSWorkspace.shared.activateFileViewerSelecting([url]); result(nil)
      case "trash":
        DispatchQueue.global(qos: .userInitiated).async {
          do {
            try FileManager.default.trashItem(at: url, resultingItemURL: nil)
            DispatchQueue.main.async { result(nil) }
          } catch { DispatchQueue.main.async { result(FlutterError(code: "trash-unavailable", message: error.localizedDescription, details: nil)) } }
        }
      default: result(FlutterMethodNotImplemented)
      }
    }

    super.awakeFromNib()
  }
  private func restoreResourceGrants() {
    let records = UserDefaults.standard.dictionary(forKey: "marker.resourceGrants") as? [String: Data] ?? [:]
    for (_, data) in records {
      var stale = false
      if let url = try? URL(resolvingBookmarkData: data, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &stale),
          url.startAccessingSecurityScopedResource() {
        resourceGrants.append(url)
        if stale, let renewed = try? url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil) {
          var updated = UserDefaults.standard.dictionary(forKey: "marker.resourceGrants") as? [String: Data] ?? [:]
          updated[url.path] = renewed
          UserDefaults.standard.set(updated, forKey: "marker.resourceGrants")
        }
      }
    }
  }

}


/// Hidden WebKit rendering keeps document text/vector content intact in PDF.
private final class DocumentExportRenderer {
  private var active: DocumentExportJob?
  func render(_ arguments: Any?, result: @escaping FlutterResult) {
    guard active == nil else { result(FlutterError(code: "export-busy", message: "An export is already running", details: nil)); return }
    guard let args = arguments as? [String: Any], let path = args["path"] as? String,
          let format = args["format"] as? String, let width = args["width"] as? Int,
          ["pdf", "png"].contains(format), (240...2048).contains(width) else {
      result(FlutterError(code: "invalid-export", message: "Expected a local document, format and width", details: nil)); return
    }
    active = DocumentExportJob(path: path, width: width, pdf: format == "pdf") { [weak self] data, error in
      self?.active = nil
      if let data = data { result(FlutterStandardTypedData(bytes: data)) }
      else { result(FlutterError(code: "export-failed", message: error ?? "Document export failed", details: nil)) }
    }
    active?.start()
  }
}

private final class DocumentExportJob: NSObject, WKNavigationDelegate {
  // Share an ephemeral browsing session across successive diagram snapshots.
  private static let dataStore = WKWebsiteDataStore.nonPersistent()
  private let path: String
  private let width: Int
  private var contentWidth: Int?
  private let pdf: Bool
  private let completion: (Data?, String?) -> Void
  private var view: WKWebView!
  private var window: NSWindow!
  private var timer: Timer?
  private var deadline: DispatchWorkItem?
  private var finished = false
  private var polling = false
  private let started = Date()
  init(path: String, width: Int, pdf: Bool, completion: @escaping (Data?, String?) -> Void) {
    self.path = path; self.width = width; self.pdf = pdf; self.completion = completion
  }
  func start() {
    let config = WKWebViewConfiguration()
    config.websiteDataStore = Self.dataStore
    view = WKWebView(frame: NSRect(x: 0, y: 0, width: width, height: 800), configuration: config)
    view.navigationDelegate = self
    window = NSWindow(contentRect: NSRect(x: -12000, y: 0, width: width, height: 800), styleMask: .borderless, backing: .buffered, defer: false)
    window.isReleasedWhenClosed = false
    window.contentView = view
    window.orderFront(nil)
    let url = URL(fileURLWithPath: path)
    view.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
    let deadline = DispatchWorkItem { [weak self] in self?.finish(nil, "Document export timed out") }
    self.deadline = deadline
    DispatchQueue.main.asyncAfter(deadline: .now() + 80, execute: deadline)
    timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in self?.poll() }
  }
  private func poll() {
    if finished || polling { return }
    if Date().timeIntervalSince(started) > 65 { finish(nil, "Document rendering timed out"); return }
    polling = true
    view.evaluateJavaScript("window.markerExport") { [weak self] value, _ in
      guard let self = self, !self.finished else { return }
      self.polling = false
      guard let status = value as? [String: Any] else { return }
      if let error = status["error"] as? String { self.finish(nil, error); return }
      if status["ready"] as? Bool == true, let height = status["height"] as? NSNumber {
        if let contentWidth = status["width"] as? NSNumber {
          self.contentWidth = min(self.width, max(1, contentWidth.intValue))
        }
        self.timer?.invalidate(); self.timer = nil
        if self.pdf { DispatchQueue.main.async { [weak self] in self?.printPdf() } } else { self.snapshot(height.intValue) }
      }
    }
  }
  private func printPdf() {
    guard #available(macOS 11.0, *) else { finish(nil, "PDF export requires macOS 11 or later"); return }
    let paperWidth = 595.2756, paperHeight = 841.8898, margin = 51.0236, scale = 0.75
    let contentWidth = (paperWidth - margin * 2) / scale
    let pageHeight = (paperHeight - margin * 2) / scale
    view.setFrameSize(NSSize(width: contentWidth, height: 800))
    window.setContentSize(NSSize(width: contentWidth, height: 800))
    // Match screen and PDF geometry before measuring line boundaries.
    let prepare = """
    const pageStyle=document.createElement('style');pageStyle.textContent='@page{size:auto!important;margin:0!important}article{padding:0!important;max-width:none!important}body{font-size:11.5pt!important}pre{border:1px solid #ddd}img{max-height:240mm;object-fit:contain}.mermaid svg{max-height:240mm}';document.head.appendChild(pageStyle);
    ({cuts:window.markerExportBreaks(\(pageHeight)),links:Array.from(document.querySelectorAll('#document a[href]')).flatMap(a=>Array.from(a.getClientRects()).map(r=>({href:a.getAttribute('href'),x:r.left,y:r.top,w:r.width,h:r.height}))),anchors:Array.from(document.querySelectorAll('#document [id]')).map(a=>({id:a.id,y:a.getBoundingClientRect().top}))});
    """
    view.evaluateJavaScript(prepare) { [weak self] value, error in
      guard let self = self, !self.finished else { return }
      guard let geometry = value as? [String: Any], let numbers = geometry["cuts"] as? [NSNumber], numbers.count > 1 else {
        self.finish(nil, error?.localizedDescription ?? "Cannot measure PDF pages"); return
      }
      let cuts = numbers.map { $0.doubleValue }
      guard cuts.allSatisfy({ $0.isFinite }), cuts.first == 0,
            zip(cuts, cuts.dropFirst()).allSatisfy({ $0.1 - $0.0 >= 1 && $0.1 - $0.0 <= pageHeight + 1 }) else {
        self.finish(nil, "Invalid PDF page geometry"); return
      }
      let links = geometry["links"] as? [[String: Any]] ?? []
      let anchors = geometry["anchors"] as? [[String: Any]] ?? []
      func number(_ values: [String: Any], _ key: String) -> Double { (values[key] as? NSNumber)?.doubleValue ?? 0 }
      let output = NSMutableData()
      var media = CGRect(x: 0, y: 0, width: paperWidth, height: paperHeight)
      guard let consumer = CGDataConsumer(data: output as CFMutableData), let context = CGContext(consumer: consumer, mediaBox: &media, [kCGPDFContextTitle: self.view.title ?? "Marker", kCGPDFContextCreator: "Marker"] as CFDictionary) else {
        self.finish(nil, "Cannot create PDF pages"); return
      }
      func capturePage(_ index: Int) {
        if self.finished { context.closePDF(); return }
        if Date().timeIntervalSince(self.started) > 75 { context.closePDF(); self.finish(nil, "PDF export timed out"); return }
        let height = cuts[index + 1] - cuts[index]
        let config = WKPDFConfiguration()
        config.rect = CGRect(x: 0, y: cuts[index], width: contentWidth, height: height)
        self.view.createPDF(configuration: config) { result in
          if self.finished { context.closePDF(); return }
          switch result {
          case .failure(let error): context.closePDF(); self.finish(nil, error.localizedDescription)
          case .success(let data):
            guard let provider = CGDataProvider(data: data as CFData), let document = CGPDFDocument(provider),
                  document.numberOfPages == 1, let page = document.page(at: 1) else {
              context.closePDF(); self.finish(nil, "Cannot read vector PDF page"); return
            }
            let source = page.getBoxRect(.mediaBox)
            guard source.width > 0 && source.height > 0 else {
              context.closePDF(); self.finish(nil, "Invalid captured PDF geometry"); return
            }
            let actualScale = (paperWidth - margin * 2) / source.width
            let used = source.height * actualScale
            context.beginPDFPage(nil)
            context.saveGState()
            context.clip(to: CGRect(x: margin, y: paperHeight - margin - used, width: paperWidth - margin * 2, height: used))
            context.translateBy(x: margin, y: paperHeight - margin - used)
            context.scaleBy(x: actualScale, y: actualScale)
            context.drawPDFPage(page)
            context.restoreGState()
            let start = cuts[index], end = cuts[index + 1]
            for link in links {
              let top = max(number(link, "y"), start), bottom = min(number(link, "y") + number(link, "h"), end)
              guard bottom > top, let href = link["href"] as? String else { continue }
              let rectangle = CGRect(x: margin + number(link, "x") * actualScale, y: paperHeight - margin - (bottom - start) * actualScale,
                width: number(link, "w") * actualScale, height: (bottom - top) * actualScale)
              if href.hasPrefix("#") {
                let name = String(href.dropFirst()).removingPercentEncoding ?? String(href.dropFirst())
                context.setDestination(("marker-" + name) as CFString, for: rectangle)
              } else if let url = URL(string: href), let scheme = url.scheme, ["http", "https", "mailto", "file"].contains(scheme) {
                context.setURL(url as CFURL, for: rectangle)
              }
            }
            for anchor in anchors {
              let y = number(anchor, "y")
              if y >= start && y < end, let name = anchor["id"] as? String {
                context.addDestination(("marker-" + name) as CFString, at: CGPoint(x: margin, y: paperHeight - margin - (y - start) * actualScale))
              }
            }
            context.endPDFPage()
            if index + 2 < cuts.count { DispatchQueue.main.async { capturePage(index + 1) } }
            else { context.closePDF(); self.finish(output as Data, nil) }
          }
        }
      }
      capturePage(0)
    }
  }
  private func snapshot(_ height: Int) {
    guard height > 0 && height <= 32768 else { finish(nil, "Document is too tall for PNG; choose PDF"); return }
    let width = contentWidth ?? self.width
    view.setFrameSize(NSSize(width: width, height: height))
    window.setContentSize(NSSize(width: width, height: height))
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
      guard let self = self, !self.finished else { return }
      let config = WKSnapshotConfiguration()
      config.rect = CGRect(x: 0, y: 0, width: width, height: height)
      config.afterScreenUpdates = true
      self.view.takeSnapshot(with: config) { [weak self] image, error in
        guard let self = self, !self.finished else { return }
        guard let image = image, let bitmap = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: width, pixelsHigh: height,
          bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0),
          let graphics = NSGraphicsContext(bitmapImageRep: bitmap) else { self.finish(nil, error?.localizedDescription ?? "Snapshot failed"); return }
        NSGraphicsContext.saveGraphicsState(); NSGraphicsContext.current = graphics
        graphics.imageInterpolation = .high
        image.draw(in: NSRect(x: 0, y: 0, width: width, height: height))
        NSGraphicsContext.restoreGraphicsState()
        self.finish(bitmap.representation(using: .png, properties: [:]), nil)
      }
    }
  }
  private func finish(_ data: Data?, _ error: String?) {
    if finished { return }; finished = true
    timer?.invalidate(); timer = nil
    deadline?.cancel(); deadline = nil
    view?.stopLoading(); window?.close(); view = nil; window = nil
    completion(data, error)
  }
  func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
    finish(nil, "Export renderer terminated. Try reducing image sizes or diagram complexity.")
  }
  func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) { finish(nil, error.localizedDescription) }
  func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) { finish(nil, error.localizedDescription) }
}
