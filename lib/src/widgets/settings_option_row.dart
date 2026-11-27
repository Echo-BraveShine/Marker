import 'package:flutter/cupertino.dart';
import '../theme/marker_style.dart';

/// Shared geometry for all settings rows, including application information.
class SettingsOptionRow extends StatelessWidget {
  const SettingsOptionRow({
    super.key,
    required this.leading,
    required this.title,
    required this.control,
  });
  final Widget leading, control;
  final String title;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(minHeight: MarkerStyle.settingsRowHeight),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          leading,
          const SizedBox(width: 8),
          Expanded(child: Text(title, style: MarkerStyle.body)),
          const SizedBox(width: 12),
          control,
        ],
      ),
    ),
  );
}
