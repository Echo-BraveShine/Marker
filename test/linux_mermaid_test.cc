#include "../linux/runner/mermaid_renderer.h"
#include "support/image_content.h"
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
      // Preserve even a failed image for CI inspection. Validate decoded pixels
      // rather than a compression-size threshold, which rejects small diagrams.
      const bool saved = g_file_set_contents(argv[2], bytes, size, nullptr);
      g_autoptr(GdkPixbuf) image = saved ? gdk_pixbuf_new_from_file(argv[2], nullptr) : nullptr;
      const int width = image ? gdk_pixbuf_get_width(image) : 0;
      const int height = image ? gdk_pixbuf_get_height(image) : 0;
      const auto content = image ? ImageContentPixels(gdk_pixbuf_get_pixels(image),
          width, height, gdk_pixbuf_get_rowstride(image), gdk_pixbuf_get_n_channels(image)) : 0;
      passed = size >= sizeof(magic) && std::memcmp(bytes, magic, sizeof(magic)) == 0 &&
          width >= 32 && height >= 32 && content >= 64;
      if (g_str_has_suffix(argv[1], "snapshot-narrow.html")) {
        passed = passed && width == 120 && height == 240 &&
            content >= 80 * 200 && content <= 82 * 202;
      }
      g_print("PNG %zu bytes, %dx%d, %zu content pixels: %s\n",
          size, width, height, content, passed ? "passed" : "FAILED");
    }
    g_main_loop_quit(loop);
  });
  g_main_loop_run(loop);
  g_main_loop_unref(loop);
  return passed ? 0 : 1;
}
