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
| Windows | runner/resources/app_icon.ico，16/24/32/48/64/128/256px，PNG 帧及透明通道；安装器复用图标 | export/dark/marker.ico |
| Linux | hicolor 下 16/24/32/48/64/128/256/512/1024px；desktop 与 GTK 窗口图标名 marker | 同目录 marker-dark.png |

运行时图标现在通过 `marker/appearance` 原生通道跟随应用实际主题切换：

- 启动时读取已保存主题并设置图标；选择自动时跟随系统外观；快速连续切换串行执行，防止旧请求覆盖新主题。
- macOS 使用 `NSApp.applicationIconImage` 更新运行中 Dock 图标，资源来自浅色/深色 imageset。Finder 内应用包的静态主图标保持浅色。
- Windows 使用 `WM_SETICON` 更新窗口与运行中任务栏图标，按当前 DPI 选择尺寸，并更新任务栏 RelaunchIconResource；保持 `dev.ekko.marker` 分组标识。关闭应用后的已有固定快捷方式可能受 Windows 图标缓存影响。
- Linux 设置 GTK 多尺寸窗口/默认图标列表，同时更新本应用用户级 `dev.ekko.marker.desktop` 的 Icon 路径，保留现有启动器其他配置，不修改系统文件。首次从 bundle 创建用户级入口时使用实际可执行路径。支持监听 desktop 文件变化的 Dock 可刷新；部分 Wayland 桌面可能缓存启动器图标，需要目标环境验证，不通过修改 app_id 破坏固定图标分组。
- 设置页中的 `MarkerLogo` 同样按实际主题选择浅色/深色资源。


保留原生图标安全留白、圆角外透明区，不在图标中嵌入应用名或文字。不把展示方案板直接缩小为系统图标。

## 导出与检查

在 macOS 运行 `python3 scripts/export_desktop_icons.py`，使用系统 sips 重采样、iconutil 创建 ICNS，并写入原生路径。无需额外图片处理依赖。导出脚本只处理尺寸与封装，不修改已选图案。

Windows 和 Linux 需要在目标系统构建并验证任务栏/启动器效果。更新系统已缓存的图标可能需要重新安装或重新启动应用；不强制重启 Finder 或桌面环境。

规范参考：[Apple 应用图标](https://developer.apple.com/design/human-interface-guidelines/app-icons/)、[Apple asset catalog 配置](https://developer.apple.com/documentation/xcode/configuring-your-app-icon)、[Microsoft ICO 格式](https://learn.microsoft.com/en-us/windows/win32/menurc/about-icons)、[freedesktop 图标主题规范](https://specifications.freedesktop.org/icon-theme/)。
