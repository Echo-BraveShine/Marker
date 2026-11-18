import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart' show Theme;

/// In-app brand mark follows the effective application appearance.
class MarkerLogo extends StatelessWidget {
  const MarkerLogo({super.key, this.size = 28});
  final double size;
  @override
  Widget build(BuildContext context) => Image.asset(
    Theme.of(context).brightness == Brightness.dark
        ? 'assets/branding/marker-dark.png'
        : 'assets/branding/marker-light.png',
    width: size,
    height: size,
    semanticLabel: 'Marker',
    filterQuality: FilterQuality.high,
  );
}
