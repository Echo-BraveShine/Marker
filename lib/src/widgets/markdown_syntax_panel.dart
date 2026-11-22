import 'marker_floating_surface.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Theme;
import '../theme/marker_colors.dart';
import 'markdown_commands.dart';

class MarkdownSyntaxPanel extends StatelessWidget {
  const MarkdownSyntaxPanel({
    super.key,
    required this.onCommand,
    required this.onClose,
    required this.enabled,
  });
  final ValueChanged<MarkdownCommand> onCommand;
  final VoidCallback onClose;
  final bool enabled;
  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<MarkerColors>()!;
    final zh = Localizations.localeOf(context).languageCode == 'zh';
    return MarkerFloatingSurface(
      key: const Key('syntax-floating-panel'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 8, 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    zh ? 'Markdown 语法' : 'Markdown syntax',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: c.textPrimary,
                    ),
                  ),
                ),
                CupertinoButton(
                  key: const Key('syntax-panel-close'),
                  padding: const EdgeInsets.all(4),
                  minimumSize: Size.zero,
                  onPressed: onClose,
                  child: Icon(
                    CupertinoIcons.xmark,
                    size: 12,
                    color: c.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    zh ? '点击插入 · 可继续在左侧编辑' : 'Insert at cursor · Keep editing',
                    style: TextStyle(fontSize: 11, color: c.textSecondary),
                  ),
                  for (final group in markdownCommandGroups.entries)
                    Padding(
                      padding: const EdgeInsets.only(top: 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            markdownGroupLabel(group.key, zh),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: c.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          LayoutBuilder(
                            builder: (context, constraints) => Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                for (final command in group.value)
                                  SizedBox(
                                    width: constraints.maxWidth < 180
                                        ? constraints.maxWidth
                                        : (constraints.maxWidth - 6) / 2,
                                    child: CupertinoButton(
                                      key: ValueKey(
                                        'md-command-${command.label}',
                                      ),
                                      alignment: Alignment.centerLeft,
                                      minimumSize: Size.zero,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 9,
                                      ),
                                      color: c.bgEditor,
                                      borderRadius: BorderRadius.circular(7),
                                      onPressed: enabled
                                          ? () => onCommand(
                                              command.forLanguage(zh),
                                            )
                                          : null,
                                      child: Text(
                                        command.labelFor(zh),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: c.textPrimary,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
