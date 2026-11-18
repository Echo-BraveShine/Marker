import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Theme;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/update_provider.dart';
import '../providers/release_updates.dart';
import '../theme/marker_colors.dart';
import '../theme/marker_style.dart';
import 'marker_logo.dart';

class AboutSettings extends ConsumerWidget {
  const AboutSettings({super.key, required this.zh});
  final bool zh;
  String t(String chinese, String english) => zh ? chinese : english;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = Theme.of(context).extension<MarkerColors>()!;
    final info = ref.watch(packageInfoProvider);
    final update = ref.watch(updateProvider);
    final message = switch (update.status) {
      ReleaseStatus.idle => t(
        '手动检查 GitHub 上的最新公开版本。',
        'Check the latest public release on GitHub.',
      ),
      ReleaseStatus.checking => t('正在检查更新…', 'Checking for updates…'),
      ReleaseStatus.noRelease => t(
        '暂未找到公开发布版本。',
        'No public release was found.',
      ),
      ReleaseStatus.current => t('当前已是最新版本。', 'You are up to date.'),
      ReleaseStatus.available => t(
        '发现新版本 ${update.latest}',
        'Version ${update.latest} is available',
      ),
      ReleaseStatus.error => switch (update.error) {
        UpdateError.restricted => t(
          '请求受限，请稍后重试。',
          'Request limited. Try again later.',
        ),
        UpdateError.network => t(
          '无法连接，请检查网络后重试。',
          'Cannot connect. Check your connection and retry.',
        ),
        UpdateError.invalidData => t(
          '版本信息格式异常，请稍后重试。',
          'Invalid release information. Try again later.',
        ),
        _ => t(
          '检查失败，请重试或查看发布页面。',
          'Check failed. Retry or visit the releases page.',
        ),
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
                            '${t('版本', 'Version')} ${value.version}${value.buildNumber.isEmpty ? '' : ' (${value.buildNumber})'}',
                        loading: () => t('读取版本中…', 'Loading version…'),
                        error: (_, _) => t('版本信息暂不可用', 'Version unavailable'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            t(
              '专注 Markdown 写作与即时预览。',
              'Focused Markdown writing and live preview.',
            ),
            style: TextStyle(color: c.textSecondary),
          ),
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
                  t('检查更新', 'Check for updates'),
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
                    t('查看并下载', 'View and download'),
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
        ],
      ),
    );
  }
}
