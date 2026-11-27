import 'package:flutter/cupertino.dart';
import 'package:marker/src/widgets/markdown_commands.dart';
import 'package:flutter/material.dart' show Tooltip;
import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:marker/main.dart';
import 'package:marker/src/l10n/app_localizations.dart';
import 'package:marker/src/providers/theme_provider.dart';
import 'package:marker/src/widgets/markdown_extensions.dart';

void main() {
  for (final language in appLanguages) {
    testWidgets(
      '${language.tag} renders phone controls, syntax and language picker',
      (tester) async {
        SharedPreferences.setMockInitialValues({'localeTag': language.tag});
        mobileWindow = {
          TargetPlatform.android,
          TargetPlatform.iOS,
        }.contains(defaultTargetPlatform);
        addTearDown(() {
          mobileWindow = false;
        });
        await tester.binding.setSurfaceSize(
          mobileWindow ? const Size(844, 390) : const Size(900, 600),
        );
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final container = ProviderContainer(
          overrides: [mermaidPreviewEnabledProvider.overrideWithValue(false)],
        );
        addTearDown(container.dispose);
        await container.read(themeProvider.notifier).init();
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MarkerApp(),
          ),
        );
        await tester.pumpAndSettle();
        final context = tester.element(
          find.byKey(const Key('document-sidebar')),
        );
        final l10n = AppLocalizations.of(context);
        expect(l10n.languageTag, language.tag);
        expect(find.text(l10n.settings), findsWidgets);
        // Narrow toolbars may only show headings; widen to expose syntax tips.
        await tester.binding.setSurfaceSize(const Size(2200, 600));
        await tester.pumpAndSettle();
        final bold = markdownCommandGroups.values
            .expand((commands) => commands)
            .firstWhere((command) => command.label == '粗体');
        expect(find.byTooltip(bold.labelFor(language.tag)), findsOneWidget);
        final tips = tester.widgetList<Tooltip>(find.byType(Tooltip));
        if (!language.tag.startsWith('zh')) {
          expect(tips.map((tip) => tip.message), isNot(contains('粗体')));
        }
        await tester.binding.setSurfaceSize(
          mobileWindow ? const Size(844, 390) : const Size(900, 600),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip(l10n.allMarkdownSyntax));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('syntax-floating-panel')), findsOneWidget);
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(CupertinoIcons.gear));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('settings-language')));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('language-list')), findsOneWidget);
        await tester.tap(find.byKey(const ValueKey('language-en')));
        await tester.pumpAndSettle();
        expect(container.read(themeProvider).followSystemLanguage, isFalse);
        expect(
          AppLocalizations.of(
            tester.element(find.byKey(const Key('document-sidebar'))),
          ).languageTag,
          'en',
        );
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      },
      variant: TargetPlatformVariant({
        TargetPlatform.android,
        TargetPlatform.iOS,
        TargetPlatform.macOS,
        TargetPlatform.windows,
        TargetPlatform.linux,
      }),
    );
  }
  testWidgets(
    'system language changes are live until a manual choice is made',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final dispatcher = tester.binding.platformDispatcher;
      dispatcher.localesTestValue = const [Locale('ja', 'JP')];
      addTearDown(() {
        dispatcher.localesTestValue = const [Locale('zh', 'CN')];
      });
      final container = ProviderContainer(
        overrides: [mermaidPreviewEnabledProvider.overrideWithValue(false)],
      );
      addTearDown(container.dispose);
      await container.read(themeProvider.notifier).init();
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MarkerApp(),
        ),
      );
      await tester.pumpAndSettle();
      String language() => AppLocalizations.of(
        tester.element(find.byKey(const Key('document-sidebar'))),
      ).languageTag;
      expect(language(), 'ja');
      dispatcher.localesTestValue = const [Locale('zh', 'TW')];
      await tester.pumpAndSettle();
      expect(language(), 'zh-Hant');
      await container
          .read(themeProvider.notifier)
          .setLocale(AppLocalizations.localeForLanguage('fr'));
      await tester.pumpAndSettle();
      dispatcher.localesTestValue = const [Locale('ko', 'KR')];
      await tester.pumpAndSettle();
      expect(language(), 'fr');
      await container.read(themeProvider.notifier).setLocale(null);
      await tester.pumpAndSettle();
      expect(language(), 'ko');
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
