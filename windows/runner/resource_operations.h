#ifndef MARKER_RESOURCE_OPERATIONS_H_
#define MARKER_RESOURCE_OPERATIONS_H_
#include <windows.h>
#include <shlobj.h>
#include <atomic>
#include <string>

// Cancel any shell plan which would permanently delete instead of recycling.
class RecycleOnlySink final : public IFileOperationProgressSink {
 public:
  HRESULT STDMETHODCALLTYPE QueryInterface(REFIID iid, void** out) override {
    if (!out) return E_POINTER;
    *out = nullptr;
    if (IsEqualIID(iid, IID_IUnknown) || IsEqualIID(iid, IID_IFileOperationProgressSink)) {
      *out = static_cast<IFileOperationProgressSink*>(this); AddRef(); return S_OK;
    }
    return E_NOINTERFACE;
  }
  ULONG STDMETHODCALLTYPE AddRef() override { return ++references_; }
  ULONG STDMETHODCALLTYPE Release() override { const ULONG count = --references_; if (!count) delete this; return count; }
  HRESULT STDMETHODCALLTYPE StartOperations() override { return S_OK; }
  HRESULT STDMETHODCALLTYPE FinishOperations(HRESULT result) override { completed = result; return S_OK; }
  HRESULT STDMETHODCALLTYPE PreRenameItem(DWORD, IShellItem*, LPCWSTR) override { return E_ABORT; }
  HRESULT STDMETHODCALLTYPE PostRenameItem(DWORD, IShellItem*, LPCWSTR, HRESULT, IShellItem*) override { return S_OK; }
  HRESULT STDMETHODCALLTYPE PreMoveItem(DWORD, IShellItem*, IShellItem*, LPCWSTR) override { return E_ABORT; }
  HRESULT STDMETHODCALLTYPE PostMoveItem(DWORD, IShellItem*, IShellItem*, LPCWSTR, HRESULT, IShellItem*) override { return S_OK; }
  HRESULT STDMETHODCALLTYPE PreCopyItem(DWORD, IShellItem*, IShellItem*, LPCWSTR) override { return E_ABORT; }
  HRESULT STDMETHODCALLTYPE PostCopyItem(DWORD, IShellItem*, IShellItem*, LPCWSTR, HRESULT, IShellItem*) override { return S_OK; }
  HRESULT STDMETHODCALLTYPE PreDeleteItem(DWORD flags, IShellItem*) override {
    return (flags & TSF_DELETE_RECYCLE_IF_POSSIBLE) ? S_OK : E_ABORT;
  }
  HRESULT STDMETHODCALLTYPE PostDeleteItem(DWORD, IShellItem*, HRESULT result, IShellItem*) override { completed = result; return S_OK; }
  HRESULT STDMETHODCALLTYPE PreNewItem(DWORD, IShellItem*, LPCWSTR) override { return E_ABORT; }
  HRESULT STDMETHODCALLTYPE PostNewItem(DWORD, IShellItem*, LPCWSTR, LPCWSTR, DWORD, HRESULT, IShellItem*) override { return S_OK; }
  HRESULT STDMETHODCALLTYPE UpdateProgress(UINT, UINT) override { return S_OK; }
  HRESULT STDMETHODCALLTYPE ResetTimer() override { return S_OK; }
  HRESULT STDMETHODCALLTYPE PauseTimer() override { return S_OK; }
  HRESULT STDMETHODCALLTYPE ResumeTimer() override { return S_OK; }
  HRESULT completed = E_FAIL;
 private:
  std::atomic<ULONG> references_{1};
};
inline std::wstring ResourceWidePath(const std::string& path) {
  const int length = MultiByteToWideChar(CP_UTF8, MB_ERR_INVALID_CHARS, path.data(), static_cast<int>(path.size()), nullptr, 0);
  if (!length) return {};
  std::wstring result(length, L'\0');
  MultiByteToWideChar(CP_UTF8, MB_ERR_INVALID_CHARS, path.data(), static_cast<int>(path.size()), result.data(), length);
  return result;
}
inline HRESULT RecycleResource(const std::wstring& path, HWND window) {
  IShellItem* item = nullptr;
  HRESULT status = SHCreateItemFromParsingName(path.c_str(), nullptr, IID_PPV_ARGS(&item));
  if (FAILED(status)) return status;
  IFileOperation* operation = nullptr;
  status = CoCreateInstance(CLSID_FileOperation, nullptr, CLSCTX_INPROC_SERVER, IID_PPV_ARGS(&operation));
  if (SUCCEEDED(status)) {
    auto* sink = new RecycleOnlySink();
    operation->SetOwnerWindow(window);
    status = operation->SetOperationFlags(FOF_NOERRORUI | FOF_NOCONFIRMATION | FOF_SILENT | FOF_ALLOWUNDO |
        FOFX_RECYCLEONDELETE | FOFX_EARLYFAILURE | FOFX_ADDUNDORECORD);
    if (SUCCEEDED(status)) status = operation->DeleteItem(item, sink);
    if (SUCCEEDED(status)) status = operation->PerformOperations();
    BOOL aborted = TRUE;
    operation->GetAnyOperationsAborted(&aborted);
    if (SUCCEEDED(status)) status = aborted ? E_ABORT : sink->completed;
    operation->Release(); sink->Release();
  }
  item->Release(); return status;
}
inline HRESULT RevealResource(const std::wstring& path) {
  PIDLIST_ABSOLUTE item = nullptr;
  HRESULT status = SHParseDisplayName(path.c_str(), nullptr, &item, 0, nullptr);
  if (SUCCEEDED(status)) { status = SHOpenFolderAndSelectItems(item, 0, nullptr, 0); CoTaskMemFree(item); }
  return status;
}
#endif
