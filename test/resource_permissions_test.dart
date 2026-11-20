import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marker/src/resources/resource_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  tearDown(
    () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(ResourcePlatform.channel, null),
  );

  test('folder access explains its purpose in the app language', () async {
    final calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(ResourcePlatform.channel, (call) async {
          calls.add(call);
          return (call.arguments as Map)['path'];
        });
    final platform = ResourcePlatform();
    expect(await platform.authorizeDirectory('/doc', chinese: true), '/doc');
    expect((calls.last.arguments as Map)['prompt'], '允许访问此目录');
    expect((calls.last.arguments as Map)['message'], contains('/doc'));
    expect(await platform.authorizeDirectory('/doc'), '/doc');
    expect((calls.last.arguments as Map)['prompt'], 'Allow folder access');
  });

  test('cancelling access does not retry the legacy panel', () async {
    final calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(ResourcePlatform.channel, (call) async {
          calls.add(call);
          return null;
        });
    expect(await ResourcePlatform().authorizeDirectory('/doc'), isNull);
    expect(calls, hasLength(1));
  });

  for (final failure in [
    MissingPluginException(),
    PlatformException(code: 'invalid-path'),
  ]) {
    test(
      'running older native host still requests folder access: $failure',
      () async {
        final methods = <String>[];
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(ResourcePlatform.channel, (call) async {
              methods.add(call.method);
              if (call.method == 'authorizeDirectoryWithContext') throw failure;
              return '/doc';
            });
        expect(await ResourcePlatform().authorizeDirectory('/doc'), '/doc');
        expect(methods, [
          'authorizeDirectoryWithContext',
          'authorizeDirectory',
        ]);
      },
    );
  }
}
