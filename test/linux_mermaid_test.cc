#include "../linux/runner/mermaid_renderer.h"
#include <gtk/gtk.h>
#include <cstdio>
#include <cstring>

int main(int argc, char** argv) {
  gtk_init(&argc, &argv);
  if (argc != 3) return 2;
  g_autofree gchar* html = nullptr;
  if (!g_file_get_contents(argv[1], &html, nullptr, nullptr)) return 3;
  GMainLoop* loop = g_main_loop_new(nullptr, FALSE);
  bool passed = false;
  const bool invalid = g_str_has_suffix(argv[1], "invalid.html");
  render_mermaid(html, 960, [&](GBytes* png, const gchar* error) {
    if (error) {
      g_print("%s: %s\n", invalid ? "EXPECTED ERROR" : "FAILED", error);
      passed = invalid;
    } else if (png && !invalid) {
      gsize size = 0;
      const auto* bytes = static_cast<const gchar*>(g_bytes_get_data(png, &size));
      const unsigned char magic[] = {137, 80, 78, 71, 13, 10, 26, 10};
      passed = size > 1000 && std::memcmp(bytes, magic, sizeof(magic)) == 0 &&
          g_file_set_contents(argv[2], bytes, size, nullptr);
      g_print("PNG %zu bytes: %s\n", size, passed ? "passed" : "FAILED");
    }
    g_main_loop_quit(loop);
  });
  g_main_loop_run(loop);
  g_main_loop_unref(loop);
  return passed ? 0 : 1;
}
