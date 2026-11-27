part of '../../main.dart';

extension _HomeSettings on _MarkerHomeState {
  Future<void> _settings() async {
    await showMarkerDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final editor = ref.watch(editorProvider);
          final page = _isMobile && editor.settingsPage == 2
              ? 0
              : editor.settingsPage;
          final settings = ref.watch(themeProvider);
          final c = Theme.of(context).extension<MarkerColors>()!;
          final labels = [
            _l10n.general,
            _l10n.editorAndPreview,
            _l10n.keyboardShortcuts,
            _l10n.about,
          ];
          Widget row(IconData icon, String title, Widget control) =>
              SettingsOptionRow(
                leading: Icon(icon, size: 16, color: c.textSecondary),
                title: title,
                control: control,
              );
          Widget group(String title, List<Widget> rows) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 12, bottom: 8),
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: c.textSecondary,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: c.bgEditor,
                    borderRadius: BorderRadius.circular(
                      MarkerStyle.groupRadius,
                    ),
                    border: Border.all(color: c.separatorSoft),
                  ),
                  child: Column(
                    children: [
                      for (var i = 0; i < rows.length; i++) ...[
                        if (i > 0)
                          Padding(
                            padding: const EdgeInsets.only(left: 36),
                            child: Container(height: 1, color: c.separatorSoft),
                          ),
                        rows[i],
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
          return MarkerDialog(
            title: Row(
              children: [
                const MarkerLogo(),
                const SizedBox(width: 8),
                Text(_l10n.message(AppMessage.settings)),
              ],
            ),
            width: 860,
            height: 620,
            scrollable: false,
            contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            content: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 136,
                  padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < labels.length; i++)
                        if (!_isMobile || i != 2)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Container(
                              decoration: BoxDecoration(
                                color: page == i ? c.bgSelected : null,
                                borderRadius: BorderRadius.circular(
                                  MarkerStyle.controlRadius,
                                ),
                              ),
                              child: CupertinoButton(
                                alignment: Alignment.centerLeft,
                                minimumSize: Size.zero,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 10,
                                ),
                                onPressed: () => ref
                                    .read(editorProvider.notifier)
                                    .update((s) => s.copyWith(settingsPage: i)),
                                child: Row(
                                  children: [
                                    Icon(
                                      i == 0
                                          ? CupertinoIcons.slider_horizontal_3
                                          : i == 1
                                          ? CupertinoIcons.textformat
                                          : i == 2
                                          ? CupertinoIcons.keyboard
                                          : CupertinoIcons.info_circle,
                                      size: 16,
                                      color: page == i
                                          ? c.textAccent
                                          : c.textSecondary,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        labels[i],
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: page == i
                                              ? FontWeight.w600
                                              : FontWeight.w400,
                                          color: c.textPrimary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(width: 1, color: c.separatorSoft),
                const SizedBox(width: 16),
                Expanded(
                  child: page == 2
                      ? ShortcutSettings(zh: _zh)
                      : SettingsScrollFrame(
                          title: labels[page],
                          page: page,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (page == 0) ...[
                                group(_l10n.message(AppMessage.appearance), [
                                  row(
                                    CupertinoIcons.circle_lefthalf_fill,
                                    _l10n.theme,
                                    SizedBox(
                                      width: 224,
                                      child:
                                          CupertinoSlidingSegmentedControl<
                                            ThemeMode
                                          >(
                                            key: const Key('settings-theme'),
                                            groupValue: settings.mode,
                                            children: {
                                              ThemeMode.system: Text(
                                                _l10n.auto,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                ),
                                              ),
                                              ThemeMode.light: Text(
                                                _l10n.lightTheme,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                ),
                                              ),
                                              ThemeMode.dark: Text(
                                                _l10n.darkTheme,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                ),
                                              ),
                                            },
                                            onValueChanged: (v) {
                                              if (v != null) {
                                                ref
                                                    .read(
                                                      themeProvider.notifier,
                                                    )
                                                    .setThemeMode(v);
                                              }
                                            },
                                          ),
                                    ),
                                  ),
                                ]),
                                group(_l10n.message(AppMessage.language), [
                                  row(
                                    CupertinoIcons.globe,
                                    _l10n.interfaceLanguage,
                                    SizedBox(
                                      width: 224,
                                      child: CupertinoButton(
                                        key: const Key('settings-language'),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8,
                                        ),
                                        minimumSize: const Size(0, 34),
                                        onPressed: () async {
                                          final selected =
                                              await showMarkerDialog<String>(
                                                context: context,
                                                builder: (_) => LanguageSettingsPanel(
                                                  selected:
                                                      settings
                                                          .followSystemLanguage
                                                      ? 'system'
                                                      : AppLocalizations.languageTagForLocale(
                                                          settings.locale,
                                                        ),
                                                ),
                                              );
                                          if (selected == null || !mounted) {
                                            return;
                                          }
                                          await ref
                                              .read(themeProvider.notifier)
                                              .setLocale(
                                                selected == 'system'
                                                    ? null
                                                    : AppLocalizations.localeForLanguage(
                                                        selected,
                                                      ),
                                              );
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Flexible(
                                              child: Text(
                                                settings.followSystemLanguage
                                                    ? _l10n.message(
                                                        AppMessage
                                                            .followSystemLanguage,
                                                      )
                                                    : _l10n.languageName(
                                                        AppLocalizations.languageTagForLocale(
                                                          settings.locale,
                                                        ),
                                                      ),
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Icon(
                                              CupertinoIcons.chevron_down,
                                              size: 12,
                                              color: c.textSecondary,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ]),
                              ] else if (page == 1) ...[
                                group(
                                  _l10n.message(AppMessage.syntaxHighlighting),
                                  [
                                    row(
                                      CupertinoIcons.textformat,
                                      _l10n.fontSize,
                                      CupertinoSwitch(
                                        key: const Key(
                                          'settings-highlight-enabled',
                                        ),
                                        value: settings.highlightEnabled,
                                        onChanged: (value) => ref
                                            .read(themeProvider.notifier)
                                            .setHighlightEnabled(value),
                                      ),
                                    ),
                                    if (settings.highlightEnabled)
                                      Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: HighlightStylePicker(
                                          key: const Key(
                                            'settings-highlight-style',
                                          ),
                                          selected: settings.highlightStyle,
                                          colors: c,
                                          zh: _zh,
                                          onChanged: (value) => ref
                                              .read(themeProvider.notifier)
                                              .setHighlightStyle(value),
                                        ),
                                      ),
                                  ],
                                ),
                                group(_l10n.message(AppMessage.editor), [
                                  row(
                                    CupertinoIcons.textformat_size,
                                    _l10n.fontSize,
                                    Text(
                                      '${editor.fontSize.round()} pt',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: c.textSecondary,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      48,
                                      0,
                                      12,
                                      8,
                                    ),
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: CupertinoSlider(
                                        min: 10,
                                        max: 24,
                                        divisions: 14,
                                        value: editor.fontSize,
                                        onChanged: (v) => _fontSize = v,
                                      ),
                                    ),
                                  ),
                                ]),
                                group(_l10n.preview, [
                                  row(
                                    CupertinoIcons.doc_text,
                                    _l10n.serifFont,
                                    CupertinoSwitch(
                                      value: editor.serif,
                                      onChanged: (v) => _serif = v,
                                    ),
                                  ),
                                ]),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: c.bgEditor,
                                    borderRadius: BorderRadius.circular(
                                      MarkerStyle.groupRadius,
                                    ),
                                  ),
                                  child: Text.rich(
                                    TextSpan(
                                      children: settings.highlightEnabled
                                          ? MarkdownHighlighter(
                                              HighlightPalette.from(
                                                settings.highlightStyle,
                                                c,
                                              ),
                                            ).highlight(
                                              '# Marker\n**Bold** and `code` [link](https://example.com)\n\n```json\n{"name": "Marker", "count": 3}\n```',
                                            )
                                          : [
                                              const TextSpan(
                                                text:
                                                    '# Marker\n**Bold** and `code` [link](https://example.com)\n\n```json\n{"name": "Marker", "count": 3}\n```',
                                              ),
                                            ],
                                    ),
                                    style: TextStyle(
                                      fontFamily: MarkerFonts.monospace,
                                      fontFamilyFallback:
                                          MarkerFonts.codeFallback,
                                      fontSize: editor.fontSize,
                                      height: 1.6,
                                      color: c.textSecondary,
                                    ),
                                  ),
                                ),
                              ] else if (page == 3) ...[
                                AboutSettings(
                                  zh: _zh,
                                  onOpenExample: () {
                                    Navigator.of(context).pop();
                                    _action(() async {
                                      final store = ref.read(
                                        sampleDocumentStoreProvider,
                                      );
                                      if (store == null) return;
                                      final path = await store.open(
                                        defaultMarkdown,
                                      );
                                      if (mounted) await _openPath(path);
                                    });
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
