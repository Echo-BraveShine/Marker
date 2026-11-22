import 'package:flutter/cupertino.dart';
import '../widgets/marker_dialog.dart';

class ResourceTextDialog extends StatefulWidget {
  const ResourceTextDialog({
    super.key,
    required this.title,
    required this.placeholder,
    required this.initial,
    required this.confirm,
  });
  final String title, placeholder, initial, confirm;
  @override
  State<ResourceTextDialog> createState() => _ResourceTextDialogState();
}

class _ResourceTextDialogState extends State<ResourceTextDialog> {
  late final _controller = TextEditingController(text: widget.initial);
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_controller.text.trim().isNotEmpty) {
      Navigator.pop(context, _controller.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) => MarkerDialog(
    width: 440,
    title: Text(widget.title),
    content: CupertinoTextField(
      key: const Key('resource-text-input'),
      controller: _controller,
      autofocus: true,
      placeholder: widget.placeholder,
      onSubmitted: (_) => _submit(),
    ),
    actions: [
      MarkerDialogButton(
        primary: true,
        onPressed: _submit,
        child: Text(widget.confirm),
      ),
    ],
  );
}
