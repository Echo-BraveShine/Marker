import 'message_catalog.dart';
export 'message_catalog.dart';
import 'package:flutter/material.dart';

part 'app_strings.dart';
part 'translations/strings_zh.dart';
part 'translations/strings_en.dart';
part 'translations/catalog_strings.dart';

/// Typed multilingual resources with script/region-aware locale resolution.
class AppLocalizations {
  const AppLocalizations(this.locale);

  final Locale locale;
  static Locale _locale(AppLanguage language) => Locale.fromSubtags(
    languageCode: language.languageCode,
    scriptCode: language.scriptCode,
    countryCode: language.countryCode,
  );
  static final supportedLocales = List<Locale>.unmodifiable(
    appLanguages.map(_locale),
  );
  static Locale localeForLanguage(String code) => _locale(appLanguageFor(code));
  static String languageTagForLocale(Locale locale) =>
      normalizeLanguageTag(locale.toLanguageTag());
  static Locale resolveLocales(List<Locale>? locales) {
    for (final locale in locales ?? const <Locale>[]) {
      final language = locale.languageCode.toLowerCase();
      if (appLanguages.any((l) => l.languageCode == language) ||
          language == 'in') {
        return localeForLanguage(locale.toLanguageTag());
      }
    }
    return supportedLocales.first;
  }

  String get languageTag => languageTagForLocale(locale);
  String languageName(String code) => appLanguageFor(code).nativeName;

  String message(AppMessage key, [Map<String, Object?> arguments = const {}]) =>
      localizedMessage(languageTag, key, arguments);

  static String languageTagOf(BuildContext context, {bool? fallbackChinese}) {
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations);
    if (l10n != null) return l10n.languageTag;
    return fallbackChinese == null
        ? languageTagForLocale(Localizations.localeOf(context))
        : languageTagFrom(fallbackChinese);
  }

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  AppStrings get strings => CatalogStrings(languageTag);

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

  String get exportDocument => message(AppMessage.exportDocument);
  String get format => exportFormat;
  String get exportingDocument => message(AppMessage.exportingDocument);
  String get manualCheckForUpdates =>
      message(AppMessage.checkTheLatestPublicReleaseOnGitHub);
  String get checkingForUpdates => message(AppMessage.checkingForUpdates);
  String get noPublicRelease => message(AppMessage.noPublicReleaseWasFound);
  String get currentVersion => message(AppMessage.youAreUpToDate);
}

extension AppLocalizationsX on AppLocalizations {
  String exportedTo(String path) =>
      message(AppMessage.exportedToValue, {"p0": path});
  String unsavedChangesWithName(String name) =>
      message(AppMessage.valueHasUnsavedChanges2, {"p0": name});
  String versionAvailableStr(String latest) =>
      message(AppMessage.versionValueIsAvailable, {"p0": latest});
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => appLanguages.any(
    (language) => language.languageCode == locale.languageCode,
  );

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) => false;
}
