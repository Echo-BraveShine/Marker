import 'dart:async';
import 'package:flutter/foundation.dart' show BindingBase;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Stabilize widget fixtures without installing HTTP mocks in IO unit tests.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  await testMain();
  if (BindingBase.debugBindingType() == null) return;
  final dispatcher = TestWidgetsFlutterBinding.instance.platformDispatcher;
  dispatcher.localeTestValue = const Locale('zh', 'CN');
  dispatcher.localesTestValue = const [Locale('zh', 'CN')];
}
