import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marker/src/l10n/app_localizations.dart';
import 'package:marker/src/resources/resource_provider.dart';
import 'package:marker/src/resources/resource_service.dart';
import 'package:marker/src/resources/resource_sidebar.dart';
import 'package:marker/src/theme/marker_app_theme.dart';

void main() {
  testWidgets(
    'mobile resource row supports long press and visible more action',
    (tester) async {
      var opened = 0;
      const item = ResourceItem(
        'https://example.test/photo.png',
        'Photo',
        ResourceAvailability.remote,
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            resourceInventoryProvider.overrideWith(
              (ref, input) async => const ResourceInventory([item], []),
            ),
          ],
          child: MaterialApp(
            theme: MarkerAppTheme().light(),
            localizationsDelegates: const [AppLocalizations.delegate],
            home: SizedBox(
              width: 300,
              child: ResourceSidebar(
                mobile: true,
                text: '',
                path: null,
                zh: false,
                onImport: () {},
                onMenu: () {},
                onItem: (_) => opened++,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final more = find.descendant(
        of: find.byKey(
          const ValueKey('resource-https://example.test/photo.png'),
        ),
        matching: find.byIcon(CupertinoIcons.ellipsis),
      );
      expect(more, findsOneWidget);
      await tester.tap(more);
      await tester.pumpAndSettle();
      expect(opened, 1);
      await tester.longPress(
        find.byKey(const ValueKey('resource-https://example.test/photo.png')),
      );
      await tester.pumpAndSettle();
      expect(opened, 2);
      expect(tester.takeException(), isNull);
    },
  );
}
