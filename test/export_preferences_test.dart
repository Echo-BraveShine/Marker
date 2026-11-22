import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marker/src/export/document_exporter.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test(
    'stored appearance loads without resetting a pending format/width edit',
    () async {
      SharedPreferences.setMockInitialValues({'exportFollowTheme': true});
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final subscription = container.listen(
        documentExportOptionsProvider,
        (_, _) {},
      );
      addTearDown(subscription.close);
      await container
          .read(documentExportOptionsProvider.notifier)
          .update(
            (value) =>
                value.copyWith(format: DocumentExportFormat.png, width: 1600),
          );
      await container.read(exportAppearanceProvider.notifier).ready;
      expect(
        container.read(documentExportOptionsProvider),
        const DocumentExportOptions(
          format: DocumentExportFormat.png,
          width: 1600,
          followTheme: true,
        ),
      );
    },
  );

  test(
    'appearance survives form disposal and a fresh application container',
    () async {
      final container = ProviderContainer();
      final subscription = container.listen(
        documentExportOptionsProvider,
        (_, _) {},
      );
      await container.read(exportAppearanceProvider.notifier).ready;
      await container
          .read(documentExportOptionsProvider.notifier)
          .update(
            (value) => value.copyWith(
              format: DocumentExportFormat.png,
              width: 1600,
              followTheme: true,
            ),
          );
      subscription.close();
      await container.pump();
      final reopened = container.listen(
        documentExportOptionsProvider,
        (_, _) {},
      );
      expect(
        container.read(documentExportOptionsProvider),
        const DocumentExportOptions(followTheme: true),
      );
      reopened.close();
      container.dispose();
      final restart = ProviderContainer();
      addTearDown(restart.dispose);
      await restart.read(exportAppearanceProvider.notifier).ready;
      expect(restart.read(exportAppearanceProvider), isTrue);
      expect(
        (await SharedPreferences.getInstance()).getBool('exportFollowTheme'),
        isTrue,
      );
    },
  );

  test(
    'early explicit toggle wins over delayed preference initialization',
    () async {
      SharedPreferences.setMockInitialValues({'exportFollowTheme': true});
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(exportAppearanceProvider.notifier);
      final write = notifier.setFollowTheme(false);
      await notifier.ready;
      await write;
      expect(container.read(exportAppearanceProvider), isFalse);
      expect(
        (await SharedPreferences.getInstance()).getBool('exportFollowTheme'),
        isFalse,
      );
    },
  );

  test('rapid appearance changes persist in user order', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(exportAppearanceProvider.notifier);
    await notifier.ready;
    final writes = [
      notifier.setFollowTheme(true),
      notifier.setFollowTheme(false),
      notifier.setFollowTheme(true),
    ];
    await Future.wait(writes);
    await notifier.saved;
    expect(container.read(exportAppearanceProvider), isTrue);
    expect(
      (await SharedPreferences.getInstance()).getBool('exportFollowTheme'),
      isTrue,
    );
  });
}
