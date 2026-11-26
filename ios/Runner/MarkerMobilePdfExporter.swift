import Flutter
import UIKit
import WebKit

/// Native print pagination keeps text selectable; the supplied HTML is already rendered.
final class MarkerMobilePdfExporter: NSObject, WKNavigationDelegate {
  private var webView: WKWebView?
  private var completion: FlutterResult?
  private var timeout: DispatchWorkItem?

  func render(html: String, result: @escaping FlutterResult) {
    guard completion == nil else { result(FlutterError(code: "busy", message: "PDF renderer busy", details: nil)); return }
    guard html.utf8.count < 128 * 1024 * 1024 else { result(FlutterError(code: "too-large", message: "PDF HTML too large", details: nil)); return }
    completion = result
    let configuration = WKWebViewConfiguration()
    let view = WKWebView(frame: CGRect(x: -10000, y: 0, width: 794, height: 1123), configuration: configuration)
    webView = view
    view.navigationDelegate = self
    // A live view tree lets WebKit finish offscreen font and SVG layout.
    UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
      .flatMap { $0.windows }.first { $0.isKeyWindow }?.rootViewController?.view.addSubview(view)
    view.loadHTMLString(html, baseURL: nil)
    let task = DispatchWorkItem { [weak self] in self?.finish(error: "PDF rendering timed out") }
    timeout = task
    DispatchQueue.main.asyncAfter(deadline: .now() + 90, execute: task)
  }
  func cancel() { if completion != nil { finish(error: "PDF cancelled") } }
  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    webView.callAsyncJavaScript("await document.fonts.ready; await Promise.all(Array.from(document.images).map(i=>i.decode())); return true;", arguments: [:], in: nil, in: .page) { [weak self] response in
      guard let self = self, self.completion != nil else { return }
      switch response {
      case .failure(let error): self.finish(error: error.localizedDescription)
      case .success: self.printDocument(webView)
      }
    }
  }
  private func printDocument(_ view: WKWebView) {
    let renderer = UIPrintPageRenderer()
    let paper = CGRect(x: 0, y: 0, width: 595.276, height: 841.89)
    let margin = 18.0 / 25.4 * 72.0
    renderer.setValue(NSValue(cgRect: paper), forKey: "paperRect")
    renderer.setValue(NSValue(cgRect: paper.insetBy(dx: margin, dy: margin)), forKey: "printableRect")
    renderer.addPrintFormatter(view.viewPrintFormatter(), startingAtPageAt: 0)
    let count = renderer.numberOfPages
    guard count > 0 && count <= 2000 else { finish(error: "Invalid PDF page count"); return }
    renderer.prepare(forDrawingPages: NSRange(location: 0, length: count))
    let data = NSMutableData()
    UIGraphicsBeginPDFContextToData(data, paper, nil)
    for page in 0..<count {
      UIGraphicsBeginPDFPage()
      renderer.drawPage(at: page, in: UIGraphicsGetPDFContextBounds())
    }
    UIGraphicsEndPDFContext()
    guard data.length > 0 else { finish(error: "Empty PDF"); return }
    let callback = completion
    cleanup()
    callback?(FlutterStandardTypedData(bytes: data as Data))
  }
  func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) { finish(error: error.localizedDescription) }
  func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) { finish(error: error.localizedDescription) }
  private func finish(error: String) {
    let callback = completion
    cleanup()
    callback?(FlutterError(code: "pdf-failed", message: error, details: nil))
  }
  private func cleanup() {
    completion = nil; timeout?.cancel(); timeout = nil
    webView?.navigationDelegate = nil; webView?.stopLoading(); webView?.removeFromSuperview(); webView = nil
  }
}
