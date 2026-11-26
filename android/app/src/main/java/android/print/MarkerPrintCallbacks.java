package android.print;

/** Bridge for Android's package-private print callback constructors. */
public final class MarkerPrintCallbacks {
    private MarkerPrintCallbacks() {}
    public abstract static class Layout extends PrintDocumentAdapter.LayoutResultCallback {
        public Layout() { super(); }
    }
    public abstract static class Write extends PrintDocumentAdapter.WriteResultCallback {
        public Write() { super(); }
    }
}
