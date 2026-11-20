import 'dart:async';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final events = <DropEvent>[];
  setUp(() {
    events.clear();
    DesktopDrop.instance.init();
    DesktopDrop.instance.addRawDropEventListener(events.add);
  });
  tearDown(() => DesktopDrop.instance.removeRawDropEventListener(events.add));
  Future<void> native(String method, Object? arguments) async {
    final ready = Completer<void>();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .handlePlatformMessage(
          'desktop_drop',
          const StandardMethodCodec().encodeMethodCall(
            MethodCall(method, arguments),
          ),
          (_) => ready.complete(),
        );
    await ready.future;
  }

  test(
    'macOS delayed promise retains the actual drop point after exit',
    () async {
      await native('entered', [400.0, 200.0]);
      await native('exited', null);
      await native('performOperation_macos', [
        {
          'path': '/tmp/中文 图片.png',
          'apple-bookmark': null,
          'fromPromise': true,
          'drop-position': [420.0, 230.0],
        },
      ]);
      final drop = events.whereType<DropDoneEvent>().single;
      expect(drop.location, const Offset(420, 230));
      expect(drop.files.single.path, '/tmp/中文 图片.png');
      expect(drop.files.single.fromPromise, isTrue);
    },
  );

  test(
    'Linux URI drops retain Unicode paths and their explicit drop point',
    () async {
      await native('performOperation_linux', [
        '# URI-list comment\r\n\r\n file:///tmp/%E4%B8%AD%E6%96%87%20%E5%9B%BE%E7%89%87.png \r\n',
        [420.0, 230.0],
      ]);
      final drop = events.whereType<DropDoneEvent>().single;
      expect(drop.location, const Offset(420, 230));
      expect(drop.files.single.path, '/tmp/中文 图片.png');
    },
  );

  test(
    'Linux file URIs retain POSIX semantics even with a drive-shaped directory',
    () async {
      await native('performOperation_linux', [
        'file:///C:/Users/RUNNER~1/Temp/%E4%B8%AD%E6%96%87%20%23%25.png',
        [420.0, 230.0],
      ]);
      final drop = events.whereType<DropDoneEvent>().single;
      expect(drop.files.single.path, '/C:/Users/RUNNER~1/Temp/中文 #%.png');
      expect(drop.location, const Offset(420, 230));
    },
  );

  test(
    'Windows drop uses final point and preserves long Unicode and UNC paths',
    () async {
      final paths = [
        r'C:\图片\中文 #%.png',
        'C:\\${List.filled(300, 'a').join()}\\图片.png',
        r'\\server\share\中文.png',
      ];
      await native('entered', [10.0, 20.0]);
      await native('exited', null);
      await native('performOperation_windows', {
        'files': paths,
        'position': [840.0, 460.0],
      });
      final drop = events.whereType<DropDoneEvent>().single;
      expect(drop.location, const Offset(840, 460));
      expect(drop.files.map((file) => file.path), paths);
    },
  );
}
