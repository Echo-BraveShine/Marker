import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marker/src/widgets/marker_logo.dart';

void main() {
  testWidgets('brand artwork follows the effective light and dark themes', (
    tester,
  ) async {
    for (final brightness in Brightness.values) {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: brightness),
          home: const MarkerLogo(),
        ),
      );
      await tester.pumpAndSettle();
      final image = tester.widget<Image>(find.byType(Image));
      expect(
        (image.image as AssetImage).assetName,
        brightness == Brightness.dark
            ? 'assets/branding/marker-dark.png'
            : 'assets/branding/marker-light.png',
      );
      expect(tester.takeException(), isNull);
    }
  });
}
