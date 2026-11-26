part of '../../main.dart';

extension _HomeToolbar on _MarkerHomeState {
  Widget _buildToolbar({
    required MarkerColors c,
    required Widget Function(IconData, String, void Function()) button,
    required Widget Function(Widget, String, void Function(), {Key? key})
    syntaxControl,
    required MarkdownCommand Function(String) commandByLabel,
  }) => Container(
    height: 44,
    color: c.bgToolbar,
    child: Row(
      children: [
        button(
          CupertinoIcons.doc_append,
          _l10n.newDocument,
          () => _action(_newFile),
        ),
        button(CupertinoIcons.folder, _l10n.openDocument, () => _action(_open)),
        button(
          CupertinoIcons.square_arrow_down_on_square,
          _l10n.saveAs,
          () => _action(() async {
            await _save(as: true);
          }),
        ),
        if (documentExportEnabled)
          button(
            CupertinoIcons.square_arrow_up,
            _l10n.exportButton,
            _exportDocument,
          ),
        button(CupertinoIcons.arrow_uturn_left, _l10n.undo, _undo.undo),
        button(CupertinoIcons.arrow_uturn_right, _l10n.redo, _undo.redo),
        button(
          CupertinoIcons.search,
          _l10n.findAndReplace,
          () => _openSearch(replace: true),
        ),
        Container(
          width: 1,
          height: 16,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          color: c.separatorSoft,
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final controls = <Widget>[
                for (final label in ['H1', 'H2', 'H3'])
                  syntaxControl(
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: c.textSecondary,
                      ),
                    ),
                    label,
                    () => _runMarkdownCommand(commandByLabel(label)),
                  ),
                for (final entry in <(String, IconData)>[
                  ('粗体', CupertinoIcons.bold),
                  ('斜体', CupertinoIcons.italic),
                  ('删除线', CupertinoIcons.strikethrough),
                  ('链接', CupertinoIcons.link),
                  ('图片', CupertinoIcons.photo),
                  ('无序列表', CupertinoIcons.list_bullet),
                  ('有序列表', CupertinoIcons.list_number),
                  ('任务列表', CupertinoIcons.checkmark_square),
                  ('引用', CupertinoIcons.quote_bubble),
                  ('行内代码', CupertinoIcons.chevron_left_slash_chevron_right),
                  ('代码块', CupertinoIcons.doc_text),
                  ('表格', CupertinoIcons.table),
                  ('分隔线', CupertinoIcons.minus),
                ])
                  syntaxControl(
                    Icon(entry.$2, size: 16, color: c.textSecondary),
                    entry.$1,
                    () => _runMarkdownCommand(commandByLabel(entry.$1)),
                  ),
                syntaxControl(
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        CupertinoIcons.textformat,
                        size: 15,
                        color: c.textSecondary,
                      ),
                      const SizedBox(height: 2),
                      Container(
                        width: 14,
                        height: 3,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          gradient: const LinearGradient(
                            colors: [
                              CupertinoColors.systemRed,
                              CupertinoColors.systemYellow,
                              CupertinoColors.systemGreen,
                              CupertinoColors.systemBlue,
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  _l10n.textColor,
                  _chooseTextColor,
                  key: const Key('text-color-toolbar'),
                ),
                syntaxControl(
                  Icon(
                    CupertinoIcons.function,
                    size: 16,
                    color: c.textSecondary,
                  ),
                  _l10n.equationTemplates,
                  () => _chooseTemplate(math: true),
                ),
                syntaxControl(
                  Icon(
                    CupertinoIcons.flowchart,
                    size: 16,
                    color: c.textSecondary,
                  ),
                  t('Mermaid 模板', 'Mermaid templates'),
                  () => _chooseTemplate(math: false),
                ),
              ];
              const represented = {
                'H1',
                'H2',
                'H3',
                '粗体',
                '斜体',
                '删除线',
                '链接',
                '图片',
                '无序列表',
                '有序列表',
                '任务列表',
                '引用',
                '行内代码',
                '代码块',
                '表格',
                '分隔线',
                '文字颜色',
                '行内公式',
                '块公式',
                'Mermaid',
              };
              const labels = {
                'Setext H1': 'S1',
                'Setext H2': 'S2',
                '粗斜体': 'BI',
                '换行': '↵',
                '段落': '¶',
                '转义': '\\',
                '已完成': '✓',
                '嵌套列表': '嵌套',
                '嵌套引用': '双引',
                '缩进代码': '缩进',
                '引用式链接': '引用链',
                '自动链接': '自动',
                '邮件': '@',
                '脚注': '[^]',
              };
              for (final command
                  in markdownCommandGroups.values
                      .expand((items) => items)
                      .where(
                        (command) => !represented.contains(command.label),
                      )) {
                controls.add(
                  syntaxControl(
                    Text(
                      labels[command.label] ?? command.label,
                      maxLines: 1,
                      overflow: TextOverflow.fade,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: c.textSecondary,
                      ),
                    ),
                    command.label,
                    () => _runMarkdownCommand(command),
                  ),
                );
              }
              final priority = [
                0,
                1,
                3,
                4,
                16,
                5,
                17,
                18,
                6,
                7,
                8,
                9,
                10,
                11,
                12,
                13,
                14,
                15,
                2,
                for (var i = 19; i < controls.length; i++) i,
              ];
              final count = (constraints.maxWidth / 32).floor().clamp(
                0,
                controls.length,
              );
              return Row(
                key: const Key('markdown-toolbar-syntax'),
                children: [
                  for (final index in priority.take(count))
                    Expanded(child: controls[index]),
                ],
              );
            },
          ),
        ),
        button(
          ref.watch(editorProvider).toolbarExpanded
              ? CupertinoIcons.chevron_up
              : CupertinoIcons.chevron_down,
          _l10n.allMarkdownSyntax,
          () => ref
              .read(editorProvider.notifier)
              .update((s) => s.copyWith(toolbarExpanded: !s.toolbarExpanded)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: CupertinoSlidingSegmentedControl<int>(
            groupValue: _mode,
            children: {
              0: Text(_l10n.edit, style: const TextStyle(fontSize: 12)),
              1: Text(_l10n.split, style: const TextStyle(fontSize: 12)),
              2: Text(_l10n.preview, style: const TextStyle(fontSize: 12)),
            },
            onValueChanged: (v) {
              if (v != null) _mode = v;
            },
          ),
        ),
      ],
    ),
  );
}
