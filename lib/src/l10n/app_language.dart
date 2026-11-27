/// Language identity is independent of Flutter and supports script/region tags.
class AppLanguage {
  const AppLanguage(
    this.tag,
    this.nativeName,
    this.languageCode, {
    this.scriptCode,
    this.countryCode,
  });
  final String tag, nativeName, languageCode;
  final String? scriptCode, countryCode;
}

const appLanguages = [
  AppLanguage('en', 'English', 'en', countryCode: 'US'),
  AppLanguage('zh-Hans', '简体中文', 'zh', scriptCode: 'Hans', countryCode: 'CN'),
  AppLanguage('zh-Hant', '繁體中文', 'zh', scriptCode: 'Hant', countryCode: 'TW'),
  AppLanguage('ja', '日本語', 'ja', countryCode: 'JP'),
  AppLanguage('ko', '한국어', 'ko', countryCode: 'KR'),
  AppLanguage('de', 'Deutsch', 'de', countryCode: 'DE'),
  AppLanguage('fr', 'Français', 'fr', countryCode: 'FR'),
  AppLanguage('es', 'Español', 'es', countryCode: 'ES'),
  AppLanguage('pt-BR', 'Português (Brasil)', 'pt', countryCode: 'BR'),
  AppLanguage('it', 'Italiano', 'it', countryCode: 'IT'),
  AppLanguage('ru', 'Русский', 'ru', countryCode: 'RU'),
  AppLanguage('tr', 'Türkçe', 'tr', countryCode: 'TR'),
  AppLanguage('pl', 'Polski', 'pl', countryCode: 'PL'),
  AppLanguage('id', 'Bahasa Indonesia', 'id', countryCode: 'ID'),
];

String normalizeLanguageTag(String tag) {
  final parts = tag.replaceAll('_', '-').toLowerCase().split('-');
  var language = parts.first;
  if (language == 'zh') {
    if (parts.contains('hant')) return 'zh-Hant';
    if (parts.contains('hans')) return 'zh-Hans';
    if (parts.any(['tw', 'hk', 'mo'].contains)) return 'zh-Hant';
    return 'zh-Hans';
  }
  if (language == 'pt') return 'pt-BR';
  if (language == 'in') language = 'id';
  return appLanguages
          .where((l) => l.languageCode == language)
          .firstOrNull
          ?.tag ??
      'en';
}

AppLanguage appLanguageFor(String tag) => appLanguages.firstWhere(
  (language) => language.tag == normalizeLanguageTag(tag),
);

/// Retain compatibility with older callers while accepting full language tags.
String languageTagFrom(Object language) => normalizeLanguageTag(
  language is bool ? (language ? 'zh-Hans' : 'en') : language as String,
);
