# Marker

基于 Flutter 的跨平台 Markdown 编辑器。支持 macOS、Windows、Linux、Android 和 iOS；移动端采用横屏布局。

本文面向项目开发与维护。[产品介绍与下载](https://echo-braveshine.github.io/Marker/) · [GitHub Releases](https://github.com/Echo-BraveShine/Marker/releases)

## 开发环境

- Flutter 版本以 [.fvmrc](.fvmrc) 为准，当前为 **3.44.9**；Dart SDK 约束见 [pubspec.yaml](pubspec.yaml)。
- 使用目标平台的原生工具链构建。iOS / macOS 需要 Xcode，Windows 需要 Visual Studio C++ 桌面开发环境，Android 使用 JDK 17 与 Android SDK。
- iOS 最低 15，macOS 最低 12。Apple 原生插件使用 Swift Package Manager，已移除 CocoaPods 集成，无需运行 `pod install`。
- Linux 的 GTK、WebKitGTK 等构建依赖以 [.github/workflows/desktop.yml](.github/workflows/desktop.yml) 为准；Windows 预览与导出依赖 WebView2 Runtime。

```sh
flutter pub get --enforce-lockfile
flutter devices
flutter run -d macos
```

将设备参数替换为目标设备 ID；安装 FVM 的环境可统一用 `fvm flutter` / `fvm dart` 执行对应命令。`desktop_drop` 使用仓库内的[定制版本](third_party/desktop_drop/README.md)，获取源码时需保留该目录。WebView 直接引用官方 Android、iOS、Windows 平台包及公共平台接口，版本固定在 pubspec 与锁文件中；不维护 WebView 插件源码补丁。macOS / Linux 使用项目原生渲染器，不引入对应的 WebView 插件。

## 代码结构

| 路径 | 职责 |
| --- | --- |
| `lib/main.dart` | 启动、依赖注入、主题和平台入口 |
| `lib/src/home/` | 工作区界面与文档操作，使用 Dart `part` 拆分主页面 |
| `lib/src/providers/` | 编辑、工作区、偏好、自动保存、更新及示例文档状态与服务 |
| `lib/src/resources/` | 图片导入、路径解析、资源整理和安全删除 |
| `lib/src/export/` | 导出选项、HTML 构建、网络图片内嵌及输出文件保护 |
| `lib/src/widgets/` | 编辑器、预览、滚动联动、共用弹窗与设置组件 |
| `lib/src/mobile/` | 移动文档存储、沙盒路径恢复、横屏缩放及安全区域 |
| `lib/src/theme/`、`lib/src/l10n/` | 配色、字体、样式与多语言文案 |
| `ios/`、`android/`、`macos/`、`windows/`、`linux/` | 原生工程、系统集成与导出桥接 |
| `assets/` | 品牌资源、中日韩及扩展拉丁字体、离线公式与 Mermaid 渲染资源 |
| `test/`、`scripts/tests/` | Dart / Flutter 测试与 Python 发布工具回归测试 |
| `.github/release/`、`.github/workflows/` | 平台打包、校验、发布与 Pages 部署 |
| `website/` | 用户官网，静态 HTML / CSS / JavaScript |

## 状态与界面约定

状态管理统一使用 `flutter_riverpod` 的 Notifier / Provider 与 Freezed 不可变模型。`editorProvider` 管理编辑及界面状态，`workspaceProvider` 管理打开的文档，`themeProvider` 管理主题和语言，`autosaveProvider` 管理保存调度与状态。`TextEditingController`、焦点、撤销控制器及渲染缓存负责控件生命周期，不另建全局状态体系。

修改 Freezed 模型后，更新生成文件并格式化：

```sh
dart run build_runner build
dart format lib test
```

界面复用 `MarkerColors`、`MarkerStyle`、`MarkerDialog` 与浮层组件；避免引入独立的弹窗样式或 Material 图标字体。手写文件保持职责单一，约 500 行时考虑拆分。完整规范见 [UI_STYLE.md](docs/UI_STYLE.md)。

## 文件与数据约定

- 桌面新建先取得系统保存位置，创建成功后再加入工作区；移动端在应用 Documents 目录创建独立文件。取消选择不修改当前文档。
- 有路径的脏文档在停止输入约 800ms 后自动保存，连续输入最长约 5 秒触发一次。写入串行执行，冲突和失败保留编辑内容，不能以缓存替代磁盘保存。
- 重启恢复工作区和草稿。确认磁盘文件已删除时，干净文档移出工作区；有未保存修改的文档转为草稿，不自动重建被删除文件。权限错误与文件删除分别处理。
- 首次初始化将语法示例保存为应用文档目录下的 `Marker Examples/Welcome.md`，接入普通文件流程。删除后不自动生成；设置 → 关于 → 打开示例可显式重建，已有文件不被覆盖。升级时保留已有编辑草稿。
- 移动端支持系统文件打开：iOS 使用文档类型关联与 Scene / AppDelegate URL 接收；Android 支持 VIEW / EDIT / SEND / SEND_MULTIPLE。冷启动与前台打开统一排队，系统授予的文件权限在原生层读取并复制到私有暂存区，导入完成后确认清理；应用不申请全盘访问权限。
- 外部 Markdown 导入独立副本，不覆盖来源文件；相同文件名与内容复用已有副本并保留本地编辑，来源内容变化时创建新副本。Marker Documents 内已有文档直接打开，文件已删除时不以暂存内容恢复。导入索引使用相对路径，适配 iOS 沙盒路径变化。
- 支持 Markdown / TXT（最多 16 MB）与 ZIP（最多 64 MB）导入。带本地图片时使用 ZIP 保持相对目录；单独文档图片缺失时提示补充资源。相机、相册图片复制到文档资源目录。
- 图片资源随文档保存和重命名迁移。HTTP / HTTPS 图片使用系统网络配置，HTTPS 保留证书校验；导出前下载内嵌，每张下载总超时 30 秒。
- 分屏滚动是双向比例联动，不是逐段精确映射；需避免渲染高度变化或程序滚动触发反馈循环。
- Mermaid 预览共用本地脚本与字体，避免每张图重复拼接大体积内嵌资源。文档稳定后在后台解析图块，空闲时串行预热及预解码最多 24 个唯一图表；任一侧滚动时延后新任务和图片替换。完成缓存按主题、平台及源码区分，首帧使用 PNG 头部尺寸预留布局。当前不使用跨会话图表快照，冷启动后仍需渲染，不能以单元测试替代各设备的帧率分析。

资源迁移、另存为和清理规则见 [RESOURCES.md](docs/RESOURCES.md)，语法覆盖见 [MARKDOWN_SUPPORT.md](docs/MARKDOWN_SUPPORT.md)。

## 导出与原生边界

桌面及移动端支持 PDF、PNG、独立 HTML。导出使用打开导出入口时的文档快照，包含未保存编辑；渲染等待字体、图片、公式和 Mermaid 就绪，资源缺失或渲染失败须明确报错。格式细节与限制见 [EXPORT.md](docs/EXPORT.md)。

移动端先生成文件字节，再调用系统文件保存面板；PDF 使用原生打印排版，PNG 分块截图后拼接或打包 ZIP。原生文件访问、剪贴板、拖放、系统栏、图标及打印行为仍需在目标设备验收，Widget 测试与构建通过不代表真机验收完成。

Android 使用原生沉浸模式，并处理系统栏临时显示时的布局。iOS 启动页使用 `LaunchScreen.storyboard`，不增加 Flutter 启动页面。启动资源跟随系统外观，应用内 Logo 跟随实际应用主题。图标及深浅资源规则见 [BRANDING.md](docs/BRANDING.md)。

## 检查与构建

提交前执行：

```sh
dart format --output=none --set-exit-if-changed lib test
flutter analyze --no-pub
flutter test --no-pub
python3 -m unittest discover -s scripts/tests -v
```

按当前主机与设备环境运行所需构建：

```sh
flutter build macos --release --no-pub
flutter build windows --release --no-pub
flutter build linux --release --no-pub
flutter build apk --release --no-pub
flutter build ios --simulator --no-pub
```

macOS 原生导出回归：`bash scripts/ci/test-macos-export.sh`；共享 Mermaid 资源与深浅中文图表回归：`bash scripts/ci/test-macos-mermaid.sh`。其他原生测试入口见 `scripts/ci/`，文件关联与窗口配置见 [DESKTOP_INTEGRATION.md](docs/DESKTOP_INTEGRATION.md)。

## APP 国际化资源

Flutter 界面的多语言文案统一位于 `lib/src/l10n/`：

- `message_key.dart`：类型明确的文案标识 `AppMessage`。
- `messages/`：14 种语言的实际文案，按语言及条目分片。
- `message_catalog.dart`：集中加载、参数替换与错误信息本地化。
- `app_localizations.dart`：Flutter 页面入口及支持语言列表。
- `syntax_messages.dart`：Markdown 命令稳定标识与文案的映射；语法分隔符和示例文档内容不属于界面翻译。

页面使用 `AppLocalizations.of(context).message(AppMessage.settings)`；无页面上下文的逻辑使用 `localizedMessage(languageCode, key, arguments)`。动态文案使用资源中的 `{p0}`、`{p1}` 等参数，同一条文案在所有语言中必须保持参数一致。不要在页面中新增中英文三元表达式或 `t('中文', 'English')`。

APP 已支持英语、简体中文、繁体中文、日语、韩语、德语、法语、西班牙语、巴西葡萄牙语、意大利语、俄语、土耳其语、波兰语、印尼语。新安装默认跟随系统；手动选择使用完整语言标签持久化，旧的中英文偏好继续有效。界面语言使用原生名称展示，未知语言回退到英语。

`app_language.dart` 统一登记语言标签、脚本、区域及原生名称。新增语言需在此登记、增加 `messages/` 对应文案分片并接入 `messageCatalogs`，同时补齐 Apple `InfoPlist.strings`、项目语言声明和 Android `locales_config.xml`。`zh-Hans`/`zh-Hant` 分开处理，`pt-BR` 不使用丢失区域信息的单独 `pt` 偏好。

旧 getter 和 bool 语言参数保持兼容；生产界面使用完整 Locale 或语言标签，尚未切换到 ARB。Apple 系统权限说明也提供以上语言，安装器和网站仍维护独立资源。

翻译初稿由本机 Claude 生成，已做条目、占位符、换行及五端 UI 变体检查；欢迎母语使用者改进术语与表达。原始 Markdown 示例及用户文档不会随界面语言自动翻译。

验证：`flutter test test/localization_catalog_test.dart test/language_preferences_test.dart test/language_ui_test.dart test/native_language_resources_test.dart`，检查文案完整性、参数一致性和语法模板行为。

## CI 与发布

| 工作流 | 触发与产物 |
| --- | --- |
| `desktop.yml` | main 推送 / PR / 手动：工作流语法、依赖、格式、静态分析、测试、三端桌面、Android APK 与 iOS 模拟器构建 |
| `release.yml` | `vX.Y.Z` 标签或手动：macOS、Windows、Linux、Android 打包；校验后发布同一个 GitHub Release |
| `pages.yml` | main 上网站或 Pages 工作流变更：部署 `website/` 到 GitHub Pages |
| `self-hosted.yml` | 维护者手动触发的自托管桌面构建 |

Release 标签必须匹配 `pubspec.yaml` 的公开版本，发布前递增合适的版本与 build number。桌面产物包括 DMG / ZIP、EXE / MSI / ZIP、DEB / RPM / AppImage / TAR；Android 输出 `Marker-android-universal.apk`，包含 ARMv7、ARM64、x86_64。所有格式加入 `SHA256SUMS.txt`。iOS 当前没有公开安装包流水线。

Android 发布依赖四项 Repository secrets：`ANDROID_KEYSTORE_BASE64`、`ANDROID_KEYSTORE_PASSWORD`、`ANDROID_KEY_ALIAS`、`ANDROID_KEY_PASSWORD`。CI 缺少固定签名配置时停止，不回退开发签名；本地未配置时可使用开发签名测试。密钥和密码不得提交仓库，后续版本保持签名一致。完整配置、签名现状及安全重跑策略见 [RELEASING.md](docs/RELEASING.md)。

设置中的关于页显示实际应用版本和示例文档入口，不提供捐赠或版本更新入口。网站只展示实际存在的 Release 附件。网站维护方式见 [website/README.md](website/README.md)。

字体及商店分发授权清单见 [FONT_LICENSES.md](docs/FONT_LICENSES.md)。

移动端编辑副本保存在应用 Documents 目录，不保留在文件选择器缓存中；顶部导出面板统一提供 PDF、PNG、HTML、MD 和 ZIP；其中 MD 分享当前 UTF-8 原始内容，ZIP 分享含本地图片的文档资源包。单独 MD 保留原始图片链接，不携带本地图片，网络图片仍需要联网。导出副本不改变应用内文档的保存位置。

Microsoft Store 专用 MSIX：手动运行 `Windows Store MSIX` 工作流，操作与身份配置见 [MICROSOFT_STORE.md](docs/MICROSOFT_STORE.md)。该流程只构建商店包，不自动提交、发布，也不改变现有安装包。

Android CI 仓库限流（Maven Central 429）、缓存与 Flutter included build 的处理见 [ANDROID_CI.md](docs/ANDROID_CI.md)。
