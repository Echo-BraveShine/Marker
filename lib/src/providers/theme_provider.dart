import '../l10n/app_localizations.dart';
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
    @Default(true) bool followSystemLanguage,
    @Default(220.0) double sidebarWidth,
    @Default(true) bool sidebarExpanded,
    @Default(false) bool highlightEnabled,
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
    final language =
        prefs.getString('localeTag') ??
        prefs.getString('languageCode') ??
        'system';
    final highlightName = prefs.getString('editorHighlightStyle');
    final highlightStyle = EditorHighlightStyle.values.firstWhere(
      (style) => style.name == highlightName,
      orElse: () => EditorHighlightStyle.classic,
    );
    if (!ref.mounted) return;
    state = SettingsState(
      mode: mode,
      sidebarExpanded: prefs.getBool('sidebarExpanded') ?? true,
      sidebarWidth: (prefs.getDouble('sidebarWidth') ?? 220)
          .clamp(180, 320)
          .toDouble(),
      highlightStyle: highlightStyle,
      highlightEnabled: prefs.getBool('editorHighlightEnabled') ?? false,
      locale: AppLocalizations.localeForLanguage(
        language == 'system' ? 'en' : language,
      ),
      followSystemLanguage: language == 'system',
    );
  }

  Future<void> setSidebarExpanded(bool expanded) async {
    state = state.copyWith(sidebarExpanded: expanded);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sidebarExpanded', expanded);
  }

  void setSidebarWidth(double width) =>
      state = state.copyWith(sidebarWidth: width.clamp(180, 320).toDouble());

  Future<void> persistSidebarWidth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('sidebarWidth', state.sidebarWidth);
  }

  Future<void> setHighlightEnabled(bool enabled) async {
    state = state.copyWith(highlightEnabled: enabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('editorHighlightEnabled', enabled);
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

  Future<void> setLocale(Locale? locale) async {
    final tag = locale == null
        ? 'system'
        : AppLocalizations.languageTagForLocale(locale);
    state = state.copyWith(
      locale: locale == null
          ? state.locale
          : AppLocalizations.localeForLanguage(tag),
      followSystemLanguage: locale == null,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('localeTag', tag);
    // The new tag is authoritative; remove the old lossy language-only value.
    await prefs.remove('languageCode');
  }
}
