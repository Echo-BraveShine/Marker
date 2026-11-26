package dev.ekko.marker

import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
  private val incomingFiles by lazy { MarkerIncomingFiles(this) }
  private var immersiveEnabled = false
  private var keyboardVisible = false
  private val layoutListener = android.view.ViewTreeObserver.OnGlobalLayoutListener {
    val decor = window.decorView
    val visible = if (android.os.Build.VERSION.SDK_INT >= 30) {
      decor.rootWindowInsets?.isVisible(android.view.WindowInsets.Type.ime()) == true
    } else {
      val frame = android.graphics.Rect()
      decor.getWindowVisibleDisplayFrame(frame)
      decor.rootView.height - frame.bottom > decor.rootView.height * 0.15
    }
    val keyboardClosed = keyboardVisible && !visible
    keyboardVisible = visible
    if (keyboardClosed && immersiveEnabled) hideSystemBars()
  }
  override fun onCreate(savedInstanceState: android.os.Bundle?) {
    // Export snapshots may draw tiles outside the visible WebView viewport.
    android.webkit.WebView.enableSlowWholeDocumentDraw()
    super.onCreate(savedInstanceState)
    incomingFiles.receive(intent)
    window.decorView.viewTreeObserver.addOnGlobalLayoutListener(layoutListener)
  }
  override fun onNewIntent(intent: android.content.Intent) {
    super.onNewIntent(intent)
    setIntent(intent)
    incomingFiles.receive(intent)
  }
  override fun onWindowFocusChanged(hasFocus: Boolean) {
    super.onWindowFocusChanged(hasFocus)
    if (hasFocus && immersiveEnabled && !keyboardVisible) hideSystemBars()
  }
  @Suppress("DEPRECATION")
  private fun hideSystemBars() {
    if (android.os.Build.VERSION.SDK_INT >= 30) {
      window.insetsController?.apply {
        systemBarsBehavior = android.view.WindowInsetsController.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE
        hide(android.view.WindowInsets.Type.systemBars())
      }
    } else {
      window.decorView.systemUiVisibility =
        android.view.View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY or
        android.view.View.SYSTEM_UI_FLAG_FULLSCREEN or
        android.view.View.SYSTEM_UI_FLAG_HIDE_NAVIGATION or
        android.view.View.SYSTEM_UI_FLAG_LAYOUT_STABLE or
        android.view.View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN or
        android.view.View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
    }
  }
  private val pdfExporter by lazy { MarkerMobilePdfExporter(this) }
  override fun onDestroy() {
    window.decorView.viewTreeObserver.removeOnGlobalLayoutListener(layoutListener)
    pdfExporter.cancel()
    incomingFiles.detach()
    super.onDestroy()
  }
  override fun configureFlutterEngine(flutterEngine: io.flutter.embedding.engine.FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    incomingFiles.attach(flutterEngine.dartExecutor.binaryMessenger)
    io.flutter.plugin.common.MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "marker/mobilePdf")
      .setMethodCallHandler { call, result ->
        when (call.method) {
          "cancel" -> { pdfExporter.cancel(); result.success(null) }
          "render" -> { val html = call.argument<String>("html"); if (html == null) result.error("invalid", "Missing HTML", null) else pdfExporter.render(html, result) }
          else -> result.notImplemented()
        }
      }
    io.flutter.plugin.common.MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "marker/display")
      .setMethodCallHandler { call, result ->
        if (call.method == "enableImmersive") {
          immersiveEnabled = true
          hideSystemBars()
          result.success(null)
        } else if (call.method != "cutoutSide") { result.notImplemented() }
        else if (android.os.Build.VERSION.SDK_INT >= 28) {
          val cutout = window.decorView.rootWindowInsets?.displayCutout
          result.success(when {
            cutout == null -> "none"
            !cutout.boundingRectLeft.isEmpty -> "left"
            !cutout.boundingRectRight.isEmpty -> "right"
            else -> "none"
          })
        } else { result.success("none") }
      }
  }
}
