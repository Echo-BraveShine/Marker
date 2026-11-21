#include "../third_party/desktop_drop/windows/drop_paths.h"
#include <shlobj.h>
#include <algorithm>
#include <cassert>
#include <cstdio>

int main() {
  const std::vector<std::wstring> names = {
      L"C:\\图片\\中文 空格 #%.png",
      L"C:\\" + std::wstring(180, L'a') + L"\\" + std::wstring(150, L'b') + L"\\图片.png",
      L"\\\\server\\share\\中文.png"};
  size_t characters = 1;
  for (const auto& name : names) characters += name.size() + 1;
  const auto memory = GlobalAlloc(GHND, sizeof(DROPFILES) + characters * sizeof(wchar_t));
  assert(memory);
  auto* header = static_cast<DROPFILES*>(GlobalLock(memory));
  assert(header);
  header->pFiles = static_cast<DWORD>(sizeof(DROPFILES));
  header->fWide = TRUE;
  auto* next = reinterpret_cast<wchar_t*>(header + 1);
  for (const auto& name : names) {
    next = std::copy(name.begin(), name.end(), next);
    *next++ = L'\0';
  }
  *next = L'\0';
  GlobalUnlock(memory);
  const auto paths = ReadDroppedPaths(reinterpret_cast<HDROP>(memory));
  assert(paths.size() == 3);
  assert(paths[0] == u8"C:\\图片\\中文 空格 #%.png");
  assert(paths[1] == "C:\\" + std::string(180, 'a') + "\\" + std::string(150, 'b') + u8"\\图片.png");
  assert(paths[2] == u8"\\\\server\\share\\中文.png");
  GlobalFree(memory);
  std::puts("Windows Unicode, long-path and UNC drop extraction passed");
}
