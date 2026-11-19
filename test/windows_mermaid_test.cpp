// Native WebView2 regression probe: load a >2 MB offline page from a file URL.
#include <windows.h>
#include <shlwapi.h>
#include <wrl.h>
#include <WebView2.h>
#include <cstdio>
#include <string>
using Microsoft::WRL::Callback;
using Microsoft::WRL::ComPtr;
static ComPtr<ICoreWebView2Controller> controller;
static ComPtr<ICoreWebView2> view;
static HWND window;
static std::wstring output;
static bool polling = false;
static bool completed = false;
static bool invalid = false;
static void Fail(const char* operation, HRESULT result) {
  std::printf("FAILED %s: 0x%08lx\n", operation, static_cast<unsigned long>(result));
  completed = true;
  PostQuitMessage(1);
}
static void Capture() {
  completed = true;
  KillTimer(window, 1);
  ComPtr<IStream> stream;
  HRESULT result = SHCreateStreamOnFileEx(output.c_str(), STGM_CREATE | STGM_READWRITE | STGM_SHARE_EXCLUSIVE,
      FILE_ATTRIBUTE_NORMAL, TRUE, nullptr, &stream);
  if (FAILED(result)) { Fail("PNG stream", result); return; }
  result = view->CapturePreview(COREWEBVIEW2_CAPTURE_PREVIEW_IMAGE_FORMAT_PNG, stream.Get(),
      Callback<ICoreWebView2CapturePreviewCompletedHandler>([stream](HRESULT status) -> HRESULT {
        if (FAILED(status)) { Fail("CapturePreview", status); return S_OK; }
        std::puts("Local-file offline Mermaid rendered and PNG captured");
        PostQuitMessage(0);
        return S_OK;
      }).Get());
  if (FAILED(result)) Fail("CapturePreview start", result);
}
static void CALLBACK Poll(HWND, UINT, UINT_PTR id, DWORD) {
  if (id == 2) { Fail("timeout", E_ABORT); return; }
  if (polling || completed) return;
  polling = true;
  view->ExecuteScript(invalid ? L"document.getElementById('diagram').textContent.startsWith('Mermaid: ')"
      : L"document.querySelector('#diagram svg') ? true : document.getElementById('diagram').textContent",
      Callback<ICoreWebView2ExecuteScriptCompletedHandler>([](HRESULT status, LPCWSTR json) -> HRESULT {
        polling = false;
        if (FAILED(status)) { Fail("ExecuteScript", status); return S_OK; }
        if (json && std::wstring(json).find(L"\"Mermaid:") == 0 && !invalid) {
          std::wprintf(L"JavaScript: %ls\n", json);
          Fail("Mermaid JavaScript", E_FAIL);
          return S_OK;
        }
        if (json && std::wstring(json) == L"true") {
          if (invalid) { completed = true; std::puts("Invalid syntax error displayed"); PostQuitMessage(0); }
          else Capture();
        }
        return S_OK;
      }).Get());
}
int wmain(int argc, wchar_t** argv) {
  if (argc != 3) return 2;
  if (FAILED(CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED))) return 3;
  output = argv[2];
  invalid = std::wstring(argv[1]).find(L"invalid.html") != std::wstring::npos;
  window = CreateWindowExW(WS_EX_TOOLWINDOW, L"STATIC", L"Marker Mermaid QA", WS_POPUP,
      100, 100, 900, 600, nullptr, nullptr, GetModuleHandle(nullptr), nullptr);
  ShowWindow(window, SW_SHOWNOACTIVATE);
  wchar_t uri[32768]; DWORD length = 32768;
  HRESULT result = UrlCreateFromPathW(argv[1], uri, &length, 0);
  if (FAILED(result)) return 4;
  const std::wstring url(uri);
  wchar_t temp[32768]; GetTempPathW(32768, temp);
  const std::wstring profile = std::wstring(temp) + L"Marker-Mermaid-WebView2-QA";
  SetTimer(window, 2, 60000, Poll);
  result = CreateCoreWebView2EnvironmentWithOptions(nullptr, profile.c_str(), nullptr,
      Callback<ICoreWebView2CreateCoreWebView2EnvironmentCompletedHandler>([url](HRESULT status, ICoreWebView2Environment* environment) -> HRESULT {
        if (FAILED(status)) { Fail("Environment", status); return S_OK; }
        return environment->CreateCoreWebView2Controller(window,
          Callback<ICoreWebView2CreateCoreWebView2ControllerCompletedHandler>([url](HRESULT created, ICoreWebView2Controller* value) -> HRESULT {
            if (FAILED(created)) { Fail("Controller", created); return S_OK; }
            controller = value;
            controller->get_CoreWebView2(&view);
            RECT bounds{0, 0, 900, 600}; controller->put_Bounds(bounds);
            EventRegistrationToken token;
            view->add_NavigationCompleted(Callback<ICoreWebView2NavigationCompletedEventHandler>(
              [](ICoreWebView2*, ICoreWebView2NavigationCompletedEventArgs* args) -> HRESULT {
                BOOL success = FALSE; args->get_IsSuccess(&success);
                if (!success) { Fail("Navigation", E_FAIL); return S_OK; }
                SetTimer(window, 1, 100, Poll);
                return S_OK;
              }).Get(), &token);
            return view->Navigate(url.c_str());
          }).Get());
      }).Get());
  if (FAILED(result)) return 5;
  MSG message;
  while (GetMessageW(&message, nullptr, 0, 0) > 0) { TranslateMessage(&message); DispatchMessageW(&message); }
  controller.Reset(); view.Reset(); DestroyWindow(window); CoUninitialize();
  return static_cast<int>(message.wParam);
}
