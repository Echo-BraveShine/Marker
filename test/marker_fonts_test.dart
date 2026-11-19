import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:marker/main.dart';
import 'package:marker/src/widgets/markdown_extensions.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:marker/src/widgets/marker_dialog.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marker/src/theme/marker_app_theme.dart';
import 'package:marker/src/theme/marker_fonts.dart';

void main() {
  testWidgets(
    'Linux typography retains bundled CJK across UI and Cupertino controls',
    (tester) async {
      for (final theme in [MarkerAppTheme().light(), MarkerAppTheme().dark()]) {
        for (final style in [
          theme.textTheme.bodyMedium,
          theme.textTheme.titleLarge,
          theme.textTheme.labelSmall,
        ]) {
          expect(style!.fontFamily, MarkerFonts.cjkFamily);
          expect(style.fontFamilyFallback, contains(MarkerFonts.cjkFamily));
        }
      }
      final cupertino = MarkerFonts.cupertino;
      for (final style in [
        cupertino.textStyle,
        cupertino.actionTextStyle,
        cupertino.navTitleTextStyle,
        cupertino.navLargeTitleTextStyle,
        cupertino.tabLabelTextStyle,
        cupertino.pickerTextStyle,
      ]) {
        expect(style.fontFamily, MarkerFonts.cjkFamily);
        expect(style.fontFamilyFallback, contains(MarkerFonts.cjkFamily));
      }
    },
    variant: TargetPlatformVariant({TargetPlatform.linux}),
  );
  test(
    'font manifest and license contain the project-owned CJK family',
    () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final manifest =
          jsonDecode(await rootBundle.loadString('FontManifest.json')) as List;
      expect(
        manifest.where((entry) => entry['family'] == MarkerFonts.cjkFamily),
        hasLength(1),
      );
      expect(
        (await rootBundle.load('assets/fonts/NotoSansSC.ttf')).lengthInBytes,
        greaterThan(1000000),
      );
      expect(
        await rootBundle.loadString('assets/fonts/OFL-NotoSansSC.txt'),
        contains('SIL OPEN FONT LICENSE'),
      );
    },
  );
  testWidgets(
    'Linux shared dialog title, content and actions use bundled Chinese',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: MarkerAppTheme().light(),
          home: MarkerDialog(
            title: const Text('保存更改'),
            content: const Text('中文文档'),
            actions: [
              MarkerDialogButton(onPressed: () {}, child: const Text('保存文档')),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      for (final label in ['保存更改', '中文文档', '保存文档']) {
        final paragraphs = tester
            .widgetList<RichText>(find.byType(RichText))
            .where((widget) => widget.text.toPlainText() == label);
        expect(paragraphs, isNotEmpty);
        for (final paragraph in paragraphs) {
          expect(
            paragraph.text.style?.fontFamily,
            MarkerFonts.cjkFamily,
            reason: label,
          );
          expect(
            paragraph.text.style?.fontFamilyFallback,
            contains(MarkerFonts.cjkFamily),
          );
        }
      }
    },
    variant: TargetPlatformVariant({TargetPlatform.linux}),
  );
  testWidgets(
    'Linux settings labels use the bundled family in rendered paragraphs',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [mermaidPreviewEnabledProvider.overrideWithValue(false)],
          child: const MarkerApp(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(CupertinoIcons.gear));
      await tester.pumpAndSettle();
      await tester.tap(find.text('关于').last);
      await tester.pumpAndSettle();
      for (final label in ['设置', '关于', '检查更新', '发布页面']) {
        final paragraphs = tester
            .widgetList<RichText>(find.byType(RichText))
            .where((widget) => widget.text.toPlainText() == label);
        expect(paragraphs, isNotEmpty, reason: label);
        for (final paragraph in paragraphs) {
          expect(
            paragraph.text.style?.fontFamily,
            MarkerFonts.cjkFamily,
            reason: label,
          );
        }
      }
      expect(tester.takeException(), isNull);
    },
    variant: TargetPlatformVariant({TargetPlatform.linux}),
  );
}
