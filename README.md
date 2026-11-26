# Marker

Flutter Markdown 编辑预览工具，支持桌面与 Android / iOS。

## 运行

```sh
flutter pub get
flutter run -d macos
```

## 当前功能

- Markdown 实时预览、编辑/分屏/预览模式
- 可拖拽分栏，双击恢复均分；窄窗口上下分屏
- 桌面新建先选择位置并创建文件，取消不会清空当前文档；手机新建自动创建独立文件
- 已有路径的文档停止输入约 800ms 后自动保存，连续输入最长约 5 秒同步一次
- 串行原子写入与保存状态；写入失败保留草稿，磁盘修改冲突需用户选择，外部删除不会被自动重建
- 状态栏或文档菜单可立即保存，支持携图另存为 UTF-8 文档
- 文档资源侧栏、图片导入/拖入/截图粘贴、图片整理与安全清理（[使用说明](docs/RESOURCES.md)）
- 新建或打开另一文档前提示保存更改
- 粗体、斜体、行内代码快捷插入
- Cmd/Ctrl+S 保存、Cmd/Ctrl+O 打开
- 字符数量、光标行列、未保存标记
- 中英文切换及浅深主题，偏好本地存储

## 移动端

- 仅支持横屏，与桌面共用侧栏、顶部工具栏、编辑分屏预览及设置布局；小屏按比例适配，并保留安全区域与键盘避让。
- 导入 Markdown 时保存独立副本；后续保存写入 Marker 的文档目录，不覆盖来源文件。
- 带本地图片的文档可通过 ZIP 导入、导出；导入包需包含一份 Markdown，图片保持原相对目录。
- 单独导入 Markdown 无法自动取得旁边图片的访问权限，建议使用包含图片的 ZIP。
- 移动端支持 PDF / PNG / HTML，通过系统文件面板保存；文档与图片仍可打包导出 ZIP。
- Android 本地构建可使用开发签名；GitHub Release 构建使用仓库 Secrets 中的固定发布密钥，缺少签名配置会停止发布。

## 验证

```sh
flutter analyze
flutter test
flutter build macos --debug
```

## 当前限制

已实现桌面关闭保护、macOS 退出保护和草稿自动恢复（编辑后约 350ms 缓存）。草稿缓存不能替代文件保存。已支持多文档恢复、分屏滚动联动及可选的编辑器语法高亮。支持 PDF、PNG 长图与独立 HTML 导出；资源打包入口暂时隐藏。资源管理涉及的原生拖放、剪贴板和废纸篓需要分别在对应桌面系统验收。

## 界面

按 docs/UI_STYLE.md 调整为一体化 macOS 标题栏、240/56px 可折叠侧栏、44px 工具栏、24px 状态栏与居中限宽预览。设置提供跟随系统/浅色/深色主题、10–24 编辑字号、衬线预览。侧栏支持文档列表与图片资源切换，支持重启恢复上次文档和可选语法高亮；浮窗与设置使用共用界面组件。

## 状态管理

统一使用 `flutter_riverpod` 的 `NotifierProvider`，配合 Freezed 不可变状态：

- `editorProvider`：文档内容、保存基线、文件路径、光标、恢复/忙碌状态与编辑界面选项。
- `themeProvider`：主题与语言，持久化到本地偏好。
- `ProviderScope` 在应用入口创建；测试使用独立容器，不共享单例状态。
- `TextEditingController`、焦点、撤销控制器和缓存计时器仅负责界面/生命周期，不承担全局状态管理。

修改 Freezed 模型后运行：

```sh
dart run build_runner build
```

启动默认展示完整语法示例；若存在未保存草稿则优先恢复。编辑区提供 Markdown 颜色高亮，并在中文输入组合期间保留系统输入样式。侧栏标签按动画过程的实际宽度显示，避免切换溢出。

分屏模式下，编辑区和预览区按滚动进度双向联动，避免互相触发循环；这是比例联动，复杂图表和图片高度不同的文档尚非逐段精确对齐。顶部向下箭头可展开完整语法面板，覆盖当前支持的 Markdown 语法类型。命令保留当前选区并插入标记，未选中文本时填入占位内容；面板限制高度并可滚动。

## 多文档工作区

新建或打开文件会加入侧栏，点击切换；每份文档保留独立草稿。重启恢复打开列表、上次选中文档与未保存内容。干净文档尝试重新读取磁盘文件；路径失效或无读取权限时保留缓存内容，保存失败可通过另存为重新选择路径。

侧栏右键菜单提供“关闭文档”和“删除磁盘文件”：关闭保留文件，删除会单独确认永久删除文件及未保存内容。关闭有修改的文档时提示保存，退出应用时检查所有打开文档。列表全部关闭后保持空工作区。状态统一由 Riverpod + Freezed 管理。

侧栏按最近实际内容编辑排序，新建/打开文档置顶；单纯选择文档不会重排，编辑时间随工作区保存并在重启后恢复。编辑区正文左/右内边距为 2/6，行号栏按位数自适应紧凑宽度。

文字颜色：选中文本后点击工具栏带彩色下划线的文字图标，拖动 HSV 色盘、调节亮度、选择常用色或输入 #RGB/#RRGGBB，然后点击“应用颜色”。应用会插入 `<span style="color:#RRGGBB">文字</span>`；无选区时插入占位文字。预览支持这个颜色扩展以及其中的粗体、斜体等基础格式；普通 Markdown 阅读器是否显示颜色取决于其 HTML 支持。

应用内保存/删除确认、文字颜色和设置统一使用 `MarkerDialog` 与 `MarkerDialogButton`：同一套标题栏、圆角、表面色、阴影与底部操作区，适配深浅主题；内容超高时滚动、操作按钮可换行。文件选择仍由系统原生对话框提供。

公式与 Mermaid 模板：工具栏 ƒx/图表按钮打开模板菜单；展开面板中的公式/Mermaid 入口也可进入。提供 10 种公式和 9 种 Mermaid 示例，点击插入后可继续修改。有选区时以选中内容替代示例主体。所有公式示例通过实际控件渲染测试，Mermaid 示例通过本地打包脚本的离线浏览器 SVG 渲染验证。

## 启动、搜索和快捷键

桌面端统一 1200×800 初始窗口、900×600 最小窗口。窗口隐藏期间配置尺寸、主题和标题栏，首帧完成后再显示；macOS 原生窗口也阻止提前显示，Windows/Linux 启动器交由 Dart 统一显示。Windows/Linux 仍需在各自系统进行构建和启动验收。

搜索按钮打开查找替换栏，支持大小写、匹配数量、前后查找、替换当前项与全部替换。Mac 使用 Cmd+F 查找、Cmd+Option+F 替换；Windows/Linux 使用 Ctrl+F 查找、Ctrl+H 替换。设置新增快捷键分类，快捷键说明与实际应用绑定共享清单。文本框继续保留系统剪贴板和撤销快捷键。

顶部功能与常用语法维持单行，按剩余宽度显示可容纳按钮，其余语法通过右侧浮层访问。

## 桌面集成更新

已将设置、选色、确认、模板和右键菜单统一为与右侧语法浮层相同的表面组件。启动帧等待设有 500ms 上限，避免隐藏窗口与首帧绘制相互等待导致窗口无法显示。

Markdown 的“打开方式”关联和三端窗口核对详见 [桌面集成说明](docs/DESKTOP_INTEGRATION.md)。macOS 已实测 Finder 右键打开；Windows 通过 Inno Setup 注册，Linux 通过 desktop/MIME 元数据或用户级安装脚本注册，不强制修改默认应用。

## 构建、发布与更新

本项目绑定 [Echo-BraveShine/Marker](https://github.com/Echo-BraveShine/Marker)。GitHub Actions 提供三端构建检查及基于版本标签的安装包发布。设置 → 关于可查看实际版本、手动检查 GitHub 更新。

详见 [发布说明](docs/RELEASING.md)，包括版本标签、安装包格式、签名现状及本地验证方式。

## 文档导出 / Document export

工具栏点击「导出」，或使用 **⌘⇧E（macOS）/ Ctrl+Shift+E（Windows、Linux）**。在设置的快捷键分类中也可查看。

- **PDF**：浅色 A4 排版，长文自动分页，文字可选择与复制。脚注保留在文末；能容纳一页的段落、代码块、表格与图表尽量整体分页，超长内容按行或表格行拆分。
- **PNG**：导出全文长图，可选择 960 / 1280 / 1600 px 宽度和跟随应用深浅主题。跟随主题选项在关闭弹窗、重启应用后保留。
- **HTML**：独立离线文件，内嵌图片、字体、公式与 Mermaid 渲染资源。

导出使用点击入口时的文档快照，包含未保存的编辑。文档中的本地图片按 Markdown 所在目录解析，网络图片会先下载并内嵌；缺失图片会提示失败；PDF、PNG 渲染时也会检查公式与图表语法。macOS 如提示目录授权，请选择相应的图片目录或导出目录。取消不会修改原文或现有输出；导出目标不能是 Markdown 文件。

PDF、PNG 中的 GIF、WebP 和 APNG 动图按首帧导出；HTML 保留动图。PNG 高度最多 32768 px；移动端单图最多 1600 万像素，超长文档可开启分图 ZIP（总量最多 64 MB），或选择 PDF。单张图片最多约 25 MB，内嵌图片总量最多 128 MB。Windows 需要 Microsoft Edge WebView2 Runtime。

Use **Export** in the toolbar or **⌘⇧E / Ctrl+Shift+E**. PDF uses light A4 pages with selectable text and endnotes, keeping fitting content blocks together and splitting oversized content at lines or table rows; PNG exports the full document at a chosen width and appearance; HTML embeds offline rendering resources. The app appearance export preference survives dialog dismissal and app restarts. Export captures unsaved content when opened. Local images resolve relative to the Markdown file; remote images are downloaded and embedded. Missing assets or invalid equations/diagrams report an error. On macOS, grant access to the relevant image or output folder when asked. Cancellation preserves existing files. PNG height is limited to 32768 px. Mobile single images are limited to 16 million pixels; use split-image ZIP (up to 64 MB) or PDF for longer documents. Images are limited to approximately 25 MB each and 128 MB total when embedded. Windows requires Edge WebView2 Runtime.

macOS 原生导出回归：`bash scripts/ci/test-macos-export.sh`，检查脚注、可复制文字、完整分页及深浅主题 PNG；桌面 CI 自动运行此检查。

移动端和桌面端均支持 HTTP / HTTPS 网络图片；导出会先下载并内嵌网络图片，每张下载总超时 30 秒，失败时明确提示。HTTPS 保留系统证书校验。

Apple 平台使用 Swift Package Manager 管理原生插件依赖（Flutter 3.44.9），iOS / macOS 不再需要 CocoaPods 或 `pod install`。最低系统版本仍为 iOS 15 / macOS 12。

首次启动的语法示例保存为应用文档目录下的 `Marker Examples/Welcome.md`，按普通文件自动保存并管理图片资源。删除后不会自动重建；设置 → 关于 →「打开示例 / Open example」可再次打开，文件缺失时重新生成，已有内容不会被覆盖。桌面端手动新建文档仍须选择保存位置。
