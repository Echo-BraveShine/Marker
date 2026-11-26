import 'package:flutter/cupertino.dart';
import 'marker_dialog.dart';
import 'package:flutter/material.dart' show Theme, SelectableText;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/update_provider.dart';
import '../providers/release_updates.dart';
import '../theme/marker_colors.dart';
import '../theme/marker_style.dart';
import '../l10n/app_localizations.dart';
import 'marker_logo.dart';

class AboutSettings extends ConsumerWidget {
  const AboutSettings({super.key, required this.zh, this.onOpenExample});
  final bool zh;
  final VoidCallback? onOpenExample;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = Theme.of(context).extension<MarkerColors>()!;
    final info = ref.watch(packageInfoProvider);
    final update = ref.watch(updateProvider);
    final message = switch (update.status) {
      ReleaseStatus.idle => l10n.manualCheckForUpdates,
      ReleaseStatus.checking => l10n.checkingForUpdates,
      ReleaseStatus.noRelease => l10n.noPublicRelease,
      ReleaseStatus.current => l10n.currentVersion,
      ReleaseStatus.available => l10n.versionAvailableStr(update.latest ?? ''),
      ReleaseStatus.error => switch (update.error) {
        UpdateError.restricted => l10n.requestLimited,
        UpdateError.network => l10n.cannotConnect,
        UpdateError.version => l10n.cannotReadVersion,
        UpdateError.invalidData => l10n.invalidReleaseInfo,
        _ => l10n.checkFailed,
      },
    };
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.bgEditor,
        borderRadius: BorderRadius.circular(MarkerStyle.groupRadius),
        border: Border.all(color: c.separatorSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const MarkerLogo(size: 56),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Marker', style: MarkerStyle.heading),
                    const SizedBox(height: 4),
                    Text(
                      info.when(
                        data: (value) =>
                            '${l10n.version} ${value.version}${value.buildNumber.isEmpty ? '' : ' (${value.buildNumber})'}',
                        loading: () => l10n.loadingVersion,
                        error: (_, _) => l10n.versionUnavailable,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(l10n.focusedMarkdown, style: TextStyle(color: c.textSecondary)),
          const SizedBox(height: 16),
          Text(
            message,
            key: const Key('update-status'),
            style: TextStyle(color: c.textSecondary),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              CupertinoButton.filled(
                key: const Key('check-updates'),
                minimumSize: Size.zero,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                onPressed: update.status == ReleaseStatus.checking
                    ? null
                    : () => ref.read(updateProvider.notifier).check(),
                child: Text(
                  l10n.checkForUpdates,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              if (update.status == ReleaseStatus.available)
                CupertinoButton(
                  key: const Key('download-update'),
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  onPressed: () => launchUrl(
                    update.page ?? releasePage,
                    mode: LaunchMode.externalApplication,
                  ),
                  child: Text(
                    l10n.viewAndDownload,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              CupertinoButton(
                key: const Key('release-page'),
                minimumSize: Size.zero,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                onPressed: () => launchUrl(
                  releasePage,
                  mode: LaunchMode.externalApplication,
                ),
                child: Text(
                  l10n.releases,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              CupertinoButton(
                minimumSize: Size.zero,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                onPressed: () => launchUrl(
                  repositoryPage,
                  mode: LaunchMode.externalApplication,
                ),
                child: Text('GitHub', style: const TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (onOpenExample != null) ...[
            _AboutActionRow(
              key: const Key('open-example'),
              icon: CupertinoIcons.book,
              title: zh ? '打开示例' : 'Open example',
              subtitle: zh
                  ? '查看完整 Markdown 语法示例'
                  : 'Explore the Markdown syntax examples',
              onPressed: onOpenExample!,
            ),
            const SizedBox(height: 10),
          ],
          _AboutActionRow(
            key: const Key('buy-coffee'),
            icon: CupertinoIcons.heart,
            external: true,
            title: zh ? '请我喝杯咖啡' : 'Buy me a coffee',
            subtitle: zh
                ? '喜欢 Marker？支持它的持续开发。'
                : 'Enjoy Marker? Support its continued development.',
            onPressed: () async {
              var opened = false;
              try {
                opened = await launchUrl(
                  Uri.https('buymeacoffee.com', '/1239383708p'),
                  mode: LaunchMode.externalApplication,
                );
              } catch (_) {
                /* Show a copyable link when no browser is available. */
              }
              if (!opened && context.mounted) {
                await showMarkerDialog<void>(
                  context: context,
                  builder: (_) => MarkerDialog(
                    title: Text(zh ? '无法打开浏览器' : 'Cannot open browser'),
                    content: const SelectableText(
                      'https://buymeacoffee.com/1239383708p',
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

/// Full-row controls share the same quiet surfaces and spacing as settings.
class _AboutActionRow extends StatelessWidget {
  const _AboutActionRow({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onPressed,
    this.external = false,
  });
  final IconData icon;
  final String title, subtitle;
  final VoidCallback onPressed;
  final bool external;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<MarkerColors>()!;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: c.bgWindow,
        borderRadius: BorderRadius.circular(MarkerStyle.controlRadius),
        border: Border.all(color: c.separatorSoft),
      ),
      child: CupertinoButton(
        alignment: Alignment.centerLeft,
        minimumSize: const Size(44, 64),
        padding: const EdgeInsets.all(12),
        onPressed: onPressed,
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: c.bgSelected,
                borderRadius: BorderRadius.circular(MarkerStyle.controlRadius),
              ),
              child: Icon(icon, size: 17, color: c.textAccent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: MarkerStyle.body.copyWith(
                      color: c.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: c.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              external
                  ? CupertinoIcons.arrow_up_right
                  : CupertinoIcons.chevron_right,
              size: 13,
              color: c.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
