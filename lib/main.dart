import 'package:desktop_drop/desktop_drop.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:path/path.dart' as p;
import 'src/resources/resource_service.dart';
import 'src/resources/resource_references.dart';
import 'src/resources/resource_provider.dart';
import 'src/resources/resource_sidebar.dart';
import 'src/widgets/shortcut_settings.dart';
import 'src/export/document_exporter.dart';
import 'src/export/export_destination.dart';
import 'src/export/export_options_panel.dart';
import 'package:flutter/rendering.dart' show RenderEditable;
import 'src/widgets/about_settings.dart';
import 'src/widgets/desktop_icon_sync.dart';
import 'src/widgets/marker_logo.dart';
import 'src/widgets/highlight_style_picker.dart';
import 'src/theme/highlight_style.dart';
import 'src/widgets/markdown_highlighter.dart';
import 'src/theme/marker_style.dart';
import 'src/theme/marker_fonts.dart';
import 'package:flutter/cupertino.dart';
import 'src/widgets/desktop_startup.dart';
import 'src/providers/external_files.dart';
import 'src/widgets/marker_floating_surface.dart';
import 'src/widgets/editor_search.dart';
import 'src/widgets/app_shortcuts.dart';
import 'src/widgets/markdown_syntax_panel.dart';
import 'src/widgets/markdown_templates.dart';
import 'src/widgets/marker_dialog.dart';
import 'src/widgets/text_color_picker.dart';
import 'src/providers/workspace_provider.dart';
import 'src/widgets/linked_scroll.dart';
import 'src/widgets/markdown_commands.dart';
import 'src/widgets/markdown_editing_controller.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'src/widgets/markdown_extensions.dart';
import 'package:markdown/markdown.dart' as md;
import 'src/widgets/line_number_gutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:window_manager/window_manager.dart';
import 'src/providers/draft_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'src/theme/marker_app_theme.dart';
import 'src/theme/marker_colors.dart';
import 'src/providers/theme_provider.dart';
import 'src/providers/editor_provider.dart';
import 'src/l10n/app_localizations.dart';
import 'src/widgets/marker_markdown_style.dart';

part 'src/resources/resource_actions.dart';
part 'src/resources/resource_management_actions.dart';
part 'src/resources/resource_import_actions.dart';
part 'src/home/home_toolbar.dart';
part 'src/home/home_sidebar.dart';
part 'src/home/home_preview.dart';
part 'src/home/home_state.dart';
part 'src/home/home_document_actions.dart';
part 'src/home/home_file_actions.dart';
part 'src/home/home_editor_actions.dart';
part 'src/home/home_settings.dart';
part 'src/home/home_view.dart';

bool desktopWindow = false;

Future<void> main(List<String> arguments) async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  final container = ProviderContainer(
    overrides: [
      initialFilesProvider.overrideWithValue(markdownOpenPaths(arguments)),
    ],
  );
  try {
    await container.read(themeProvider.notifier).init();
  } catch (error) {
    debugPrint('Theme initialization failed: $error');
  }
  desktopWindow =
      !kIsWeb &&
      [
        TargetPlatform.macOS,
        TargetPlatform.windows,
        TargetPlatform.linux,
      ].contains(defaultTargetPlatform);
  if (desktopWindow) {
    await windowManager.ensureInitialized();
    final mode = container.read(themeProvider).mode;
    final dark =
        mode == ThemeMode.dark ||
        (mode == ThemeMode.system &&
            binding.platformDispatcher.platformBrightness == Brightness.dark);
    await windowManager.waitUntilReadyToShow(
      WindowOptions(
        title: 'Marker',
        size: const Size(1200, 800),
        minimumSize: const Size(900, 600),
        center: true,
        backgroundColor: dark
            ? MarkerColors.dark.bgWindow
            : MarkerColors.light.bgWindow,
        titleBarStyle: defaultTargetPlatform == TargetPlatform.macOS
            ? TitleBarStyle.hidden
            : TitleBarStyle.normal,
      ),
    );
    await windowManager.setPreventClose(true);
    await container.read(desktopIconProvider).setDark(dark);
  }
  runApp(
    UncontrolledProviderScope(container: container, child: const MarkerApp()),
  );
  if (desktopWindow) {
    await revealDesktopWindow(
      firstFrame: binding.endOfFrame,
      show: windowManager.show,
      focus: windowManager.focus,
    );
  }
}

class MarkerApp extends ConsumerWidget {
  const MarkerApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Marker',
      debugShowCheckedModeBanner: false,
      theme: MarkerAppTheme().light(),
      darkTheme: MarkerAppTheme().dark(),
      themeMode: vm.mode,
      locale: vm.locale,
      supportedLocales: const [Locale('zh', 'CN'), Locale('en', 'US')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) => CupertinoTheme(
        // 确保 Cupertino 组件在所有平台上使用正确的字体，尤其是中文
        data: CupertinoThemeData(
          brightness: Theme.of(context).brightness,
          textTheme: MarkerFonts.cupertino,
        ),
        child: DesktopIconSync(
          enabled: desktopWindow,
          child: child ?? const SizedBox.shrink(),
        ),
      ),

      home: const MarkerHome(),
    );
  }
}
