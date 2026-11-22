import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marker/src/theme/marker_app_theme.dart';
import 'package:marker/src/widgets/markdown_commands.dart';
import 'package:marker/src/widgets/markdown_syntax_panel.dart';

void main() {
  for (final zh in [true, false]) {
    testWidgets(
      'syntax panel localizes groups and commands (${zh ? 'zh' : 'en'})',
      (tester) async {
        MarkdownCommand? selected;
        await tester.pumpWidget(
          MaterialApp(
            locale: Locale(zh ? 'zh' : 'en'),
            supportedLocales: const [Locale('zh'), Locale('en')],
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            theme: MarkerAppTheme().light(),
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 340,
                  height: 550,
                  child: MarkdownSyntaxPanel(
                    enabled: true,
                    onClose: () {},
                    onCommand: (value) => selected = value,
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          find.text(zh ? 'Markdown 语法' : 'Markdown syntax'),
          findsOneWidget,
        );
        expect(find.text(zh ? '列表与块' : 'Lists and blocks'), findsOneWidget);
        expect(
          find.text(zh ? '链接与扩展' : 'Links and extensions'),
          findsOneWidget,
        );
        expect(find.text(zh ? '粗体' : 'Bold'), findsOneWidget);
        expect(find.text(zh ? 'Bold' : '粗体'), findsNothing);
        await tester.tap(find.byKey(const ValueKey('md-command-粗体')));
        expect(selected!.label, '粗体');
        expect(selected!.placeholder, zh ? '粗体' : 'Bold');
        expect(tester.takeException(), isNull);
      },
    );
  }
}
