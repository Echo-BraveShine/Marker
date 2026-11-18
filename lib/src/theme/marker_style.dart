import 'package:flutter/widgets.dart';

/// Desktop metrics aligned with EJson's WorkbenchStyle.
abstract final class MarkerStyle {
  static const space4 = 4.0;
  static const space8 = 8.0;
  static const space12 = 12.0;
  static const space16 = 16.0;
  static const space20 = 20.0;
  static const controlRadius = 7.0;
  static const groupRadius = 11.0;
  static const floatingRadius = 15.0;
  static const settingsRowHeight = 56.0;
  static const body = TextStyle(fontSize: 13, height: 1.38);
  static const heading = TextStyle(
    fontSize: 15,
    height: 1.3,
    letterSpacing: -.15,
    fontWeight: FontWeight.w600,
  );
}
