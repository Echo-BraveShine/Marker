import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

// Document export and resource packaging are released independently.
const documentExportEnabled = true;
const resourcePackageExportEnabled = false;

class AppShortcut {
  const AppShortcut(
    this.id,
    this.zh,
    this.en,
    this.key, {
    this.shift = false,
    this.alt = false,
    this.native = false,
    this.primary = true,
    this.windowsKey,
    this.noWindowsControl = false,
  });
  final String id, zh, en;
  final LogicalKeyboardKey key;
  final LogicalKeyboardKey? windowsKey;
  final bool shift, alt, native, noWindowsControl, primary;
  SingleActivator activator(TargetPlatform platform) {
    final mac = platform == TargetPlatform.macOS;
    return SingleActivator(
      mac ? key : windowsKey ?? key,
      meta: mac && primary,
      control: !mac && primary && !noWindowsControl,
      shift: shift,
      alt: mac ? alt : (id == 'replace' ? false : alt),
    );
  }

  String display(TargetPlatform platform) {
    final mac = platform == TargetPlatform.macOS;
    final actual = mac ? key : windowsKey ?? key;
    final label = actual == LogicalKeyboardKey.comma
        ? ','
        : actual.keyLabel.toUpperCase();
    return '${!primary
        ? ''
        : mac
        ? '⌘'
        : noWindowsControl
        ? ''
        : 'Ctrl+'}${shift ? (mac ? '⇧' : 'Shift+') : ''}${(mac
            ? alt
            : id == 'replace'
            ? false
            : alt) ? (mac ? '⌥' : 'Alt+') : ''}$label';
  }
}

const appShortcuts = [
  AppShortcut(
    'indent',
    '缩进（编辑器内）',
    'Indent (editor)',
    LogicalKeyboardKey.tab,
    native: true,
    primary: false,
  ),
  AppShortcut(
    'outdent',
    '反缩进（编辑器内）',
    'Outdent (editor)',
    LogicalKeyboardKey.tab,
    native: true,
    primary: false,
    shift: true,
  ),
  AppShortcut('new', '新建文档', 'New document', LogicalKeyboardKey.keyN),
  AppShortcut('open', '打开文档', 'Open document', LogicalKeyboardKey.keyO),
  AppShortcut('save', '保存', 'Save', LogicalKeyboardKey.keyS),
  AppShortcut('saveAs', '另存为', 'Save as', LogicalKeyboardKey.keyS, shift: true),
  if (documentExportEnabled)
    AppShortcut(
      'export',
      '导出文档',
      'Export document',
      LogicalKeyboardKey.keyE,
      shift: true,
    ),
  AppShortcut('close', '关闭当前文档', 'Close document', LogicalKeyboardKey.keyW),
  AppShortcut('find', '查找', 'Find', LogicalKeyboardKey.keyF),
  AppShortcut(
    'replace',
    '查找与替换',
    'Find and replace',
    LogicalKeyboardKey.keyF,
    alt: true,
    windowsKey: LogicalKeyboardKey.keyH,
  ),
  AppShortcut(
    'next',
    '下一个匹配',
    'Next match',
    LogicalKeyboardKey.keyG,
    windowsKey: LogicalKeyboardKey.f3,
    noWindowsControl: true,
  ),
  AppShortcut(
    'previous',
    '上一个匹配',
    'Previous match',
    LogicalKeyboardKey.keyG,
    shift: true,
    windowsKey: LogicalKeyboardKey.f3,
    noWindowsControl: true,
  ),
  AppShortcut('bold', '粗体', 'Bold', LogicalKeyboardKey.keyB),
  AppShortcut('italic', '斜体', 'Italic', LogicalKeyboardKey.keyI),
  AppShortcut('code', '行内代码', 'Inline code', LogicalKeyboardKey.keyE),
  AppShortcut(
    'strike',
    '删除线',
    'Strikethrough',
    LogicalKeyboardKey.keyX,
    shift: true,
  ),
  AppShortcut('editor', '编辑模式', 'Editor mode', LogicalKeyboardKey.digit1),
  AppShortcut('split', '分屏模式', 'Split mode', LogicalKeyboardKey.digit2),
  AppShortcut('preview', '预览模式', 'Preview mode', LogicalKeyboardKey.digit3),
  AppShortcut(
    'sidebar',
    '切换侧栏',
    'Toggle sidebar',
    LogicalKeyboardKey.keyB,
    shift: true,
  ),
  AppShortcut(
    'syntax',
    '全部语法',
    'All syntax',
    LogicalKeyboardKey.keyM,
    shift: true,
  ),
  AppShortcut('settings', '设置', 'Settings', LogicalKeyboardKey.comma),
  AppShortcut('quit', '退出应用', 'Quit app', LogicalKeyboardKey.keyQ),
  AppShortcut('undo', '撤销', 'Undo', LogicalKeyboardKey.keyZ, native: true),
  AppShortcut(
    'redo',
    '重做',
    'Redo',
    LogicalKeyboardKey.keyZ,
    shift: true,
    native: true,
  ),
  AppShortcut('cut', '剪切', 'Cut', LogicalKeyboardKey.keyX, native: true),
  AppShortcut('copy', '复制', 'Copy', LogicalKeyboardKey.keyC, native: true),
  AppShortcut('paste', '粘贴', 'Paste', LogicalKeyboardKey.keyV, native: true),
  AppShortcut(
    'selectAll',
    '全选',
    'Select all',
    LogicalKeyboardKey.keyA,
    native: true,
  ),
];
