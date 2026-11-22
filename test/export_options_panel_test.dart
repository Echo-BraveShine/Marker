import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marker/src/export/document_exporter.dart';
import 'package:marker/src/export/export_options_panel.dart';
import 'package:marker/src/theme/marker_app_theme.dart';
import 'package:marker/src/widgets/marker_dialog.dart';
import 'package:marker/src/widgets/marker_floating_surface.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  for (final dark in [false, true]) {
    testWidgets(
      'export panel shares app chrome and controls (${dark ? 'dark' : 'light'})',
      (tester) async {
        DocumentExportOptions? result;
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: dark ? MarkerAppTheme().dark() : MarkerAppTheme().light(),
              home: Builder(
                builder: (context) => CupertinoButton(
                  onPressed: () async {
                    result = await showMarkerDialog<DocumentExportOptions>(
                      context: context,
                      builder: (_) => const ExportOptionsPanel(zh: true),
                    );
                  },
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        expect(find.byType(MarkerFloatingSurface), findsOneWidget);
        expect(find.byType(MarkerDialogButton), findsOneWidget);
        expect(find.byKey(const Key('dialog-close')), findsOneWidget);
        expect(find.text('取消'), findsNothing);
        expect(find.textContaining('A4 自动分页'), findsOneWidget);
        await tester.tap(find.text('PNG'));
        await tester.pumpAndSettle();
        expect(find.text('图片宽度（px）'), findsOneWidget);
        await tester.tap(find.text('1600'));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(CupertinoSwitch));
        await tester.pumpAndSettle();
        await tester.tap(find.text('导出'));
        await tester.pumpAndSettle();
        expect(result!.format, DocumentExportFormat.png);
        expect(result!.width, 1600);
        expect(result!.followTheme, isTrue);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
