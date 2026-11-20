#include "include/desktop_drop/desktop_drop_plugin.h"

#include <windows.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <memory>
#include <iostream>
#include "drop_paths.h"

namespace {

    using FlutterMethodChannel = std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>>;


    class DesktopDropTarget : public IDropTarget {
    public:

        DesktopDropTarget(FlutterMethodChannel channel, HWND window_handle);

        HRESULT DragEnter(IDataObject *pDataObj, DWORD grfKeyState, POINTL pt, DWORD *pdwEffect) override;

        HRESULT DragOver(DWORD grfKeyState, POINTL pt, DWORD *pdwEffect) override;

        HRESULT DragLeave() override;

        HRESULT Drop(IDataObject *pDataObj, DWORD grfKeyState, POINTL pt, DWORD *pdwEffect) override;

        HRESULT QueryInterface(const IID &riid, void **ppvObject) override;

        ULONG AddRef() override;

        ULONG Release() override;

        virtual ~DesktopDropTarget();
        void Dispose();

    private:
        FlutterMethodChannel channel_;
        HWND window_handle_;
        LONG ref_count_;
        bool need_revoke_ole_initialize_;
        bool registered_ = false;
        bool accepts_files_ = false;
    };

    class DesktopDropPlugin : public flutter::Plugin {

    public:
        static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

        explicit DesktopDropPlugin(DesktopDropTarget *target);

        ~DesktopDropPlugin() override;

    private:

        DesktopDropTarget *target_;

    };

    // Take ownership of the initial COM reference. RegisterDragDrop keeps its
    // own reference until Dispose revokes the registration.
    DesktopDropPlugin::DesktopDropPlugin(DesktopDropTarget *target) : target_(target) {}

    DesktopDropPlugin::~DesktopDropPlugin() {
        target_->Dispose();
        target_->Release();
    }


    // static
    void DesktopDropPlugin::RegisterWithRegistrar(
            flutter::PluginRegistrarWindows *registrar) {
        auto channel =
                std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
                        registrar->messenger(), "desktop_drop",
                        &flutter::StandardMethodCodec::GetInstance());

        HWND hwnd = nullptr;
        if (registrar->GetView()) {
            hwnd = registrar->GetView()->GetNativeWindow();
        }

        if (hwnd == nullptr) {
            // no window, no drop.
            return;
        }

        channel->SetMethodCallHandler([](const auto &call, auto result) {
            result->NotImplemented();
        });

        auto drop_target = new DesktopDropTarget(std::move(channel), hwnd);

        auto plugin = std::make_unique<DesktopDropPlugin>(drop_target);

        registrar->AddPlugin(std::move(plugin));
    }


    DesktopDropTarget::DesktopDropTarget(FlutterMethodChannel channel, HWND window_handle) : channel_(
            std::move(channel)), window_handle_(window_handle), ref_count_(1), need_revoke_ole_initialize_(false) {
        const HRESULT ole = OleInitialize(nullptr);
        need_revoke_ole_initialize_ = SUCCEEDED(ole);
        const HRESULT ret = SUCCEEDED(ole) ? RegisterDragDrop(window_handle_, this) : ole;
        registered_ = SUCCEEDED(ret);

        if (ret != 0) {
            std::cout << "RegisterDragDrop failed: " << ret << std::endl;
        }
    }

    HRESULT DesktopDropTarget::DragEnter(IDataObject *pDataObj, DWORD grfKeyState, POINTL pt, DWORD *pdwEffect) {
        if (!pdwEffect) return E_POINTER;
        FORMATETC format = {CF_HDROP, nullptr, DVASPECT_CONTENT, -1, TYMED_HGLOBAL};
        accepts_files_ = pDataObj && pDataObj->QueryGetData(&format) == S_OK;
        *pdwEffect = accepts_files_ ? (*pdwEffect & DROPEFFECT_COPY) : DROPEFFECT_NONE;
        POINT point = {pt.x, pt.y};
        ScreenToClient(window_handle_, &point);
        channel_->InvokeMethod("entered", std::make_unique<flutter::EncodableValue>(
                flutter::EncodableList{
                        flutter::EncodableValue(double(point.x)),
                        flutter::EncodableValue(double(point.y))
                }
        ));
        return 0;
    }

    HRESULT DesktopDropTarget::DragOver(DWORD grfKeyState, POINTL pt, DWORD *pdwEffect) {
        if (!pdwEffect) return E_POINTER;
        *pdwEffect = accepts_files_ ? (*pdwEffect & DROPEFFECT_COPY) : DROPEFFECT_NONE;
        POINT point = {pt.x, pt.y};
        ScreenToClient(window_handle_, &point);
        channel_->InvokeMethod("updated", std::make_unique<flutter::EncodableValue>(
                flutter::EncodableList{
                        flutter::EncodableValue(double(point.x)),
                        flutter::EncodableValue(double(point.y))
                }
        ));
        return 0;
    }

    HRESULT DesktopDropTarget::DragLeave() {
        accepts_files_ = false;
        channel_->InvokeMethod("exited", std::make_unique<flutter::EncodableValue>());
        return 0;
    }

    HRESULT DesktopDropTarget::Drop(IDataObject *pDataObj, DWORD grfKeyState, POINTL pt, DWORD *pdwEffect) {
        if (!pdwEffect) return E_POINTER;
        const bool allow_copy = (*pdwEffect & DROPEFFECT_COPY) != 0;
        *pdwEffect = DROPEFFECT_NONE;

        flutter::EncodableList list = {};

        // construct a FORMATETC object
        FORMATETC fmtetc = {CF_HDROP, nullptr, DVASPECT_CONTENT, -1, TYMED_HGLOBAL};
        STGMEDIUM stgmed = {};

        // CF_HDROP is an owned storage-medium handle, not a locked pointer.
        if (allow_copy && pDataObj && pDataObj->QueryGetData(&fmtetc) == S_OK) {
            if (pDataObj->GetData(&fmtetc, &stgmed) == S_OK) {
                for (const auto& path : ReadDroppedPaths(reinterpret_cast<HDROP>(stgmed.hGlobal))) {
                    list.push_back(flutter::EncodableValue(path));
                }

                // release the data using the COM API
                ReleaseStgMedium(&stgmed);
            }
        }
        accepts_files_ = false;
        if (!list.empty()) {
            POINT point = {pt.x, pt.y};
            ScreenToClient(window_handle_, &point);
            flutter::EncodableMap args = {
                {flutter::EncodableValue("files"), flutter::EncodableValue(list)},
                {flutter::EncodableValue("position"), flutter::EncodableValue(flutter::EncodableList{
                    flutter::EncodableValue(double(point.x)), flutter::EncodableValue(double(point.y))})}
            };
            channel_->InvokeMethod("performOperation_windows", std::make_unique<flutter::EncodableValue>(args));
            *pdwEffect = DROPEFFECT_COPY;
        } else {
            channel_->InvokeMethod("exited", std::make_unique<flutter::EncodableValue>());
        }

        return 0;
    }

    HRESULT DesktopDropTarget::QueryInterface(const IID &iid, void **ppvObject) {
        if (iid == IID_IDropTarget || iid == IID_IUnknown) {
            AddRef();
            *ppvObject = this;
            return S_OK;
        } else {
            *ppvObject = nullptr;
            return E_NOINTERFACE;
        }
    }

    ULONG DesktopDropTarget::AddRef() {
        return InterlockedIncrement(&ref_count_);
    }

    ULONG DesktopDropTarget::Release() {
        LONG count = InterlockedDecrement(&ref_count_);

        if (count == 0) {
            delete this;
            return 0;
        } else {
            return count;
        }
    }

    void DesktopDropTarget::Dispose() {
        if (registered_) {
            registered_ = false;
            RevokeDragDrop(window_handle_);
        }
        if (need_revoke_ole_initialize_) {
            need_revoke_ole_initialize_ = false;
            OleUninitialize();
        }
    }

    DesktopDropTarget::~DesktopDropTarget() { Dispose(); }

}  // namespace

void DesktopDropPluginRegisterWithRegistrar(
        FlutterDesktopPluginRegistrarRef registrar) {
    DesktopDropPlugin::RegisterWithRegistrar(
            flutter::PluginRegistrarManager::GetInstance()
                    ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));

}
