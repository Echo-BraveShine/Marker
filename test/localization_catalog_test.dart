import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marker/src/l10n/app_localizations.dart';
import 'package:marker/src/widgets/app_shortcuts.dart';
import 'package:marker/src/widgets/markdown_templates.dart';
import 'package:marker/src/resources/resource_service.dart';
import 'package:marker/src/export/export_destination.dart';

void main() {
  Set<String> parameters(String value) =>
      RegExp(r'\{(p\d+)\}').allMatches(value).map((m) => m[1]!).toSet();
  test(
    'all typed messages have Chinese and English with matching parameters',
    () {
      final expected = AppMessage.values.toSet();
      expect(zhMessages.keys.toSet(), expected);
      expect(enMessages.keys.toSet(), expected);
      expect(messageCatalogs.keys.toSet(), supportedLanguageCodes.toSet());
      for (final catalog in messageCatalogs.values) {
        expect(catalog.keys.toSet(), expected);
      }
      for (final key in expected) {
        final zh = zhMessages[key]!, en = enMessages[key]!;
        expect(zh.trim(), isNotEmpty, reason: key.name);
        expect(en.trim(), isNotEmpty, reason: key.name);
        expect(parameters(zh), parameters(en), reason: key.name);
        final values = {
          for (final parameter in parameters(en)) parameter: 'VALUE',
        };
        for (final language in supportedLanguageCodes) {
          final translation = messageCatalogs[language]![key]!;
          expect(
            parameters(translation),
            parameters(en),
            reason: '${key.name}:$language',
          );
          expect(
            translation.trim(),
            isNotEmpty,
            reason: '${key.name}:$language',
          );
          expect(
            localizedMessage(language, key, values),
            isNot(contains(RegExp(r'\{p\d+\}'))),
            reason: '${key.name}:$language',
          );
        }
      }
    },
  );
  test('application views do not reintroduce inline bilingual text', () {
    final pairs = RegExp(
      r"""\bt\(\s*['"]|\b(?:_?zh|chinese)\s*\?\s*['"][^'"]*[\u4e00-\u9fff]""",
    );
    for (final folder in ['home', 'widgets', 'resources', 'export']) {
      for (final file in Directory(
        'lib/src/$folder',
      ).listSync(recursive: true).whereType<File>()) {
        if (!file.path.endsWith('.dart') ||
            file.path.endsWith('.freezed.dart')) {
          continue;
        }
        expect(
          pairs.hasMatch(file.readAsStringSync()),
          isFalse,
          reason: file.path,
        );
      }
    }
  });
  test(
    'parameter substitution preserves literal paths without recursive expansion',
    () {
      const path = r'/tmp/{p0}/中文/$photo.md';
      expect(
        localizedMessage('en', AppMessage.exportedToValue, {'p0': path}),
        'Exported to $path',
      );
      expect(
        () => localizedMessage('zh', AppMessage.exportedToValue),
        throwsArgumentError,
      );
    },
  );
  test(
    'language registration and context-free labels use the same catalog',
    () {
      expect(
        AppLocalizations.supportedLocales
            .map(AppLocalizations.languageTagForLocale)
            .toSet(),
        supportedLanguageCodes.toSet(),
      );
      for (final shortcut in appShortcuts) {
        expect(shortcut.labelFor(true), zhMessages[shortcut.message]);
        expect(shortcut.labelFor(false), enMessages[shortcut.message]);
      }
      for (final template in [...mathTemplates, ...mermaidTemplates]) {
        expect(template.labelFor(true), zhMessages[template.message]);
        expect(template.labelFor(false), enMessages[template.message]);
      }
      expect(
        AppLocalizations.localeForLanguage('en'),
        const Locale('en', 'US'),
      );
      expect(
        AppLocalizations.localeForLanguage('unsupported'),
        const Locale('en', 'US'),
      );
    },
  );
  test(
    'localized failures keep compatibility while translating their details',
    () {
      final failure = const ResourceFailure.localized(
        AppMessage.cannotReadOriginalImage,
      );
      expect(failure.localize('zh'), '读取原图失败');
      expect(failure.localize('en'), 'Cannot read original image');
      const legacy = ResourceFailure('测试', 'Test');
      expect(legacy.zh, '测试');
      expect(legacy.en, 'Test');
      const export = ExportDestinationException.localized(
        AppMessage.unsupportedExportFormat,
      );
      expect(export.zh, '不支持的导出格式');
      expect(export.en, 'Unsupported export format');
    },
  );
}
