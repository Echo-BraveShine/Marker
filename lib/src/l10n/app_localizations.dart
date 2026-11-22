import 'package:flutter/material.dart';

part 'app_strings.dart';
part 'translations/strings_zh.dart';
part 'translations/strings_en.dart';

/// 轻量级 i18n（中/英），不依赖 flutter gen-l10n 生成代码
class AppLocalizations {
  const AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  AppStrings get strings =>
      locale.languageCode == 'en' ? StringsEn() : StringsZh();

  String get title => strings.title;
  String get file => strings.file;
  String get openFile => strings.openFile;
  String get save => strings.save;
  String get export => strings.export;
  String get exportHtml => strings.exportHtml;
  String get exportPdf => strings.exportPdf;
  String get settings => strings.settings;
  String get theme => strings.theme;
  String get themeLight => strings.themeLight;
  String get themeDark => strings.themeDark;
  String get themeSystem => strings.themeSystem;
  String get language => strings.language;
  String get languageZh => strings.languageZh;
  String get languageEn => strings.languageEn;
  String get edit => strings.edit;
  String get preview => strings.preview;
  String get split => strings.split;
  String get statusLine => strings.statusLine;
  String get recoveredUnsavedDoc => strings.recoveredUnsavedDoc;
  String get closeDocument => strings.closeDocument;
  String get rename => strings.rename;
  String get moveToTrash => strings.moveToTrash;
  String get moveToTrashPrompt => strings.moveToTrashPrompt;
  String get moveToTrashContent => strings.moveToTrashContent;
  String get saveAs => strings.saveAs;
  String get saveChanges => strings.saveChanges;
  String get discard => strings.discard;
  String get pathConflict => strings.pathConflict;
  String get saveCancelled => strings.saveCancelled;
  String get fileOperationFailed => strings.fileOperationFailed;
  String get unableToExport => strings.unableToExport;
  String get importImages => strings.importImages;
  String get stopRemainingWork => strings.stopRemainingWork;
  String get cannotReadImages => strings.cannotReadImages;
  String get importOrPasteImages => strings.importOrPasteImages;
  String get customSyntaxUnchanged => strings.customSyntaxUnchanged;
  String get localImages => strings.localImages;
  String get webImages => strings.webImages;
  String get needsAttention => strings.needsAttention;
  String get managed => strings.managed;
  String get linkedUrl => strings.linkedUrl;
  String get clickToRepair => strings.clickToRepair;
  String get exportFormat => strings.exportFormat;
  String get exportA4Info => strings.exportA4Info;
  String get useAppAppearance => strings.useAppAppearance;
  String get imageWidth => strings.imageWidth;
  String get selfContainedHtml => strings.selfContainedHtml;
  String get exportButton => strings.exportButton;
  String get version => strings.version;
  String get loadingVersion => strings.loadingVersion;
  String get versionUnavailable => strings.versionUnavailable;
  String get focusedMarkdown => strings.focusedMarkdown;
  String get checkForUpdates => strings.checkForUpdates;
  String get versionAvailable => strings.versionAvailable;
  String get requestLimited => strings.requestLimited;
  String get cannotConnect => strings.cannotConnect;
  String get cannotReadVersion => strings.cannotReadVersion;
  String get invalidReleaseInfo => strings.invalidReleaseInfo;
  String get checkFailed => strings.checkFailed;
  String get viewAndDownload => strings.viewAndDownload;
  String get releases => strings.releases;
  String get unsavedDoc => strings.unsavedDoc;
  String get unsupportedLinkType => strings.unsupportedLinkType;
  String get webImageLoadFailed => strings.webImageLoadFailed;
  String get cannotAccessImage => strings.cannotAccessImage;
  String get imageNotFound => strings.imageNotFound;
  String get locateImage => strings.locateImage;
  String get allowImageFolderAndRetry => strings.allowImageFolderAndRetry;
  String get reloadImage => strings.reloadImage;
  String get saveToResolveImages => strings.saveToResolveImages;
  String get stop => strings.stop;
  String get toggleSidebar => strings.toggleSidebar;
  String get resources => strings.resources;
  String get files => strings.files;
  String get documents => strings.documents;
  String get documentResources => strings.documentResources;
  String get newDocument => strings.newDocument;
  String get openDocument => strings.openDocument;
  String get undo => strings.undo;
  String get redo => strings.redo;
  String get findAndReplace => strings.findAndReplace;
  String get textColor => strings.textColor;
  String get equationTemplates => strings.equationTemplates;
  String get mermaidTemplates => strings.mermaidTemplates;
  String get allMarkdownSyntax => strings.allMarkdownSyntax;
  String get fontSize => strings.fontSize;
  String get serifFont => strings.serifFont;
  String get startWriting => strings.startWriting;
  String get auto => strings.auto;
  String get lightTheme => strings.lightTheme;
  String get darkTheme => strings.darkTheme;
  String get general => strings.general;
  String get editorAndPreview => strings.editorAndPreview;
  String get keyboardShortcuts => strings.keyboardShortcuts;
  String get about => strings.about;
  String get appearance => strings.appearance;
  String get interfaceLanguage => strings.interfaceLanguage;

  String get exportDocument =>
      locale.languageCode == 'zh' ? '导出文档' : 'Export document';
  String get format => exportFormat;
  String get exportingDocument =>
      locale.languageCode == 'zh' ? '正在导出文档…' : 'Exporting document…';
  String get manualCheckForUpdates => locale.languageCode == 'zh'
      ? '手动检查 GitHub 上的最新公开版本。'
      : 'Check the latest public release on GitHub.';
  String get checkingForUpdates =>
      locale.languageCode == 'zh' ? '正在检查更新…' : 'Checking for updates…';
  String get noPublicRelease => locale.languageCode == 'zh'
      ? '暂未找到公开发布版本。'
      : 'No public release was found.';
  String get currentVersion =>
      locale.languageCode == 'zh' ? '当前已是最新版本。' : 'You are up to date.';
}

extension AppLocalizationsX on AppLocalizations {
  String exportedTo(String path) =>
      locale.languageCode == 'zh' ? '已导出到 $path' : 'Exported to $path';
  String unsavedChangesWithName(String name) => locale.languageCode == 'zh'
      ? '$name 有未保存的内容。'
      : '$name has unsaved changes.';
  String versionAvailableStr(String latest) => locale.languageCode == 'zh'
      ? '发现新版本 $latest'
      : 'Version $latest is available';
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['zh', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) => false;
}
