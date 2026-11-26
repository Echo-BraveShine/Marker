package dev.ekko.marker

import android.app.Activity
import android.os.CancellationSignal
import android.os.Handler
import android.os.Looper
import android.os.ParcelFileDescriptor
import android.print.PageRange
import android.print.PrintAttributes
import android.print.PrintDocumentAdapter
import android.print.PrintDocumentInfo
import android.webkit.WebView
import android.webkit.WebViewClient
import android.view.ViewGroup
import io.flutter.plugin.common.MethodChannel
import java.io.File

/** Native print pagination over the already-rendered HTML. */
class MarkerMobilePdfExporter(private val activity: Activity) {
  private var completion: MethodChannel.Result? = null
  private var view: WebView? = null
  private var output: File? = null
  private var adapter: PrintDocumentAdapter? = null
  private var signal: CancellationSignal? = null
  private var printing = false
  private var descriptor: ParcelFileDescriptor? = null
  private val handler = Handler(Looper.getMainLooper())
  private val timeout = Runnable { fail("PDF rendering timed out") }

  fun render(html: String, result: MethodChannel.Result) {
    if (completion != null) { result.error("busy", "PDF renderer busy", null); return }
    if (html.length > 64 * 1024 * 1024) { result.error("too-large", "PDF HTML too large", null); return }
    completion = result
    printing = false
    signal = CancellationSignal()
    val web = WebView(activity)
    view = web
    web.settings.javaScriptEnabled = true
    val density = activity.resources.displayMetrics.density
    val width = (794 * density).toInt()
    val height = (1123 * density).toInt()
    (activity.window.decorView as ViewGroup).addView(web, ViewGroup.LayoutParams(width, height))
    web.translationX = -10000f
    web.measure(android.view.View.MeasureSpec.makeMeasureSpec(width, android.view.View.MeasureSpec.EXACTLY), android.view.View.MeasureSpec.makeMeasureSpec(height, android.view.View.MeasureSpec.EXACTLY))
    web.layout(0, 0, width, height)
    web.webViewClient = object : WebViewClient() {
      override fun onPageFinished(webView: WebView, url: String) {
        web.evaluateJavascript("""window.markerPdfReady=false;window.markerPdfError=false;document.fonts.ready.then(()=>Promise.all(Array.from(document.images).map(i=>i.decode()))).then(()=>window.markerPdfReady=true).catch(()=>window.markerPdfError=true);""", null)
        poll(web)
      }
    }
    web.loadDataWithBaseURL(null, html, "text/html", "UTF-8", null)
    handler.postDelayed(timeout, 90000)
  }
  private fun poll(web: WebView) {
    if (completion == null || view !== web) return
    web.evaluateJavascript("window.markerPdfError?'error':(window.markerPdfReady?'ready':'wait')") { state ->
      if (completion == null || view !== web || printing) return@evaluateJavascript
      when (state) {
        "\"ready\"" -> print(web)
        "\"error\"" -> fail("Image or font could not be loaded")
        else -> handler.postDelayed({ poll(web) }, 100)
      }
    }
  }
  private fun print(web: WebView) {
    try {
      printing = true
      val adapter = web.createPrintDocumentAdapter("Marker")
      this.adapter = adapter
      val attributes = PrintAttributes.Builder().setMediaSize(PrintAttributes.MediaSize.ISO_A4)
        .setResolution(PrintAttributes.Resolution("pdf", "PDF", 300, 300))
        // CSS @page owns the 18 mm margins; do not apply a second native inset.
        .setMinMargins(PrintAttributes.Margins.NO_MARGINS).build()
      adapter.onLayout(null, attributes, signal!!, object : android.print.MarkerPrintCallbacks.Layout() {
        override fun onLayoutFinished(info: PrintDocumentInfo, changed: Boolean) {
          if (completion == null) return
          try {
            val file = File.createTempFile("marker-pdf-", ".pdf", activity.cacheDir)
            output = file
            val fd = ParcelFileDescriptor.open(file, ParcelFileDescriptor.MODE_READ_WRITE or ParcelFileDescriptor.MODE_TRUNCATE)
            descriptor = fd
            adapter.onWrite(arrayOf(PageRange.ALL_PAGES), fd, signal!!, object : android.print.MarkerPrintCallbacks.Write() {
              override fun onWriteFinished(pages: Array<PageRange>) {
                if (completion == null) return
                try {
                  descriptor?.close(); descriptor = null
                  if (file.length() == 0L || file.length() > 256L * 1024 * 1024) { fail("Invalid PDF size"); return }
                  val bytes = file.readBytes()
                  val callback = completion; cleanup(); callback?.success(bytes)
                } catch (error: Exception) { fail(error.message ?: "PDF write failed") }
              }
              override fun onWriteFailed(error: CharSequence?) { fail(error?.toString() ?: "PDF write failed") }
              override fun onWriteCancelled() { fail("PDF write cancelled") }
            })
          } catch (error: Exception) { fail(error.message ?: "Cannot create PDF file") }
        }
        override fun onLayoutFailed(error: CharSequence?) { fail(error?.toString() ?: "PDF layout failed") }
        override fun onLayoutCancelled() { fail("PDF layout cancelled") }
      }, null)
    } catch (error: Exception) { fail(error.message ?: "PDF rendering failed") }
  }
  fun cancel() { if (completion != null) fail("PDF cancelled") }
  private fun fail(message: String) { val callback = completion; cleanup(); callback?.error("pdf-failed", message, null) }
  private fun cleanup() {
    completion = null; handler.removeCallbacksAndMessages(null)
    signal?.cancel(); signal = null
    adapter?.onFinish(); adapter = null
    try { descriptor?.close() } catch (_: Exception) {}
    descriptor = null; output?.delete(); output = null
    view?.let { (it.parent as? ViewGroup)?.removeView(it); it.stopLoading(); it.destroy() }; view = null
  }
}
