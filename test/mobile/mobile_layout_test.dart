import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marker/main.dart';
import 'package:marker/src/widgets/markdown_extensions.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => mobileWindow = true);
  tearDown(() => mobileWindow = false);
  testWidgets(
    'landscape phones retain desktop sidebar toolbar panes and settings',
    (tester) async {
      const display = MethodChannel('marker/display');
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        display,
        (_) async => 'right',
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          display,
          null,
        ),
      );
      SharedPreferences.setMockInitialValues({});
      final android = defaultTargetPlatform == TargetPlatform.android;
      final top = android ? 24.0 : 0.0;
      final bottom = android ? 16.0 : 0.0;
      tester.view.padding = FakeViewPadding(
        top: top * tester.view.devicePixelRatio,
        bottom: bottom * tester.view.devicePixelRatio,
        left: 44 * tester.view.devicePixelRatio,
        right: 44 * tester.view.devicePixelRatio,
      );
      tester.view.viewPadding = FakeViewPadding(
        top: top * tester.view.devicePixelRatio,
        bottom: bottom * tester.view.devicePixelRatio,
        left: 44 * tester.view.devicePixelRatio,
        right: 44 * tester.view.devicePixelRatio,
      );
      addTearDown(tester.view.resetPadding);
      addTearDown(tester.view.resetViewPadding);
      await tester.binding.setSurfaceSize(const Size(844, 390));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [mermaidPreviewEnabledProvider.overrideWithValue(false)],
          child: const MarkerApp(),
        ),
      );
      await tester.pumpAndSettle();
      final originalSidebarWidth = tester
          .getSize(find.byKey(const Key('document-sidebar')))
          .width;
      expect(originalSidebarWidth, lessThan(200));
      expect(
        tester.getRect(find.byIcon(CupertinoIcons.sidebar_left)).left,
        greaterThanOrEqualTo(44),
      );
      expect(
        tester.getRect(find.byIcon(CupertinoIcons.gear)).left,
        greaterThanOrEqualTo(44),
      );
      await tester.tap(find.text('文件'));
      await tester.pumpAndSettle();
      expect(
        tester.getSize(find.byKey(const Key('document-sidebar'))).width,
        lessThan(originalSidebarWidth),
      );
      await tester.tap(find.byKey(const Key('sidebar-files-toggle')));
      await tester.pumpAndSettle();
      expect(
        tester.getSize(find.byKey(const Key('document-sidebar'))).width,
        closeTo(originalSidebarWidth, 0.01),
      );
      await tester.tap(
        find.descendant(
          of: find.byType(CupertinoSlidingSegmentedControl<int>),
          matching: find.text('编辑'),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('editor')), '# Mobile');
      await tester.tap(
        find.descendant(
          of: find.byType(CupertinoSlidingSegmentedControl<int>),
          matching: find.text('分屏'),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('editor')));
      await tester.pumpAndSettle();
      final field = tester.widget<CupertinoTextField>(
        find.byKey(const Key('editor')),
      );
      expect(field.focusNode!.hasFocus, isTrue);
      await tester.tapAt(
        tester.getRect(find.byKey(const Key('preview'))).center,
      );
      await tester.pumpAndSettle();
      expect(field.focusNode!.hasFocus, isFalse);
      expect(field.controller!.text, '# Mobile');
      for (final size in [
        const Size(568, 320),
        const Size(844, 390),
        const Size(1024, 768),
      ]) {
        await tester.binding.setSurfaceSize(size);
        await tester.pumpAndSettle();
        await tester.tap(
          find.descendant(
            of: find.byType(CupertinoSlidingSegmentedControl<int>),
            matching: find.text('分屏'),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          find.byKey(const Key('markdown-toolbar-syntax')),
          findsOneWidget,
        );
        final sidebar = tester.getRect(
          find.byKey(const Key('document-sidebar')),
        );
        final editor = tester.getRect(find.byKey(const Key('editor')));
        final preview = tester.getRect(find.byKey(const Key('preview')));
        expect(
          tester.getSize(find.byKey(const Key('document-status-bar'))).height,
          closeTo(24, 0.01),
        );
        expect(sidebar.top, closeTo(top, 0.01));
        expect(sidebar.bottom, closeTo(size.height - bottom, 0.01));
        expect(sidebar.left, greaterThan(0));
        expect(sidebar.left, lessThan(44));
        expect(sidebar.right, lessThan(editor.left));
        expect(editor.right, lessThanOrEqualTo(preview.left));
        expect((editor.top - preview.top).abs(), lessThan(2));
        expect(
          tester.getRect(find.byKey(const Key('sidebar-settings'))).center.dy,
          closeTo(
            tester
                .getRect(find.byKey(const Key('document-status-bar')))
                .center
                .dy,
            0.01,
          ),
        );
        final toolbar = tester.getRect(
          find.descendant(
            of: find.byType(CupertinoSlidingSegmentedControl<int>),
            matching: find.text('分屏'),
          ),
        );
        expect(toolbar.top, greaterThanOrEqualTo(top));
        expect(toolbar.center.dy, lessThan(editor.top));
        expect(
          tester.getRect(find.byKey(const Key('document-statistics'))).right,
          lessThanOrEqualTo(size.width - 43),
        );
        final previewButton = find.descendant(
          of: find.byType(CupertinoSlidingSegmentedControl<int>),
          matching: find.text('预览'),
        );
        expect(
          tester.getRect(previewButton).right,
          lessThanOrEqualTo(size.width - 43),
        );
        expect(find.byIcon(CupertinoIcons.ellipsis_circle), findsNothing);
        expect(tester.takeException(), isNull);
      }
      await tester.binding.setSurfaceSize(const Size(844, 390));
      await tester.pumpAndSettle();
      final settingsRow = tester.getRect(
        find.byKey(const Key('sidebar-settings')),
      );
      await tester.tapAt(Offset(settingsRow.right - 5, settingsRow.center.dy));
      await tester.pumpAndSettle();
      expect(find.text('快捷键'), findsNothing);
      for (final tab in ['编辑与预览', '关于']) {
        await tester.tap(find.text(tab).first);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
      await tester.tap(find.byKey(const Key('dialog-close')));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(CupertinoIcons.ellipsis));
      await tester.pumpAndSettle();
      expect(find.text('立即保存'), findsOneWidget);
      expect(find.text('关闭文档'), findsOneWidget);
      await tester.tap(find.byKey(const Key('dialog-close')));
      await tester.pumpAndSettle();
      final documentButton = find.byWidgetPredicate(
        (w) =>
            w is CupertinoButton &&
            w.key is ValueKey<String> &&
            (w.key as ValueKey<String>).value.startsWith('document-') &&
            !(w.key as ValueKey<String>).value.startsWith('document-more-'),
      );
      await tester.longPress(documentButton.first);
      await tester.pumpAndSettle();
      expect(find.text('关闭文档'), findsOneWidget);
      await tester.tap(find.byKey(const Key('dialog-close')));
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox.shrink());
    },
    variant: TargetPlatformVariant({
      TargetPlatform.android,
      TargetPlatform.iOS,
    }),
  );
}
