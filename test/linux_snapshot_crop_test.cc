#include "../linux/runner/snapshot_crop.h"
#include "support/image_content.h"
#include <cassert>
#include <cstdio>
#include <vector>

int main() {
  for (const int density : {1, 2}) {
    auto* viewport = cairo_image_surface_create(CAIRO_FORMAT_ARGB32,
        960 * density, 400 * density);
    cairo_surface_set_device_scale(viewport, density, density);
    auto* context = cairo_create(viewport);
    cairo_set_source_rgb(context, .17, .17, .18);
    cairo_paint(context);
    cairo_set_source_rgb(context, 1, 1, 1);
    cairo_rectangle(context, 12, 12, 80, 200);
    cairo_fill(context);
    cairo_destroy(context);
    auto* crop = CropSnapshot(viewport, 960, 120, 240);
    cairo_surface_flush(crop);
    assert(cairo_image_surface_get_width(crop) == 120);
    assert(cairo_image_surface_get_height(crop) == 240);
    // The 80 x 200 CSS-pixel diagram must keep its size, even in a wider view.
    const auto ink = ImageContentPixels(cairo_image_surface_get_data(crop),
        120, 240, cairo_image_surface_get_stride(crop), 4);
    std::printf("%dx crop: %zu content pixels\n", density, ink);
    // Resampling at 2x can add an antialiased one-pixel edge.
    assert(ink >= 80 * 200 && ink <= 82 * 202);
    cairo_surface_destroy(crop);
    cairo_surface_destroy(viewport);
  }
  std::vector<unsigned char> blank(120 * 240 * 4, 0);
  assert(ImageContentPixels(blank.data(), 120, 240, 120 * 4, 4) == 0);
  std::fill(blank.begin(), blank.end(), 255);
  assert(ImageContentPixels(blank.data(), 120, 240, 120 * 4, 4) == 0);
  std::puts("CSS snapshot crop and blank-image checks passed at 1x and 2x");
}
