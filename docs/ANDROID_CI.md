# Android CI 依赖仓库

APK 构建若在 `dev.flutter.flutter-plugin-loader` 阶段下载 Kotlin 依赖失败，并显示 Maven Central `429 Too Many Requests`，说明构建机器出口受到依赖仓库限流；这条日志本身不表示项目 Kotlin 版本不兼容。

`desktop.yml` 的 Android 检查和 `release.yml` 的 Android 发布任务会在构建前运行 `scripts/configure_android_ci.py`，将仓库策略复制到当前 Gradle 用户目录的 `init.d/marker-android-repositories.gradle`。该文件只影响这台 CI Runner 的 Gradle 调用，不修改 Flutter SDK、插件源码或项目依赖版本。

策略由 `scripts/ci/android-repositories.init.gradle` 管理：

- Maven Central 依赖使用 [Google Cloud 文档介绍的 Central 镜像](https://docs.cloud.google.com/docs/buildpacks/java#google_cloud_hosted_maven_central_mirror)。Google Android Maven 与 Gradle Plugin Portal 继续用于各自的独有内容。
- 插件解析、项目依赖和 Flutter SDK 的 included Gradle build 都应用相同策略；只修改 `android/settings.gradle.kts` 无法覆盖全部构建。
- 保留 Gradle 缓存，缓存键包含 Flutter 版本、依赖锁定文件及仓库策略；不执行 `--refresh-dependencies` 或清空依赖缓存。
- 将 Gradle worker 上限控制为 2，降低冷缓存时的并发下载。不增加短间隔重复请求。

初始化脚本只改 Central 的已知地址，不改私有仓库地址，不关闭 TLS 校验，也不改变 Flutter included build 的 `FAIL_ON_PROJECT_REPOS` 规则。

测试入口：

```sh
python3 -m unittest discover -s scripts/tests -p test_android_ci_repositories.py -v
```

设置 `MARKER_GRADLE_EXECUTABLE` 指向本机 Gradle 并配置合适的 `JAVA_HOME` 时，还会执行离线复合构建测试，验证主项目和 Flutter 风格的 included build 均生效；普通发布脚本测试会跳过此可选 Gradle 测试。

本地验证可使用独立临时 Gradle 用户目录并复用已有依赖缓存，避免把 CI 策略长期安装到开发机。此次修复未使用本机虚拟机。

如果调整策略后仍出现 429，保留具体下载地址判断是 Central、Plugin Portal 还是 Google Maven 返回限流；不要仅凭插件加载器错误更换 Kotlin 版本。[Sonatype 对 429 的说明](https://central.sonatype.org/faq/429-error/)。
