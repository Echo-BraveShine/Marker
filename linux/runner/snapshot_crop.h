#ifndef MARKER_SNAPSHOT_CROP_H_
#define MARKER_SNAPSHOT_CROP_H_
#include <cairo.h>
#include <algorithm>

// Return an owned CSS-pixel crop. The input is a WebKit viewport snapshot,
// whose width may exceed the document and whose pixel density may exceed 1.
inline cairo_surface_t* CropSnapshot(cairo_surface_t* source,
    int viewport_width, int width, int height) {
  const double density = static_cast<double>(cairo_image_surface_get_width(source)) /
      std::max(1, viewport_width);
  auto* cropped = cairo_image_surface_create(CAIRO_FORMAT_ARGB32, width, height);
  auto* context = cairo_create(cropped);
  double scale_x = 1, scale_y = 1;
  cairo_surface_get_device_scale(source, &scale_x, &scale_y);
  cairo_surface_set_device_scale(source, 1, 1);
  cairo_scale(context, 1 / density, 1 / density);
  cairo_set_source_surface(context, source, 0, 0);
  cairo_pattern_set_extend(cairo_get_source(context), CAIRO_EXTEND_PAD);
  cairo_pattern_set_filter(cairo_get_source(context), CAIRO_FILTER_BEST);
  cairo_paint(context);
  cairo_destroy(context);
  cairo_surface_set_device_scale(source, scale_x, scale_y);
  return cropped;
}
#endif
