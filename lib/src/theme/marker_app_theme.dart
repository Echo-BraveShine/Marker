import 'marker_fonts.dart';
import 'package:flutter/material.dart';
import 'package:marker/src/theme/marker_colors.dart';
import 'package:marker/src/theme/marker_typography.dart';

class MarkerAppTheme {
  ThemeData light() {
    return ThemeData(
      useMaterial3: false,
      fontFamily: MarkerFonts.ui,
      fontFamilyFallback: MarkerFonts.fallback,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF0066CC),
        surface: Color(0xFFFFFFFF),
        onSurface: Color(0xFF1D1D1F),
        onPrimary: Colors.white,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: MarkerColors.light.bgEditor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      extensions: const [MarkerColors.light],
      textTheme: MarkerTextTheme.light.apply(
        fontFamily: MarkerFonts.ui,
        fontFamilyFallback: MarkerFonts.fallback,
      ),
      dividerColor: MarkerColors.light.separator,
    );
  }

  ThemeData dark() {
    return ThemeData(
      useMaterial3: false,
      fontFamily: MarkerFonts.ui,
      fontFamilyFallback: MarkerFonts.fallback,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF3D9BFF),
        surface: Color(0xFF1A1A1C),
        onSurface: Color(0xFFF5F5F7),
        onPrimary: Colors.white,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: MarkerColors.dark.bgEditor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      extensions: const [MarkerColors.dark],
      textTheme: MarkerTextTheme.dark.apply(
        fontFamily: MarkerFonts.ui,
        fontFamilyFallback: MarkerFonts.fallback,
      ),
      dividerColor: MarkerColors.dark.separator,
    );
  }
}
