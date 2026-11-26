import Cocoa
import WebKit
import PDFKit

let app = NSApplication.shared
app.setActivationPolicy(.prohibited)
let input = CommandLine.arguments[1], output = CommandLine.arguments[2]
var finished = false
private let job = DocumentExportJob(path: input, width: 960, pdf: false) { data, error in
  guard let data = data, data.count > 1000,
        let image = NSBitmapImageRep(data: data),
        image.pixelsWide > 24, image.pixelsHigh > 24 else {
    fputs("Mermaid resource load/render failed: \(error ?? "invalid PNG")\n", stderr)
    exit(1)
  }
  do { try data.write(to: URL(fileURLWithPath: output)) }
  catch { fputs("Cannot write Mermaid snapshot\n", stderr); exit(2) }
  print("PASS: shared script/font, PNG \(image.pixelsWide)x\(image.pixelsHigh), \(data.count) bytes")
  finished = true
}
job.start()
let deadline = Date().addingTimeInterval(40)
while !finished && Date() < deadline {
  RunLoop.main.run(until: Date().addingTimeInterval(0.05))
}
if !finished { fputs("Mermaid native harness timed out\n", stderr); exit(3) }
