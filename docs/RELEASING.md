# GitHub 构建与发布

仓库：<https://github.com/Echo-BraveShine/Marker>

## 日常提交

`Desktop checks` 在分支 push、PR 或手动触发时执行：锁文件安装依赖 → 格式检查 → 静态检查 → Flutter 测试 → macOS/Windows/Linux 原生 Debug 构建。Windows、macOS 构建前额外运行各自的平台测试；Python 发布工具回归测试也纳入检查。Flutter 版本统一读取 `.fvmrc`。

项目已初始化为 `main` 分支并绑定 origin。提交源码时包含 `pubspec.lock`、`.fvmrc`、Freezed 生成文件及平台工程；构建目录、Pods、FVM SDK、编辑器设置和测试沙盒不提交。当前准备代码不代表已经推送至远端。

## 正式版本

1. 将 `pubspec.yaml` 的版本更新为 `X.Y.Z+BUILD`；四个数字均不超过 65535，以满足 Windows 版本资源格式。
2. 提交、推送代码，等待 Desktop checks 通过。
3. 创建并推送与版本一致的 `vX.Y.Z` 标签。**推送版本标签会自动打包并创建 GitHub Release。**

例如当前版本为 `0.0.1+1`，对应标签 `v0.0.1`。发布流程再次检查 tag 与应用版本，不允许错版发布。Windows 安装器从相同版本输入生成，避免安装包长期停留在硬编码版本。

也可在 Actions → Release → Run workflow 中选择一个已经存在的标签。`build_only` 默认开启：只生成构建产物、不发布 Release；关闭后发布。

## 产物

| 平台 | 文件 |
| --- | --- |
| macOS ARM64 + Intel | `Marker-macos-universal.zip`、`Marker-macos-universal.dmg` |
| Windows x64 | `Marker-Windows-x64-Setup.exe`、`Marker-windows-x64.zip` |
| Linux x64 / Debian amd64 | `Marker-linux-x64.tar.gz`、`Marker-linux-amd64.deb` |
| 校验 | `SHA256SUMS.txt` |

macOS 对所有 Mach-O 文件检查 ARM64、x86_64，防止插件缺少架构；DMG 包含拖入 Applications 的入口。Windows 安装器注册 Markdown 打开方式，便携包附带 VC++ 运行库。Linux TAR 含用户级安装脚本：解压到独立目录后，在该目录执行 `bash install-user.sh .`；DEB 安装至 `/opt/marker`，注册桌面入口、MIME 与图标。

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
- `EXPECTED_VERSION=0.0.1 EXPECTED_BUILD=1 bash .github/release/macos.sh`

Windows 与 Linux 的原生构建及安装器应由对应 runner 验证。本机完成的 YAML / Actions 静态检查不等于已在 GitHub 执行过工作流。

参考本机 EJson 的 `.github/workflows/desktop.yml`、`release.yml` 与版本更新模块，按 Marker 的单应用目录与文件关联脚本调整；没有复制 EJson 的网站、包管理器发布和额外格式处理功能。

## Windows MSVC 14.51 兼容

当前 flutter_inappwebview_windows 的 WebView2/C++/WinRT 依赖在 C++17 下仍使用 experimental coroutine。MSVC 14.51 将其弃用提示升级为 STL1011。项目在生成插件目标后，仅给 `flutter_inappwebview_windows_plugin` 加入 `_SILENCE_EXPERIMENTAL_COROUTINE_DEPRECATION_WARNINGS`，使用 Microsoft 提供的兼容开关；不修改 pub 缓存，也不全局关闭警告或降低应用自身的 `/WX` 检查。

此配置同时适用于 Desktop checks 与 Release 的 Windows 构建。更新代码后重新执行失败工作流即可；单独重跑旧提交仍会使用旧配置。后续插件迁移到标准协程后应移除该兼容项。

参考：[Microsoft STL experimental/coroutine](https://github.com/microsoft/STL/blob/main/stl/inc/experimental/coroutine)。

## 工作流与旧标签的关系

参照 EJson，Release 使用两个独立 checkout：应用源码来自所选标签解析出的固定 commit；`release-tools` 来自本次工作流的 `github.workflow_sha`，包含打包脚本、版本与校验工具、工具测试、Windows 安装器和图标。脚本接收 `--project-dir .` 明确读取应用源码目录，不会误读打包工具目录的版本。

手动在新版工作流所在分支运行旧标签时，可以使用修复后的打包工具；直接重跑历史 workflow run 仍使用历史工作流。标签里的应用代码或 Flutter 测试错误仍需通过包含修复的新版本标签解决，不能靠更换打包脚本绕过。发布前会再次确认标签没有被移动到其他提交。

所有平台产物都做非空与文件名完整性检查，再计算校验值。Windows 同时检查 EXE、安装器的公开版本和 build number；Linux 检查 DEB 版本与架构；macOS 检查双架构及签名完整性。架构不匹配、任一平台构建失败或产物缺失均阻止发布。

工具回归测试：`python3 -m unittest discover -s scripts/tests -v`。发布模拟使用临时目录与伪 GitHub CLI，不会创建真实 Release。手动 `build_only` 仍默认开启，推送正式标签仍自动发布。


## Parallels 自托管验证

`.github/workflows/self-hosted.yml` 仅允许仓库所有者手动触发，不接收 PR 自动任务。Windows 使用 `marker-windows-x64` 标签和独立的 x64 Flutter SDK；Ubuntu 使用 `marker-linux-arm64` 标签。该工作流上传安装包供验证，不发布 GitHub Release；正式三端发布仍使用云端 Release 工作流。

虚拟机已准备 Runner 2.338.2。Ubuntu SDK 位于 `/opt/marker-ci/flutter`，Runner 位于 `/opt/marker-ci/runner`，使用独立账号 `marker-runner`。Windows SDK 位于 `C:\MarkerValidation\flutter-x64`，Runner 位于 `C:\MarkerRunner`，服务使用 NETWORK SERVICE。首次注册需仓库管理员取得临时注册令牌，通过环境变量 `MARKER_RUNNER_TOKEN` 提供给 `scripts/ci/register-linux-runner.sh` 或 `register-windows-runner.ps1`；不要提交或持久保存令牌。准备 SDK 和下载 Runner 不等于已完成注册；必须在 GitHub Runner 列表确认在线。

2026-11-18 本地验证：Ubuntu ARM64 的静态分析、64 项 Flutter 测试、Release 构建及 DEB/TAR 打包通过，另 2 项 Windows 专属测试跳过；Windows x64 的 66 项 Flutter 测试通过。Windows 完整构建尚未验证通过，ARM64 虚拟机中的 PDFium 子构建遇到 MSBuild 架构配置问题。本地验证不能替代 GitHub Actions 的完整运行结果。

Windows 图标切换函数避免使用 `small` 作为变量名，以防 Windows RPC 头文件宏展开为 `char`；修改后的函数已通过 MSVC x64 `/W4 /WX` 编译检查。
