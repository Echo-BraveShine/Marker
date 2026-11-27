import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:marker/src/l10n/app_localizations.dart';
import 'package:marker/src/providers/theme_provider.dart';

void main() {
  test(
    'language tags preserve scripts and regions with deterministic fallbacks',
    () {
      const cases = {
        'zh': 'zh-Hans',
        'zh_CN': 'zh-Hans',
        'zh-TW': 'zh-Hant',
        'zh-HK': 'zh-Hant',
        'zh-MO': 'zh-Hant',
        'zh-Hans-TW': 'zh-Hans',
        'zh-Hant-CN': 'zh-Hant',
        'pt': 'pt-BR',
        'pt-PT': 'pt-BR',
        'en-GB': 'en',
        'in-ID': 'id',
        'unknown': 'en',
      };
      for (final entry in cases.entries) {
        expect(normalizeLanguageTag(entry.key), entry.value);
        expect(
          AppLocalizations.languageTagForLocale(
            AppLocalizations.localeForLanguage(entry.key),
          ),
          entry.value,
        );
      }
      expect(
        AppLocalizations.languageTagForLocale(
          AppLocalizations.resolveLocales(const [
            Locale('xx'),
            Locale('ja', 'JP'),
          ]),
        ),
        'ja',
      );
      expect(
        AppLocalizations.languageTagForLocale(
          AppLocalizations.resolveLocales(const [Locale('zh', 'TW')]),
        ),
        'zh-Hant',
      );
      expect(
        AppLocalizations.resolveLocales(const [Locale('xx')]),
        const Locale('en', 'US'),
      );
    },
  );
  test(
    'legacy language choice migrates and full locale selections survive restart',
    () async {
      SharedPreferences.setMockInitialValues({'languageCode': 'zh'});
      var container = ProviderContainer();
      await container.read(themeProvider.notifier).init();
      expect(container.read(themeProvider).followSystemLanguage, isFalse);
      expect(
        AppLocalizations.languageTagForLocale(
          container.read(themeProvider).locale,
        ),
        'zh-Hans',
      );
      await container
          .read(themeProvider.notifier)
          .setLocale(AppLocalizations.localeForLanguage('zh-Hant'));
      container.dispose();
      container = ProviderContainer();
      await container.read(themeProvider.notifier).init();
      expect(
        AppLocalizations.languageTagForLocale(
          container.read(themeProvider).locale,
        ),
        'zh-Hant',
      );
      await container
          .read(themeProvider.notifier)
          .setLocale(AppLocalizations.localeForLanguage('pt-BR'));
      container.dispose();
      container = ProviderContainer();
      await container.read(themeProvider.notifier).init();
      expect(
        AppLocalizations.languageTagForLocale(
          container.read(themeProvider).locale,
        ),
        'pt-BR',
      );
      await container.read(themeProvider.notifier).setLocale(null);
      container.dispose();
      container = ProviderContainer();
      addTearDown(container.dispose);
      await container.read(themeProvider.notifier).init();
      expect(container.read(themeProvider).followSystemLanguage, isTrue);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('localeTag'), 'system');
      expect(prefs.containsKey('languageCode'), isFalse);
    },
  );
}
