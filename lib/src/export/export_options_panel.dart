import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Theme;
import '../theme/marker_colors.dart';
import '../theme/marker_style.dart';
import '../widgets/marker_dialog.dart';
import 'document_exporter.dart';

class ExportOptionsPanel extends StatefulWidget {
  const ExportOptionsPanel({super.key, required this.zh});
  final bool zh;
  @override
  State<ExportOptionsPanel> createState() => _ExportOptionsPanelState();
}

class _ExportOptionsPanelState extends State<ExportOptionsPanel> {
  DocumentExportFormat _format = DocumentExportFormat.pdf;
  bool _followTheme = false;
  int _width = 1280;
  String t(String zh, String en) => widget.zh ? zh : en;
  @override
  Widget build(BuildContext context) {
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
      title: Text(t('导出文档', 'Export document')),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            t('格式', 'Format'),
            style: TextStyle(fontSize: 12, color: c.textSecondary),
          ),
          const SizedBox(height: 10),
          group(
            CupertinoSlidingSegmentedControl<DocumentExportFormat>(
              backgroundColor: c.bgSidebar,
              thumbColor: Theme.of(context).brightness == Brightness.dark
                  ? c.separator
                  : c.bgEditor,
              groupValue: _format,
              children: const {
                DocumentExportFormat.pdf: Text('PDF'),
                DocumentExportFormat.png: Text('PNG'),
                DocumentExportFormat.html: Text('HTML'),
              },
              onValueChanged: (value) {
                if (value != null) setState(() => _format = value);
              },
            ),
          ),
          const SizedBox(height: 16),
          if (_format == DocumentExportFormat.pdf)
            Text(
              t(
                'A4 自动分页，文字可选择与复制。包含公式、Mermaid 与图片。',
                'A4 pages with selectable, copyable text, including equations, Mermaid and images.',
              ),
              style: TextStyle(fontSize: 13, color: c.textSecondary),
            )
          else ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    t('跟随应用深浅主题', 'Use app appearance'),
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                CupertinoSwitch(
                  value: _followTheme,
                  onChanged: (value) => setState(() => _followTheme = value),
                ),
              ],
            ),
            if (_format == DocumentExportFormat.png) ...[
              const SizedBox(height: 16),
              Text(
                t('图片宽度（px）', 'Image width (px)'),
                style: TextStyle(fontSize: 12, color: c.textSecondary),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: CupertinoSlidingSegmentedControl<int>(
                  groupValue: _width,
                  children: const {
                    960: Text('960'),
                    1280: Text('1280'),
                    1600: Text('1600'),
                  },
                  onValueChanged: (value) {
                    if (value != null) setState(() => _width = value);
                  },
                ),
              ),
            ] else ...[
              const SizedBox(height: 12),
              Text(
                t(
                  '独立 HTML，包含图片与图表，可离线查看。',
                  'Self-contained HTML with embedded images and diagrams, available offline.',
                ),
                style: TextStyle(fontSize: 13, color: c.textSecondary),
              ),
            ],
          ],
        ],
      ),
      actions: [
        MarkerDialogButton(
          primary: true,
          onPressed: () => Navigator.pop(
            context,
            DocumentExportOptions(
              format: _format,
              followTheme: _followTheme,
              width: _width,
            ),
          ),
          child: Text(t('导出', 'Export')),
        ),
      ],
    );
  }
}
