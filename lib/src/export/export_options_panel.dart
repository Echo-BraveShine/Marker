import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Theme;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/marker_colors.dart';
import '../theme/marker_style.dart';
import '../widgets/marker_dialog.dart';
import '../l10n/app_localizations.dart';
import 'document_exporter.dart';

class ExportOptionsPanel extends ConsumerWidget {
  const ExportOptionsPanel({super.key, required this.zh});
  final bool zh;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final options = ref.watch(documentExportOptionsProvider);
    void update(DocumentExportOptions Function(DocumentExportOptions) change) =>
        ref.read(documentExportOptionsProvider.notifier).update(change);
    final c = Theme.of(context).extension<MarkerColors>()!;
    Widget group(Widget child) => Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.bgEditor,
        borderRadius: BorderRadius.circular(MarkerStyle.groupRadius),
        border: Border.all(color: c.separatorSoft),
      ),
      child: child,
    );
    return MarkerDialog(
      width: 440,
      title: Text(l10n.exportDocument),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.format,
            style: TextStyle(fontSize: 12, color: c.textSecondary),
          ),
          const SizedBox(height: 10),
          group(
            CupertinoSlidingSegmentedControl<DocumentExportFormat>(
              backgroundColor: c.bgSidebar,
              thumbColor: Theme.of(context).brightness == Brightness.dark
                  ? c.separator
                  : c.bgEditor,
              groupValue: options.format,
              children: const {
                DocumentExportFormat.pdf: Text('PDF'),
                DocumentExportFormat.png: Text('PNG'),
                DocumentExportFormat.html: Text('HTML'),
              },
              onValueChanged: (value) {
                if (value != null) {
                  update((state) => state.copyWith(format: value));
                }
              },
            ),
          ),
          const SizedBox(height: 16),
          if (options.format == DocumentExportFormat.pdf)
            Text(
              l10n.exportA4Info,
              style: TextStyle(fontSize: 13, color: c.textSecondary),
            )
          else ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.useAppAppearance,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                CupertinoSwitch(
                  value: options.followTheme,
                  onChanged: (value) =>
                      update((state) => state.copyWith(followTheme: value)),
                ),
              ],
            ),
            if (options.format == DocumentExportFormat.png) ...[
              const SizedBox(height: 16),
              Text(
                l10n.imageWidth,
                style: TextStyle(fontSize: 12, color: c.textSecondary),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: CupertinoSlidingSegmentedControl<int>(
                  groupValue: options.width,
                  children: const {
                    960: Text('960'),
                    1280: Text('1280'),
                    1600: Text('1600'),
                  },
                  onValueChanged: (value) {
                    if (value != null) {
                      update((state) => state.copyWith(width: value));
                    }
                  },
                ),
              ),
            ] else ...[
              const SizedBox(height: 12),
              Text(
                l10n.selfContainedHtml,
                style: TextStyle(fontSize: 13, color: c.textSecondary),
              ),
            ],
          ],
        ],
      ),
      actions: [
        MarkerDialogButton(
          primary: true,
          onPressed: () =>
              Navigator.pop(context, ref.read(documentExportOptionsProvider)),
          child: Text(l10n.exportButton),
        ),
      ],
    );
  }
}