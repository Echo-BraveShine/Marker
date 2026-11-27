# Microsoft Store（Windows x64 / MSIX）

本流程只构建、检查并上传 GitHub Actions 构建产物，不创建 Partner Center 提交，也不发布商店。原有 EXE、MSI、ZIP 及其他平台发布流程继续使用原有格式；Store 包不加入 GitHub Release 的必需附件清单。

## 产品身份

唯一配置文件为 `windows/store/identity.json`，对应 Partner Center“产品标识”：

| 字段 | 配置值 |
| --- | --- |
| Identity/Name | Ekko.MarkerDocument |
| Identity/Publisher | CN=BA61D7A5-6B75-4849-9DEE-E6EC853CF873 |
| Properties/PublisherDisplayName | Ekko |
| Package Family Name | Ekko.MarkerDocument_b7jpczkdr5bmw |
| Store ID | 9MZ7T2N8TWM4 |

前三项写入生成的 `AppxManifest.xml`，PFN 用于核对，不手工写入 Manifest；Package SID 暂不需要。以上是产品身份，不是登录凭据。构建无需 Partner Center 密钥或付费代码签名证书。

应用显示名称目前仍为 **Marker**，未作品牌改名。提交前核对 Partner Center 已保留的应用名称与之匹配；确认新名称后另行统一修改。其他平台 Bundle ID 不受影响。

## GitHub Actions 操作

1. 将这些改动提交并推送到自己的仓库（本次实现没有替你提交或推送）。
2. 打开 Actions → **Windows Store MSIX** → Run workflow。
3. `source_ref` 填包含这些脚本的分支、提交或标签，例如 `main`；旧标签若不包含 Store 支持，不能直接使用。
4. 无需填写版本号：从选定源码的 `pubspec.yaml` 自动读取，例如 `1.0.0+1` → `1.0.0.0`。第一段至少 1，各段最多 65535，第四段固定 0。更新上架时提升 `pubspec.yaml` 的主/次/修订版本，例如 `1.0.1+2` → `1.0.1.0`；仅增加 `+build` 不会提升商店包版本。
5. 下载 `Marker-Microsoft-Store-x64-版本号` Artifact。

产物包括：

- `Marker-Store-x64-版本号.msix`：提交商店的未签名应用包。
- `.msix.sha256`：对应 SHA-256。
- `AppxManifest.xml` 和 `identity.json`：方便审核身份、权限及文件关联。
- `build-info.json`：源码提交、商店版本及工作流链接。
- 本说明文档。

应用版本统一由 `pubspec.yaml` 管理，目前为 `1.0.0+1`，界面显示 `1.0.0`。商店包自动使用同一公开版本的四段形式 `1.0.0.0`，第四段保留为 0，不把 Flutter 的 `+1` 用作第四段；构建时不覆盖应用构建号。无需另行维护商店版本输入。首段为 0 或预发布版本会在构建前明确报错。

工作流先执行打包契约测试、Flutter 分析和测试，再构建 Windows Release。PowerShell 补齐 Visual C++ Release CRT，Python 检查 Flutter 资源和字体授权文件不丢失，再调用 Windows SDK MakeAppx（不关闭其语义校验），最终解包检查身份、版本和必需内容，并生成校验和。

## 包行为与依赖

- 面向 Windows 10 2004（19041）及以上桌面 x64；没有声明尚未验证的 Windows ARM64 原生包。
- `.md` / `.markdown` 文件关联由 MSIX 清单注册，路径参数带引号，兼容中文和空格。卸载由系统撤销注册，不额外写默认应用设置。
- 保留普通桌面进程权限 `runFullTrust`：Flutter Win32 窗口、用户选取的本地文档和图片、桌面导出需要。审核问到受限权限时如实解释这些用途。
- 声明网络能力以支持网络图片和链接；不增加摄像头、定位、后台服务等权限。
- Visual C++ Release CRT 随包部署。Mermaid 和渲染导出仍使用现有 Microsoft Edge WebView2 Evergreen Runtime：需在目标 Windows 上核对运行库可用性，缺失时应用会提示安装；此流程不在 MSIX 安装期间下载或执行额外安装器。
- WebView2 数据目录已使用用户 Application Support，避免写入只读 WindowsApps 目录。
- 商店包使用系统包身份分组任务栏，普通 EXE/MSI/便携包继续使用原 AUMID。运行时深浅主题图标逻辑保留；Start/Store 系统展示使用清单中的图标。
- 商店使用现有已批准 Logo，未重新设计。`windows/store/Assets/` 的 PNG 是原 Windows 图标的尺寸衍生；替换品牌图时同时更新这些资源。

## 上传、安装测试与审核

在 Partner Center 对应产品的新提交“程序包”页面上传 `.msix`，补齐截图、功能描述、隐私政策 URL、支持信息、年龄分级和审核说明。未上架前不在官网展示可用的商店安装链接。

此包没有附加本地证书。Microsoft Store 审核通过后负责重新签名；**未签名 Artifact 不是给普通用户直接双击安装的安装包**。本地安装/WACK 测试应对包的测试副本使用匹配 Publisher 的开发证书签名并信任测试证书，或者使用 Partner Center 私有测试分发。不要改生产包的 Publisher 或加入调试专用 OID。不要把私钥/证书文件放进源码或安装包。

提交前在真实 Windows 测试设备或 GitHub Windows 环境完成安装、启动、卸载、WACK 认证及核心操作：中文/空格路径打开、默认打开方式、重命名与自动保存、网络图片重试、Mermaid、PDF/PNG/HTML、深浅主题及任务栏图标。当前 macOS 本地仅验证脚本和资源契约，不等同 Windows 安装或商店认证通过；按用户要求不使用本机虚拟机。

本地 Windows 构建示例（PowerShell，需 Flutter、Python、VS C++ Build Tools、Windows SDK）：

```powershell
flutter pub get
flutter build windows --release
./.github/release/windows-store.ps1
```

官方参考：[上架检查清单](https://learn.microsoft.com/en-us/windows/apps/publish/store-readiness-checklist)、[MSIX 包与签名规则](https://learn.microsoft.com/en-us/windows/apps/publish/publish-your-app/msix/app-package-requirements)、[MakeAppx](https://learn.microsoft.com/en-us/windows/msix/package/create-app-package-with-makeappx-tool)、[文件关联](https://learn.microsoft.com/en-us/windows/apps/desktop/modernize/desktop-to-uwp-extensions)。
