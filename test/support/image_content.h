#ifndef MARKER_TEST_IMAGE_CONTENT_H_
#define MARKER_TEST_IMAGE_CONTENT_H_
#include <cstdlib>
#include <cstddef>

// Compare with the empty padding at (0, 0); compression size says nothing about
// whether a small state diagram actually rendered. Supports RGB and RGBA.
inline std::size_t ImageContentPixels(const unsigned char* pixels, int width,
    int height, int stride, int channels) {
  if (!pixels || width < 1 || height < 1 || (channels != 3 && channels != 4)) return 0;
  std::size_t content = 0;
  for (int y = 0; y < height; ++y) {
    for (int x = 0; x < width; ++x) {
      const auto* pixel = pixels + y * stride + x * channels;
      if (channels == 4 && pixel[3] < 32) continue;
      int difference = 0;
      for (int c = 0; c < channels; ++c) {
        difference += std::abs(static_cast<int>(pixel[c]) - pixels[c]);
      }
      if (difference > 24) ++content;
    }
  }
  return content;
}
#endif
