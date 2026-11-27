part of '../../main.dart';

class MarkerHome extends ConsumerStatefulWidget {
  const MarkerHome({super.key});
  @override
  ConsumerState<MarkerHome> createState() => _MarkerHomeState();
}

class _MarkerHomeState extends ConsumerState<MarkerHome>
    with WindowListener, WidgetsBindingObserver {
  final _drafts = DraftStore();

  Timer? _draftTimer;

  Timer? _diskTimer;
  bool _syncingDisk = false;
  bool _closeRequested = false;
  Completer<void>? _diskSyncCompletion;

  Timer? _toastTimer;

  OverlayEntry? _toastEntry;

  bool get _restoring => ref.read(editorProvider).restoring;

  set _restoring(bool value) => ref
      .read(editorProvider.notifier)
      .update((s) => s.copyWith(restoring: value));

  bool get _sidebar => ref.read(themeProvider).sidebarExpanded;

  set _sidebar(bool value) =>
      unawaited(ref.read(themeProvider.notifier).setSidebarExpanded(value));

  String? _lastDraftText;

  bool _switchingDocument = false;

  final _pendingOpenFiles = <String>[];
  final _pendingMobileFiles = <MobileOpenFile>[];
  final _receivedMobileTokens = <String>{};
  MobileOpenFiles? _mobileOpenFiles;

  static const _filesChannel = MethodChannel('marker/files');

  WorkspaceNotifier get _workspace => ref.read(workspaceProvider.notifier);

  final _controller = MarkdownEditingController(text: defaultMarkdown);

  final _focus = FocusNode();

  final _lineIndex = LineNumberIndex();

  String? _anchorSource;
  List<int> _anchorLines = [];
  Object? _editorAnchorSignature;
  List<double> _editorAnchorOffsets = [];
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
  final _editorMountKey = GlobalKey();

  final _previewAnchors = MarkdownScrollAnchors();
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

  bool get _isMobile => mobileWindow;

  bool get _zh => _l10n.locale.languageCode == 'zh';
  String get _languageTag => _l10n.languageTag;

  bool get _dirty => _controller.text != _saved;

  String get _name => _path?.split(RegExp(r'[/\\]')).last ?? 'Untitled.md';

  AppLocalizations get _l10n => AppLocalizations.of(context);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ref.read(autosaveProvider);
    ref.listenManual(workspaceProvider, (previous, next) {
      if (!mounted) return;
      final active = next.documents
          .where((d) => d.id == next.activeId)
          .firstOrNull;
      if (active != null && active.path == _path && active.saved != _saved) {
        _saved = active.saved;
      }
    });
    _controller.addListener(_changed);
    FocusManager.instance.addEarlyKeyEventHandler(_handleSyntaxEscape);
    FocusManager.instance.addEarlyKeyEventHandler(_handleNavigationKey);
    _linkedScroll = LinkedScroll(
      _editorScroll,
      _previewScroll,
      enabled: () => mounted && _mode == 1,
      mapOffset: _mapContentScroll,
    );
    if (!desktopWindow && !mobileWindow) {
      Future.microtask(() => ref.read(themeProvider.notifier).init());
    }
    if (desktopWindow) windowManager.addListener(this);
    _restore();
    _connectExternalFiles();
    _diskTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      unawaited(_syncDeletedDocuments());
    });
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

  KeyEventResult _handleNavigationKey(KeyEvent event) {
    if (!mounted) return KeyEventResult.ignored;
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    if (!_focus.hasFocus || !(ModalRoute.of(context)?.isCurrent ?? true)) {
      return KeyEventResult.ignored;
    }

    final keyboard = HardwareKeyboard.instance;
    if (event.logicalKey == LogicalKeyboardKey.tab &&
        !keyboard.isControlPressed &&
        !keyboard.isMetaPressed &&
        !keyboard.isAltPressed &&
        !_busy &&
        !_restoring &&
        !ref.read(resourceUiProvider).busy) {
      final next = indentMarkdownSelection(
        _controller.value,
        outdent: keyboard.isShiftPressed,
      );
      if (next != _controller.value) _controller.value = next;
      return KeyEventResult.handled;
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
          final root = await ref.read(mobileDocumentsRootProvider);
          if (!mounted) return;
          final paths = MobilePathRestore(
            root,
            draft['mobileDocumentsRoot'] as String?,
          );
          final oldPath = draft['path'] as String?;
          final restoredPath = paths.restore(oldPath);
          final restoredText = await paths.images(
            draft['text'] as String,
            oldPath,
            restoredPath,
          );
          if (!mounted) return;
          _workspace.add(
            text: restoredText,
            saved: draft['saved'] as String,
            path: restoredPath,
          );
        } else {
          final store = ref.read(sampleDocumentStoreProvider);
          final path = await store?.initialize(defaultMarkdown);
          if (!mounted) return;
          if (path != null) {
            final text = await File(path).readAsString();
            if (!mounted) return;
            _workspace.add(text: text, saved: text, path: path);
          } else if (store == null) {
            _workspace.add(text: defaultMarkdown, saved: defaultMarkdown);
          }
        }
      }
      final store = ref.read(sampleDocumentStoreProvider);
      final legacy = _workspace.active;
      if (restored &&
          store != null &&
          legacy?.path == null &&
          (legacy?.text == defaultMarkdown ||
              legacy?.text == legacyDefaultMarkdown) &&
          legacy?.saved == legacy?.text) {
        final path = await store.initialize(defaultMarkdown);
        if (!mounted) return;
        if (path != null) {
          final text = await File(path).readAsString();
          if (!mounted) return;
          _workspace.snapshot(text, text, path);
        }
      }
      _loadActive();
      await _workspace.persist();
      if (mounted &&
          ref.read(workspaceProvider).documents.any((d) => d.dirty)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _toast(_l10n.message(AppMessage.unsavedDraftsRestored));
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

  Future<void> _persist() async {
    _draftTimer?.cancel();
    _snapshot();
    await _workspace.persist();
    await _drafts.write(_controller.text, _saved, _path);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) =>
      _handleAutosaveLifecycle(state);

  @override
  void onWindowClose() {
    if (_busy) {
      _closeRequested = true;
      return;
    }
    _closeRequested = false;
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
    unawaited(_mobileOpenFiles?.disconnect() ?? Future<void>.value());
    WidgetsBinding.instance.removeObserver(this);
    FocusManager.instance.removeEarlyKeyEventHandler(_handleSyntaxEscape);
    FocusManager.instance.removeEarlyKeyEventHandler(_handleNavigationKey);
    _draftTimer?.cancel();
    _diskTimer?.cancel();
    if (desktopWindow &&
        [
          TargetPlatform.macOS,
          TargetPlatform.windows,
          TargetPlatform.linux,
        ].contains(defaultTargetPlatform)) {
      if (defaultTargetPlatform == TargetPlatform.macOS) {
        _filesChannel.setMethodCallHandler(null);
      }
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

  @override
  Widget build(BuildContext context) => _buildHome(context);
}
