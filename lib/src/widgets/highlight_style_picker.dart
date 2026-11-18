import 'package:flutter/cupertino.dart';
import '../theme/highlight_style.dart';
import '../theme/marker_colors.dart';
import '../theme/marker_style.dart';

class HighlightStylePicker extends StatelessWidget {
  const HighlightStylePicker({
    super.key,
    required this.selected,
    required this.colors,
    required this.zh,
    required this.onChanged,
  });
  final EditorHighlightStyle selected;
  final MarkerColors colors;
  final bool zh;
  final ValueChanged<EditorHighlightStyle> onChanged;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final columns = constraints.maxWidth >= 460 ? 3 : 2;
      final width = (constraints.maxWidth - (columns - 1) * 8) / columns;
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final style in EditorHighlightStyle.values)
            SizedBox(
              width: width,
              child: Semantics(
                selected: selected == style,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: selected == style
                        ? colors.bgSelected
                        : colors.bgToolbar,
                    borderRadius: BorderRadius.circular(
                      MarkerStyle.controlRadius,
                    ),
                    border: Border.all(
                      color: selected == style
                          ? colors.textAccent
                          : colors.separatorSoft,
                    ),
                  ),
                  child: CupertinoButton(
                    key: ValueKey('highlight-${style.name}'),
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.all(10),
                    onPressed: () => onChanged(style),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                style.label(zh),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colors.textPrimary,
                                ),
                              ),
                            ),
                            if (selected == style)
                              Icon(
                                CupertinoIcons.check_mark,
                                size: 12,
                                color: colors.textAccent,
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            for (final role in [
                              HighlightRole.title,
                              HighlightRole.keyword,
                              HighlightRole.string,
                              HighlightRole.number,
                              HighlightRole.comment,
                            ])
                              Padding(
                                padding: const EdgeInsets.only(right: 5),
                                child: Container(
                                  width: 10,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: HighlightPalette.from(
                                      style,
                                      colors,
                                    )[role],
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    },
  );
}
