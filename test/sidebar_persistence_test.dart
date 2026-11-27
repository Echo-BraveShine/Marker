import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marker/src/providers/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test(
    'sidebar visibility survives restart independently of desktop width',
    () async {
      SharedPreferences.setMockInitialValues({'sidebarWidth': 280.0});
      final first = ProviderContainer();
      await first.read(themeProvider.notifier).init();
      expect(first.read(themeProvider).sidebarExpanded, isTrue);
      await first.read(themeProvider.notifier).setSidebarExpanded(false);
      first.dispose();
      final second = ProviderContainer();
      await second.read(themeProvider.notifier).init();
      expect(second.read(themeProvider).sidebarExpanded, isFalse);
      expect(second.read(themeProvider).sidebarWidth, 280);
      await second.read(themeProvider.notifier).setSidebarExpanded(true);
      second.dispose();
      final third = ProviderContainer();
      addTearDown(third.dispose);
      await third.read(themeProvider.notifier).init();
      expect(third.read(themeProvider).sidebarExpanded, isTrue);
    },
  );
}
