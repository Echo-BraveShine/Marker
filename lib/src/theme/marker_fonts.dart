import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';

/// Every explicit UI style must retain the bundled Chinese fallback.
abstract final class MarkerFonts {
  static const cjkFamily = 'Marker Noto Sans SC';
  static String get ui => switch (defaultTargetPlatform) {
    TargetPlatform.linux => cjkFamily,
    TargetPlatform.windows => 'Segoe UI',
    _ => '.SF Pro Text',
  };
  static CupertinoTextThemeData get cupertino {
    const base = CupertinoTextThemeData();
    TextStyle font(TextStyle style) =>
        style.copyWith(fontFamily: ui, fontFamilyFallback: fallback);
    return CupertinoTextThemeData(
      textStyle: font(base.textStyle),
      actionTextStyle: font(base.actionTextStyle),
      tabLabelTextStyle: font(base.tabLabelTextStyle),
      navTitleTextStyle: font(base.navTitleTextStyle),
      navLargeTitleTextStyle: font(base.navLargeTitleTextStyle),
      navActionTextStyle: font(base.navActionTextStyle),
      pickerTextStyle: font(base.pickerTextStyle),
      dateTimePickerTextStyle: font(base.dateTimePickerTextStyle),
    );
  }

  static List<String> get fallback => switch (defaultTargetPlatform) {
    TargetPlatform.linux => [cjkFamily, 'Noto Color Emoji'],
    TargetPlatform.windows => [cjkFamily, 'Segoe UI Emoji'],
    _ => ['PingFang SC', cjkFamily, 'Apple Color Emoji'],
  };
  static String get monospace => switch (defaultTargetPlatform) {
    TargetPlatform.windows => 'Cascadia Code',
    TargetPlatform.linux => 'monospace',
    _ => 'Menlo',
  };
  static List<String> get codeFallback => [
    if (defaultTargetPlatform == TargetPlatform.windows) 'Consolas',
    if (defaultTargetPlatform == TargetPlatform.macOS) 'SF Mono',
    cjkFamily,
    ...fallback.where((family) => family != cjkFamily),
  ];
  static List<String> get serifFallback => ['Georgia', ...fallback];
}
