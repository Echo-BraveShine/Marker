# WebView JavaScript bridges must retain annotated entry points.
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# Print callbacks must retain their package to access Android's constructors.
-keep class android.print.MarkerPrintCallbacks { *; }
-keep class android.print.MarkerPrintCallbacks$* { *; }
