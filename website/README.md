# Marker website

纯静态官网，参照 EJson 的 `website/` + 独立 Pages 工作流；无需 Node 依赖或构建服务。

本地预览：`python3 -m http.server 4173 --directory website`，访问 `http://localhost:4173`。

在 GitHub 仓库 Settings → Pages → Build and deployment 中选择 **GitHub Actions**。推送 `website/` 或 `.github/workflows/pages.yml` 到 main 后自动部署，也可以手动运行 Website 工作流。预期地址为 https://echo-braveshine.github.io/Marker/，实际以上线工作流返回地址为准。

所有资源使用相对路径，支持 `/Marker/` 子目录。网页支持中英切换、系统/浅色/深色外观、本地偏好保存；编辑器是标明用途的交互示意，不是 App 截图或在线编辑器。无第三方字体、统计或脚本依赖。

下载区读取 GitHub latest release 的实际附件，只为存在的文件显示下载按钮。无公开 Release、API 受限或网络错误时回退到仓库发布列表，不生成猜测的安装包链接。增加发布格式时同步修改 `site.js` 的 `packages` 映射。

下载区包含 macOS、Windows、Linux 和 Android，Android 对应 `Marker-android-universal.apk`。只有最新 Release 实际包含 APK 时才显示直接下载链接，旧版本没有 APK 时继续提供发布列表入口。iOS 仅说明尚未开放下载，不展示不可用的安装入口；源码构建说明保留在仓库 README。

介绍文案与应用保持一致：桌面与横屏手机、自动保存、本地 / 网络图片、手机相机 / 相册及 PDF / PNG / HTML 导出。中英文内容同步更新，下载卡片在宽屏双列、小屏单列展示。

内容定位：面向使用者，介绍写作体验、图片管理、自动保存、导出和下载安装，使用常见问题说明本地保存、移动端 ZIP 与横屏操作。不在产品文案中展示构建命令、签名配置或状态管理实现；相关内容统一维护在仓库 README 和 docs/ 中。
