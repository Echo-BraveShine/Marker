import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Theme;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/update_provider.dart';
import '../theme/marker_colors.dart';
import '../theme/marker_style.dart';
import '../l10n/app_localizations.dart';
import 'marker_logo.dart';
import 'settings_option_row.dart';

/// Uses the same flat rows as general and editor settings.
class AboutSettings extends ConsumerWidget {
  const AboutSettings({super.key, required this.zh, this.onOpenExample});
  final bool zh;
  final VoidCallback? onOpenExample;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = Theme.of(context).extension<MarkerColors>()!;
    final info = ref.watch(packageInfoProvider);
    return Container(
      decoration: BoxDecoration(
        color: c.bgEditor,
        borderRadius: BorderRadius.circular(MarkerStyle.groupRadius),
        border: Border.all(color: c.separatorSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          SettingsOptionRow(
            key: const Key('about-app-info'),
            leading: const MarkerLogo(size: 16),
            title: 'Marker',
            control: Text(
              info.when(
                data: (value) => '${l10n.version} ${value.version}',
                loading: () => l10n.loadingVersion,
                error: (_, _) => l10n.versionUnavailable,
              ),
              style: MarkerStyle.body.copyWith(color: c.textSecondary),
            ),
          ),
          if (onOpenExample != null) ...[
            Padding(
              padding: const EdgeInsets.only(left: 36),
              child: Container(height: 1, color: c.separatorSoft),
            ),
            CupertinoButton(
              key: const Key('open-example'),
              alignment: Alignment.centerLeft,
              minimumSize: Size.zero,
              padding: EdgeInsets.zero,
              onPressed: onOpenExample,
              child: SettingsOptionRow(
                leading: Icon(
                  CupertinoIcons.book,
                  size: 16,
                  color: c.textSecondary,
                ),
                title: messageForLanguage(
                  AppLocalizations.languageTagOf(context, fallbackChinese: zh),
                  AppMessage.openExample,
                ),
                control: Icon(
                  CupertinoIcons.chevron_right,
                  size: 12,
                  color: c.textSecondary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
