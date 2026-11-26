import Flutter
import UIKit

/// Receive document URLs before Flutter is ready and copy under the URL grant.
final class MarkerIncomingFiles {
  static let shared = MarkerIncomingFiles()
  private var channel: FlutterMethodChannel?
  private var listening = false
  private var pending: [String: [String: String]] = [:]
  private var sources = Set<String>()
  private let io = DispatchQueue(label: "dev.ekko.marker.incoming-files", qos: .userInitiated)
  private let folder = FileManager.default.temporaryDirectory.appendingPathComponent("incoming-documents", isDirectory: true)

  private init() {
    io.async { [self] in
      try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
      for stage in (try? FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil)) ?? [] {
        let manifest = stage.appendingPathComponent("ready.json")
        if let data = try? Data(contentsOf: manifest),
           let value = try? JSONSerialization.jsonObject(with: data) as? [String: String],
           let supplied = value["name"], let name = try? safeName(supplied) {
          let file = stage.appendingPathComponent(name)
          if FileManager.default.fileExists(atPath: file.path) {
            var incoming = ["token": stage.lastPathComponent, "path": file.path]
            incoming["ownedRelativePath"] = value["ownedRelativePath"]
            deliver(incoming)
          }
        } else if let attributes = try? FileManager.default.attributesOfItem(atPath: stage.path),
                  let date = attributes[.modificationDate] as? Date, Date().timeIntervalSince(date) > 86400 {
          try? FileManager.default.removeItem(at: stage)
        }
      }
    }
  }
  func attach(_ messenger: FlutterBinaryMessenger) {
    let bridge = FlutterMethodChannel(name: "marker/mobileFiles", binaryMessenger: messenger)
    channel = bridge
    bridge.setMethodCallHandler { [weak self] call, result in
      guard let self = self else { result(nil); return }
      switch call.method {
      case "start": self.listening = true; result(Array(self.pending.values))
      case "stop": self.listening = false; result(nil)
      case "ack":
        if let token = call.arguments as? String, self.pending.removeValue(forKey: token) != nil {
          self.io.async { try? FileManager.default.removeItem(at: self.folder.appendingPathComponent(token)) }
        }
        result(nil)
      default: result(FlutterMethodNotImplemented)
      }
    }
  }
  @discardableResult
  func receive(_ url: URL) -> Bool {
    guard url.isFileURL else { return false }
    let source = url.absoluteString
    guard sources.insert(source).inserted else { return true }
    let accessed = url.startAccessingSecurityScopedResource()
    io.async { [self] in
      defer {
        if accessed { url.stopAccessingSecurityScopedResource() }
        DispatchQueue.main.async { self.sources.remove(source) }
      }
      let token = UUID().uuidString
      let stage = folder.appendingPathComponent(token, isDirectory: true)
      do {
        let name = try safeName(url.lastPathComponent)
        try FileManager.default.createDirectory(at: stage, withIntermediateDirectories: true)
        var coordinationError: NSError?
        var copyError: Error?
        NSFileCoordinator().coordinate(readingItemAt: url, options: [], error: &coordinationError) { readable in
          do { try copy(readable, to: stage.appendingPathComponent(name)) }
          catch { copyError = error }
        }
        if let error = coordinationError { throw error }
        if let error = copyError { throw error }
        var metadata = ["name": name]
        var incoming = ["token": token, "path": stage.appendingPathComponent(name).path]
        if let root = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
          let base = root.resolvingSymlinksInPath().path + "/"
          let original = url.resolvingSymlinksInPath().path
          if original.hasPrefix(base) {
            let relative = String(original.dropFirst(base.count))
            if !relative.hasPrefix("Inbox/") {
              metadata["ownedRelativePath"] = relative
              incoming["ownedRelativePath"] = relative
            }
          }
        }
        try JSONSerialization.data(withJSONObject: metadata).write(to: stage.appendingPathComponent("ready.json"), options: .atomic)
        deliver(incoming)
      } catch {
        try? FileManager.default.removeItem(at: stage)
        deliver(["token": token, "error": error.localizedDescription])
      }
    }
    return true
  }
  private func safeName(_ supplied: String) throws -> String {
    let name = supplied.replacingOccurrences(of: "\\", with: "/").components(separatedBy: "/").last?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    guard !name.isEmpty, !name.contains(":"), name.rangeOfCharacter(from: .controlCharacters) == nil,
          ["md", "markdown", "txt", "zip"].contains((name as NSString).pathExtension.lowercased()) else {
      throw NSError(domain: "MarkerImport", code: 1, userInfo: [NSLocalizedDescriptionKey: "请选择 Markdown、TXT 或 ZIP 文件 / Select Markdown, TXT or ZIP"])
    }
    return name
  }
  private func copy(_ source: URL, to target: URL) throws {
    guard let input = InputStream(url: source), let output = OutputStream(url: target, append: false) else {
      throw NSError(domain: "MarkerImport", code: 2, userInfo: [NSLocalizedDescriptionKey: "无法读取文件 / Cannot read file"])
    }
    input.open(); output.open()
    defer { input.close(); output.close() }
    var buffer = [UInt8](repeating: 0, count: 65536)
    var total = 0
    while true {
      let count = input.read(&buffer, maxLength: buffer.count)
      if count < 0 { throw input.streamError ?? NSError(domain: "MarkerImport", code: 3) }
      if count == 0 { break }
      total += count
      guard total <= 64 * 1024 * 1024 else {
        throw NSError(domain: "MarkerImport", code: 4, userInfo: [NSLocalizedDescriptionKey: "文件超过 64 MB / File exceeds 64 MB"])
      }
      try buffer.withUnsafeBufferPointer { pointer in
        var written = 0
        while written < count {
          let amount = output.write(pointer.baseAddress!.advanced(by: written), maxLength: count - written)
          if amount <= 0 { throw output.streamError ?? NSError(domain: "MarkerImport", code: 5) }
          written += amount
        }
      }
    }
  }
  private func deliver(_ value: [String: String]) {
    DispatchQueue.main.async { [self] in
      pending[value["token"]!] = value
      if listening { channel?.invokeMethod("openFiles", arguments: [value]) }
    }
  }
}
