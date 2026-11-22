part of '../app_localizations.dart';

class StringsZh implements AppStrings {
  @override
  String get title => 'Marker';

  @override
  String get recoveredUnsavedDoc => '已恢复未保存的文档';

  @override
  String get file => '文件';

  @override
  String get openFile => '打开文件';

  @override
  String get save => '保存';

  @override
  String get export => '导出';

  @override
  String get exportHtml => '导出 HTML';

  @override
  String get exportPdf => '导出 PDF';

  @override
  String get settings => '设置';

  @override
  String get theme => '主题';

  @override
  String get themeLight => '浅色';

  @override
  String get themeDark => '深色';

  @override
  String get themeSystem => '系统';

  @override
  String get fontSize => '字号';

  @override
  String get language => '语言';

  @override
  String get languageZh => '简体中文';

  @override
  String get languageEn => 'English';

  @override
  String get edit => '编辑';

  @override
  String get preview => '预览';

  @override
  String get split => '分屏';

  @override
  String get statusLine => '第 1 行，第 1 列';

  // 文档操作
  @override
  String get closeDocument => '关闭文档';

  @override
  String get rename => '重命名…';

  @override
  String get moveToTrash => '移到废纸篓…';

  @override
  String get moveToTrashPrompt => '将文档移到废纸篓？';

  @override
  String get moveToTrashContent => '文档文件将移到废纸篓，关联图片会保留。未保存的编辑内容将关闭。';

  @override
  String get saveAs => '另存为';

  @override
  String get saveChanges => '保存更改？';

  @override
  String get discard => '不保存';

  @override
  String get pathConflict => '该路径已由另一个打开的文档使用，请选择其他路径。';

  @override
  String get saveCancelled => '已取消保存，文档内容已保留。';

  @override
  String get fileOperationFailed => '文件操作失败';

  @override
  String get unableToExport => '无法导出文档';

  // 资源侧边栏
  @override
  String get importImages => '导入图片';

  @override
  String get stopRemainingWork => '停止后续处理';

  @override
  String get cannotReadImages => '无法读取图片，请检查目录权限。';

  @override
  String get importOrPasteImages => '导入图片或将截图粘贴到编辑区。\n原图会保留，资源目录按需创建。';

  @override
  String get customSyntaxUnchanged => '部分特殊语法保持原样';

  @override
  String get localImages => '本地图片';

  @override
  String get webImages => '网络图片';

  @override
  String get needsAttention => '需要处理';

  @override
  String get managed => '已管理';

  @override
  String get linkedUrl => '保留网址';

  @override
  String get clickToRepair => '点击修复';

  // 导出选项
  @override
  String get exportFormat => '格式';

  @override
  String get exportA4Info => 'A4 自动分页，文字可选择与复制。包含公式、Mermaid 与图片。';

  @override
  String get useAppAppearance => '跟随应用深浅主题';

  @override
  String get imageWidth => '图片宽度（px）';

  @override
  String get selfContainedHtml => '独立 HTML，包含图片与图表，可离线查看。';

  @override
  String get exportButton => '导出';

  // 关于设置
  @override
  String get version => '版本';

  @override
  String get loadingVersion => '读取版本中…';

  @override
  String get unsavedDoc => '有未保存的内容';

  @override
  String get unsupportedLinkType => '不支持此链接类型';

  @override
  String get webImageLoadFailed => '网络图片加载失败';

  @override
  String get cannotAccessImage => '无法访问图片，请授权目录';

  @override
  String get imageNotFound => '图片未找到';

  @override
  String get locateImage => '重新定位图片';

  @override
  String get allowImageFolderAndRetry => '授权图片所在目录并重试';

  @override
  String get reloadImage => '重新加载图片';

  @override
  String get saveToResolveImages => '保存文档以解析相对路径图片';

  @override
  String get stop => '停止';

  @override
  String get toggleSidebar => '切换侧栏';

  @override
  String get resources => '资源';

  @override
  String get files => '文件';

  @override
  String get documents => '文档列表';

  @override
  String get documentResources => '文档资源';

  @override
  String get newDocument => '新建';

  @override
  String get openDocument => '打开';

  @override
  String get undo => '撤销';

  @override
  String get redo => '重做';

  @override
  String get findAndReplace => '搜索替换';

  @override
  String get textColor => '文字颜色';

  @override
  String get equationTemplates => '公式模板';

  @override
  String get mermaidTemplates => 'Mermaid 模板';

  @override
  String get allMarkdownSyntax => '全部 Markdown 语法';

  @override
  String get serifFont => '衬线字体';

  @override
  String get startWriting => '开始书写…';

  @override
  String get auto => '自动';

  @override
  String get lightTheme => '浅色';

  @override
  String get darkTheme => '深色';

  @override
  String get general => '通用';

  @override
  String get editorAndPreview => '编辑与预览';

  @override
  String get keyboardShortcuts => '快捷键';

  @override
  String get about => '关于';

  @override
  String get appearance => '外观';

  @override
  String get interfaceLanguage => '界面语言';

  @override
  String get versionUnavailable => '版本信息暂不可用';

  @override
  String get focusedMarkdown => '专注 Markdown 写作与即时预览。';

  @override
  String get checkForUpdates => '检查更新';

  @override
  String get versionAvailable => '发现新版本';

  @override
  String get requestLimited => '请求受限，请稍后重试。';

  @override
  String get cannotConnect => '无法连接，请检查网络后重试。';

  @override
  String get cannotReadVersion => '无法读取当前版本信息，请重试。';

  @override
  String get invalidReleaseInfo => '版本信息格式异常，请稍后重试。';

  @override
  String get checkFailed => '检查失败，请重试或查看发布页面。';

  @override
  String get viewAndDownload => '查看并下载';

  @override
  String get releases => '发布页面';
}

/// 英文实现
