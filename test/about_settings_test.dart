import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:marker/src/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:marker/src/providers/release_updates.dart';
import 'package:marker/src/providers/update_provider.dart';
import 'package:marker/src/theme/marker_app_theme.dart';
import 'package:marker/src/widgets/about_settings.dart';

class _FakeReleaseClient extends GitHubReleaseClient {
  _FakeReleaseClient(this.status);
  final ReleaseStatus status;
  @override
  Future<ReleaseResult> check(String installed) async =>
      (status: status, latest: '1.2.0', page: releasePage);
}

void main() {
  testWidgets('shows version and example without donation or update controls', (
    tester,
  ) async {
    var exampleOpened = false;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          packageInfoProvider.overrideWith(
            (ref) async => PackageInfo(
              appName: 'Marker',
              packageName: 'dev.ekko.marker',
              version: '1.0.0',
              buildNumber: '7',
            ),
          ),
          releaseClientProvider.overrideWithValue(
            _FakeReleaseClient(ReleaseStatus.available),
          ),
        ],
        child: MaterialApp(
          locale: const Locale('zh', 'CN'),
          supportedLocales: const [Locale('zh', 'CN'), Locale('en', 'US')],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: MarkerAppTheme().light(),
          home: Scaffold(
            body: AboutSettings(
              zh: true,
              onOpenExample: () => exampleOpened = true,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('版本 1.0.0'), findsOneWidget);
    expect(find.textContaining('(7)'), findsNothing);
    expect(find.text('GitHub'), findsNothing);
    expect(find.byKey(const Key('about-app-info')), findsOneWidget);
    expect(find.byKey(const Key('buy-coffee')), findsNothing);
    expect(find.text('请我喝杯咖啡'), findsNothing);
    expect(find.text('打开示例'), findsOneWidget);
    final exampleRow = tester.getRect(find.byKey(const Key('open-example')));
    await tester.tapAt(Offset(exampleRow.right - 20, exampleRow.center.dy));
    expect(exampleOpened, isTrue);
    for (final key in [
      'check-updates',
      'download-update',
      'release-page',
      'update-status',
    ]) {
      expect(find.byKey(Key(key)), findsNothing);
    }
    expect(tester.takeException(), isNull);
  });
  testWidgets('about does not expose release controls', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          packageInfoProvider.overrideWith(
            (ref) async => PackageInfo(
              appName: 'Marker',
              packageName: 'dev.ekko.marker',
              version: '1.0.0',
              buildNumber: '1',
            ),
          ),
          releaseClientProvider.overrideWithValue(
            _FakeReleaseClient(ReleaseStatus.noRelease),
          ),
        ],
        child: MaterialApp(
          locale: const Locale('zh', 'CN'),
          supportedLocales: const [Locale('zh', 'CN'), Locale('en', 'US')],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: MarkerAppTheme().light(),
          home: const Scaffold(body: AboutSettings(zh: true)),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('check-updates')), findsNothing);
    expect(find.byKey(const Key('release-page')), findsNothing);
    expect(find.byKey(const Key('download-update')), findsNothing);
  });
}
