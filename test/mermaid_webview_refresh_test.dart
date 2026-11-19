import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:marker/src/widgets/mermaid_diagram.dart';

void main() {
  testWidgets(
    'native preview reloads the completed page on source and theme changes',
    (tester) async {
      final previous = InAppWebViewPlatform.instance;
      InAppWebViewPlatform.instance = _WebViewPlatform();
      addTearDown(() {
        if (previous != null) InAppWebViewPlatform.instance = previous;
      });
      await tester.pumpWidget(
        const CupertinoApp(
          home: MermaidDiagram(source: 'flowchart LR\nA --> B', dark: false),
        ),
      );
      await tester.runAsync(
        () => rootBundle.loadString('assets/mermaid.min.js', cache: false),
      );
      await tester.pumpAndSettle();
      expect(find.text('original light'), findsOneWidget);
      await tester.pumpWidget(
        const CupertinoApp(
          home: MermaidDiagram(source: 'flowchart LR\nA --> C', dark: false),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('changed light'), findsOneWidget);
      await tester.pumpWidget(
        const CupertinoApp(
          home: MermaidDiagram(source: 'flowchart LR\nA --> C', dark: true),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('changed dark'), findsOneWidget);
    },
    variant: TargetPlatformVariant({TargetPlatform.macOS}),
  );
}

class _WebViewPlatform extends InAppWebViewPlatform {
  @override
  PlatformInAppWebViewWidget createPlatformInAppWebViewWidget(
    PlatformInAppWebViewWidgetCreationParams params,
  ) => _WebViewWidget(params);
}

class _WebViewWidget extends PlatformInAppWebViewWidget {
  _WebViewWidget(super.params) : super.implementation();
  @override
  Widget build(BuildContext context) =>
      _FrozenWebView(html: params.initialData!.data);
  @override
  T controllerFromPlatform<T>(PlatformInAppWebViewController controller) =>
      throw UnimplementedError();
  @override
  void dispose() {}
}

// Native views consume initialData once; later widget updates do not navigate.
class _FrozenWebView extends StatefulWidget {
  const _FrozenWebView({required this.html});
  final String html;
  @override
  State<_FrozenWebView> createState() => _FrozenWebViewState();
}

class _FrozenWebViewState extends State<_FrozenWebView> {
  late final html = widget.html;
  @override
  Widget build(BuildContext context) => Text(
    '${html.contains('A --> B') ? 'original' : 'changed'} ${html.contains("theme:'dark'") ? 'dark' : 'light'}',
  );
}
