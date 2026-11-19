// Run on Windows with the light and dark .ico paths as arguments.
#include <windows.h>
#include <cstdio>
#include <initializer_list>
int wmain(int argc, wchar_t** argv) {
  if (argc != 3) return 2;
  for (int variant = 1; variant <= 2; ++variant) {
    for (const int size : {16, 20, 24, 32, 40, 48, 64, 96, 128, 256}) {
      HICON icon = static_cast<HICON>(LoadImageW(nullptr, argv[variant], IMAGE_ICON,
          size, size, LR_LOADFROMFILE));
      ICONINFO info{};
      if (!icon || !GetIconInfo(icon, &info)) return 3;
      BITMAP bitmap{};
      const int result = GetObjectW(info.hbmColor, sizeof(bitmap), &bitmap);
      const bool valid = result == static_cast<int>(sizeof(bitmap)) &&
          bitmap.bmWidth == size && bitmap.bmHeight == size;
      if (info.hbmColor) DeleteObject(info.hbmColor);
      if (info.hbmMask) DeleteObject(info.hbmMask);
      DestroyIcon(icon);
      if (!valid) { std::printf("FAILED variant=%d size=%d\n", variant, size); return 4; }
    }
  }
  std::puts("Light/dark native ICO frames at 16..256px (10 sizes each): passed");
  return 0;
}
