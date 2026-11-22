import 'package:desktop_drop/desktop_drop.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:path/path.dart' as p;
import 'src/resources/resource_service.dart';
import 'src/resources/resource_references.dart';
import 'src/resources/resource_provider.dart';
import 'src/resources/resource_sidebar.dart';
import 'src/widgets/shortcut_settings.dart';
import 'src/export/document_exporter.dart';
import 'src/export/export_destination.dart';
import 'src/export/export_options_panel.dart';
import 'package:flutter/rendering.dart' show RenderEditable;
import 'src/widgets/about_settings.dart';
import 'src/widgets/desktop_icon_sync.dart';
import 'src/widgets/marker_logo.dart';
import 'src/widgets/highlight_style_picker.dart';
import 'src/theme/highlight_style.dart';
import 'src/widgets/markdown_highlighter.dart';
import 'src/theme/marker_style.dart';
import 'src/theme/marker_fonts.dart';
import 'package:flutter/cupertino.dart';
import 'src/widgets/desktop_startup.dart';
import 'src/providers/external_files.dart';
import 'src/widgets/marker_floating_surface.dart';
import 'src/widgets/editor_search.dart';
import 'src/widgets/app_shortcuts.dart';
import 'src/widgets/markdown_syntax_panel.dart';
import 'src/widgets/markdown_templates.dart';
import 'src/widgets/marker_dialog.dart';
import 'src/widgets/text_color_picker.dart';
import 'src/providers/workspace_provider.dart';
import 'src/widgets/linked_scroll.dart';
import 'src/widgets/markdown_commands.dart';
import 'src/widgets/markdown_editing_controller.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'src/widgets/markdown_extensions.dart';
import 'package:markdown/markdown.dart' as md;
import 'src/widgets/line_number_gutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:window_manager/window_manager.dart';
import 'src/providers/draft_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'src/theme/marker_app_theme.dart';
import 'src/theme/marker_colors.dart';
import 'src/providers/theme_provider.dart';
import 'src/providers/editor_provider.dart';
import 'src/l10n/app_localizations.dart';
import 'src/widgets/marker_markdown_style.dart';

part 'src/resources/resource_actions.dart';

bool desktopWindow = false;

Future<void> main(List<String> arguments) async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  final container = ProviderContainer(
    overrides: [
      initialFilesProvider.overrideWithValue(markdownOpenPaths(arguments)),
    ],
  );
  try {
    await container.read(themeProvider.notifier).init();
  } catch (error) {
    debugPrint('Theme initialization failed: $error');
  }
  desktopWindow =
      !kIsWeb &&
      [
        TargetPlatform.macOS,
        TargetPlatform.windows,
        TargetPlatform.linux,
      ].contains(defaultTargetPlatform);
  if (desktopWindow) {
    await windowManager.ensureInitialized();
    final mode = container.read(themeProvider).mode;
    final dark =
        mode == ThemeMode.dark ||
        (mode == ThemeMode.system &&
            binding.platformDispatcher.platformBrightness == Brightness.dark);
    await windowManager.waitUntilReadyToShow(
      WindowOptions(
        title: 'Marker',
        size: const Size(1200, 800),
        minimumSize: const Size(900, 600),
        center: true,
        backgroundColor: dark
            ? MarkerColors.dark.bgWindow
            : MarkerColors.light.bgWindow,
        titleBarStyle: defaultTargetPlatform == TargetPlatform.macOS
            ? TitleBarStyle.hidden
            : TitleBarStyle.normal,
      ),
    );
    await windowManager.setPreventClose(true);
    await container.read(desktopIconProvider).setDark(dark);
  }
  runApp(
    UncontrolledProviderScope(container: container, child: const MarkerApp()),
  );
  if (desktopWindow) {
    await revealDesktopWindow(
      firstFrame: binding.endOfFrame,
      show: windowManager.show,
      focus: windowManager.focus,
    );
  }
}

class MarkerApp extends ConsumerWidget {
  const MarkerApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Marker',
      debugShowCheckedModeBanner: false,
      theme: MarkerAppTheme().light(),
      darkTheme: MarkerAppTheme().dark(),
      themeMode: vm.mode,
      locale: vm.locale,
      supportedLocales: const [Locale('zh', 'CN'), Locale('en', 'US')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) => CupertinoTheme(
        // 确保 Cupertino 组件在所有平台上使用正确的字体，尤其是中文
        data: CupertinoThemeData(
          brightness: Theme.of(context).brightness,
          textTheme: MarkerFonts.cupertino,
        ),
        child: DesktopIconSync(
          enabled: desktopWindow,
          child: child ?? const SizedBox.shrink(),
        ),
      ),

      home: const MarkerHome(),
    );
  }
}

class MarkerHome extends ConsumerStatefulWidget {
  const MarkerHome({super.key});
  @override
  ConsumerState<MarkerHome> createState() => _MarkerHomeState();
}

class _MarkerHomeState extends ConsumerState<MarkerHome> with WindowListener {
  final _drafts = DraftStore();
  Timer? _draftTimer;
  Timer? _toastTimer;
  OverlayEntry? _toastEntry;
  bool get _restoring => ref.read(editorProvider).restoring;
  set _restoring(bool value) => ref
      .read(editorProvider.notifier)
      .update((s) => s.copyWith(restoring: value));
  bool get _sidebar => ref.read(editorProvider).sidebar;
  set _sidebar(bool value) => ref
      .read(editorProvider.notifier)
      .update((s) => s.copyWith(sidebar: value));
  String? _lastDraftText;
  bool _switchingDocument = false;
  final _pendingOpenFiles = <String>[];
  static const _filesChannel = MethodChannel('marker/files');
  WorkspaceNotifier get _workspace => ref.read(workspaceProvider.notifier);
  final _controller = MarkdownEditingController(text: defaultMarkdown);
  final _focus = FocusNode();
  final _lineIndex = LineNumberIndex();
  Widget? _previewCache;
  Object? _previewSignature;
  int _imageEpoch = 0;
  RenderEditable? _editable() => _focus.context
      ?.findAncestorStateOfType<EditableTextState>()
      ?.renderEditable;
  final _searchFocus = FocusNode();
  final _editorScroll = ScrollController();
  final _previewScroll = ScrollController();
  final _undo = UndoHistoryController();
  late final LinkedScroll _linkedScroll;
  String? get _path => ref.read(editorProvider).path;
  set _path(String? value) =>
      ref.read(editorProvider.notifier).update((s) => s.copyWith(path: value));
  String get _saved => ref.read(editorProvider).saved;
  set _saved(String value) =>
      ref.read(editorProvider.notifier).update((s) => s.copyWith(saved: value));
  double get _fontSize => ref.read(editorProvider).fontSize;
  set _fontSize(double value) => ref
      .read(editorProvider.notifier)
      .update((s) => s.copyWith(fontSize: value));
  bool get _serif => ref.read(editorProvider).serif;
  set _serif(bool value) =>
      ref.read(editorProvider.notifier).update((s) => s.copyWith(serif: value));
  int get _mode => ref.read(editorProvider).mode;
  set _mode(int value) {
    if (_mode != value) {
      // Reset linked scroll when mode changes to prevent stale sync
      _linkedScroll.reset();
    }
    ref.read(editorProvider.notifier).update((s) => s.copyWith(mode: value));
  }

  double get _ratio => ref.read(editorProvider).ratio;
  set _ratio(double value) =>
      ref.read(editorProvider.notifier).update((s) => s.copyWith(ratio: value));
  bool get _busy => ref.read(editorProvider).busy;
  set _busy(bool value) =>
      ref.read(editorProvider.notifier).update((s) => s.copyWith(busy: value));
  bool get _dirty => _controller.text != _saved;
  String get _name => _path?.split(RegExp(r'[/\\]')).last ?? 'Untitled.md';
  bool get _zh => Localizations.localeOf(context).languageCode == 'zh';
  String t(String zh, String en) => _zh ? zh : en;
  @override
  void initState() {
    super.initState();
    _controller.addListener(_changed);
    FocusManager.instance.addEarlyKeyEventHandler(_handleSyntaxEscape);
    FocusManager.instance.addEarlyKeyEventHandler(_handleNavigationKey);
    _linkedScroll = LinkedScroll(
      _editorScroll,
      _previewScroll,
      enabled: () => mounted && _mode == 1,
    );
    if (!desktopWindow) {
      Future.microtask(() => ref.read(themeProvider.notifier).init());
    }
    if (desktopWindow) windowManager.addListener(this);
    _restore();
    _connectExternalFiles();
  }

  KeyEventResult _handleSyntaxEscape(KeyEvent event) {
    if (mounted &&
        event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.escape &&
        (ModalRoute.of(context)?.isCurrent ?? true) &&
        ref.read(editorProvider).toolbarExpanded) {
      ref
          .read(editorProvider.notifier)
          .update((s) => s.copyWith(toolbarExpanded: false));
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  // Handles intentional navigation keys (arrows, Home/End, PageUp/Down) that
  // should transfer ownership from preview to editor before caret reveal.
  // This prevents leadership theft during split-scroll gestures while still
  // allowing cursor movement to work correctly.
  KeyEventResult _handleNavigationKey(KeyEvent event) {
    if (!mounted) return KeyEventResult.ignored;
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    if (!_focus.hasFocus || !(ModalRoute.of(context)?.isCurrent ?? true)) {
      return KeyEventResult.ignored;
    }

    // Map intentional navigation keys - transfer ownership for editor caret movement
    const navigationKeys = <LogicalKeyboardKey>[
      LogicalKeyboardKey.arrowUp,
      LogicalKeyboardKey.arrowDown,
      LogicalKeyboardKey.arrowLeft,
      LogicalKeyboardKey.arrowRight,
      LogicalKeyboardKey.home,
      LogicalKeyboardKey.end,
      LogicalKeyboardKey.pageUp,
      LogicalKeyboardKey.pageDown,
    ];

    if (navigationKeys.contains(event.logicalKey)) {
      // Transfer control to editor for this intentional navigation gesture
      _linkedScroll.takeEditorControl();
      // Observe navigation without consuming the key intended for EditableText.
      return KeyEventResult.ignored;
    }
    return KeyEventResult.ignored;
  }

  void _update(VoidCallback change) => change();

  Future<void> _restore() async {
    try {
      final restored = await _workspace.restore();
      if (!mounted) return;
      if (!restored) {
        final draft = await _drafts.read();
        if (!mounted) return;
        if (draft != null && draft['text'] != draft['saved']) {
          _workspace.add(
            text: draft['text'] as String,
            saved: draft['saved'] as String,
            path: draft['path'] as String?,
          );
        } else {
          _workspace.add(text: defaultMarkdown, saved: defaultMarkdown);
        }
      }
      _loadActive();
      await _workspace.persist();
      if (mounted &&
          ref.read(workspaceProvider).documents.any((d) => d.dirty)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _toast(t('已恢复未保存的文档', 'Recovered unsaved documents'));
        });
      }
    } catch (e) {
      _error(e);
    }
    if (mounted) {
      _restoring = false;
      _drainExternalFiles();
    }
  }

  void _snapshot() {
    if (_workspace.active == null && _controller.text.isNotEmpty) {
      _workspace.add(text: _controller.text, saved: _saved, path: _path);
    } else {
      _workspace.snapshot(_controller.text, _saved, _path);
    }
  }

  void _loadActive() {
    _linkedScroll.reset();
    _draftTimer?.cancel();
    final document = _workspace.active;
    _switchingDocument = true;
    try {
      ref
          .read(editorProvider.notifier)
          .update(
            (s) => s.copyWith(
              path: document?.path,
              markdown: document?.text ?? '',
              saved: document?.saved ?? '',
              cursorLine: 1,
              cursorColumn: 1,
            ),
          );
      _controller.value = TextEditingValue(
        text: document?.text ?? '',
        selection: const TextSelection.collapsed(offset: 0),
      );
      _lastDraftText = _controller.text;
    } finally {
      _switchingDocument = false;
    }
    if (desktopWindow) windowManager.setTitle(_name);
  }

  Future<void> _selectDocument(String id) async {
    _snapshot();
    _workspace.select(id);
    _loadActive();
    await _workspace.persist();
  }

  Future<void> _documentMenu(OpenDocument document, Offset position) async {
    final c = Theme.of(context).extension<MarkerColors>()!;
    final size = MediaQuery.sizeOf(context);
    final action = await showGeneralDialog<String>(
      context: context,
      barrierLabel: t('文档菜单', 'Document menu'),
      barrierDismissible: true,
      barrierColor: c.bgWindow.withValues(alpha: 0),
      transitionDuration: const Duration(milliseconds: 100),
      pageBuilder: (context, animation, secondary) => Stack(
        children: [
          Positioned(
            left: position.dx.clamp(
              8,
              (size.width - 224).clamp(8, double.infinity),
            ),
            top: position.dy.clamp(
              8,
              (size.height - 158).clamp(8, double.infinity),
            ),
            child: MarkerFloatingSurface(
              width: 216,
              padding: const EdgeInsets.all(6),
              child: DefaultTextStyle(
                style: TextStyle(
                  fontFamily: MarkerFonts.ui,
                  fontFamilyFallback: MarkerFonts.fallback,
                  fontSize: 13,
                  height: 1.38,
                  color: c.textPrimary,
                  decoration: TextDecoration.none,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final entry in [
                      (
                        'close',
                        t('关闭文档', 'Close document'),
                        CupertinoIcons.xmark,
                      ),
                      if (document.path != null)
                        ('rename', t('重命名…', 'Rename…'), CupertinoIcons.pencil),
                      if (document.path != null)
                        (
                          'delete',
                          t('移到废纸篓…', 'Move to Trash…'),
                          CupertinoIcons.trash,
                        ),
                    ])
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (entry.$1 == 'delete')
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              child: Container(
                                height: 1,
                                color: c.separatorSoft,
                              ),
                            ),
                          CupertinoButton(
                            minimumSize: Size.zero,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 8,
                            ),
                            onPressed: () => Navigator.pop(context, entry.$1),
                            child: Row(
                              children: [
                                Icon(
                                  entry.$3,
                                  size: 16,
                                  color: entry.$1 == 'delete'
                                      ? CupertinoColors.systemRed
                                      : c.textSecondary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  entry.$2,
                                  style: TextStyle(
                                    fontFamily: MarkerFonts.ui,
                                    fontFamilyFallback: MarkerFonts.fallback,
                                    fontSize: 13,
                                    color: entry.$1 == 'delete'
                                        ? CupertinoColors.systemRed
                                        : c.textPrimary,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
    if (!mounted || action == null) return;
    await _action(() async {
      if (action == 'rename') {
        await _selectDocument(document.id);
        await _renameResourceDocument();
      } else {
        await _closeDocument(document.id, delete: action == 'delete');
      }
    });
  }

  Future<void> _closeDocument(String id, {bool delete = false}) async {
    await _selectDocument(id);
    if (!mounted) return;
    final document = _workspace.active;
    if (document == null) return;
    if (delete && document.path != null) {
      final confirmed = await showMarkerDialog<bool>(
        context: context,
        builder: (context) => MarkerDialog(
          title: Text(t('将文档移到废纸篓？', 'Move document to Trash?')),
          content: Text(
            '${document.path}\n\n${t('文档文件将移到废纸篓，关联图片会保留。未保存的编辑内容将关闭。', 'The document moves to Trash; associated images are kept. Unsaved edits will be closed.')}',
          ),
          actions: [
            MarkerDialogButton(
              isDestructiveAction: true,
              onPressed: () => Navigator.pop(context, true),
              child: Text(t('移到废纸篓', 'Move to Trash')),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
      await ref.read(resourcePlatformProvider).trash(document.path!);
    } else if (!await _confirm()) {
      return;
    }
    if (!mounted) return;
    _draftTimer?.cancel();
    _workspace.remove(id);
    _loadActive();
    await _workspace.persist();
  }

  Future<void> _persist() async {
    _draftTimer?.cancel();
    _snapshot();
    await _workspace.persist();
    await _drafts.write(_controller.text, _saved, _path);
  }

  @override
  void onWindowClose() {
    _action(() async {
      _snapshot();
      final originalId = ref.read(workspaceProvider).activeId;
      final ids = ref
          .read(workspaceProvider)
          .documents
          .where((d) => d.dirty)
          .map((d) => d.id)
          .toList();
      for (final id in ids) {
        _snapshot();
        _workspace.select(id);
        _loadActive();
        if (!mounted || !await _confirm()) return;
        // Keep only the saved baseline when the user discards at exit.
        _workspace.snapshot(_saved, _saved, _path);
        _loadActive();
      }
      if (ids.isNotEmpty && originalId != null) {
        _workspace.select(originalId);
        _loadActive();
      }
      _draftTimer?.cancel();
      await _workspace.persist();
      if (defaultTargetPlatform == TargetPlatform.macOS) {
        await const MethodChannel(
          'marker/lifecycle',
        ).invokeMethod<void>('quit');
      } else {
        // Persistence/confirmation succeeded; hide before native plugin teardown.
        await windowManager.hide();
        await windowManager.destroy();
      }
    });
  }

  void _changed() {
    if (!mounted || _switchingDocument) return;
    final previous = ref.read(editorProvider);
    final text = _controller.text;
    final textChanged = previous.markdown != text;
    if (textChanged) _linkedScroll.takeEditorControl();
    final offset = _controller.selection.isValid
        ? _controller.selection.extentOffset
        : 0;
    _lineIndex.update(text);
    final lineIndex = _lineIndex.lineAt(offset);
    final line = lineIndex + 1;
    final column = offset - _lineIndex.start(lineIndex) + 1;
    if (textChanged ||
        previous.cursorLine != line ||
        previous.cursorColumn != column) {
      ref
          .read(editorProvider.notifier)
          .update(
            (state) => state.copyWith(
              markdown: text,
              cursorLine: line,
              cursorColumn: column,
            ),
          );
    }
    if (_restoring || _lastDraftText == text) return;
    _lastDraftText = text;
    _snapshot();
    _draftTimer?.cancel();
    _draftTimer = Timer(const Duration(milliseconds: 350), () async {
      try {
        await _persist();
      } catch (e) {
        _error(e);
      }
    });
    if (desktopWindow) windowManager.setTitle('$_name${_dirty ? ' •' : ''}');
  }

  @override
  void dispose() {
    FocusManager.instance.removeEarlyKeyEventHandler(_handleSyntaxEscape);
    FocusManager.instance.removeEarlyKeyEventHandler(_handleNavigationKey);
    _draftTimer?.cancel();
    if (desktopWindow && defaultTargetPlatform == TargetPlatform.macOS) {
      _filesChannel.setMethodCallHandler(null);
    }
    if (desktopWindow) windowManager.removeListener(this);
    _toastTimer?.cancel();
    _toastEntry?.remove();
    _toastEntry?.dispose();
    _controller.dispose();
    _focus.dispose();
    _searchFocus.dispose();
    _linkedScroll.dispose();
    _editorScroll.dispose();
    _previewScroll.dispose();
    _undo.dispose();
    super.dispose();
  }

  Future<bool> _save({bool as = false}) async {
    var text = _controller.text;
    try {
      final sourcePath = _path;
      var path = sourcePath;
      if (as || path == null) {
        final target = await getSaveLocation(suggestedName: _name);
        if (target == null) return false;
        path = target.path;
      }
      final targetPath = path;
      final duplicate = ref
          .read(workspaceProvider)
          .documents
          .where(
            (d) =>
                d.path != null &&
                p.equals(d.path!, targetPath) &&
                d.id != ref.read(workspaceProvider).activeId,
          )
          .firstOrNull;
      if (duplicate != null) {
        _toast(
          t(
            '该路径已由另一个打开的文档使用，请选择其他路径。',
            'Another open document uses this path. Choose a different path.',
          ),
        );
        return false;
      }
      final copying = sourcePath != null && !p.equals(sourcePath, targetPath);
      final references = copying
          ? await parseResourceReferencesAsync(text)
          : null;
      if (copying &&
          (references!.images.isNotEmpty ||
              references.unsupported.isNotEmpty)) {
        final inventory = await _resources.scan(text, sourcePath);
        if (!mounted || !await _confirmResourceIssues(inventory)) return false;
        var download = false;
        if (inventory.items.any(
          (i) => i.availability == ResourceAvailability.remote,
        )) {
          final decision = await _resourceCollectionChoice(
            t('另存文档与图片', 'Save document and images as'),
            inventory,
            standalone: true,
          );
          if (decision == null) return false;
          download = decision;
        }
        final result = await _retryIncomplete(
          (allow) => _resourceWork.run(
            t('保存文档副本', 'Saving document copy'),
            (token, progress) => _withResourceAccess(
              () => _resources.saveCopy(
                text: text,
                sourcePath: sourcePath,
                targetPath: targetPath,
                downloadRemote: download,
                allowIncomplete: allow,
                cancellation: token,
                onProgress: progress,
              ),
              directory: p.dirname(targetPath),
            ),
          ),
          allowIncomplete:
              inventory.unresolved.isNotEmpty ||
              inventory.unsupported.isNotEmpty,
        );

        text = result.text;
        if (result.issues.isNotEmpty && mounted) {
          await _showResourceIssues(
            result.issues.map(_resourceIssueText).toList(),
          );
        }
      } else {
        await _withResourceAccess(
          () => _resources.atomicWrite(File(targetPath), text),
          directory: p.dirname(targetPath),
        );
      }
      if (!mounted) return true;
      if (copying) {
        _snapshot();
        _workspace.add(text: text, saved: text, path: targetPath);
        _loadActive();
      } else {
        if (_workspace.active == null) {
          _workspace.add(text: text, saved: text, path: targetPath);
        }
        _path = targetPath;
        _saved = text;
      }
      await _persist();
      return true;
    } on ResourceCancelled {
      if (mounted) {
        _toast(
          t(
            '已取消保存，文档内容已保留。',
            'Save cancelled. Your document content is preserved.',
          ),
        );
      }
      return false;
    } catch (e) {
      _error(e);
      return false;
    }
  }

  void _toast(String message) {
    _toastTimer?.cancel();
    _toastEntry?.remove();
    _toastEntry?.dispose();
    final overlay = Overlay.of(context);
    final colors = Theme.of(context).extension<MarkerColors>()!;
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => Positioned(
        bottom: 48,
        left: 32,
        right: 32,
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 560),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: colors.textPrimary,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              message,
              style: TextStyle(
                fontFamily: MarkerFonts.ui,
                fontFamilyFallback: MarkerFonts.fallback,
                fontSize: 13,
                color: colors.bgEditor,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ),
      ),
    );
    overlay.insert(entry);
    _toastEntry = entry;
    _toastTimer = Timer(const Duration(seconds: 3), () {
      entry.remove();
      entry.dispose();
      _toastEntry = null;
    });
  }

  void _error(Object e) {
    if (mounted) {
      _toast(
        e is ResourceFailure
            ? t(e.zh, e.en)
            : t('文件操作失败：$e', 'File operation failed: $e'),
      );
    }
  }

  Future<bool> _confirm() async {
    if (!_dirty) return true;
    final answer = await showMarkerDialog<int>(
      context: context,
      builder: (context) => MarkerDialog(
        title: Text(t('保存更改？', 'Save changes?')),
        content: Text(t('$_name 有未保存的内容。', '$_name has unsaved changes.')),
        actions: [
          MarkerDialogButton(
            onPressed: () => Navigator.pop(context, 1),
            child: Text(t('不保存', 'Discard')),
          ),
          MarkerDialogButton(
            primary: true,
            onPressed: () => Navigator.pop(context, 2),
            child: Text(t('保存', 'Save')),
          ),
        ],
      ),
    );
    return answer == 1 || (answer == 2 && await _save());
  }

  Future<void> _exportDocument() async {
    if (_busy || _restoring) return;
    // Capture the unsaved document before either asynchronous dialog opens.
    final source = _controller.text, documentPath = _path, title = _name;
    final dark = Theme.of(context).brightness == Brightness.dark;
    await _action(() async {
      try {
        await ref.read(exportAppearanceProvider.notifier).ready;
        if (!mounted) return;
        final options = await showMarkerDialog<DocumentExportOptions>(
          context: context,
          builder: (context) => ExportOptionsPanel(zh: _zh),
        );
        if (options == null || !mounted) return;
        final basename = title.replaceFirst(
          RegExp(r'\.(md|markdown)$', caseSensitive: false),
          '',
        );
        final extension = options.format.name;
        final target = await getSaveLocation(
          suggestedName: '$basename.$extension',
          acceptedTypeGroups: [
            XTypeGroup(label: extension.toUpperCase(), extensions: [extension]),
          ],
        );
        if (target == null || !mounted) return;
        final writer = ExportDestinationWriter();
        // Reject unsafe destinations before the expensive renderer starts.
        final destination = writer.resolvePath(
          target.path,
          extension: extension,
          sourcePath: documentPath,
        );
        Future<Uint8List> render() => ref
            .read(exportControllerProvider.notifier)
            .export(
              source: source,
              title: title,
              documentPath: documentPath,
              options: options,
              dark: dark,
            );
        final bytes = documentPath == null
            ? await render()
            : await _withResourceAccess(
                render,
                directory: p.dirname(documentPath),
              );
        if (!mounted) return;
        final savedPath = await _withResourceAccess(
          () => writer.write(
            bytes,
            selectedPath: target.path,
            extension: extension,
            sourcePath: documentPath,
          ),
          directory: p.dirname(destination),
        );
        if (mounted) _toast(t('已导出到 $savedPath', 'Exported to $savedPath'));
      } on ResourceCancelled {
        // Cancelling source-folder authorization leaves the destination intact.
        return;
      } catch (error) {
        if (!mounted) return;
        await showMarkerDialog<void>(
          context: context,
          builder: (_) => MarkerDialog(
            title: Text(t('无法导出文档', 'Unable to export document')),
            content: Text(exportFailureMessage(error, chinese: _zh)),
          ),
        );
      }
    });
  }

  Future<void> _action(Future<void> Function() action) async {
    if (_busy || _restoring) return;
    _update(() => _busy = true);
    try {
      await action();
    } on ResourceCancelled {
      if (mounted) _toast(t('已停止后续资源处理', 'Remaining work stopped'));
    } catch (e) {
      _error(e);
    } finally {
      if (mounted) {
        _update(() => _busy = false);
        _drainExternalFiles();
      }
    }
  }

  Future<void> _connectExternalFiles() async {
    if (desktopWindow && defaultTargetPlatform == TargetPlatform.macOS) {
      _filesChannel.setMethodCallHandler((call) async {
        if (call.method == 'openFiles') {
          _queueExternalFiles((call.arguments as List).cast<String>());
        }
      });
      try {
        final initial = await _filesChannel.invokeListMethod<String>('start');
        if (mounted) _queueExternalFiles(initial ?? const []);
      } catch (error) {
        if (mounted) _error(error);
      }
    }
    if (mounted) _queueExternalFiles(ref.read(initialFilesProvider));
  }

  void _queueExternalFiles(Iterable<String> paths) {
    for (final path in markdownOpenPaths(paths)) {
      if (!_pendingOpenFiles.contains(path)) _pendingOpenFiles.add(path);
    }
    _drainExternalFiles();
  }

  void _drainExternalFiles() {
    if (!mounted || _restoring || _busy || _pendingOpenFiles.isEmpty) return;
    _action(() async {
      while (mounted && _pendingOpenFiles.isNotEmpty) {
        final path = _pendingOpenFiles.removeAt(0);
        try {
          await _openPath(path);
        } catch (error) {
          _error(error);
        }
      }
    });
  }

  Future<void> _newFile() async {
    final location = await getSaveLocation(
      suggestedName: 'Untitled.md',
      acceptedTypeGroups: [
        const XTypeGroup(label: 'Markdown', extensions: ['md']),
      ],
    );
    if (location == null || !mounted) return;
    final existing = ref
        .read(workspaceProvider)
        .documents
        .where((d) => d.path == location.path)
        .firstOrNull;
    if (existing != null) {
      await _selectDocument(existing.id);
      _toast(t('此文件已打开', 'This file is already open'));
      return;
    }
    if (await File(location.path).exists()) {
      await _openPath(location.path);
      if (mounted) {
        _toast(
          t(
            '已打开现有文件，未覆盖原内容。',
            'Opened the existing file without overwriting it.',
          ),
        );
      }
      return;
    }
    // Keep the current document intact until creating the selected file succeeds.
    await XFile.fromData(
      Uint8List(0),
      mimeType: 'text/markdown',
    ).saveTo(location.path);
    if (!mounted) return;
    _snapshot();
    _workspace.add(text: '', saved: '', path: location.path);
    _loadActive();
    await _persist();
    if (desktopWindow) await windowManager.setTitle(_name);
    _focus.requestFocus();
  }

  Future<void> _open() async {
    final file = await openFile(
      acceptedTypeGroups: [
        const XTypeGroup(
          label: 'Markdown',
          extensions: ['md', 'markdown', 'txt'],
        ),
      ],
    );
    if (file == null) return;
    await _openPath(file.path);
  }

  Future<void> _openPath(String input) async {
    final path = File(input).absolute.path;
    final existing = ref
        .read(workspaceProvider)
        .documents
        .where((d) => d.path == path)
        .firstOrNull;
    if (existing != null) {
      await _selectDocument(existing.id);
      return;
    }
    final text = await File(path).readAsString();
    if (!mounted) return;
    _snapshot();
    _workspace.add(text: text, saved: text, path: path);
    _loadActive();
    await _persist();
  }

  void _openSearch({bool replace = false}) {
    ref
        .read(editorProvider.notifier)
        .update(
          (s) => s.copyWith(
            searchVisible: true,
            replaceVisible: replace,
            mode: s.mode == 2 ? 1 : s.mode,
          ),
        );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _searchFocus.requestFocus();
    });
  }

  void _closeSearch() {
    ref
        .read(editorProvider.notifier)
        .update((s) => s.copyWith(searchVisible: false));
    _focus.requestFocus();
  }

  void _findMatch({bool forward = true, bool fromStart = false}) {
    final state = ref.read(editorProvider);
    final matches = findEditorMatches(
      _controller.text,
      state.searchQuery,
      caseSensitive: state.searchCaseSensitive,
    );
    if (matches.isEmpty) return;
    final selection = _controller.selection;
    final position = selection.isValid
        ? (forward ? selection.end : selection.start)
        : 0;
    final match = fromStart
        ? matches.first
        : forward
        ? matches.where((m) => m.start >= position).firstOrNull ?? matches.first
        : matches.where((m) => m.end <= position).lastOrNull ?? matches.last;
    _linkedScroll.takeEditorControl();
    _controller.selection = TextSelection(
      baseOffset: match.start,
      extentOffset: match.end,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _focus.context
          ?.findAncestorStateOfType<EditableTextState>()
          ?.bringIntoView(TextPosition(offset: match.start));
    });
  }

  void _replaceMatch() {
    if (_busy || _restoring) return;
    final state = ref.read(editorProvider);
    final matches = findEditorMatches(
      _controller.text,
      state.searchQuery,
      caseSensitive: state.searchCaseSensitive,
    );
    final selection = _controller.selection;
    if (!matches.any(
      (m) => m.start == selection.start && m.end == selection.end,
    )) {
      _findMatch(fromStart: true);
      return;
    }
    _controller.value = TextEditingValue(
      text: _controller.text.replaceRange(
        selection.start,
        selection.end,
        state.replacement,
      ),
      selection: TextSelection.collapsed(
        offset: selection.start + state.replacement.length,
      ),
    );
    _findMatch();
  }

  void _replaceAllMatches() {
    if (_busy || _restoring) return;
    final state = ref.read(editorProvider);
    _controller.value = replaceEditorMatches(
      _controller.value,
      state.searchQuery,
      state.replacement,
      caseSensitive: state.searchCaseSensitive,
    );
  }

  Map<ShortcutActivator, VoidCallback> _shortcutBindings() {
    void command(String label) => _runMarkdownCommand(
      markdownCommandGroups.values
          .expand((items) => items)
          .firstWhere((c) => c.label == label),
    );
    final actions = <String, VoidCallback>{
      'new': () => _action(_newFile),
      'open': () => _action(_open),
      'save': () => _action(() async {
        await _save();
      }),
      if (documentExportEnabled) 'export': _exportDocument,
      'saveAs': () => _action(() async {
        await _save(as: true);
      }),
      'close': () {
        final id = ref.read(workspaceProvider).activeId;
        if (id != null) _action(() => _closeDocument(id));
      },
      'find': () => _openSearch(),
      'replace': () => _openSearch(replace: true),
      'next': () => _findMatch(),
      'previous': () => _findMatch(forward: false),
      'bold': () => command('粗体'),
      'italic': () => command('斜体'),
      'code': () => command('行内代码'),
      'strike': () => command('删除线'),
      'editor': () => _mode = 0,
      'split': () => _mode = 1,
      'preview': () => _mode = 2,
      'sidebar': () => _sidebar = !_sidebar,
      'syntax': () => ref
          .read(editorProvider.notifier)
          .update((s) => s.copyWith(toolbarExpanded: !s.toolbarExpanded)),
      'settings': _settings,
      'quit': () {
        if (desktopWindow) onWindowClose();
      },
    };
    return {
      for (final shortcut in appShortcuts.where((s) => !s.native))
        shortcut.activator(defaultTargetPlatform): actions[shortcut.id]!,
      const SingleActivator(LogicalKeyboardKey.escape): () {
        if (ref.read(editorProvider).searchVisible) {
          _closeSearch();
        } else {
          ref
              .read(editorProvider.notifier)
              .update((s) => s.copyWith(toolbarExpanded: false));
        }
      },
    };
  }

  void _insertCommand(MarkdownCommand command) {
    if (_busy || _restoring) return;
    _controller.value = command.apply(_controller.value);
    _focus.requestFocus();
  }

  void _runMarkdownCommand(MarkdownCommand command) {
    if (command.label == 'Mermaid') {
      _chooseTemplate(math: false);
    } else if (command.label == '行内公式' || command.label == '块公式') {
      _chooseTemplate(math: true);
    } else if (command.label == '图片') {
      _importPictures();
    } else if (command.label == '文字颜色') {
      _chooseTextColor();
    } else {
      _insertCommand(command);
    }
  }

  Future<void> _chooseTextColor() async {
    if (_busy || _restoring) return;
    final original = _controller.value;
    final color = await showMarkerDialog<String>(
      context: context,
      builder: (_) => const TextColorPicker(),
    );
    if (!mounted || color == null) return;
    _controller.value = MarkdownCommand(
      '文字颜色',
      '<span style="color:$color">',
      '</span>',
      t('彩色文字', 'Colored text'),
    ).apply(original);
    _focus.requestFocus();
  }

  Future<void> _chooseTemplate({required bool math}) async {
    if (_busy || _restoring) return;
    final original = _controller.value;
    final templates = math ? mathTemplates : mermaidTemplates;
    final template = await showMarkerDialog<MarkdownTemplate>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        final c = Theme.of(context).extension<MarkerColors>()!;
        return MarkerDialog(
          title: Text(
            math
                ? t('公式模板', 'Equation templates')
                : t('Mermaid 模板', 'Mermaid templates'),
          ),
          width: 560,
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t(
                  '选择模板插入；有选区时使用所选内容，可继续编辑。',
                  'Choose a template to insert. Selected text replaces the sample.',
                ),
                style: TextStyle(fontSize: 12, color: c.textSecondary),
              ),
              const SizedBox(height: 12),
              for (final item in templates)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: c.bgEditor,
                      border: Border.all(color: c.separatorSoft),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: CupertinoButton(
                      key: ValueKey('template-${item.id}'),
                      alignment: Alignment.centerLeft,
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.all(12),
                      onPressed: () => Navigator.pop(context, item),
                      child: SizedBox(
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _zh ? item.label : item.englishLabel,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: c.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              item.source,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: MarkerFonts.monospace,
                                fontFamilyFallback: MarkerFonts.codeFallback,
                                fontSize: 11,
                                color: c.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          actions: [],
        );
      },
    );
    if (!mounted || template == null) return;
    _controller.value = template.command.apply(original);
    _focus.requestFocus();
  }

  Future<void> _settings() async {
    await showMarkerDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final editor = ref.watch(editorProvider);
          final settings = ref.watch(themeProvider);
          final c = Theme.of(context).extension<MarkerColors>()!;
          final labels = [
            t('通用', 'General'),
            t('编辑与预览', 'Editor & preview'),
            t('快捷键', 'Keyboard shortcuts'),
            t('关于', 'About'),
          ];
          Widget row(IconData icon, String title, Widget control) =>
              ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: MarkerStyle.settingsRowHeight,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Icon(icon, size: 16, color: c.textSecondary),
                      const SizedBox(width: 8),
                      Expanded(child: Text(title, style: MarkerStyle.body)),
                      const SizedBox(width: 12),
                      control,
                    ],
                  ),
                ),
              );
          Widget group(String title, List<Widget> rows) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 12, bottom: 8),
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: c.textSecondary,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: c.bgEditor,
                    borderRadius: BorderRadius.circular(
                      MarkerStyle.groupRadius,
                    ),
                    border: Border.all(color: c.separatorSoft),
                  ),
                  child: Column(
                    children: [
                      for (var i = 0; i < rows.length; i++) ...[
                        if (i > 0)
                          Padding(
                            padding: const EdgeInsets.only(left: 36),
                            child: Container(height: 1, color: c.separatorSoft),
                          ),
                        rows[i],
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
          return MarkerDialog(
            title: Row(
              children: [
                const MarkerLogo(),
                const SizedBox(width: 8),
                Text(t('设置', 'Settings')),
              ],
            ),
            width: 860,
            height: 620,
            scrollable: false,
            contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            content: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 136,
                  padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < labels.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Container(
                            decoration: BoxDecoration(
                              color: editor.settingsPage == i
                                  ? c.bgSelected
                                  : null,
                              borderRadius: BorderRadius.circular(
                                MarkerStyle.controlRadius,
                              ),
                            ),
                            child: CupertinoButton(
                              alignment: Alignment.centerLeft,
                              minimumSize: Size.zero,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 10,
                              ),
                              onPressed: () => ref
                                  .read(editorProvider.notifier)
                                  .update((s) => s.copyWith(settingsPage: i)),
                              child: Row(
                                children: [
                                  Icon(
                                    i == 0
                                        ? CupertinoIcons.slider_horizontal_3
                                        : i == 1
                                        ? CupertinoIcons.textformat
                                        : i == 2
                                        ? CupertinoIcons.keyboard
                                        : CupertinoIcons.info_circle,
                                    size: 16,
                                    color: editor.settingsPage == i
                                        ? c.textAccent
                                        : c.textSecondary,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      labels[i],
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: editor.settingsPage == i
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                        color: c.textPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(width: 1, color: c.separatorSoft),
                const SizedBox(width: 16),
                Expanded(
                  child: editor.settingsPage == 2
                      ? ShortcutSettings(zh: _zh)
                      : SingleChildScrollView(
                          key: PageStorageKey(
                            'settings-content-${editor.settingsPage}',
                          ),
                          padding: EdgeInsets.zero,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                labels[editor.settingsPage],
                                style: MarkerStyle.heading,
                              ),
                              const SizedBox(height: 12),
                              if (editor.settingsPage == 0) ...[
                                group(t('外观', 'Appearance'), [
                                  row(
                                    CupertinoIcons.circle_lefthalf_fill,
                                    t('主题', 'Theme'),
                                    SizedBox(
                                      width: 224,
                                      child:
                                          CupertinoSlidingSegmentedControl<
                                            ThemeMode
                                          >(
                                            key: const Key('settings-theme'),
                                            groupValue: settings.mode,
                                            children: {
                                              ThemeMode.system: Text(
                                                t('自动', 'Auto'),
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                ),
                                              ),
                                              ThemeMode.light: Text(
                                                t('浅色', 'Light'),
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                ),
                                              ),
                                              ThemeMode.dark: Text(
                                                t('深色', 'Dark'),
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                ),
                                              ),
                                            },
                                            onValueChanged: (v) {
                                              if (v != null) {
                                                ref
                                                    .read(
                                                      themeProvider.notifier,
                                                    )
                                                    .setThemeMode(v);
                                              }
                                            },
                                          ),
                                    ),
                                  ),
                                ]),
                                group(t('语言', 'Language'), [
                                  row(
                                    CupertinoIcons.globe,
                                    t('界面语言', 'Language'),
                                    SizedBox(
                                      width: 224,
                                      child:
                                          CupertinoSlidingSegmentedControl<
                                            String
                                          >(
                                            key: const Key('settings-language'),
                                            groupValue:
                                                settings.locale.languageCode,
                                            children: const {
                                              'zh': Text(
                                                '简体中文',
                                                style: TextStyle(fontSize: 12),
                                              ),
                                              'en': Text(
                                                'English',
                                                style: TextStyle(fontSize: 12),
                                              ),
                                            },
                                            onValueChanged: (v) {
                                              if (v != null) {
                                                ref
                                                    .read(
                                                      themeProvider.notifier,
                                                    )
                                                    .setLocale(
                                                      Locale(
                                                        v,
                                                        v == 'zh' ? 'CN' : 'US',
                                                      ),
                                                    );
                                              }
                                            },
                                          ),
                                    ),
                                  ),
                                ]),
                              ] else if (editor.settingsPage == 1) ...[
                                group(t('语法高亮', 'Syntax highlighting'), [
                                  row(
                                    CupertinoIcons.textformat,
                                    t('文本高亮', 'Text highlighting'),
                                    CupertinoSwitch(
                                      key: const Key(
                                        'settings-highlight-enabled',
                                      ),
                                      value: settings.highlightEnabled,
                                      onChanged: (value) => ref
                                          .read(themeProvider.notifier)
                                          .setHighlightEnabled(value),
                                    ),
                                  ),
                                  if (settings.highlightEnabled)
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: HighlightStylePicker(
                                        key: const Key(
                                          'settings-highlight-style',
                                        ),
                                        selected: settings.highlightStyle,
                                        colors: c,
                                        zh: _zh,
                                        onChanged: (value) => ref
                                            .read(themeProvider.notifier)
                                            .setHighlightStyle(value),
                                      ),
                                    ),
                                ]),
                                group(t('编辑器', 'Editor'), [
                                  row(
                                    CupertinoIcons.textformat_size,
                                    t('字号', 'Text size'),
                                    Text(
                                      '${editor.fontSize.round()} pt',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: c.textSecondary,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      48,
                                      0,
                                      12,
                                      8,
                                    ),
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: CupertinoSlider(
                                        min: 10,
                                        max: 24,
                                        divisions: 14,
                                        value: editor.fontSize,
                                        onChanged: (v) => _fontSize = v,
                                      ),
                                    ),
                                  ),
                                ]),
                                group(t('预览', 'Preview'), [
                                  row(
                                    CupertinoIcons.doc_text,
                                    t('衬线字体', 'Serif font'),
                                    CupertinoSwitch(
                                      value: editor.serif,
                                      onChanged: (v) => _serif = v,
                                    ),
                                  ),
                                ]),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: c.bgEditor,
                                    borderRadius: BorderRadius.circular(
                                      MarkerStyle.groupRadius,
                                    ),
                                  ),
                                  child: Text.rich(
                                    TextSpan(
                                      children: settings.highlightEnabled
                                          ? MarkdownHighlighter(
                                              HighlightPalette.from(
                                                settings.highlightStyle,
                                                c,
                                              ),
                                            ).highlight(
                                              '# Marker\n**Bold** and `code` [link](https://example.com)\n\n```json\n{"name": "Marker", "count": 3}\n```',
                                            )
                                          : [
                                              const TextSpan(
                                                text:
                                                    '# Marker\n**Bold** and `code` [link](https://example.com)\n\n```json\n{"name": "Marker", "count": 3}\n```',
                                              ),
                                            ],
                                    ),
                                    style: TextStyle(
                                      fontFamily: MarkerFonts.monospace,
                                      fontFamilyFallback:
                                          MarkerFonts.codeFallback,
                                      fontSize: editor.fontSize,
                                      height: 1.6,
                                      color: c.textSecondary,
                                    ),
                                  ),
                                ),
                              ] else if (editor.settingsPage == 3) ...[
                                AboutSettings(zh: _zh),
                              ],
                            ],
                          ),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final editorState = ref.watch(editorProvider);
    final workspace = ref.watch(workspaceProvider);
    final resourceState = ref.watch(resourceUiProvider);
    final exporting = ref.watch(exportControllerProvider).isLoading;
    final c = Theme.of(context).extension<MarkerColors>()!;
    final offset = _controller.selection.isValid
        ? _controller.selection.extentOffset
        : 0;
    _lineIndex.update(_controller.text);
    final lineIndex = _lineIndex.lineAt(offset);
    final line = lineIndex + 1;
    final column = offset - _lineIndex.start(lineIndex) + 1;
    Widget button(IconData icon, String label, VoidCallback action) => Tooltip(
      message: label,
      child: SizedBox(
        width: 34,
        height: 28,
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          onPressed: _busy ? null : action,
          child: Icon(icon, size: 16, color: c.textSecondary),
        ),
      ),
    );
    _controller.searchQuery = editorState.searchVisible
        ? editorState.searchQuery
        : '';
    _controller.searchCaseSensitive = editorState.searchCaseSensitive;
    _controller.colors = c;
    _controller.highlightStyle = ref.watch(themeProvider).highlightStyle;
    _controller.highlightEnabled = ref.watch(themeProvider).highlightEnabled;
    MarkdownCommand commandByLabel(String label) => markdownCommandGroups.values
        .expand((items) => items)
        .firstWhere((command) => command.label == label);
    Widget syntaxControl(
      Widget icon,
      String label,
      VoidCallback action, {
      Key? key,
    }) => Tooltip(
      message: label,
      child: SizedBox(
        width: double.infinity,
        height: 28,
        child: CupertinoButton(
          key: key,
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          onPressed: _busy || _restoring ? null : action,
          child: icon,
        ),
      ),
    );
    final editorStyle = TextStyle(
      fontFamily: MarkerFonts.monospace,
      fontFamilyFallback: MarkerFonts.codeFallback,
      fontSize: _fontSize,
      height: 1.6,
      color: c.textPrimary,
    );
    final rawEditor = LinkedScrollRegion(
      link: _linkedScroll,
      controller: _editorScroll,
      child: KeyedSubtree(
        key: ValueKey(workspace.activeId),
        child: ColoredBox(
          color: c.bgEditor,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final digits = _lineIndex.length.toString().length;
              final numberMeasure = TextPainter(
                text: TextSpan(text: '9' * digits, style: editorStyle),
                textDirection: TextDirection.ltr,
                textScaler: MediaQuery.textScalerOf(context),
              )..layout();
              final gutterWidth = numberMeasure.width + 8;
              numberMeasure.dispose();
              return Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LineNumberGutter(
                    key: const Key('line-numbers'),
                    controller: _controller,
                    scrollController: _editorScroll,
                    style: editorStyle,
                    index: _lineIndex,
                    editable: _editable,
                    color: c.textTertiary,
                    width: gutterWidth,
                  ),
                  Expanded(
                    child: CupertinoTextField(
                      key: const Key('editor'),
                      scrollPadding: EdgeInsets.zero,
                      controller: _controller,
                      undoController: _undo,
                      focusNode: _focus,
                      readOnly: _restoring || resourceState.busy,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      style: editorStyle,
                      strutStyle: StrutStyle.fromTextStyle(
                        editorStyle,
                        forceStrutHeight: true,
                      ),
                      scrollController: _editorScroll,
                      minLines: null,
                      decoration: null,
                      padding: const EdgeInsets.fromLTRB(4, 10, 4, 10),
                      placeholder: t('开始书写…', 'Start writing…'),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
    final editor = Actions(
      actions: <Type, Action<Intent>>{
        PasteTextIntent: CallbackAction<PasteTextIntent>(
          onInvoke: (_) {
            _pasteResourceOrText();
            return null;
          },
        ),
      },
      child: rawEditor,
    );
    final previewSignature = (
      _controller.text,
      _path,
      _serif,
      _imageEpoch,
      Theme.of(context),
      Localizations.localeOf(context),
      ref.watch(mermaidPreviewEnabledProvider),
    );
    if (_previewSignature != previewSignature) {
      _previewSignature = previewSignature;
      _previewCache = LinkedScrollRegion(
        link: _linkedScroll,
        controller: _previewScroll,
        child: RepaintBoundary(
          child: ColoredBox(
            color: c.bgPreview,
            child: SizedBox.expand(
              child: Markdown(
                key: const Key('preview'),
                extensionSet: md.ExtensionSet.gitHubFlavored,
                controller: _previewScroll,
                blockSyntaxes: [MermaidSyntax(), MathBlockSyntax()],
                inlineSyntaxes: [TextColorSyntax(), MathInlineSyntax()],
                builders: {
                  'text-color': TextColorBuilder(),
                  'math-inline': MathBuilder(),
                  'math-block': MathBuilder(block: true),
                  'mermaid': MermaidBuilder(
                    enabled: ref.watch(mermaidPreviewEnabledProvider),
                  ),
                },
                onTapLink: (text, href, title) async {
                  if (href == null) return;
                  try {
                    if (href.startsWith('#')) {
                      if (_previewScroll.hasClients) {
                        _linkedScroll.takeControl(_previewScroll);
                        await _previewScroll.animateTo(
                          href.startsWith('#fnref')
                              ? 0
                              : _previewScroll.position.maxScrollExtent,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOut,
                        );
                      }
                      return;
                    }
                    final uri = resolveDocumentUri(href, _path);
                    if (![
                      'http',
                      'https',
                      'mailto',
                      'file',
                    ].contains(uri.scheme)) {
                      _toast(t('不支持此链接类型', 'Unsupported link type'));
                      return;
                    }
                    if (!await launchUrl(
                      uri,
                      mode: LaunchMode.externalApplication,
                    )) {
                      throw StateError('无法打开链接');
                    }
                  } catch (e) {
                    _error(e);
                  }
                },
                sizedImageBuilder: (config) {
                  final uri = config.uri;
                  final alt = config.alt;
                  final resolved = resolveResourceUri(uri.toString(), _path);
                  Widget failure(
                    BuildContext context,
                    Object error,
                    StackTrace? stack,
                  ) {
                    String reason;
                    if (resolved.scheme != 'file') {
                      reason = t('网络图片加载失败', 'Web image could not be loaded');
                    } else if (error is FileSystemException &&
                        [
                          1,
                          13,
                          if (Platform.isWindows) 5,
                        ].contains(error.osError?.errorCode)) {
                      reason = t(
                        '无法访问图片，请授权目录',
                        'Cannot access image; allow folder access',
                      );
                    } else if (error is FileSystemException &&
                        [2, 3].contains(error.osError?.errorCode)) {
                      reason = t('图片未找到', 'Image not found');
                    } else {
                      reason = t(
                        '无法解析图片，请检查格式或文件是否损坏',
                        'Cannot decode image; check its format or integrity',
                      );
                    }
                    return Text(
                      '${alt ?? ''} · $reason',
                      style: TextStyle(color: c.textSecondary),
                    );
                  }

                  if (resolved.scheme == 'file') {
                    return Image.file(
                      File.fromUri(resolved),
                      key: ValueKey((resolved.toString(), _imageEpoch, config)),
                      width: config.width,
                      height: config.height,
                      errorBuilder: (context, error, stack) => Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          failure(context, error, stack),
                          CupertinoButton(
                            minimumSize: const Size(0, 28),
                            onPressed: () => _action(
                              () => _relocateResource(uri.toString()),
                            ),
                            child: Text(t('重新定位图片', 'Locate image')),
                          ),
                          CupertinoButton(
                            onPressed: () => _action(() async {
                              await _authorizeResourceFolder(
                                p.dirname(File.fromUri(resolved).path),
                              );
                              await FileImage(File.fromUri(resolved)).evict();
                              _imageEpoch++;
                            }),
                            child: Text(
                              t('授权图片所在目录并重试', 'Allow image folder and retry'),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  if (['http', 'https'].contains(resolved.scheme)) {
                    return Image.network(
                      resolved.toString(),
                      key: ValueKey((resolved.toString(), _imageEpoch, config)),
                      errorBuilder: (context, error, stack) => Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          failure(context, error, stack),
                          CupertinoButton(
                            minimumSize: const Size(0, 28),
                            onPressed: () async {
                              await NetworkImage(resolved.toString()).evict();
                              _imageEpoch++;
                              _previewSignature = null;
                              _resourceWork.refresh();
                            },
                            child: Text(t('重新加载图片', 'Reload image')),
                          ),
                        ],
                      ),
                    );
                  }
                  return Text(
                    t(
                      '请先保存文档以加载相对路径图片',
                      'Save the document to resolve relative images',
                    ),
                  );
                },
                data: _controller.text,
                selectable: true,
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 10,
                ),
                styleSheet: MarkerMarkdownStyle.build(context).copyWith(
                  p: TextStyle(
                    fontFamily: _serif ? 'New York' : MarkerFonts.ui,
                    fontFamilyFallback: _serif
                        ? MarkerFonts.serifFallback
                        : MarkerFonts.fallback,
                    fontSize: 15,
                    height: 1.7,
                    color: c.textPrimary,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
    final preview = _previewCache!;
    return CallbackShortcuts(
      bindings: _shortcutBindings(),
      child: Focus(
        autofocus: true,
        child: _resourceDropZone(
          Scaffold(
            backgroundColor: c.bgWindow,
            body: Column(
              children: [
                if (desktopWindow &&
                    defaultTargetPlatform == TargetPlatform.macOS)
                  SizedBox(
                    height: 36,
                    child: DragToMoveArea(
                      child: Center(
                        child: Text(
                          '$_name${_dirty ? ' •' : ''}',
                          style: TextStyle(
                            fontSize: 12,
                            color: c.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        key: const Key('document-sidebar'),
                        width: _sidebar
                            ? ref.watch(themeProvider).sidebarWidth
                            : 56,
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(color: c.bgSidebar),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final expanded = constraints.maxWidth >= 170;
                            return Column(
                              children: [
                                SizedBox(
                                  height: 44,
                                  child: Row(
                                    children: [
                                      button(
                                        CupertinoIcons.sidebar_left,
                                        t('切换侧栏', 'Toggle sidebar'),
                                        () =>
                                            _update(() => _sidebar = !_sidebar),
                                      ),
                                      if (expanded)
                                        Expanded(
                                          child: Text(
                                            resourceState.showResources
                                                ? t('资源', 'Resources')
                                                : t('文件', 'Files'),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: c.textSecondary,
                                            ),
                                          ),
                                        ),

                                      if (expanded)
                                        button(
                                          resourceState.showResources
                                              ? CupertinoIcons.doc_text
                                              : CupertinoIcons
                                                    .photo_on_rectangle,
                                          resourceState.showResources
                                              ? t('文档列表', 'Documents')
                                              : t('文档资源', 'Document resources'),
                                          _resourceWork.toggle,
                                        ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: resourceState.showResources && expanded
                                      ? ResourceSidebar(
                                          text: _controller.text,
                                          path: _path,
                                          zh: _zh,
                                          onImport: () => _importPictures(),
                                          onMenu: _resourceMenu,
                                          onItem: _resourceItemMenu,
                                        )
                                      : ListView.builder(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                          ),
                                          itemCount: workspace.documents.length,
                                          itemBuilder: (context, index) {
                                            final document =
                                                workspace.documents[index];
                                            return GestureDetector(
                                              onSecondaryTapUp: _busy
                                                  ? null
                                                  : (details) => _documentMenu(
                                                      document,
                                                      details.globalPosition,
                                                    ),
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                  bottom: 4,
                                                ),
                                                child: Container(
                                                  height: 32,
                                                  decoration: BoxDecoration(
                                                    color:
                                                        document.id ==
                                                            workspace.activeId
                                                        ? c.bgSelected
                                                        : null,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          7,
                                                        ),
                                                  ),
                                                  child: Tooltip(
                                                    message:
                                                        document.path ??
                                                        document.name,
                                                    child: CupertinoButton(
                                                      key: ValueKey(
                                                        'document-${document.id}',
                                                      ),
                                                      minimumSize: Size.zero,
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 8,
                                                          ),
                                                      onPressed: _busy
                                                          ? null
                                                          : () => _action(
                                                              () =>
                                                                  _selectDocument(
                                                                    document.id,
                                                                  ),
                                                            ),
                                                      child: Row(
                                                        children: [
                                                          Icon(
                                                            CupertinoIcons
                                                                .doc_text,
                                                            size: 16,
                                                            color:
                                                                document.id ==
                                                                    workspace
                                                                        .activeId
                                                                ? c.textAccent
                                                                : c.textSecondary,
                                                          ),
                                                          if (expanded) ...[
                                                            const SizedBox(
                                                              width: 8,
                                                            ),
                                                            Expanded(
                                                              child: Text(
                                                                '${document.name}${document.dirty ? ' •' : ''}',
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style: TextStyle(
                                                                  fontSize: 12,
                                                                  color: c
                                                                      .textPrimary,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  child: Row(
                                    children: [
                                      button(
                                        CupertinoIcons.gear,
                                        t('设置', 'Settings'),
                                        _settings,
                                      ),
                                      if (expanded)
                                        Text(
                                          t('设置', 'Settings'),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: c.textSecondary,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      if (_sidebar)
                        MouseRegion(
                          cursor: SystemMouseCursors.resizeColumn,
                          child: GestureDetector(
                            key: const Key('sidebar-resize'),
                            behavior: HitTestBehavior.opaque,
                            onHorizontalDragUpdate: (details) => ref
                                .read(themeProvider.notifier)
                                .setSidebarWidth(
                                  ref.read(themeProvider).sidebarWidth +
                                      details.delta.dx,
                                ),
                            onHorizontalDragEnd: (_) => ref
                                .read(themeProvider.notifier)
                                .persistSidebarWidth(),
                            child: SizedBox(
                              width: 5,
                              child: Center(
                                child: Container(
                                  width: 1,
                                  color: c.separatorSoft,
                                ),
                              ),
                            ),
                          ),
                        ),
                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              height: 44,
                              color: c.bgToolbar,
                              child: Row(
                                children: [
                                  button(
                                    CupertinoIcons.doc_append,
                                    t('新建', 'New'),
                                    () => _action(_newFile),
                                  ),
                                  button(
                                    CupertinoIcons.folder,
                                    t('打开', 'Open'),
                                    () => _action(_open),
                                  ),
                                  button(
                                    CupertinoIcons.square_arrow_down,
                                    t('保存', 'Save'),
                                    () => _action(() async {
                                      await _save();
                                    }),
                                  ),
                                  button(
                                    CupertinoIcons.square_arrow_down_on_square,
                                    t('另存为', 'Save as'),
                                    () => _action(() async {
                                      await _save(as: true);
                                    }),
                                  ),
                                  if (documentExportEnabled)
                                    button(
                                      CupertinoIcons.square_arrow_up,
                                      t('导出', 'Export'),
                                      _exportDocument,
                                    ),
                                  button(
                                    CupertinoIcons.arrow_uturn_left,
                                    t('撤销', 'Undo'),
                                    _undo.undo,
                                  ),
                                  button(
                                    CupertinoIcons.arrow_uturn_right,
                                    t('重做', 'Redo'),
                                    _undo.redo,
                                  ),
                                  button(
                                    CupertinoIcons.search,
                                    t('搜索替换', 'Find and replace'),
                                    () => _openSearch(replace: true),
                                  ),
                                  Container(
                                    width: 1,
                                    height: 16,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 5,
                                    ),
                                    color: c.separatorSoft,
                                  ),
                                  Expanded(
                                    child: LayoutBuilder(
                                      builder: (context, constraints) {
                                        final controls = <Widget>[
                                          for (final label in [
                                            'H1',
                                            'H2',
                                            'H3',
                                          ])
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
                                              () => _runMarkdownCommand(
                                                commandByLabel(label),
                                              ),
                                            ),
                                          for (final entry in <(String, IconData)>[
                                            ('粗体', CupertinoIcons.bold),
                                            ('斜体', CupertinoIcons.italic),
                                            (
                                              '删除线',
                                              CupertinoIcons.strikethrough,
                                            ),
                                            ('链接', CupertinoIcons.link),
                                            ('图片', CupertinoIcons.photo),
                                            (
                                              '无序列表',
                                              CupertinoIcons.list_bullet,
                                            ),
                                            (
                                              '有序列表',
                                              CupertinoIcons.list_number,
                                            ),
                                            (
                                              '任务列表',
                                              CupertinoIcons.checkmark_square,
                                            ),
                                            ('引用', CupertinoIcons.quote_bubble),
                                            (
                                              '行内代码',
                                              CupertinoIcons
                                                  .chevron_left_slash_chevron_right,
                                            ),
                                            ('代码块', CupertinoIcons.doc_text),
                                            ('表格', CupertinoIcons.table),
                                            ('分隔线', CupertinoIcons.minus),
                                          ])
                                            syntaxControl(
                                              Icon(
                                                entry.$2,
                                                size: 16,
                                                color: c.textSecondary,
                                              ),
                                              entry.$1,
                                              () => _runMarkdownCommand(
                                                commandByLabel(entry.$1),
                                              ),
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
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          2,
                                                        ),
                                                    gradient:
                                                        const LinearGradient(
                                                          colors: [
                                                            CupertinoColors
                                                                .systemRed,
                                                            CupertinoColors
                                                                .systemYellow,
                                                            CupertinoColors
                                                                .systemGreen,
                                                            CupertinoColors
                                                                .systemBlue,
                                                          ],
                                                        ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            t('文字颜色', 'Text color'),
                                            _chooseTextColor,
                                            key: const Key(
                                              'text-color-toolbar',
                                            ),
                                          ),
                                          syntaxControl(
                                            Icon(
                                              CupertinoIcons.function,
                                              size: 16,
                                              color: c.textSecondary,
                                            ),
                                            t('公式模板', 'Equation templates'),
                                            () => _chooseTemplate(math: true),
                                          ),
                                          syntaxControl(
                                            Icon(
                                              CupertinoIcons.flowchart,
                                              size: 16,
                                              color: c.textSecondary,
                                            ),
                                            t(
                                              'Mermaid 模板',
                                              'Mermaid templates',
                                            ),
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
                                                  (command) => !represented
                                                      .contains(command.label),
                                                )) {
                                          controls.add(
                                            syntaxControl(
                                              Text(
                                                labels[command.label] ??
                                                    command.label,
                                                maxLines: 1,
                                                overflow: TextOverflow.fade,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: c.textSecondary,
                                                ),
                                              ),
                                              command.label,
                                              () =>
                                                  _runMarkdownCommand(command),
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
                                          for (
                                            var i = 19;
                                            i < controls.length;
                                            i++
                                          )
                                            i,
                                        ];
                                        final count =
                                            (constraints.maxWidth / 32)
                                                .floor()
                                                .clamp(0, controls.length);
                                        return Row(
                                          key: const Key(
                                            'markdown-toolbar-syntax',
                                          ),
                                          children: [
                                            for (final index in priority.take(
                                              count,
                                            ))
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
                                    t('全部 Markdown 语法', 'All Markdown syntax'),
                                    () => ref
                                        .read(editorProvider.notifier)
                                        .update(
                                          (s) => s.copyWith(
                                            toolbarExpanded: !s.toolbarExpanded,
                                          ),
                                        ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    child:
                                        CupertinoSlidingSegmentedControl<int>(
                                          groupValue: _mode,
                                          children: {
                                            0: Text(
                                              t('编辑', 'Edit'),
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                            1: Text(
                                              t('分屏', 'Split'),
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                            2: Text(
                                              t('预览', 'Preview'),
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                          },
                                          onValueChanged: (v) {
                                            if (v != null) _mode = v;
                                          },
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            if (ref.watch(editorProvider).searchVisible)
                              EditorSearchBar(
                                editor: _controller,
                                queryFocus: _searchFocus,
                                onNext: () => _findMatch(),
                                onPrevious: () => _findMatch(forward: false),
                                onQuery: () => _findMatch(fromStart: true),
                                onReplace: _replaceMatch,
                                onReplaceAll: _replaceAllMatches,
                                onClose: _closeSearch,
                              ),
                            Expanded(
                              child: LayoutBuilder(
                                builder: (context, size) {
                                  Widget buildPanes() {
                                    if (_mode == 0) {
                                      return SizedBox.expand(child: editor);
                                    }
                                    if (_mode == 2) {
                                      return SizedBox.expand(child: preview);
                                    }
                                    if (size.maxWidth < 560) {
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Expanded(child: editor),
                                          const Divider(height: 1),
                                          Expanded(child: preview),
                                        ],
                                      );
                                    }
                                    return Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        SizedBox(
                                          width: (size.maxWidth - 8) * _ratio,
                                          child: editor,
                                        ),
                                        MouseRegion(
                                          cursor:
                                              SystemMouseCursors.resizeColumn,
                                          child: GestureDetector(
                                            onDoubleTap: () =>
                                                _update(() => _ratio = .5),
                                            onHorizontalDragUpdate: (d) =>
                                                _update(
                                                  () => _ratio =
                                                      (_ratio +
                                                              d.delta.dx /
                                                                  (size.maxWidth -
                                                                      8))
                                                          .clamp(.2, .8),
                                                ),
                                            child: Container(
                                              width: 8,
                                              color: c.bgToolbar,
                                              child: Center(
                                                child: Container(
                                                  width: 1,
                                                  color: c.separator,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(child: preview),
                                      ],
                                    );
                                  }

                                  final rightSpace =
                                      _mode == 1 && size.maxWidth >= 560
                                      ? (size.maxWidth - 8) * (1 - _ratio)
                                      : size.maxWidth;
                                  return Stack(
                                    children: [
                                      Positioned.fill(child: buildPanes()),
                                      if (ref
                                          .watch(editorProvider)
                                          .toolbarExpanded)
                                        Positioned(
                                          top: 10,
                                          bottom: 10,
                                          right: 10,
                                          width: (rightSpace - 20).clamp(
                                            40.0,
                                            340.0,
                                          ),
                                          child: MarkdownSyntaxPanel(
                                            enabled: !_busy && !_restoring,
                                            onCommand: _runMarkdownCommand,
                                            onClose: () => ref
                                                .read(editorProvider.notifier)
                                                .update(
                                                  (s) => s.copyWith(
                                                    toolbarExpanded: false,
                                                  ),
                                                ),
                                          ),
                                        ),
                                    ],
                                  );
                                },
                              ),
                            ),
                            DefaultTextStyle(
                              style: TextStyle(
                                fontSize: 11,
                                color: c.textTertiary,
                              ),
                              child: Container(
                                height: 24,
                                color: c.bgToolbar,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      t(
                                        '行 $line，列 $column',
                                        'Ln $line, Col $column',
                                      ),
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                    const Spacer(),
                                    Text(
                                      resourceState.busy
                                          ? '${resourceState.operation}${resourceState.total > 0 ? ' ${resourceState.done}/${resourceState.total}' : ''}'
                                          : exporting
                                          ? t('正在导出文档…', 'Exporting document…')
                                          : '${_lineIndex.characters} ${t('字符', 'characters')} · UTF-8 · Markdown',
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                    if (resourceState.busy)
                                      CupertinoButton(
                                        key: const Key(
                                          'stop-resource-operation',
                                        ),
                                        padding: const EdgeInsets.only(left: 8),
                                        minimumSize: const Size(0, 20),
                                        onPressed: _resourceWork.cancel,
                                        child: Text(
                                          t('停止', 'Stop'),
                                          style: const TextStyle(fontSize: 11),
                                        ),
                                      ),
                                  ],
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
      ),
    );
  }
}
