#include "flutter_window.h"

#include <optional>
#include <flutter/standard_method_codec.h>
#include <shobjidl.h>
#include <initguid.h>
#include <propkey.h>
#include <propvarutil.h>
#include "resource.h"

#include "flutter/generated_plugin_registrant.h"

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  // The size here must match the window dimensions to avoid unnecessary surface
  // creation / destruction in the startup path.
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }
  RegisterPlugins(flutter_controller_->engine());
  SetChildContent(flutter_controller_->view()->GetNativeWindow());

  appearance_channel_ = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
      flutter_controller_->engine()->messenger(), "marker/appearance",
      &flutter::StandardMethodCodec::GetInstance());
  appearance_channel_->SetMethodCallHandler([this](const auto& call, auto result) {
    if (call.method_name() != "setDark") { result->NotImplemented(); return; }
    const auto* dark = call.arguments() ? std::get_if<bool>(call.arguments()) : nullptr;
    if (!dark) { result->Error("invalid-arguments", "Expected dark appearance boolean"); return; }
    if (!ApplyAppearanceIcon(*dark)) { result->Error("missing-icon", "Appearance icon resource not found"); return; }
    result->Success();
  });

  // Dart configures the size/theme and reveals the window after its first frame.
  flutter_controller_->ForceRedraw();

  return true;
}

bool FlutterWindow::ApplyAppearanceIcon(bool dark) {
  const int resource = dark ? IDI_APP_ICON_DARK : IDI_APP_ICON;
  using GetWindowDpi = UINT(WINAPI*)(HWND);
  const auto get_dpi = reinterpret_cast<GetWindowDpi>(
      GetProcAddress(GetModuleHandleW(L"user32.dll"), "GetDpiForWindow"));
  const UINT dpi = get_dpi ? get_dpi(GetHandle()) : 96;
  using GetMetricsDpi = int(WINAPI*)(int, UINT);
  const auto metrics = reinterpret_cast<GetMetricsDpi>(
      GetProcAddress(GetModuleHandleW(L"user32.dll"), "GetSystemMetricsForDpi"));
  const UINT effective_dpi = dpi ? dpi : 96;
  const int large_size = metrics ? metrics(SM_CXICON, effective_dpi) : MulDiv(32, effective_dpi, 96);
  const int small_size = metrics ? metrics(SM_CXSMICON, effective_dpi) : MulDiv(16, effective_dpi, 96);
  HICON large_icon = static_cast<HICON>(LoadImageW(GetModuleHandleW(nullptr), MAKEINTRESOURCEW(resource),
      IMAGE_ICON, large_size, large_size, LR_DEFAULTCOLOR));
  HICON small_icon = static_cast<HICON>(LoadImageW(GetModuleHandleW(nullptr), MAKEINTRESOURCEW(resource),
      IMAGE_ICON, small_size, small_size, LR_DEFAULTCOLOR));
  if (!large_icon || !small_icon) {
    if (large_icon) DestroyIcon(large_icon);
    if (small_icon) DestroyIcon(small_icon);
    return false;
  }
  // LR_SHARED can return a cached frame of the wrong size. Own DPI-specific icons.
  HICON previous_large = appearance_large_icon_;
  HICON previous_small = appearance_small_icon_;
  appearance_large_icon_ = large_icon;
  appearance_small_icon_ = small_icon;
  dark_icon_ = dark;
  SendMessageW(GetHandle(), WM_SETICON, ICON_BIG, reinterpret_cast<LPARAM>(large_icon));
  SendMessageW(GetHandle(), WM_SETICON, ICON_SMALL, reinterpret_cast<LPARAM>(small_icon));
  if (previous_large) DestroyIcon(previous_large);
  if (previous_small) DestroyIcon(previous_small);
  // Keep the existing AppUserModelID; never break taskbar grouping when changing theme.
  IPropertyStore* properties = nullptr;
  if (SUCCEEDED(SHGetPropertyStoreForWindow(GetHandle(), IID_PPV_ARGS(&properties)))) {
    wchar_t path[32768];
    const DWORD length = GetModuleFileNameW(nullptr, path, 32768);
    if (length > 0 && length < 32768) {
      const std::wstring exe(path, length);
      const auto set = [properties](const PROPERTYKEY& key, const std::wstring& text) {
        PROPVARIANT value;
        if (SUCCEEDED(InitPropVariantFromString(text.c_str(), &value))) {
          properties->SetValue(key, value);
          PropVariantClear(&value);
        }
      };
      set(PKEY_AppUserModel_RelaunchCommand, L"\"" + exe + L"\"");
      set(PKEY_AppUserModel_RelaunchDisplayNameResource, L"@" + exe + L",-" + std::to_wstring(IDS_APP_NAME));
      set(PKEY_AppUserModel_RelaunchIconResource, exe + L",-" + std::to_wstring(resource));
      properties->Commit();
    }
    properties->Release();
  }
  return true;
}

void FlutterWindow::OnDestroy() {
  if (appearance_large_icon_) { DestroyIcon(appearance_large_icon_); appearance_large_icon_ = nullptr; }
  if (appearance_small_icon_) { DestroyIcon(appearance_small_icon_); appearance_small_icon_ = nullptr; }
  appearance_channel_.reset();
  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  if (message == WM_DPICHANGED) { ApplyAppearanceIcon(dark_icon_); }
  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (flutter_controller_) {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      return *result;
    }
  }

  switch (message) {
    case WM_FONTCHANGE:
      flutter_controller_->engine()->ReloadSystemFonts();
      break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}
