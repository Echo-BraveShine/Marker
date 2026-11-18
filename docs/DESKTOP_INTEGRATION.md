# 桌面启动与文件关联

## 窗口配置核对

| 配置 | macOS | Windows | Linux |
| --- | --- | --- | --- |
| 初始尺寸（逻辑像素） | 1200×800 | 1200×800 | 1200×800 |
| 最小尺寸（逻辑像素） | 900×600 | 900×600 | 900×600 |
| 首次定位 | 居中 | 居中 | 居中 |
| 配置尺寸、主题后再显示 | 是 | 是 | 是 |
| 首帧等待上限 | 500ms | 500ms | 500ms |
| 标题栏 | 一体化原生交通灯 | 系统标题栏 | 系统标题栏 |

不可无限等待隐藏窗口的 rasterized 信号：部分系统在窗口显示前不绘制，造成循环等待。现使用有上限的帧等待，然后显示已配置的窗口；原生背景也匹配主题，避免用黑色填充。三端均由 Dart 统一决定显示时机，启动器不再抢先显示或在显示后改变尺寸。

## macOS

Info.plist 声明 .md/.markdown 的 Editor 角色和 Markdown UTI。AppDelegate 接收 Finder URL 事件，先排队，在 Flutter 文件事件通道就绪后发送。支持冷启动和已经运行的应用，不覆盖当前未保存文档，而是加入侧栏。

安装至应用程序目录，或注册开发包后，可在 Finder 的“打开方式”中找到 Marker。不会强制更改原有默认应用。本机已实际验证“打开方式 → Marker”及侧栏文档加载。

## Windows

启动参数中的文件路径会打开至工作区。发布时在 Windows 上运行 `flutter build windows --release`，再用 Inno Setup 编译 `windows/installer/marker.iss`。安装程序按当前用户注册 .md/.markdown 的 OpenWithProgids 和 marker.exe SupportedTypes，不覆盖 UserChoice 默认应用；卸载时移除本应用注册项。

`BuildOutput` 可通过 Inno Setup 编译参数覆盖，默认使用 build/windows/x64/runner/Release。Windows 需在对应系统构建与实机测试。

## Linux

启动参数中的文件路径会打开至工作区。提供 .desktop、MIME 定义及用户级安装脚本：

```sh
flutter build linux --release
bash linux/packaging/install-user.sh build/linux/x64/release/bundle
```

脚本安装至当前用户目录并更新 desktop/MIME 缓存；不会自动更改默认应用。系统打包也可使用 CMake 安装的 share/applications 和 share/mime/packages 元数据。Linux 需在对应系统构建与实机测试。

## 应用内面板

设置、选色、保存/删除确认、模板、右键菜单与语法浮层复用 MarkerFloatingSurface：15px 圆角、中性表面、柔和边框和相同阴影。确认类面板保留模态行为；语法面板保持不阻挡编辑。系统文件选择器仍由操作系统提供。

## 应用标识

桌面统一标识为 `dev.ekko.marker`：macOS 的 CFBundleIdentifier、Linux application-id / desktop 文件名 / StartupWMClass、Windows AppUserModelID 和安装器 AppId。Windows 文档 ProgID 为 `dev.ekko.marker.Markdown`。Windows 使用 AppUserModelID 表达桌面应用身份，没有 macOS 式 bundle identifier。更换 macOS 标识会使用新的应用容器，旧标识的偏好与工作区仍保留在旧容器中，不会自动清除。
