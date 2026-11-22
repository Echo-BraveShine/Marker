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

  String labelFor(bool zh) => zh ? label : _englishSyntaxText[label] ?? label;

  /// Keep the command identity stable for image/color/template dispatch.
  MarkdownCommand forLanguage(bool zh) => zh
      ? this
      : MarkdownCommand(
          label,
          _englishSyntaxText[before] ?? before,
          _englishSyntaxText[after] ?? after,
          _englishSyntaxText[placeholder] ?? placeholder,
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

String markdownGroupLabel(String label, bool zh) => zh
    ? label
    : switch (label) {
        '标题' => 'Headings',
        '文本' => 'Text',
        '列表与块' => 'Lists and blocks',
        '链接与扩展' => 'Links and extensions',
        _ => label,
      };

const _englishSyntaxText = <String, String>{
  '文字颜色': 'Text color',
  '彩色文字': 'Colored text',
  '粗体': 'Bold',
  '斜体': 'Italic',
  '粗斜体': 'Bold italic',
  '删除线': 'Strikethrough',
  '行内代码': 'Inline code',
  '换行': 'Line break',
  '段落': 'Paragraph',
  '转义': 'Escape',
  '文本': 'Text',
  '一级标题': 'Heading 1',
  '二级标题': 'Heading 2',
  '三级标题': 'Heading 3',
  '四级标题': 'Heading 4',
  '五级标题': 'Heading 5',
  '六级标题': 'Heading 6',
  '标题': 'Heading',
  '无序列表': 'Bullet list',
  '有序列表': 'Numbered list',
  '任务列表': 'Task list',
  '已完成': 'Completed task',
  '嵌套列表': 'Nested list',
  '列表项': 'List item',
  '待办事项': 'Task',
  '已完成事项': 'Completed task',
  '子项': 'Child item',
  '引用': 'Blockquote',
  '嵌套引用': 'Nested blockquote',
  '分隔线': 'Horizontal rule',
  '代码块': 'Code block',
  '缩进代码': 'Indented code',
  '表格': 'Table',
  '内容': 'Content',
  '链接': 'Link',
  '图片': 'Image',
  '引用式链接': 'Reference link',
  '自动链接': 'Autolink',
  '邮件': 'Email',
  '链接文字': 'Link text',
  '图片说明': 'Image description',
  '行内公式': 'Inline math',
  '块公式': 'Block math',
  '脚注': 'Footnote',
  '正文': 'Text',
  '- 父项\n  - ': '- Parent item\n  - ',
  '> 引用\n>> ': '> Quote\n>> ',
  '| 列一 | 列二 |\n| :--- | ---: |\n| ':
      '| Column 1 | Column 2 |\n| :--- | ---: |\n| ',
  ' | 内容 |': ' | Content |',
  '[^note]\n\n[^note]: 脚注内容': '[^note]\n\n[^note]: Footnote content',
};
