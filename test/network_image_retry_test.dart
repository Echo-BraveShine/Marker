import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marker/src/widgets/resource_network_image.dart';

class _Client implements HttpClient {
  int requests = 0;
  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _Request(++requests == 1);
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _Headers implements HttpHeaders {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _Request implements HttpClientRequest {
  _Request(this.fail);
  final bool fail;
  @override
  HttpHeaders get headers => _Headers();
  @override
  Future<HttpClientResponse> close() async => _Response(fail);
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _Response extends Stream<List<int>> implements HttpClientResponse {
  _Response(this.fail);
  final bool fail;
  final bytes = File('assets/branding/marker-light.png').readAsBytesSync();
  @override
  int get statusCode => fail ? 503 : 200;
  @override
  int get contentLength => bytes.length;
  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;
  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int>)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) => Stream<List<int>>.value(bytes).listen(
    onData,
    onError: onError,
    onDone: onDone,
    cancelOnError: cancelOnError,
  );
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  testWidgets('retry issues a new request without rebuilding Markdown', (
    tester,
  ) async {
    final client = _Client();
    final failures = <Object>[];
    await HttpOverrides.runZoned(() async {
      await tester.pumpWidget(
        CupertinoApp(
          home: ResourceNetworkImage(
            imageUrl: 'https://example.com/retry.png',
            retryBuilder: (context, url, error, retry) {
              failures.add(error);
              return CupertinoButton(
                onPressed: retry,
                child: const Text('Retry'),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();
      expect(client.requests, 1);
      expect(find.text('Retry'), findsOneWidget);
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pumpAndSettle();
      expect(client.requests, 2);
      expect(find.text('Retry'), findsNothing, reason: '$failures');
      expect(find.byType(RawImage), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    }, createHttpClient: (_) => client);
  });
}
