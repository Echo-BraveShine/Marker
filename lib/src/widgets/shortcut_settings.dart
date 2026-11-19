import '../theme/marker_fonts.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Theme;
import '../theme/marker_colors.dart';
import '../theme/marker_style.dart';
import 'app_shortcuts.dart';

class ShortcutSettings extends StatelessWidget {
  const ShortcutSettings({super.key, required this.zh});
  final bool zh;
  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<MarkerColors>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(zh ? '快捷键' : 'Keyboard shortcuts', style: MarkerStyle.heading),
        const SizedBox(height: 12),
        Expanded(
          child: Container(
            key: const Key('shortcut-frame'),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: c.bgEditor,
              borderRadius: BorderRadius.circular(MarkerStyle.groupRadius),
              border: Border.all(color: c.separatorSoft),
            ),
            child: ListView.separated(
              key: const PageStorageKey('shortcut-list'),
              padding: const EdgeInsets.symmetric(vertical: 6),
              itemCount: appShortcuts.length,
              separatorBuilder: (_, _) => Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                color: c.separatorSoft,
              ),
              itemBuilder: (context, index) {
                final shortcut = appShortcuts[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          zh ? shortcut.zh : shortcut.en,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        shortcut.display(defaultTargetPlatform),
                        style: TextStyle(
                          fontFamily: MarkerFonts.monospace,
                          fontFamilyFallback: MarkerFonts.codeFallback,
                          fontSize: 12,
                          color: c.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          zh
              ? 'Esc 关闭搜索或语法面板。编辑框内支持系统原生剪贴板与撤销操作。'
              : 'Esc closes search or syntax panel. Text fields retain native clipboard and undo shortcuts.',
          style: TextStyle(fontSize: 11, color: c.textSecondary),
        ),
      ],
    );
  }
}
