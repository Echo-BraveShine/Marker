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
  testWidgets(
    'shows actual version and offers release downloads after checking',
    (tester) async {
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
            theme: MarkerAppTheme().light(),
            home: const Scaffold(body: AboutSettings(zh: true)),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('版本 1.0.0 (7)'), findsOneWidget);
      await tester.tap(find.byKey(const Key('check-updates')));
      await tester.pumpAndSettle();
      expect(find.text('发现新版本 1.2.0'), findsOneWidget);
      expect(find.byKey(const Key('download-update')), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('no public release does not appear as an application failure', (
    tester,
  ) async {
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
          theme: MarkerAppTheme().light(),
          home: const Scaffold(body: AboutSettings(zh: true)),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('check-updates')));
    await tester.pumpAndSettle();
    expect(find.text('暂未找到公开发布版本。'), findsOneWidget);
    expect(find.byKey(const Key('download-update')), findsNothing);
  });
}
