import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Theme;
import '../theme/marker_colors.dart';
import '../theme/marker_style.dart';

/// The heading and frame stay fixed while each settings page scrolls inside.
class SettingsScrollFrame extends StatelessWidget {
  const SettingsScrollFrame({
    super.key,
    required this.title,
    required this.page,
    required this.child,
  });
  final String title;
  final int page;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<MarkerColors>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: MarkerStyle.heading),
        const SizedBox(height: 12),
        Expanded(
          child: Container(
            key: ValueKey('settings-frame-$page'),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: colors.bgEditor,
              border: Border.all(color: colors.separatorSoft),
              borderRadius: BorderRadius.circular(MarkerStyle.groupRadius),
            ),
            child: SingleChildScrollView(
              key: PageStorageKey('settings-content-$page'),
              padding: const EdgeInsets.all(12),
              child: child,
            ),
          ),
        ),
      ],
    );
  }
}
