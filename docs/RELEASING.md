# GitHub 构建与发布

仓库：<https://github.com/Echo-BraveShine/Marker>

## 日常提交

`Desktop checks` 在分支 push、PR 或手动触发时执行：锁文件安装依赖 → 格式检查 → 静态检查 → Flutter 测试 → macOS/Windows/Linux 原生 Debug 构建。Windows、macOS 构建前额外运行各自的平台测试；Python 发布工具回归测试也纳入检查。Flutter 版本统一读取 `.fvmrc`。

项目已初始化为 `main` 分支并绑定 origin。提交源码时包含 `pubspec.lock`、`.fvmrc`、Freezed 生成文件及平台工程；构建目录、Pods、FVM SDK、编辑器设置和测试沙盒不提交。当前准备代码不代表已经推送至远端。

## 正式版本

1. 将 `pubspec.yaml` 的版本更新为 `X.Y.Z+BUILD`；公开版本的 major、minor 不超过 255，patch 与 BUILD 不超过 65535，以满足 MSI 和 Windows 版本资源格式。
2. 提交、推送代码，等待 Desktop checks 通过。
3. 创建并推送与版本一致的 `vX.Y.Z` 标签。**推送版本标签会自动打包并创建 GitHub Release。**

例如当前版本为 `0.0.1+1`，对应标签 `v0.0.1`。发布流程再次检查 tag 与应用版本，不允许错版发布。Windows 安装器从相同版本输入生成，避免安装包长期停留在硬编码版本。

也可在 Actions → Release → Run workflow 中选择一个已经存在的标签。`build_only` 默认开启：只生成构建产物、不发布 Release；关闭后发布。

## 产物

| 平台 | 文件 |
| --- | --- |
| macOS 通用 | `Marker-macos.zip` |
| macOS ARM64 / Intel | `Marker-macos-arm64.dmg`、`Marker-macos-x86_64.dmg` |
| Windows x64 | `Marker-Windows-x64-Setup.exe`、`Marker-Windows-x64.msi`（英文）、`Marker-Windows-x64-zh-CN.msi`（中文）、`Marker-windows-x64.zip` |
| Linux x64 | `Marker-linux-x64.tar.gz`、`Marker-linux-amd64.deb`、`Marker-linux-x86_64.AppImage`、`Marker-linux-x86_64.rpm` |
| Linux ARM64 | `Marker-linux-arm64.tar.gz`、`Marker-linux-arm64.deb`、`Marker-linux-aarch64.AppImage`、`Marker-linux-aarch64.rpm` |
| 校验 | `SHA256SUMS.txt`，覆盖以上 15 个安装包 |

macOS 对所有 Mach-O 文件检查 ARM64、x86_64，防止插件缺少架构；DMG 分别裁剪为 ARM64、x86_64，逐个检查所有 Mach-O 架构、重新签名并验证镜像，包含拖入 Applications 的入口。Windows EXE 与 MSI 注册 Markdown 打开方式，便携包附带 VC++ 运行库。MSI 使用独立 UpgradeCode；云端 Release 校验其版本、实际静默安装、检查安装文件并卸载，自托管低权限 Runner 只构建及检查 MSI 元数据。Linux TAR 含用户级安装脚本：解压到独立目录后，在该目录执行 `bash install-user.sh .`；DEB 安装至 `/opt/marker`，注册桌面入口、MIME 与图标。

macOS 当前使用临时签名，未配置 Developer ID/公证；Windows 未配置商业代码签名。项目没有假设或写入发布证书。macOS 对首次下载的未公证软件可能显示系统提示。

所有平台构建通过后才执行发布；失败的平台不会被静默跳过。支持续传空 Release 或不完整 Release，不覆盖已发布安装包。已有 SHA256 校验清单时必须遵守原校验值；若重建的缺失安装包与原清单不一致，会停止并报错，需找回原构建产物或发布新版本。没有校验清单的部分 Release 会下载并保留原安装包，与新增包一起生成首份完整校验清单。补发较旧标签不会将其设为最新版本。工作流仅发布任务具有 `contents: write`，分支/PR 检查无发布权限，不需要额外 GitHub Token。

## 应用检查更新

设置 → 关于读取 `package_info_plus` 提供的实际版本和 build number。点击检查更新请求：

`https://api.github.com/repos/Echo-BraveShine/Marker/releases/latest`

比较公开语义版本，不把 build number 当作公开新版本。首次尚无 Release（或仓库不是公开可访问）时显示“暂未找到公开发布版本”；请求受限、超时和格式错误提供独立提示。发现新版后打开本仓库对应 Release 页面供用户下载安装，不自动执行安装包。

## 本地验证

- `python3 scripts/release_version.py --project-dir . --tag v0.0.1`
- `flutter pub get --enforce-lockfile`
- `dart format --output=none --set-exit-if-changed lib test`
- `flutter analyze --no-pub`
- `flutter test --no-pub`
- `flutter build macos --release --no-pub`
- 安装 `dmgbuild==1.6.5` 后运行 `DMGBUILD=/path/to/dmgbuild EXPECTED_VERSION=0.0.1 EXPECTED_BUILD=1 bash .github/release/macos.sh`

Windows 与 Linux 的原生构建及安装器应由对应 runner 验证。本机完成的 YAML / Actions 静态检查不等于已在 GitHub 执行过工作流。

参考本机 EJson 的 `.github/workflows/desktop.yml`、`release.yml` 与版本更新模块，按 Marker 的单应用目录与文件关联脚本调整；没有复制 EJson 的网站、包管理器发布和额外格式处理功能。

## Windows MSVC 14.51 兼容

当前 flutter_inappwebview_windows 的 WebView2/C++/WinRT 依赖在 C++17 下仍使用 experimental coroutine。MSVC 14.51 将其弃用提示升级为 STL1011。项目在生成插件目标后，仅给 `flutter_inappwebview_windows_plugin` 加入 `_SILENCE_EXPERIMENTAL_COROUTINE_DEPRECATION_WARNINGS`，使用 Microsoft 提供的兼容开关；不修改 pub 缓存，也不全局关闭警告或降低应用自身的 `/WX` 检查。

此配置同时适用于 Desktop checks 与 Release 的 Windows 构建。更新代码后重新执行失败工作流即可；单独重跑旧提交仍会使用旧配置。后续插件迁移到标准协程后应移除该兼容项。

参考：[Microsoft STL experimental/coroutine](https://github.com/microsoft/STL/blob/main/stl/inc/experimental/coroutine)。

## 工作流与旧标签的关系

参照 EJson，Release 使用两个独立 checkout：应用源码来自所选标签解析出的固定 commit；`release-tools` 来自本次工作流的 `github.workflow_sha`，包含打包脚本、版本与校验工具、工具测试、Windows 安装器和图标。脚本接收 `--project-dir .` 明确读取应用源码目录，不会误读打包工具目录的版本。

工具 checkout 使用非 cone 的精确目录匹配，只下载 `.github/release`、`scripts`、`linux/packaging`、Windows 安装器和图标目录。默认 cone 模式会额外检出根目录 `pubspec.yaml`，但缺少 `assets`，导致 `flutter analyze` 报 `asset_does_not_exist`；因此两处工具 checkout 都必须保持 `sparse-checkout-cone-mode: false`。

手动在新版工作流所在分支运行旧标签时，可以使用修复后的打包工具；直接重跑历史 workflow run 仍使用历史工作流。标签里的应用代码或 Flutter 测试错误仍需通过包含修复的新版本标签解决，不能靠更换打包脚本绕过。发布前会再次确认标签没有被移动到其他提交。

所有平台产物都做非空与文件名完整性检查，再计算校验值。Linux 两种架构的校验文件单独命名，防止合并时互相覆盖；发布必须包含完整 15 包，缺少任何格式或架构都会停止。Windows 同时检查 EXE、安装器的公开版本和 build number；Linux 检查 DEB 版本与架构；macOS 检查双架构及签名完整性。架构不匹配、任一平台构建失败或产物缺失均阻止发布。

工具回归测试：`python3 -m unittest discover -s scripts/tests -v`。发布模拟使用临时目录与伪 GitHub CLI，不会创建真实 Release。手动 `build_only` 仍默认开启，推送正式标签仍自动发布。


## Parallels 自托管验证

`.github/workflows/self-hosted.yml` 仅允许仓库所有者手动触发，不接收 PR 自动任务。Windows 使用 `marker-windows-x64` 标签和独立的 x64 Flutter SDK；Ubuntu 使用 `marker-linux-arm64` 标签。该工作流上传安装包供验证，不发布 GitHub Release；正式三端发布仍使用云端 Release 工作流，Linux ARM64 已纳入正式发布矩阵。Ubuntu VM 需管理员预装 `rpm patchelf xvfb xauth xdotool`，Windows 通过 setup-dotnet 提供 WiX 所需 SDK；三处 Windows 工作流显式安装 NuGet 6.14.0，供 WebView 插件及 WiX UI 扩展使用。ARM64 Windows 虚拟机即使以 x64 Dart 构建，也需安装 ARM64 MSVC 工具以满足 PDFium 的下载子项目配置。

虚拟机已准备 Runner 2.338.2。Ubuntu SDK 位于 `/opt/marker-ci/flutter`，Runner 位于 `/opt/marker-ci/runner`，使用独立账号 `marker-runner`。Windows SDK 位于 `C:\MarkerValidation\flutter-x64`，Runner 位于 `C:\MarkerRunner`，服务使用 NETWORK SERVICE。首次注册需仓库管理员取得临时注册令牌，通过环境变量 `MARKER_RUNNER_TOKEN` 提供给 `scripts/ci/register-linux-runner.sh` 或 `register-windows-runner.ps1`；不要提交或持久保存令牌。准备 SDK 和下载 Runner 不等于已完成注册；必须在 GitHub Runner 列表确认在线。

2026-11-18 本地验证：Ubuntu ARM64 的静态分析、64 项 Flutter 测试、Release 构建及 DEB/TAR 打包通过，另 2 项 Windows 专属测试跳过；Windows x64 的 66 项 Flutter 测试通过。此处为当日历史结果；2026-11-19 补齐 ARM64 MSVC、NuGet 并启用 UTF-8 编译后，Windows x64 Release 构建已通过。本地验证不能替代 GitHub Actions 的完整运行结果。

Windows 图标切换函数避免使用 `small` 作为变量名，以防 Windows RPC 头文件宏展开为 `char`；修改后的函数已通过 MSVC x64 `/W4 /WX` 编译检查。


## 与 EJson 工作流的适配边界

EJson 的 Flutter 应用位于 `apps/ejson`，检查和打包在该目录运行；Marker 的应用位于仓库根目录。EJson 的工具 checkout 在应用分析目录外，Marker 的 `release-tools` 则位于应用分析目录内。因此 Marker 不能直接沿用默认 cone 稀疏检出：它会带入根 `pubspec.yaml`，却不带入 `assets`。验证时必须保留真实工具 checkout 后运行 `flutter analyze --no-pub`，不能只在单一源码 checkout 下验证。

两者都将分支检查与标签发布分开：Desktop checks 成功不触发 Release；推送 `vX.Y.Z` 标签才自动发布。Marker 的手动发布默认 `build_only=true`，实际发布需取消该选项。源码始终来自所选标签，工具修复来自运行工作流的提交；重跑历史 run 不会获取新工作流，旧标签中的应用问题也不会自动修复。

验证结论需区分三层：静态工作流检查、各操作系统上的本地步骤验证、GitHub 托管环境整条 Release 成功。前两者通过不代表第三者通过。路径转换测试、Windows 头文件宏与 MSVC 版本属于应用和平台差异，应单独验证，不能由 EJson 工作流成功推断 Marker 成功。


## 安装视觉与中英文

macOS DMG 使用 Marker 定制背景、中英双语拖拽说明、固定 Finder 图标位置；两个架构共享相同布局。Windows EXE 使用现代向导、Marker 侧栏及图标，启动时根据系统语言选择默认值，也可选择 English / 简体中文。Windows MSI 分别提供 en-US 和 zh-CN 两包，使用 WiX 原生语言资源翻译按钮、向导和进度文本；两个语言包共享同一产品标识，避免同时安装两份；升级检测忽略语言，允许后续版本在中英安装之间升级。EXE 支持 `/LANG=en` 或 `/LANG=zh` 静默选择。

Linux TAR 可运行 `bash install-user.sh --gui .` 打开品牌 GTK 安装页（需要 `python3-gi` 和 GTK 3 introspection），默认根据系统 locale 选择语言，页面可切换 English / 简体中文；`MARKER_INSTALLER_LANGUAGE=en|zh` 可覆盖默认语言。命令行 `bash install-user.sh .` 保留，欢迎、结果文案同样支持中英。DEB/RPM 由系统软件中心负责语言与安装页面，应用描述包含中文和英文；AppImage 直接运行，不额外添加安装向导。

背景和向导位图由 `scripts/branding/installer_assets.py` 从既有 Logo 与可编辑 SVG 生成。生成工具仅开发时需要 `cairosvg pillow`，CI 使用提交的 PNG/BMP；DMG 排版使用固定版本 `dmgbuild==1.6.5`。Inno 中文语言文件来自 [Inno Setup 官方翻译](https://jrsoftware.org/inno-setup/translations)，随源码保存，不在构建时临时下载。


MSVC 的共用编译设置显式启用 `/utf-8`，防止中文 Windows 的 CP936 将依赖源码中的 UTF-8 注释误判为 C4819，并因 `/WX` 阻止构建。保留严格警告检查，不修改 pub 缓存。


Windows 打包前必须验证 `flutter_windows.dll`、ICU、AOT 和 AssetManifest 均存在且非空。CMake 强制将应用安装输出指向构建目录，避免插件子项目影响默认前缀后把资源写入 Program Files；MSI 测试要求目标目录为空，防止历史资源掩盖缺包。WiX 调试符号不进入发布目录，校验清单在所有操作系统统一使用 UTF-8/LF。


### 2026-11-19 本机验证结果

- macOS：通用 ZIP、ARM64 DMG、Intel DMG 实际生成；全部 Mach-O 架构与签名、DMG 校验通过；读取镜像 `.DS_Store` 确认双语背景、拖拽入口和窗口布局。
- Windows ARM64 虚拟机中的 x64 工具链：Release 构建通过；EXE、便携 ZIP、中英两个 MSI 已实际打包；两个 MSI 在干净目录静默安装、检查运行库及资源后卸载通过。ZIP 包含 60 个条目，13 个 PE 文件均为 x64，校验值验证通过。
- Ubuntu ARM64：TAR、DEB、AppImage、RPM 实际打包及元数据校验通过；AppImage 解包与窗口启动检查通过；GTK 安装页中英切换和当前用户安装通过。
- 发布与语言回归测试 15 项及 actionlint 通过。以上是本机验证，不代表 GitHub 托管环境的新一轮 Release 已运行；Linux x64 的新增格式仍需由对应云端 runner 验证。


## AppImage 的无头启动检查

AppImage 生成完成后，在独立 Xvfb 与 D-Bus 会话中启动实际运行文件，检查同一可见窗口连续出现且进程保持存活。CI 仅在此检查中启用 Mesa 软件渲染、X11 并关闭 AT-SPI 桥，避免无 GPU/辅助功能总线环境干扰。窗口枚举的临时 BadWindow 可在限定时间内重试；应用提前退出、窗口未稳定出现或超时仍会使 Release 失败，并输出启动日志。正式 AppImage 的运行环境不改变。


### Mermaid 桌面回归检查

Linux 构建环境增加 `libwebkit2gtk-4.1-dev`；DEB/RPM 增加 WebKitGTK 4.1 运行依赖。Desktop checks 在 Linux 导出离线测试页，再运行 `scripts/ci/test-linux-native.sh`，覆盖 9 类图表的深浅主题、中文标签、无效语法，以及桌面入口的主题图标与配置保留。TAR/AppImage 使用系统 WebKitGTK 4.1。

Windows 离线页面必须通过本地文件 URL 加载，不能将 3.3MB 的 Mermaid 脚本内联后交给限制 2MB 的 `NavigateToString`；页面显式使用 UTF-8。WebView2 profile 使用用户数据目录，不能写 Program Files。`test/windows_mermaid_test.cpp` 是原生 WebView2 回归探针，需在登录用户会话运行（SYSTEM 后台会话无法可靠创建控制器）；`test/windows_icon_sizes_test.cpp` 校验两套 ICO 在 10 个尺寸的原生加载结果。
