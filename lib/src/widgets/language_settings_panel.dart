import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Theme;
import '../l10n/app_localizations.dart';
import '../theme/marker_colors.dart';
import '../theme/marker_style.dart';
import 'marker_dialog.dart';

class LanguageSettingsPanel extends StatelessWidget {
  const LanguageSettingsPanel({super.key, required this.selected});
  final String selected;
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).extension<MarkerColors>()!;
    final choices = [
      ('system', l10n.message(AppMessage.followSystemLanguage)),
      for (final language in appLanguages) (language.tag, language.nativeName),
    ];
    return MarkerDialog(
      title: Text(l10n.interfaceLanguage),
      width: 460,
      height: 520,
      scrollable: false,
      content: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: colors.bgEditor,
          border: Border.all(color: colors.separatorSoft),
          borderRadius: BorderRadius.circular(MarkerStyle.groupRadius),
        ),
        child: ListView.separated(
          key: const Key('language-list'),
          padding: const EdgeInsets.symmetric(vertical: 4),
          itemCount: choices.length,
          separatorBuilder: (_, _) => Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            color: colors.separatorSoft,
          ),
          itemBuilder: (context, index) {
            final choice = choices[index];
            return CupertinoButton(
              key: ValueKey('language-${choice.$1}'),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              onPressed: () => Navigator.pop(context, choice.$1),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      choice.$2,
                      style: TextStyle(fontSize: 13, color: colors.textPrimary),
                    ),
                  ),
                  if (selected == choice.$1)
                    Icon(
                      CupertinoIcons.check_mark,
                      size: 16,
                      color: colors.textAccent,
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
