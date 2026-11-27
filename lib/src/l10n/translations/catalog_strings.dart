part of '../app_localizations.dart';

class CatalogStrings implements AppStrings {
  const CatalogStrings(this.languageTag);
  final String languageTag;
  @override
  String get title => localizedMessage(languageTag, AppMessage.title);
  @override
  String get recoveredUnsavedDoc =>
      localizedMessage(languageTag, AppMessage.recoveredUnsavedDoc);
  @override
  String get file => localizedMessage(languageTag, AppMessage.file);
  @override
  String get openFile => localizedMessage(languageTag, AppMessage.openFile);
  @override
  String get save => localizedMessage(languageTag, AppMessage.save);
  @override
  String get export => localizedMessage(languageTag, AppMessage.export);
  @override
  String get exportHtml => localizedMessage(languageTag, AppMessage.exportHtml);
  @override
  String get exportPdf => localizedMessage(languageTag, AppMessage.exportPdf);
  @override
  String get settings => localizedMessage(languageTag, AppMessage.settings);
  @override
  String get theme => localizedMessage(languageTag, AppMessage.theme);
  @override
  String get themeLight => localizedMessage(languageTag, AppMessage.themeLight);
  @override
  String get themeDark => localizedMessage(languageTag, AppMessage.themeDark);
  @override
  String get themeSystem =>
      localizedMessage(languageTag, AppMessage.themeSystem);
  @override
  String get fontSize => localizedMessage(languageTag, AppMessage.fontSize);
  @override
  String get language => localizedMessage(languageTag, AppMessage.language);
  @override
  String get languageZh => localizedMessage(languageTag, AppMessage.languageZh);
  @override
  String get languageEn => localizedMessage(languageTag, AppMessage.languageEn);
  @override
  String get edit => localizedMessage(languageTag, AppMessage.edit);
  @override
  String get preview => localizedMessage(languageTag, AppMessage.preview);
  @override
  String get split => localizedMessage(languageTag, AppMessage.split);
  @override
  String get statusLine => localizedMessage(languageTag, AppMessage.statusLine);
  @override
  String get closeDocument =>
      localizedMessage(languageTag, AppMessage.closeDocument);
  @override
  String get rename => localizedMessage(languageTag, AppMessage.rename);
  @override
  String get moveToTrash =>
      localizedMessage(languageTag, AppMessage.moveToTrash);
  @override
  String get moveToTrashPrompt =>
      localizedMessage(languageTag, AppMessage.moveToTrashPrompt);
  @override
  String get moveToTrashContent =>
      localizedMessage(languageTag, AppMessage.moveToTrashContent);
  @override
  String get saveAs => localizedMessage(languageTag, AppMessage.saveAs);
  @override
  String get saveChanges =>
      localizedMessage(languageTag, AppMessage.saveChanges);
  @override
  String get discard => localizedMessage(languageTag, AppMessage.discard);
  @override
  String get pathConflict =>
      localizedMessage(languageTag, AppMessage.pathConflict);
  @override
  String get saveCancelled =>
      localizedMessage(languageTag, AppMessage.saveCancelled);
  @override
  String get fileOperationFailed =>
      localizedMessage(languageTag, AppMessage.fileOperationFailed);
  @override
  String get unableToExport =>
      localizedMessage(languageTag, AppMessage.unableToExport);
  @override
  String get importImages =>
      localizedMessage(languageTag, AppMessage.importImages);
  @override
  String get stopRemainingWork =>
      localizedMessage(languageTag, AppMessage.stopRemainingWork);
  @override
  String get cannotReadImages =>
      localizedMessage(languageTag, AppMessage.cannotReadImages);
  @override
  String get importOrPasteImages =>
      localizedMessage(languageTag, AppMessage.importOrPasteImages);
  @override
  String get customSyntaxUnchanged =>
      localizedMessage(languageTag, AppMessage.customSyntaxUnchanged);
  @override
  String get localImages =>
      localizedMessage(languageTag, AppMessage.localImages);
  @override
  String get webImages => localizedMessage(languageTag, AppMessage.webImages);
  @override
  String get needsAttention =>
      localizedMessage(languageTag, AppMessage.needsAttention);
  @override
  String get managed => localizedMessage(languageTag, AppMessage.managed);
  @override
  String get linkedUrl => localizedMessage(languageTag, AppMessage.linkedUrl);
  @override
  String get clickToRepair =>
      localizedMessage(languageTag, AppMessage.clickToRepair);
  @override
  String get exportFormat =>
      localizedMessage(languageTag, AppMessage.exportFormat);
  @override
  String get exportA4Info =>
      localizedMessage(languageTag, AppMessage.exportA4Info);
  @override
  String get useAppAppearance =>
      localizedMessage(languageTag, AppMessage.useAppAppearance);
  @override
  String get imageWidth => localizedMessage(languageTag, AppMessage.imageWidth);
  @override
  String get selfContainedHtml =>
      localizedMessage(languageTag, AppMessage.selfContainedHtml);
  @override
  String get exportButton => localizedMessage(languageTag, AppMessage.export);
  @override
  String get version => localizedMessage(languageTag, AppMessage.version);
  @override
  String get loadingVersion =>
      localizedMessage(languageTag, AppMessage.loadingVersion);
  @override
  String get unsavedDoc => localizedMessage(languageTag, AppMessage.unsavedDoc);
  @override
  String get unsupportedLinkType =>
      localizedMessage(languageTag, AppMessage.unsupportedLinkType);
  @override
  String get webImageLoadFailed =>
      localizedMessage(languageTag, AppMessage.webImageLoadFailed);
  @override
  String get cannotAccessImage =>
      localizedMessage(languageTag, AppMessage.cannotAccessImage);
  @override
  String get imageNotFound =>
      localizedMessage(languageTag, AppMessage.imageNotFound);
  @override
  String get locateImage =>
      localizedMessage(languageTag, AppMessage.locateImage);
  @override
  String get allowImageFolderAndRetry =>
      localizedMessage(languageTag, AppMessage.allowImageFolderAndRetry);
  @override
  String get reloadImage =>
      localizedMessage(languageTag, AppMessage.reloadImage);
  @override
  String get saveToResolveImages =>
      localizedMessage(languageTag, AppMessage.saveToResolveImages);
  @override
  String get stop => localizedMessage(languageTag, AppMessage.stop);
  @override
  String get toggleSidebar =>
      localizedMessage(languageTag, AppMessage.toggleSidebar);
  @override
  String get resources => localizedMessage(languageTag, AppMessage.resources);
  @override
  String get files => localizedMessage(languageTag, AppMessage.files);
  @override
  String get documents => localizedMessage(languageTag, AppMessage.documents);
  @override
  String get documentResources =>
      localizedMessage(languageTag, AppMessage.documentResources);
  @override
  String get newDocument =>
      localizedMessage(languageTag, AppMessage.newDocument);
  @override
  String get openDocument =>
      localizedMessage(languageTag, AppMessage.openDocument);
  @override
  String get undo => localizedMessage(languageTag, AppMessage.undo);
  @override
  String get redo => localizedMessage(languageTag, AppMessage.redo);
  @override
  String get findAndReplace =>
      localizedMessage(languageTag, AppMessage.findAndReplace);
  @override
  String get textColor => localizedMessage(languageTag, AppMessage.textColor);
  @override
  String get equationTemplates =>
      localizedMessage(languageTag, AppMessage.equationTemplates);
  @override
  String get mermaidTemplates =>
      localizedMessage(languageTag, AppMessage.mermaidTemplates);
  @override
  String get allMarkdownSyntax =>
      localizedMessage(languageTag, AppMessage.allMarkdownSyntax);
  @override
  String get serifFont => localizedMessage(languageTag, AppMessage.serifFont);
  @override
  String get startWriting =>
      localizedMessage(languageTag, AppMessage.startWriting);
  @override
  String get auto => localizedMessage(languageTag, AppMessage.auto);
  @override
  String get lightTheme => localizedMessage(languageTag, AppMessage.themeLight);
  @override
  String get darkTheme => localizedMessage(languageTag, AppMessage.themeDark);
  @override
  String get general => localizedMessage(languageTag, AppMessage.general);
  @override
  String get editorAndPreview =>
      localizedMessage(languageTag, AppMessage.editorAndPreview);
  @override
  String get keyboardShortcuts =>
      localizedMessage(languageTag, AppMessage.keyboardShortcuts);
  @override
  String get about => localizedMessage(languageTag, AppMessage.about);
  @override
  String get appearance => localizedMessage(languageTag, AppMessage.appearance);
  @override
  String get interfaceLanguage =>
      localizedMessage(languageTag, AppMessage.interfaceLanguage);
  @override
  String get versionUnavailable =>
      localizedMessage(languageTag, AppMessage.versionUnavailable);
  @override
  String get focusedMarkdown =>
      localizedMessage(languageTag, AppMessage.focusedMarkdown);
  @override
  String get checkForUpdates =>
      localizedMessage(languageTag, AppMessage.checkForUpdates);
  @override
  String get versionAvailable =>
      localizedMessage(languageTag, AppMessage.versionAvailable);
  @override
  String get requestLimited =>
      localizedMessage(languageTag, AppMessage.requestLimited);
  @override
  String get cannotConnect =>
      localizedMessage(languageTag, AppMessage.cannotConnect);
  @override
  String get cannotReadVersion =>
      localizedMessage(languageTag, AppMessage.cannotReadVersion);
  @override
  String get invalidReleaseInfo =>
      localizedMessage(languageTag, AppMessage.invalidReleaseInfo);
  @override
  String get checkFailed =>
      localizedMessage(languageTag, AppMessage.checkFailed);
  @override
  String get viewAndDownload =>
      localizedMessage(languageTag, AppMessage.viewAndDownload);
  @override
  String get releases => localizedMessage(languageTag, AppMessage.releases);
}
