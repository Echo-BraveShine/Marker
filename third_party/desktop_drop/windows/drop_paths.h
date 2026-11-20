#ifndef DESKTOP_DROP_PATHS_H_
#define DESKTOP_DROP_PATHS_H_
#include <windows.h>
#include <shellapi.h>
#include <string>
#include <vector>
#include <utility>

inline std::vector<std::string> ReadDroppedPaths(HDROP drop) {
  std::vector<std::string> paths;
  const UINT count = DragQueryFileW(drop, 0xFFFFFFFF, nullptr, 0);
  for (UINT index = 0; index < count; ++index) {
    const UINT length = DragQueryFileW(drop, index, nullptr, 0);
    if (length == 0) continue;
    std::vector<wchar_t> buffer(static_cast<size_t>(length) + 1);
    if (DragQueryFileW(drop, index, buffer.data(), length + 1) != length) continue;
    const int bytes = WideCharToMultiByte(CP_UTF8, WC_ERR_INVALID_CHARS,
        buffer.data(), static_cast<int>(length), nullptr, 0, nullptr, nullptr);
    if (bytes <= 0) continue;
    std::string path(static_cast<size_t>(bytes), '\0');
    if (WideCharToMultiByte(CP_UTF8, WC_ERR_INVALID_CHARS, buffer.data(),
        static_cast<int>(length), &path[0], bytes, nullptr, nullptr) == bytes) {
      paths.push_back(std::move(path));
    }
  }
  return paths;
}
#endif
