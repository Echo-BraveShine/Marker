import 'package:flutter/material.dart';

/// 所有语言实现必须实现的抽象契约
abstract class AppStrings {
  String get title;
  String get file;
  String get openFile;
  String get save;
  String get export;
  String get exportHtml;
  String get exportPdf;
  String get settings;
  String get theme;
  String get themeLight;
  String get themeDark;
  String get themeSystem;
  String get language;
  String get languageZh;
  String get languageEn;
  String get edit;
  String get preview;
  String get split;
  String get statusLine;
}

/// 中文实现
class StringsZh implements AppStrings {
  @override
  String get title => 'Marker';

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
  String get split => '分割线';

  @override
  String get statusLine => '第 1 行，第 1 列';
}

/// 英文实现
class StringsEn implements AppStrings {
  @override
  String get title => 'Marker';

  @override
  String get file => 'File';

  @override
  String get openFile => 'Open File';

  @override
  String get save => 'Save';

  @override
  String get export => 'Export';

  @override
  String get exportHtml => 'Export HTML';

  @override
  String get exportPdf => 'Export PDF';

  @override
  String get settings => 'Settings';

  @override
  String get theme => 'Theme';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System';

  @override
  String get language => 'Language';

  @override
  String get languageZh => '简体中文';

  @override
  String get languageEn => 'English';

  @override
  String get edit => 'Edit';

  @override
  String get preview => 'Preview';

  @override
  String get split => 'Split';

  @override
  String get statusLine => 'Line 1, Column 1';
}

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
