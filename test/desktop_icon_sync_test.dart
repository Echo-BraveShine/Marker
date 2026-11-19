import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marker/src/widgets/desktop_icon_sync.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  tearDown(
    () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(DesktopIconController.channel, null),
  );

  test('serializes native requests and suppresses duplicate updates', () async {
    final calls = <bool>[];
    final first = Completer<void>();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(DesktopIconController.channel, (call) async {
          expect(call.method, 'setDark');
          calls.add(call.arguments as bool);
          if (calls.length == 1) await first.future;
          return null;
        });
    final controller = DesktopIconController();
    final pending = controller.setDark(false);
    controller.setDark(true);
    first.complete();
    await pending;
    expect(calls, [false, true]);
    await controller.setDark(true);
    expect(calls, [false, true]);
    await controller.setDark(false);
    expect(calls.last, false);
  });

  test('native failure does not prevent a later retry', () async {
    var calls = 0;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(DesktopIconController.channel, (call) async {
          if (++calls == 1) throw PlatformException(code: 'missing-icon');
          return null;
        });
    final controller = DesktopIconController();
    await controller.setDark(true);
    await controller.setDark(true);
    expect(calls, 2);
  });

  testWidgets('effective system appearance updates native icons', (
    tester,
  ) async {
    final calls = <bool>[];
    tester.binding.platformDispatcher.platformBrightnessTestValue =
        Brightness.light;
    addTearDown(
      tester.binding.platformDispatcher.clearPlatformBrightnessTestValue,
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          DesktopIconController.channel,
          (call) async => calls.add(call.arguments as bool),
        );
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: ThemeMode.system,
          builder: (context, child) =>
              DesktopIconSync(enabled: true, child: child!),
          home: const SizedBox(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(calls.last, false);
    tester.binding.platformDispatcher.platformBrightnessTestValue =
        Brightness.dark;
    await tester.pumpAndSettle();
    expect(calls.last, true);
    tester.binding.platformDispatcher.platformBrightnessTestValue =
        Brightness.light;
    await tester.pumpAndSettle();
    expect(calls.last, false);
  });
  testWidgets('explicit application theme overrides system icon appearance', (
    tester,
  ) async {
    final calls = <bool>[];
    tester.binding.platformDispatcher.platformBrightnessTestValue =
        Brightness.dark;
    addTearDown(
      tester.binding.platformDispatcher.clearPlatformBrightnessTestValue,
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          DesktopIconController.channel,
          (call) async => calls.add(call.arguments as bool),
        );
    final mode = ValueNotifier(ThemeMode.light);
    addTearDown(mode.dispose);
    await tester.pumpWidget(
      ProviderScope(
        child: ValueListenableBuilder<ThemeMode>(
          valueListenable: mode,
          builder: (context, value, child) => MaterialApp(
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: value,
            builder: (context, child) =>
                DesktopIconSync(enabled: true, child: child!),
            home: const SizedBox(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(calls.last, false);
    mode.value = ThemeMode.dark;
    await tester.pumpAndSettle();
    expect(calls.last, true);
    mode.value = ThemeMode.light;
    await tester.pumpAndSettle();
    expect(calls.last, false);
  });
}
