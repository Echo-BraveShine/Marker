#include "../linux/runner/mermaid_renderer.h"
#include <gtk/gtk.h>
#include <cstring>
int main(int argc, char** argv) {
  gtk_init(&argc, &argv);
  if (argc != 3) return 2;
  g_autofree gchar* html = nullptr;
  if (!g_file_get_contents(argv[1], &html, nullptr, nullptr)) return 3;
  const bool pdf = g_str_has_suffix(argv[2], ".pdf");
  GMainLoop* loop = g_main_loop_new(nullptr, FALSE);
  bool passed = false;
  render_document_export(html, pdf ? 794 : 1280, pdf, [&](GBytes* bytes, const gchar* error) {
    if (error) g_printerr("FAILED: %s\n", error);
    else {
      gsize length = 0;
      const auto* data = static_cast<const gchar*>(g_bytes_get_data(bytes, &length));
      passed = length > 1000 && (pdf ? std::memcmp(data, "%PDF-", 5) == 0 : static_cast<unsigned char>(data[0]) == 137) &&
          g_file_set_contents(argv[2], data, length, nullptr);
      g_print("Document %s: %zu bytes %s\n", pdf ? "PDF" : "PNG", length, passed ? "passed" : "FAILED");
    }
    g_main_loop_quit(loop);
  });
  g_main_loop_run(loop);g_main_loop_unref(loop);
  return passed ? 0 : 1;
}
