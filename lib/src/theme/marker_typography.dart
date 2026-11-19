import 'package:flutter/material.dart';
import 'marker_fonts.dart';

/// Markdown 编辑预览专用字体令牌，跟随浅/深主题自动适配
class MarkerTypography {
  MarkerTypography._internal();
  static final MarkerTypography _instance = MarkerTypography._internal();
  factory MarkerTypography() => _instance;

  // 编辑区等宽字体（平台相关）
  String get editorFontFamily => MarkerFonts.monospace;

  // UI 与中文回退统一使用平台字体令牌。
  String get uiFontFamily => MarkerFonts.ui;

  // Markdown 正文字号：15pt，行高 1.7
  double get previewBaseFontSize => 15.0;

  // 段间距
  double get previewParagraphSpacing => 4.0;

  // 代码块字号：编辑区字号 - 1
  double get codeBlockFontSize => 13.0;

  // 行高系数
  double get editorLineHeight => 1.6;
  double get previewLineHeight => 1.7;
  double get codeBlockLineHeight => 1.5;
}

// 以下为预设字号阶梯（供 pubspec.yaml 中的 TextTheme 扩展使用）
// Markdown 标题 H1-H6 对应的字号比例
class MarkerTextTheme {
  // 浅色主题文本主题
  static TextTheme light = TextTheme(
    displayLarge: const TextStyle(
      fontSize: 57,
      fontWeight: FontWeight.w400,
      color: Color(0xFF1D1D1F),
    ),
    displayMedium: const TextStyle(
      fontSize: 45,
      fontWeight: FontWeight.w400,
      color: Color(0xFF1D1D1F),
    ),
    displaySmall: const TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.w400,
      color: Color(0xFF1D1D1F),
    ),
    headlineLarge: const TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w400,
      color: Color(0xFF1D1D1F),
    ),
    headlineMedium: const TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w400,
      color: Color(0xFF1D1D1F),
    ),
    headlineSmall: const TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w400,
      color: Color(0xFF1D1D1F),
    ),
    titleLarge: const TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w400,
      color: Color(0xFF1D1D1F),
    ),
    titleMedium: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: Color(0xFF1D1D1F),
    ),
    titleSmall: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: Color(0xFF1D1D1F),
    ),
    bodyLarge: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: Color(0xFF1D1D1F),
    ),
    bodyMedium: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: Color(0xFF1D1D1F),
    ),
    bodySmall: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: Color(0xFF6E6E73),
    ),
    labelLarge: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.normal,
      color: Color(0xFF1D1D1F),
    ),
    labelMedium: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: Color(0xFF6E6E73),
    ),
    labelSmall: const TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.normal,
      color: Color(0xFF6E6E73),
    ),
  );

  // 深色主题文本主题
  static TextTheme dark = TextTheme(
    displayLarge: const TextStyle(
      fontSize: 57,
      fontWeight: FontWeight.w400,
      color: Color(0xFFF5F5F7),
    ),
    displayMedium: const TextStyle(
      fontSize: 45,
      fontWeight: FontWeight.w400,
      color: Color(0xFFF5F5F7),
    ),
    displaySmall: const TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.w400,
      color: Color(0xFFF5F5F7),
    ),
    headlineLarge: const TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w400,
      color: Color(0xFFF5F5F7),
    ),
    headlineMedium: const TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w400,
      color: Color(0xFFF5F5F7),
    ),
    headlineSmall: const TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w400,
      color: Color(0xFFF5F5F7),
    ),
    titleLarge: const TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w400,
      color: Color(0xFFF5F5F7),
    ),
    titleMedium: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: Color(0xFFF5F5F7),
    ),
    titleSmall: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: Color(0xFFF5F5F7),
    ),
    bodyLarge: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: Color(0xFFF5F5F7),
    ),
    bodyMedium: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: Color(0xFFF5F5F7),
    ),
    bodySmall: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: Color(0xFF98989D),
    ),
    labelLarge: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.normal,
      color: Color(0xFFF5F5F7),
    ),
    labelMedium: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: Color(0xFF98989D),
    ),
    labelSmall: const TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.normal,
      color: Color(0xFF98989D),
    ),
  );
}
