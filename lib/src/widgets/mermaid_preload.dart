import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:markdown/markdown.dart' as md;
import 'markdown_extensions.dart' show MermaidSyntax, MathBlockSyntax;
import 'mermaid_diagram.dart';
import 'mermaid_render_scope.dart';

/// Use the same parser as preview, on a worker isolate; fences inside quotes/lists
/// and fenced examples must behave exactly like the visible document.
List<String> collectMermaidSources(String source) {
  final document = md.Document(
    extensionSet: md.ExtensionSet.gitHubFlavored,
    encodeHtml: false,
    blockSyntaxes: [MermaidSyntax(), MathBlockSyntax()],
  );
  final result = <String>{};
  void visit(md.Node node) {
    if (node is! md.Element || result.length >= 24) return;
    if (node.tag == 'mermaid') {
      result.add(node.textContent);
    } else {
      for (final child in node.children ?? <md.Node>[]) {
        visit(child);
      }
    }
  }

  for (final node in document.parseLines(
    const LineSplitter().convert(source),
  )) {
    visit(node);
  }
  return result.toList();
}

/// Pre-render before lazy Markdown blocks enter the viewport. Native page starts
/// and first image swaps wait for both panes (including linked jumps) to settle.
class MermaidPreload extends ConsumerStatefulWidget {
  const MermaidPreload({
    super.key,
    required this.source,
    required this.dark,
    required this.enabled,
    required this.controllers,
    required this.child,
  });
  final String source;
  final bool dark, enabled;
  final List<ScrollController> controllers;
  final Widget child;
  @override
  ConsumerState<MermaidPreload> createState() => _MermaidPreloadState();
}

class _MermaidPreloadState extends ConsumerState<MermaidPreload> {
  Timer? _debounce, _settle;
  Completer<void>? _idle;
  int _generation = 0;
  @override
  void initState() {
    super.initState();
    for (final controller in widget.controllers) {
      controller.addListener(_moving);
    }
    _schedule();
  }

  @override
  void didUpdateWidget(MermaidPreload oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.controllers, widget.controllers)) {
      for (final c in oldWidget.controllers) {
        c.removeListener(_moving);
      }
      for (final c in widget.controllers) {
        c.addListener(_moving);
      }
    }
    if (oldWidget.source != widget.source ||
        oldWidget.dark != widget.dark ||
        oldWidget.enabled != widget.enabled) {
      _schedule();
    }
  }

  bool get _scrolling => widget.controllers.any(
    (c) => c.positions.any((p) => p.isScrollingNotifier.value),
  );
  void _moving() {
    if (!mounted) return;
    _idle ??= Completer<void>();
    _settle?.cancel();
    _settle = Timer(const Duration(milliseconds: 220), () {
      if (_scrolling) {
        _moving();
        return;
      }
      final completer = _idle;
      _idle = null;
      completer?.complete();
    });
  }

  Future<void> _waitForIdle() async {
    if (!mounted) return;
    if (_scrolling && _idle == null) _moving();
    while (mounted && _idle != null) {
      await _idle!.future;
    }
  }

  void _schedule() {
    _debounce?.cancel();
    final generation = ++_generation;
    if (!widget.enabled || !widget.source.contains('mermaid')) return;
    _debounce = Timer(
      const Duration(milliseconds: 350),
      () => _warm(generation),
    );
  }

  Future<void> _warm(int generation) async {
    try {
      await _waitForIdle();
      if (!mounted || generation != _generation) return;
      final source = widget.source, dark = widget.dark;
      final renderer = ref.read(mermaidRenderProvider);
      final diagrams = await compute(collectMermaidSources, source);
      for (final diagram in diagrams) {
        await _waitForIdle();
        if (!mounted || generation != _generation) return;
        try {
          final bytes = await renderer.render(
            diagram,
            dark,
            waitForIdle: _waitForIdle,
          );
          await _waitForIdle();
          if (!mounted || generation != _generation) return;
          await precacheImage(MemoryImage(bytes), context, onError: (_, _) {});
        } catch (_) {
          // A visible block owns the localized error UI; do not abort other diagrams.
        }
      }
    } catch (_) {
      // Speculative warming must never interrupt editing or loading a document.
    }
  }

  @override
  void dispose() {
    _generation++;
    _debounce?.cancel();
    _settle?.cancel();
    _idle?.complete();
    _idle = null;
    for (final c in widget.controllers) {
      c.removeListener(_moving);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MermaidRenderScope(
    waitForIdle: _waitForIdle,
    child: NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.depth == 0 &&
            notification.metrics.axis == Axis.vertical) {
          _moving();
        }
        return false;
      },
      child: widget.child,
    ),
  );
}
