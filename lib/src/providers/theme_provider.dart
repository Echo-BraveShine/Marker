import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/highlight_style.dart';
part 'theme_provider.freezed.dart';

@freezed
abstract class SettingsState with _$SettingsState {
  const factory SettingsState({
    @Default(ThemeMode.system) ThemeMode mode,
    @Default(Locale('zh', 'CN')) Locale locale,
    @Default(220.0) double sidebarWidth,
    @Default(EditorHighlightStyle.classic) EditorHighlightStyle highlightStyle,
  }) = _SettingsState;
}

final themeProvider = NotifierProvider<SettingsNotifier, SettingsState>(
  SettingsNotifier.new,
);

class SettingsNotifier extends Notifier<SettingsState> {
  @override
  SettingsState build() => const SettingsState();
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final mode = switch (prefs.getString('themeMode')) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    final language = prefs.getString('languageCode') ?? 'zh';
    final highlightName = prefs.getString('editorHighlightStyle');
    final highlightStyle = EditorHighlightStyle.values.firstWhere(
      (style) => style.name == highlightName,
      orElse: () => EditorHighlightStyle.classic,
    );
    if (!ref.mounted) return;
    state = SettingsState(
      mode: mode,
      sidebarWidth: (prefs.getDouble('sidebarWidth') ?? 220)
          .clamp(180, 320)
          .toDouble(),
      highlightStyle: highlightStyle,
      locale: Locale(language, language == 'zh' ? 'CN' : 'US'),
    );
  }

  void setSidebarWidth(double width) =>
      state = state.copyWith(sidebarWidth: width.clamp(180, 320).toDouble());

  Future<void> persistSidebarWidth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('sidebarWidth', state.sidebarWidth);
  }

  Future<void> setHighlightStyle(EditorHighlightStyle style) async {
    state = state.copyWith(highlightStyle: style);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('editorHighlightStyle', style.name);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(mode: mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', mode.name);
  }

  Future<void> setLocale(Locale locale) async {
    state = state.copyWith(locale: locale);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', locale.languageCode);
  }
}
