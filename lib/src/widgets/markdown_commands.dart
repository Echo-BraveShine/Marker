import '../l10n/message_catalog.dart';
import '../l10n/syntax_messages.dart';
import 'package:flutter/services.dart';

class MarkdownCommand {
  const MarkdownCommand(
    this.label,
    this.before,
    this.after,
    this.placeholder, {
    this.block = false,
  });
  final String label, before, after, placeholder;
  final bool block;

  String labelFor(Object zh) => localizedSyntaxText(label, zh);

  /// Keep the command identity stable for image/color/template dispatch.
  MarkdownCommand forLanguage(Object zh) => languageTagFrom(zh) == 'zh-Hans'
      ? this
      : MarkdownCommand(
          label,
          localizedSyntaxText(before, zh),
          localizedSyntaxText(after, zh),
          localizedSyntaxText(placeholder, zh),
          block: block,
        );
  TextEditingValue apply(TextEditingValue value) {
    final selection = value.selection;
    final start = selection.isValid ? selection.start : value.text.length;
    final end = selection.isValid ? selection.end : start;
    final content = start == end
        ? placeholder
        : value.text.substring(start, end);
    final prefix =
        block && start > 0 && !value.text.substring(0, start).endsWith('\n\n')
        ? '\n\n'
        : '';
    final suffix =
        block &&
            end < value.text.length &&
            !value.text.substring(end).startsWith('\n\n')
        ? '\n\n'
        : '';
    return TextEditingValue(
      text: value.text.replaceRange(
        start,
        end,
        '$prefix$before$content$after$suffix',
      ),
      selection: TextSelection(
        baseOffset: start + prefix.length + before.length,
        extentOffset: start + prefix.length + before.length + content.length,
      ),
    );
  }
}

const markdownCommandGroups = <String, List<MarkdownCommand>>{
  '标题': [
    MarkdownCommand('H1', '# ', '', '一级标题', block: true),
    MarkdownCommand('H2', '## ', '', '二级标题', block: true),
    MarkdownCommand('H3', '### ', '', '三级标题', block: true),
    MarkdownCommand('H4', '#### ', '', '四级标题', block: true),
    MarkdownCommand('H5', '##### ', '', '五级标题', block: true),
    MarkdownCommand('H6', '###### ', '', '六级标题', block: true),
    MarkdownCommand('Setext H1', '', '\n===', '标题', block: true),
    MarkdownCommand('Setext H2', '', '\n---', '标题', block: true),
  ],
  '文本': [
    MarkdownCommand('文字颜色', '<span style="color:#0066CC">', '</span>', '彩色文字'),
    MarkdownCommand('粗体', '**', '**', '粗体'),
    MarkdownCommand('斜体', '*', '*', '斜体'),
    MarkdownCommand('粗斜体', '***', '***', '粗斜体'),
    MarkdownCommand('删除线', '~~', '~~', '删除线'),
    MarkdownCommand('行内代码', '`', '`', 'code'),
    MarkdownCommand('换行', '', '  \n', '文本'),
    MarkdownCommand('段落', '', '\n\n', '段落'),
    MarkdownCommand('转义', '\\', '', '*'),
  ],
  '列表与块': [
    MarkdownCommand('无序列表', '- ', '', '列表项', block: true),
    MarkdownCommand('有序列表', '1. ', '', '列表项', block: true),
    MarkdownCommand('任务列表', '- [ ] ', '', '待办事项', block: true),
    MarkdownCommand('已完成', '- [x] ', '', '已完成事项', block: true),
    MarkdownCommand('嵌套列表', '- 父项\n  - ', '', '子项', block: true),
    MarkdownCommand('引用', '> ', '', '引用', block: true),
    MarkdownCommand('嵌套引用', '> 引用\n>> ', '', '嵌套引用', block: true),
    MarkdownCommand('分隔线', '', '\n---', '', block: true),
    MarkdownCommand('代码块', '```text\n', '\n```', 'code', block: true),
    MarkdownCommand('缩进代码', '    ', '', 'code', block: true),
    MarkdownCommand(
      '表格',
      '| 列一 | 列二 |\n| :--- | ---: |\n| ',
      ' | 内容 |',
      '内容',
      block: true,
    ),
  ],
  '链接与扩展': [
    MarkdownCommand('链接', '[', '](https://example.com)', '链接文字'),
    MarkdownCommand('图片', '![', '](images/example.png)', '图片说明'),
    MarkdownCommand(
      '引用式链接',
      '[',
      '][ref]\n\n[ref]: https://example.com',
      '链接文字',
      block: true,
    ),
    MarkdownCommand('自动链接', '<', '>', 'https://example.com'),
    MarkdownCommand('邮件', '<', '>', 'hello@example.com'),
    MarkdownCommand('行内公式', r'$', r'$', 'E=mc^2'),
    MarkdownCommand('块公式', '\$\$\n', '\n\$\$', r'\frac{a}{b}', block: true),
    MarkdownCommand(
      'Mermaid',
      '```mermaid\n',
      '\n```',
      'flowchart LR\n  A --> B',
      block: true,
    ),
    MarkdownCommand('脚注', '', '[^note]\n\n[^note]: 脚注内容', '正文', block: true),
  ],
};

String markdownGroupLabel(String label, Object zh) => switch (label) {
  '标题' => messageForLanguage(zh, AppMessage.headings),
  '文本' => messageForLanguage(zh, AppMessage.text),
  '列表与块' => messageForLanguage(zh, AppMessage.listsAndBlocks),
  '链接与扩展' => messageForLanguage(zh, AppMessage.linksAndExtensions),
  _ => label,
};
