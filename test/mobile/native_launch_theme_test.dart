import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'iOS native launch uses system-adaptive background and light/dark logos',
    () {
      final storyboard = File(
        'ios/Runner/Base.lproj/LaunchScreen.storyboard',
      ).readAsStringSync();
      expect(storyboard, contains('launchScreen="YES"'));
      expect(storyboard, contains('image="LaunchImage"'));
      expect(storyboard, contains('name="LaunchBackground"'));
      final plist = File('ios/Runner/Info.plist').readAsStringSync();
      expect(
        plist,
        matches(
          RegExp(
            r'<key>UIUserInterfaceStyle</key>\s*<string>Automatic</string>',
          ),
        ),
      );
      expect(
        plist,
        matches(
          RegExp(
            r'<key>UILaunchStoryboardName</key>\s*<string>LaunchScreen</string>',
          ),
        ),
      );
      const base = 'ios/Runner/Assets.xcassets';
      final images =
          (jsonDecode(
                    File(
                      '$base/LaunchImage.imageset/Contents.json',
                    ).readAsStringSync(),
                  )
                  as Map)['images']
              as List;
      for (final scale in ['1x', '2x', '3x']) {
        final variants = images
            .where((image) => image['scale'] == scale)
            .toList();
        expect(variants, hasLength(2));
        expect(
          variants.where((image) => image['appearances'] != null),
          hasLength(1),
        );
        final light = variants.firstWhere(
          (image) => image['appearances'] == null,
        );
        final dark = variants.firstWhere(
          (image) => image['appearances'] != null,
        );
        expect(
          dark['appearances'],
          equals([
            {'appearance': 'luminosity', 'value': 'dark'},
          ]),
        );
        final a = File(
          '$base/LaunchImage.imageset/${light['filename']}',
        ).readAsBytesSync();
        final b = File(
          '$base/LaunchImage.imageset/${dark['filename']}',
        ).readAsBytesSync();
        expect(a, isNotEmpty);
        expect(b, isNot(equals(a)));
      }
      final colors =
          (jsonDecode(
                    File(
                      '$base/LaunchBackground.colorset/Contents.json',
                    ).readAsStringSync(),
                  )
                  as Map)['colors']
              as List;
      expect(colors, hasLength(2));
      expect(
        colors.last['appearances'],
        equals([
          {'appearance': 'luminosity', 'value': 'dark'},
        ]),
      );
      expect(colors.first['color'], isNot(equals(colors.last['color'])));
    },
  );

  test('Android native launch has day/night themes including Android 12', () {
    const res = 'android/app/src/main/res';
    for (final folder in [
      'values',
      'values-night',
      'values-v31',
      'values-night-v31',
    ]) {
      final styles = File('$res/$folder/styles.xml').readAsStringSync();
      expect(styles, contains('name="LaunchTheme"'));
      if (folder.endsWith('v31')) {
        expect(styles, contains('android:windowSplashScreenBackground'));
        expect(
          styles,
          contains('android:windowSplashScreenIconBackgroundColor'),
        );
        expect(styles, contains('@drawable/splash_logo'));
      }
    }
    expect(
      File('$res/values/colors.xml').readAsStringSync(),
      isNot(equals(File('$res/values-night/colors.xml').readAsStringSync())),
    );
    for (final density in ['mdpi', 'hdpi', 'xhdpi', 'xxhdpi', 'xxxhdpi']) {
      final light = File(
        '$res/drawable-$density/splash_logo.png',
      ).readAsBytesSync();
      final dark = File(
        '$res/drawable-night-$density/splash_logo.png',
      ).readAsBytesSync();
      expect(light, isNotEmpty);
      expect(dark, isNot(equals(light)));
    }
  });
}
