import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:marker/main.dart';
import 'package:marker/src/resources/resource_provider.dart';
import 'package:marker/src/resources/resource_service.dart';
import 'package:marker/src/widgets/markdown_extensions.dart';
import 'package:marker/src/widgets/resource_network_image.dart';

void main() {
  testWidgets(
    'remote images have preview, source navigation and a separate more panel',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      const url = 'https://example.com/marker.png';
      const image = ResourceItem(url, '图片示例', ResourceAvailability.remote);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mermaidPreviewEnabledProvider.overrideWithValue(false),
            resourceInventoryProvider.overrideWith(
              (ref, input) async => const ResourceInventory([image], []),
            ),
          ],
          child: const MarkerApp(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('editor')),
        '# Image\n\n![图片示例]($url)\n\nText',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(CupertinoIcons.photo_on_rectangle));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(CupertinoSlidingSegmentedControl<int>),
          matching: find.text('预览'),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('resource-$url')));
      await tester.pumpAndSettle();
      final controller = tester
          .widget<CupertinoTextField>(find.byKey(const Key('editor')))
          .controller!;
      expect(controller.selection.textInside(controller.text), '![图片示例]($url)');
      await tester.tap(
        find.descendant(
          of: find.byKey(const ValueKey('resource-$url')),
          matching: find.byType(ResourceNetworkImage),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(InteractiveViewer), findsOneWidget);
      await tester.tap(find.text('更多'));
      await tester.pumpAndSettle();
      expect(find.text('下载到文档资源'), findsOneWidget);
      await tester.tap(find.byKey(const Key('dialog-close')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('resource-more-$url')));
      await tester.pumpAndSettle();
      expect(find.text('复制引用路径'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
