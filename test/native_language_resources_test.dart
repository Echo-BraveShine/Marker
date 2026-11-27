import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:marker/src/l10n/message_catalog.dart';
import 'package:marker/src/theme/marker_fonts.dart';

void main() {
  test(
    'Apple projects declare and package every supported system language',
    () {
      for (final platform in ['ios', 'macos']) {
        final plist = File('$platform/Runner/Info.plist').readAsStringSync();
        final localizations = RegExp(
          r'<key>CFBundleLocalizations</key>\s*<array>(.*?)</array>',
          dotAll: true,
        ).firstMatch(plist)![1]!;
        expect(
          RegExp(
            r'<string>(.*?)</string>',
          ).allMatches(localizations).map((m) => m[1]!).toSet(),
          supportedLanguageCodes.toSet(),
        );
        final project = File(
          '$platform/Runner.xcodeproj/project.pbxproj',
        ).readAsStringSync();
        expect(project, contains('InfoPlist.strings in Resources'));
        for (final language in appLanguages) {
          final path = '${language.tag}.lproj/InfoPlist.strings';
          expect(project, contains(path));
          final strings = File('$platform/Runner/$path').readAsStringSync();
          expect(strings, contains('NSLocalNetworkUsageDescription'));
          if (platform == 'ios') {
            expect(strings, contains('NSCameraUsageDescription'));
            expect(strings, contains('NSPhotoLibraryUsageDescription'));
          }
        }
      }
    },
  );
  test('Android per-app language list matches Flutter locale registration', () {
    final xml = File(
      'android/app/src/main/res/xml/locales_config.xml',
    ).readAsStringSync();
    expect(
      RegExp(
        r'android:name="([^"]+)"',
      ).allMatches(xml).map((m) => m[1]!).toSet(),
      supportedLanguageCodes.toSet(),
    );
    expect(
      File('android/app/src/main/AndroidManifest.xml').readAsStringSync(),
      contains('@xml/locales_config'),
    );
  });
  test(
    'offline fallback fonts cover Korean and extended Latin on minimal systems',
    () {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      for (final family in [
        MarkerFonts.koreanFamily,
        MarkerFonts.latinFamily,
      ]) {
        expect(pubspec, contains('family: $family'));
        expect(MarkerFonts.fallback, contains(family));
      }
      for (final file in [
        'assets/fonts/NotoSansKR.ttf',
        'assets/fonts/MarkerSans-Regular.ttf',
        'assets/fonts/MarkerSans-Bold.ttf',
        'assets/export/fonts/MarkerKorean-Regular.woff2',
        'assets/export/fonts/MarkerKorean-Bold.woff2',
        'assets/fonts/OFL-NotoSansKR.txt',
      ]) {
        expect(File(file).lengthSync(), greaterThan(1000));
      }
    },
  );
}
