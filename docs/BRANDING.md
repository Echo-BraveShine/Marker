# Marker · B / DUET

批准方向：双文档面板与 M 形负空间，表示 Markdown 编辑与同步预览。

- 浅色：暖白底座、深蓝左面板、青绿右面板。
- 深色：石墨灰底座、浅蓝左面板、薄荷青右面板。
- 生产图片去除方案板文字与背景，外部保持透明。原始母版与 1024px PNG 位于 `assets/branding`。
- 使用内置 image_gen 制作；完整提示词保存于 `assets/branding/generation-prompts.json`。

## 桌面接入

| 平台 | 主图标接入 | 深色备选 |
| --- | --- | --- |
| macOS | AppIcon.appiconset，16/32/128/256/512pt 的 1x/2x，最大 1024px | export/dark/Marker.icns |
| Windows | runner/resources/app_icon.ico，16/20/24/32/40/48/64/96/128/256px，PNG 帧及透明通道；安装器复用图标 | export/dark/marker.ico |
| Linux | hicolor 下 16/24/32/48/64/128/256/512/1024px；desktop 与 GTK 窗口图标名 marker | 同目录 marker-dark.png |
| Android | `mipmap-*` 内 ic_launcher.png（48/72/96/144/192px）；API 26+ 用 `mipmap-anydpi-v26` 自适应图标 | `mipmap-night-*`，同尺寸与同自适应层 |
| iOS | AppIcon.appiconset，Xcode 16 单尺寸 1024px，系统自动派生全部槽位 | dark / tinted 两个 appearance 变体 |

运行时图标现在通过 `marker/appearance` 原生通道跟随应用实际主题切换：

- 启动时读取已保存主题并设置图标；选择自动时跟随系统外观；快速连续切换串行执行，防止旧请求覆盖新主题。
- macOS 使用 `NSApp.applicationIconImage` 更新运行中 Dock 图标，资源来自浅色/深色 imageset。Finder 内应用包的静态主图标保持浅色。
- Windows 使用 `WM_SETICON` 更新窗口与运行中任务栏图标，按当前 DPI 选择尺寸，并更新任务栏 RelaunchIconResource；保持 `dev.ekko.marker` 分组标识。关闭应用后的已有固定快捷方式可能受 Windows 图标缓存影响。
- Linux 设置 GTK 多尺寸窗口/默认图标列表，同时更新本应用用户级 `dev.ekko.marker.desktop` 的 Icon 路径，保留现有启动器其他配置，不修改系统文件。图标复制到持久用户目录，避免引用 AppImage 临时挂载目录；优先保留用户/系统入口配置，首次从 AppImage 创建入口时使用 APPIMAGE 原始路径。支持监听 desktop 文件变化的 Dock 可刷新；部分 Wayland 桌面可能缓存启动器图标，需要目标环境验证，不通过修改 app_id 破坏固定图标分组。
- 设置页中的 `MarkerLogo` 同样按实际主题选择浅色/深色资源。


保留原生图标安全留白、圆角外透明区，不在图标中嵌入应用名或文字。不把展示方案板直接缩小为系统图标。

## 导出与检查

在 macOS 运行 `python3 scripts/export_desktop_icons.py`，使用系统 sips 重采样、iconutil 创建 ICNS，并写入原生路径。Windows 图标导出还需要开发依赖 Pillow（`python3 -m pip install Pillow`），按可见图形边界统一深浅图标占比，并生成常用 DPI 帧；不改变已选图案。MSI 广告快捷方式使用包含图标的 PE 文件，并保持 .exe 后缀与目标一致（ARPPRODUCTICON 单独使用 .ico），同时指定稳定 AppUserModelID，供搜索与任务栏分组使用。

移动端运行 `python3 scripts/export_mobile_icons.py`（需要同一份 Pillow）。桌面母版是带圆角、边缘高光和投影的卡片，而移动端系统会自己裁圆角；直接把整张卡片贴到方块上，卡片边缘的高光会在底色上留下一圈亮环，因此脚本只取居中的彩色字形，按原有比例重绘到卡片底色上，再按平台输出：

- Android：`mipmap-*` 与 `mipmap-night-*` 为全出血位图；`mipmap-anydpi-v26` 与 `mipmap-night-anydpi-v26` 生成自适应图标（纯色 background + 只含字形的 foreground，mark 落在 66% 安全区内）。夜间版由系统深色模式自动选中。
- iOS：`AppIcon.appiconset` 只保留 Xcode 16 的单尺寸格式（`Icon-1024-default/dark/tinted.png`），由系统派生其余尺寸；默认图标为无 alpha 的 RGB；dark 字形使用透明背景，tinted 为灰度图。iOS 18+ 由系统的主屏幕图标外观设置选择 dark / tinted，应用内切换主题不会直接改变主屏幕图标。

旧的逐尺寸 iOS PNG（`Icon-App-*`）已移除：同时存在会让 actool 报 "unassigned child" 警告，并可能让构建继续使用过期资源。验证：

```sh
xcrun actool ios/Runner/Assets.xcassets --compile /tmp/icons-check \
  --platform iphoneos --minimum-deployment-target 15.0 --app-icon AppIcon \
  --output-partial-info-plist /tmp/icons-check/p.plist --errors --warnings
```

输出应无 warnings/errors。

Windows 和 Linux 需要在目标系统构建并验证任务栏/启动器效果。更新系统已缓存的图标可能需要重新安装或重新启动应用；不强制重启 Finder 或桌面环境。

规范参考：[Apple 应用图标](https://developer.apple.com/design/human-interface-guidelines/app-icons/)、[Apple asset catalog 配置](https://developer.apple.com/documentation/xcode/configuring-your-app-icon)、[Microsoft ICO 格式](https://learn.microsoft.com/en-us/windows/win32/menurc/about-icons)、[freedesktop 图标主题规范](https://specifications.freedesktop.org/icon-theme/)。

## 移动端资源检查

- Android 自适应图标 XML 放在 `mipmap-anydpi-v26`，432px 图层位于 `mipmap-xxxhdpi`，对应 108dp。字形全部位于中心直径 66dp 圆形安全区；API 33+ 增加 monochrome 图层，供支持主题图标的启动器使用。
- Android 12+ 启动图使用无独立图标背景的 288dp 画布，120dp 字形位于直径 192dp 的安全圆内；旧版本使用居中 bitmap。深浅启动页均使用透明字形及页面背景，不复用桌面圆角卡片和阴影。
- iOS LaunchScreen 使用居中的 120pt 字形，提供 1x/2x/3x 与深浅资源；背景使用动态颜色，横屏方向与应用一致。
- iOS 图标沿用受支持的 Asset Catalog PNG 格式；没有新增 Icon Composer 的分层 Liquid Glass 素材，系统负责派生其余外观效果。
- 启动页遵循系统外观，应用内主题在 Flutter 首帧加载；主屏幕图标显示及缓存由系统和启动器控制，不保证随应用内主题即时刷新。

重建所有移动图标与启动图：`python3 scripts/export_mobile_icons.py`（需 Pillow）。

规范：[Android 自适应图标](https://developer.android.com/develop/ui/compose/system/icon_design_adaptive)、[Android 启动页](https://developer.android.com/develop/ui/views/launch/splash-screen)、[Apple 启动体验](https://developer.apple.com/design/human-interface-guidelines/launching)。
