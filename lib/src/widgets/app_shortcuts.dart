import '../l10n/message_catalog.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

// Document export and resource packaging are released independently.
const documentExportEnabled = true;
const resourcePackageExportEnabled = false;

class AppShortcut {
  const AppShortcut(
    this.id,
    this.message,
    this.key, {
    this.shift = false,
    this.alt = false,
    this.native = false,
    this.primary = true,
    this.windowsKey,
    this.noWindowsControl = false,
  });
  final String id;
  final AppMessage message;
  String get zh => localizedMessage('zh', message);
  String get en => localizedMessage('en', message);
  String labelFor(Object chinese) => messageForLanguage(chinese, message);
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
    AppMessage.indentEditor,
    LogicalKeyboardKey.tab,
    native: true,
    primary: false,
  ),
  AppShortcut(
    'outdent',
    AppMessage.outdentEditor,
    LogicalKeyboardKey.tab,
    native: true,
    primary: false,
    shift: true,
  ),
  AppShortcut('new', AppMessage.newDocument2, LogicalKeyboardKey.keyN),
  AppShortcut('open', AppMessage.openDocument2, LogicalKeyboardKey.keyO),
  AppShortcut('save', AppMessage.save, LogicalKeyboardKey.keyS),
  AppShortcut(
    'saveAs',
    AppMessage.saveAs,
    LogicalKeyboardKey.keyS,
    shift: true,
  ),
  if (documentExportEnabled)
    AppShortcut(
      'export',
      AppMessage.exportDocument,
      LogicalKeyboardKey.keyE,
      shift: true,
    ),
  AppShortcut('close', AppMessage.closeDocument2, LogicalKeyboardKey.keyW),
  AppShortcut('find', AppMessage.find, LogicalKeyboardKey.keyF),
  AppShortcut(
    'replace',
    AppMessage.findAndReplace2,
    LogicalKeyboardKey.keyF,
    alt: true,
    windowsKey: LogicalKeyboardKey.keyH,
  ),
  AppShortcut(
    'next',
    AppMessage.nextMatch,
    LogicalKeyboardKey.keyG,
    windowsKey: LogicalKeyboardKey.f3,
    noWindowsControl: true,
  ),
  AppShortcut(
    'previous',
    AppMessage.previousMatch,
    LogicalKeyboardKey.keyG,
    shift: true,
    windowsKey: LogicalKeyboardKey.f3,
    noWindowsControl: true,
  ),
  AppShortcut('bold', AppMessage.bold, LogicalKeyboardKey.keyB),
  AppShortcut('italic', AppMessage.italic, LogicalKeyboardKey.keyI),
  AppShortcut('code', AppMessage.inlineCode, LogicalKeyboardKey.keyE),
  AppShortcut(
    'strike',
    AppMessage.strikethrough,
    LogicalKeyboardKey.keyX,
    shift: true,
  ),
  AppShortcut('editor', AppMessage.editorMode, LogicalKeyboardKey.digit1),
  AppShortcut('split', AppMessage.splitMode, LogicalKeyboardKey.digit2),
  AppShortcut('preview', AppMessage.previewMode, LogicalKeyboardKey.digit3),
  AppShortcut(
    'sidebar',
    AppMessage.toggleSidebar,
    LogicalKeyboardKey.keyB,
    shift: true,
  ),
  AppShortcut(
    'syntax',
    AppMessage.allSyntax,
    LogicalKeyboardKey.keyM,
    shift: true,
  ),
  AppShortcut('settings', AppMessage.settings, LogicalKeyboardKey.comma),
  AppShortcut('quit', AppMessage.quitApp, LogicalKeyboardKey.keyQ),
  AppShortcut('undo', AppMessage.undo, LogicalKeyboardKey.keyZ, native: true),
  AppShortcut(
    'redo',
    AppMessage.redo,
    LogicalKeyboardKey.keyZ,
    shift: true,
    native: true,
  ),
  AppShortcut('cut', AppMessage.cut, LogicalKeyboardKey.keyX, native: true),
  AppShortcut('copy', AppMessage.copy, LogicalKeyboardKey.keyC, native: true),
  AppShortcut('paste', AppMessage.paste, LogicalKeyboardKey.keyV, native: true),
  AppShortcut(
    'selectAll',
    AppMessage.selectAll,
    LogicalKeyboardKey.keyA,
    native: true,
  ),
];
