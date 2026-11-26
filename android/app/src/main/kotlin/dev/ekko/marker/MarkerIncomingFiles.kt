package dev.ekko.marker

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.provider.OpenableColumns
import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.util.UUID
import java.util.concurrent.Executors
import org.json.JSONObject

/** Keep URI grants within native copying; Flutter only receives app-private files. */
class MarkerIncomingFiles(context: Context) {
  private val context = context.applicationContext
  private val folder = File(this.context.cacheDir, "incoming-documents")
  private val io = Executors.newSingleThreadExecutor()
  private val main = Handler(Looper.getMainLooper())
  private val pending = linkedMapOf<String, Map<String, String>>()
  private val sources = mutableSetOf<String>()
  private var channel: MethodChannel? = null
  private var listening = false

  init {
    io.execute {
      folder.mkdirs()
      folder.listFiles()?.forEach { stage ->
        val manifest = File(stage, "ready.json")
        if (manifest.isFile) {
          try {
            val name = JSONObject(manifest.readText()).getString("name")
            val file = File(stage, safeName(name))
            if (file.isFile) deliver(mapOf("token" to stage.name, "path" to file.path))
          } catch (_: Exception) { /* A partial cache entry is never imported. */ }
        } else if (System.currentTimeMillis() - stage.lastModified() > 86400000L) {
          stage.deleteRecursively()
        }
      }
    }
  }

  fun attach(messenger: BinaryMessenger) {
    channel = MethodChannel(messenger, "marker/mobileFiles").also { bridge ->
      bridge.setMethodCallHandler { call, result ->
        when (call.method) {
          "start" -> { listening = true; result.success(pending.values.toList()) }
          "stop" -> { listening = false; result.success(null) }
          "ack" -> {
            val token = call.arguments as? String
            if (token != null && pending.remove(token) != null) {
              io.execute { File(folder, token).deleteRecursively() }
            }
            result.success(null)
          }
          else -> result.notImplemented()
        }
      }
    }
  }

  @Suppress("DEPRECATION")
  fun receive(intent: Intent?) {
    if (intent == null) return
    val uris = when (intent.action) {
      Intent.ACTION_VIEW, Intent.ACTION_EDIT -> listOfNotNull(intent.data)
      Intent.ACTION_SEND -> listOfNotNull(intent.getParcelableExtra<Uri>(Intent.EXTRA_STREAM))
      Intent.ACTION_SEND_MULTIPLE -> intent.getParcelableArrayListExtra<Uri>(Intent.EXTRA_STREAM)?.toList() ?: emptyList()
      else -> return
    }
    val inputs = if (uris.isNotEmpty()) uris else {
      val clip = intent.clipData
      (0 until (clip?.itemCount ?: 0)).mapNotNull { clip?.getItemAt(it)?.uri }
    }
    if (inputs.isEmpty()) {
      deliver(mapOf("token" to UUID.randomUUID().toString(), "error" to "请选择 Markdown、TXT 或 ZIP 文件 / Select a document file"))
    }
    if (inputs.distinct().size > 16) {
      deliver(mapOf("token" to UUID.randomUUID().toString(), "error" to "单次最多导入 16 个文件 / Select up to 16 files"))
      return
    }
    inputs.distinct().forEach { uri ->
      if (!sources.add(uri.toString())) return@forEach
      io.execute {
        val token = UUID.randomUUID().toString()
        val stage = File(folder, token)
        try {
          require(uri.scheme == "content" || uri.scheme == "file") { "Unsupported file URI" }
          val supplied = if (uri.scheme == "content") {
            context.contentResolver.query(uri, arrayOf(OpenableColumns.DISPLAY_NAME), null, null, null)?.use { cursor ->
              if (cursor.moveToFirst()) cursor.getString(0) else null
            }
          } else uri.lastPathSegment
          val name = safeName(supplied ?: "document.md")
          stage.mkdirs()
          val target = File(stage, name)
          context.contentResolver.openInputStream(uri)?.use { input ->
            target.outputStream().use { output ->
              val buffer = ByteArray(64 * 1024)
              var total = 0L
              while (true) {
                val count = input.read(buffer)
                if (count < 0) break
                total += count
                require(total <= 64L * 1024 * 1024) { "文件超过 64 MB / File exceeds 64 MB" }
                output.write(buffer, 0, count)
              }
            }
          } ?: error("无法读取文件 / Cannot read file")
          File(stage, "ready.json").writeText(JSONObject().put("name", name).toString())
          deliver(mapOf("token" to token, "path" to target.path))
        } catch (error: Exception) {
          stage.deleteRecursively()
          deliver(mapOf("token" to token, "error" to (error.message ?: "Cannot read file")))
        } finally {
          main.post { sources.remove(uri.toString()) }
        }
      }
    }
  }

  private fun safeName(value: String): String {
    val name = value.replace('\\', '/').substringAfterLast('/').trim()
    require(name.isNotEmpty() && !name.contains(Regex("[:\\x00-\\x1f]"))) { "Invalid file name" }
    require(name.substringAfterLast('.', "").lowercase() in listOf("md", "markdown", "txt", "zip")) {
      "仅支持 Markdown、TXT 或 ZIP / Select Markdown, TXT or ZIP"
    }
    return name
  }
  private fun deliver(file: Map<String, String>) {
    main.post {
      pending[file.getValue("token")] = file
      if (listening) channel?.invokeMethod("openFiles", listOf(file))
    }
  }
  fun detach() { listening = false; channel?.setMethodCallHandler(null); channel = null; io.shutdown() }
}
