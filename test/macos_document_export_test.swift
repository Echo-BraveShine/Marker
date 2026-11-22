import Cocoa
import WebKit
import PDFKit

let app = NSApplication.shared
app.setActivationPolicy(.prohibited)
let args = CommandLine.arguments
let input = args[1], output = args[2], pdf = args[3] == "pdf"
var finished = false
private let job = DocumentExportJob(path: input, width: pdf ? 794 : 1280, pdf: pdf) { data, error in
  guard let data = data else { fputs("FAILED: \(error ?? "unknown")\n", stderr); exit(1) }
  do { try data.write(to: URL(fileURLWithPath: output)) } catch { fputs("WRITE FAILED\n", stderr); exit(1) }
  if pdf {
    guard let document = PDFDocument(data: data), document.pageCount > 1, let text = document.string,
          text.contains("Marker export 12345"), text.contains("END-OF-DOCUMENT-98765"), text.contains("中文"), text.contains("FOOTNOTE-END-45678") else {
      fputs("PDF missing pages or selectable text\n", stderr); exit(2)
    }
    // Verify first page includes 'Boundary heading level 6' (not truncated at level 4)
    if let firstPageText = document.page(at: 0)?.string {
      guard firstPageText.contains("Boundary heading level 6") else {
        fputs("First page missing 'Boundary heading level 6'\n", stderr); exit(9)
      }
    } else {
      fputs("Cannot read first page\n", stderr); exit(10)
    }
    // Verify first page has >=55% usable content height using PDF selection bounds
    let firstPage = document.page(at: 0)!
    let pageBounds = firstPage.bounds(for: .mediaBox)
    let contentBounds = firstPage.selection(for: pageBounds)?.bounds(for: firstPage) ?? .zero
    let contentHeight = max(0, contentBounds.height)
    let usableHeight = pageBounds.height - 2 * 51.0236  // A4 margin (18mm ≈ 51.02pt)
    let ratio = contentHeight / usableHeight
    guard ratio >= 0.55 else { fputs("Sparse first page\n", stderr); exit(11) }
    if input.hasSuffix("document-complex.html") && !text.contains("COMPLEX-END-12345") {
      fputs("Complex document tail missing\n", stderr); exit(7)
    }
    for marker in ["CODE-BLOCK-START", "PARAGRAPH-START", "FOOTNOTE-END-45678"] {
      guard text.components(separatedBy: marker).count == 2 else {
        fputs("Missing or repeated PDF text: \(marker)\n", stderr); exit(8)
      }
    }
    // Normalize whitespace for robust marker matching (allows wrapping across lines).
    let compactPages = (0..<document.pageCount).map { index in
      (document.page(at: index)?.string ?? "").filter { !$0.isWhitespace }
    }
    let compactText = compactPages.joined()
    // Verify each row has both START and END markers on the same page.
    for i in 0..<35 {
      let startMarker = "ROW-\(i)-START"
      let endMarker = "ROW-\(i)-END-FINAL"
      guard compactText.contains(startMarker) && compactText.contains(endMarker) else {
        fputs("Long table row \(i) missing markers\n", stderr); exit(12)
      }
      // Ensure markers appear exactly once each.
      guard compactText.components(separatedBy: startMarker).count == 2 else {
        fputs("Repeated row \(i) start marker\n", stderr); exit(12)
      }
      guard compactText.components(separatedBy: endMarker).count == 2 else {
        fputs("Repeated row \(i) end marker\n", stderr); exit(12)
      }
      // Verify both markers are on the same page.
      let pagesWithStart = (0..<document.pageCount).filter { idx in
        compactPages[idx].contains(startMarker)
      }
      let pagesWithEnd = (0..<document.pageCount).filter { idx in
        compactPages[idx].contains(endMarker)
      }
      guard pagesWithStart == pagesWithEnd, pagesWithStart.count == 1 else {
        fputs("Long table row \(i) markers not on same page or missing\n", stderr); exit(12)
      }
    }
    guard text.contains("TRAILER") else {
      fputs("Long table missing TRAILER marker\n", stderr); exit(12)
    }
    for pair in [("CODE-BLOCK-START", "CODE-BLOCK-END"), ("PARAGRAPH-START", "PARAGRAPH-END"), ("TABLE-START", "TABLE-END"), ("HEADING-WITH-CONTENT", "HEADING-CONTENT")] {
      guard (0..<document.pageCount).contains(where: { index in
        let pageText = document.page(at:index)?.string ?? ""
        return pageText.contains(pair.0) && pageText.contains(pair.1)
      }) else { fputs("Block split across pages: \(pair)\n", stderr); exit(5) }
    }
    for line in 0..<85 {
      if !text.contains("Oversized-line-\(line) stays") { fputs("Missing long code line \(line)\n", stderr); exit(6) }
    }
    print("PASS: footnote present, fitting code/paragraph/table/heading blocks kept whole")
    print("PASS: first page includes 'Boundary heading level 6', content >=55%")
    print("PASS: PDF pages=\(document.pageCount), selectable Chinese/English, final paragraph present, bytes=\(data.count)")
  } else {
    guard let image = NSBitmapImageRep(data: data), image.pixelsWide == 1280, image.pixelsHigh > 1000 else {
      fputs("PNG dimensions invalid\n", stderr); exit(3)
    }
    print("PASS: PNG \(image.pixelsWide)x\(image.pixelsHigh), bytes=\(data.count)")
  }
  finished = true
}
job.start()
let deadline = Date().addingTimeInterval(100)
while !finished && Date() < deadline { RunLoop.main.run(until: Date().addingTimeInterval(0.05)) }
if !finished { fputs("HARNESS TIMEOUT\n", stderr); exit(4) }
