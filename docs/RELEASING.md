# GitHub 构建与发布

仓库：<https://github.com/Echo-BraveShine/Marker>

## 日常提交

`Desktop checks` 在分支 push、PR 或手动触发时执行：锁文件安装依赖 → 格式检查 → 静态检查 → Flutter 测试 → macOS/Windows/Linux 原生 Debug 构建。Flutter 版本统一读取 `.fvmrc`。

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

所有平台构建通过后才执行发布；失败的平台不会被静默跳过。同一 Release 已存在时整体跳过，不覆盖安装包或校验值；若先前手工创建了空 Release，需先处理该 Release 再重新运行。补发较旧标签不会将其设为最新版本。工作流仅发布任务具有 `contents: write`，分支/PR 检查无发布权限，不需要额外 GitHub Token。

## 应用检查更新

设置 → 关于读取 `package_info_plus` 提供的实际版本和 build number。点击检查更新请求：

`https://api.github.com/repos/Echo-BraveShine/Marker/releases/latest`

比较公开语义版本，不把 build number 当作公开新版本。首次尚无 Release（或仓库不是公开可访问）时显示“暂未找到公开发布版本”；请求受限、超时和格式错误提供独立提示。发现新版后打开本仓库对应 Release 页面供用户下载安装，不自动执行安装包。

## 本地验证

- `python3 scripts/release_version.py --tag v0.0.1`
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
