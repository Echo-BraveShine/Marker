import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marker/src/theme/marker_colors.dart';
import 'package:marker/src/providers/editor_provider.dart';

/// 编辑区视图：将输入同步到 editorProvider
class EditorPane extends ConsumerStatefulWidget {
  const EditorPane({super.key});

  @override
  ConsumerState<EditorPane> createState() => _EditorPaneState();
}

class _EditorPaneState extends ConsumerState<EditorPane> {
  late final TextEditingController _controller;
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    final vm = ref.read(editorProvider);
    _controller = TextEditingController(text: vm.markdown);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<MarkerColors>()!;
    return Container(
      color: colors.bgEditor,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        keyboardType: TextInputType.multiline,
        style: TextStyle(
          fontFamily: 'Menlo',
          fontFamilyFallback: const ['Consolas', 'Noto Sans SC'],
          fontSize: 14,
          height: 1.6,
          color: colors.textPrimary,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Start writing...',
        ),
        onChanged: (value) {
          ref.read(editorProvider.notifier).setMarkdown(value);
        },
      ),
    );
  }
}
