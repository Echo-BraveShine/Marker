import 'package:flutter/painting.dart';
import 'marker_colors.dart';

enum EditorHighlightStyle {
  classic,
  github,
  solarized,
  monokai,
  dracula,
  nord,
  oneDark,
  tokyoNight,
  catppuccin,
  rosePine,
  gruvbox,
  ayu;

  String label(bool zh) => switch (this) {
    classic => zh ? '经典' : 'Classic',
    github => 'GitHub',
    solarized => 'Solarized',
    monokai => 'Monokai',
    dracula => 'Dracula',
    nord => 'Nord',
    oneDark => 'One Dark',
    tokyoNight => 'Tokyo Night',
    catppuccin => 'Catppuccin',
    rosePine => 'Rosé Pine',
    gruvbox => 'Gruvbox',
    ayu => 'Ayu',
  };
}

enum HighlightRole {
  plain,
  marker,
  title,
  emphasis,
  link,
  code,
  quote,
  list,
  table,
  math,
  keyword,
  string,
  number,
  comment,
}

class HighlightPalette {
  HighlightPalette(this.colors);
  final Map<HighlightRole, Color> colors;
  Color? operator [](HighlightRole role) => colors[role];

  factory HighlightPalette.from(
    EditorHighlightStyle style,
    MarkerColors theme,
  ) {
    final dark = theme.bgEditor.computeLuminance() < .5;
    final (accent, code, string, number, comment) = switch (style) {
      EditorHighlightStyle.classic => (
        theme.textAccent,
        theme.syntaxCodeInline,
        dark ? const Color(0xFF9CD49A) : const Color(0xFF267345),
        dark ? const Color(0xFFE7BB7C) : const Color(0xFF946000),
        theme.textSecondary,
      ),
      EditorHighlightStyle.github =>
        dark
            ? (
                const Color(0xFF79C0FF),
                const Color(0xFFFF7B72),
                const Color(0xFFA5D6FF),
                const Color(0xFFD2A8FF),
                const Color(0xFF8B949E),
              )
            : (
                const Color(0xFF0550AE),
                const Color(0xFFCF222E),
                const Color(0xFF0A3069),
                const Color(0xFF8250DF),
                const Color(0xFF57606A),
              ),
      EditorHighlightStyle.solarized =>
        dark
            ? (
                const Color(0xFF52B5D5),
                const Color(0xFFDB9B39),
                const Color(0xFFADC448),
                const Color(0xFFE58ABA),
                const Color(0xFF93A1A1),
              )
            : (
                const Color(0xFF006B8F),
                const Color(0xFF966500),
                const Color(0xFF557000),
                const Color(0xFFB02E73),
                const Color(0xFF657B83),
              ),
      EditorHighlightStyle.monokai =>
        dark
            ? (
                const Color(0xFF66D9EF),
                const Color(0xFFF78CBA),
                const Color(0xFFE6DB74),
                const Color(0xFFBD9EFF),
                const Color(0xFFA5A595),
              )
            : (
                const Color(0xFF00758A),
                const Color(0xFFB72B66),
                const Color(0xFF736600),
                const Color(0xFF7050AC),
                const Color(0xFF68685D),
              ),
      EditorHighlightStyle.dracula =>
        dark
            ? (
                const Color(0xFFBD93F9),
                const Color(0xFFFF79C6),
                const Color(0xFFF1FA8C),
                const Color(0xFF8BE9FD),
                const Color(0xFF9BA5CD),
              )
            : (
                const Color(0xFF6C3CB5),
                const Color(0xFFA82070),
                const Color(0xFF656900),
                const Color(0xFF006D86),
                const Color(0xFF656A85),
              ),
      EditorHighlightStyle.nord =>
        dark
            ? (
                const Color(0xFF88C0D0),
                const Color(0xFF81A1C1),
                const Color(0xFFA3BE8C),
                const Color(0xFFB48EAD),
                const Color(0xFF9AA9BD),
              )
            : (
                const Color(0xFF28677B),
                const Color(0xFF3D5D86),
                const Color(0xFF4C692B),
                const Color(0xFF86527B),
                const Color(0xFF657185),
              ),
      EditorHighlightStyle.oneDark =>
        dark
            ? (
                const Color(0xFF61AFEF),
                const Color(0xFFC678DD),
                const Color(0xFF98C379),
                const Color(0xFFD19A66),
                const Color(0xFF9CA3AF),
              )
            : (
                const Color(0xFF2263A4),
                const Color(0xFF8E3EB2),
                const Color(0xFF467126),
                const Color(0xFF965A25),
                const Color(0xFF69717D),
              ),
      EditorHighlightStyle.tokyoNight =>
        dark
            ? (
                const Color(0xFF7AA2F7),
                const Color(0xFFBB9AF7),
                const Color(0xFF9ECE6A),
                const Color(0xFFFF9E64),
                const Color(0xFF9AA5CE),
              )
            : (
                const Color(0xFF3259B0),
                const Color(0xFF7846B4),
                const Color(0xFF4D7424),
                const Color(0xFFA95522),
                const Color(0xFF687393),
              ),
      EditorHighlightStyle.catppuccin =>
        dark
            ? (
                const Color(0xFF89B4FA),
                const Color(0xFFCBA6F7),
                const Color(0xFFA6E3A1),
                const Color(0xFFFAB387),
                const Color(0xFFA6ADC8),
              )
            : (
                const Color(0xFF1E66D4),
                const Color(0xFF8839EF),
                const Color(0xFF397A21),
                const Color(0xFFA45922),
                const Color(0xFF6C6F85),
              ),
      EditorHighlightStyle.rosePine =>
        dark
            ? (
                const Color(0xFF9CCFD8),
                const Color(0xFFC4A7E7),
                const Color(0xFFF6C177),
                const Color(0xFFEBBCBA),
                const Color(0xFF9893A5),
              )
            : (
                const Color(0xFF286983),
                const Color(0xFF87609E),
                const Color(0xFF916522),
                const Color(0xFFA84758),
                const Color(0xFF797480),
              ),
      EditorHighlightStyle.gruvbox =>
        dark
            ? (
                const Color(0xFF83A598),
                const Color(0xFFFB4934),
                const Color(0xFFB8BB26),
                const Color(0xFFD3869B),
                const Color(0xFFA89984),
              )
            : (
                const Color(0xFF306A78),
                const Color(0xFFA82A1B),
                const Color(0xFF667000),
                const Color(0xFF94406D),
                const Color(0xFF706454),
              ),
      EditorHighlightStyle.ayu =>
        dark
            ? (
                const Color(0xFF73D0FF),
                const Color(0xFFFFB454),
                const Color(0xFFB8E673),
                const Color(0xFFD2A6FF),
                const Color(0xFF9AA6B7),
              )
            : (
                const Color(0xFF006D99),
                const Color(0xFF9D5900),
                const Color(0xFF507000),
                const Color(0xFF8052AD),
                const Color(0xFF687586),
              ),
    };
    return HighlightPalette({
      HighlightRole.marker: theme.textSecondary,
      HighlightRole.title: accent,
      HighlightRole.emphasis: accent,
      HighlightRole.link: accent,
      HighlightRole.code: code,
      HighlightRole.quote: comment,
      HighlightRole.list: accent,
      HighlightRole.table: theme.textSecondary,
      HighlightRole.math: code,
      HighlightRole.keyword: code,
      HighlightRole.string: string,
      HighlightRole.number: number,
      HighlightRole.comment: comment,
    });
  }
}
