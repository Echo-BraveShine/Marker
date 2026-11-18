import 'package:flutter/material.dart';

/// Apple 风格颜色令牌，通过 `Theme.of(context).extension<MarkerColors>()!` 读取
class MarkerColors extends ThemeExtension<MarkerColors> {
  const MarkerColors({
    required this.bgWindow,
    required this.bgSidebar,
    required this.bgToolbar,
    required this.bgEditor,
    required this.bgPreview,
    required this.bgCodeBlock,
    required this.bgHover,
    required this.bgSelected,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textAccent,
    required this.textLink,
    required this.separator,
    required this.separatorSoft,
    required this.syntaxTitle,
    required this.syntaxStrong,
    required this.syntaxLink,
    required this.syntaxCodeInline,
    required this.syntaxQuote,
    required this.syntaxList,
    required this.syntaxTable,
  });

  // 表面色
  final Color bgWindow;
  final Color bgSidebar;
  final Color bgToolbar;
  final Color bgEditor;
  final Color bgPreview;
  final Color bgCodeBlock;
  final Color bgHover;
  final Color bgSelected;

  // 文字色
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textAccent;
  final Color textLink;

  // 分隔线
  final Color separator;
  final Color separatorSoft;

  // 编辑区语法高亮
  final Color syntaxTitle;
  final Color syntaxStrong;
  final Color syntaxLink;
  final Color syntaxCodeInline;
  final Color syntaxQuote;
  final Color syntaxList;
  final Color syntaxTable;

  static const light = MarkerColors(
    bgWindow: Color(0xFFF5F5F7),
    bgSidebar: Color(0xFFF6F6F7),
    bgToolbar: Color(0xFFF6F6F7),
    bgEditor: Color(0xFFFFFFFF),
    bgPreview: Color(0xFFFFFFFF),
    bgCodeBlock: Color(0xFFF6F8FA),
    bgHover: Color(0x0D000000),
    bgSelected: Color(0xFFE0EDFF),
    textPrimary: Color(0xFF252527),
    textSecondary: Color(0xFF626267),
    textTertiary: Color(0xFFAEAEB2),
    textAccent: Color(0xFF0066CC),
    textLink: Color(0xFF0066CC),
    separator: Color(0xFFD2D2D7),
    separatorSoft: Color(0xFFDEDEE2),
    syntaxTitle: Color(0xFF252527),
    syntaxStrong: Color(0xFF252527),
    syntaxLink: Color(0xFF0066CC),
    syntaxCodeInline: Color(0xFFAD3DA4),
    syntaxQuote: Color(0xFF626267),
    syntaxList: Color(0xFF626267),
    syntaxTable: Color(0xFF626267),
  );

  static const dark = MarkerColors(
    bgWindow: Color(0xFF2B2B2D),
    bgSidebar: Color(0xFF262628),
    bgToolbar: Color(0xFF262628),
    bgEditor: Color(0xFF1E1E1E),
    bgPreview: Color(0xFF2B2B2D),
    bgCodeBlock: Color(0xFF242428),
    bgHover: Color(0x0FFFFFFF),
    bgSelected: Color(0xFF284567),
    textPrimary: Color(0xFFF5F5F7),
    textSecondary: Color(0xFFB2B2B7),
    textTertiary: Color(0xFF636366),
    textAccent: Color(0xFF79B7FF),
    textLink: Color(0xFF79B7FF),
    separator: Color(0xFF3A3A3E),
    separatorSoft: Color(0xFF3B3B3E),
    syntaxTitle: Color(0xFFF5F5F7),
    syntaxStrong: Color(0xFFF5F5F7),
    syntaxLink: Color(0xFF79B7FF),
    syntaxCodeInline: Color(0xFFFF7AB2),
    syntaxQuote: Color(0xFFB2B2B7),
    syntaxList: Color(0xFFB2B2B7),
    syntaxTable: Color(0xFFB2B2B7),
  );

  @override
  MarkerColors copyWith({
    Color? bgWindow,
    Color? bgSidebar,
    Color? bgToolbar,
    Color? bgEditor,
    Color? bgPreview,
    Color? bgCodeBlock,
    Color? bgHover,
    Color? bgSelected,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? textAccent,
    Color? textLink,
    Color? separator,
    Color? separatorSoft,
    Color? syntaxTitle,
    Color? syntaxStrong,
    Color? syntaxLink,
    Color? syntaxCodeInline,
    Color? syntaxQuote,
    Color? syntaxList,
    Color? syntaxTable,
  }) {
    return MarkerColors(
      bgWindow: bgWindow ?? this.bgWindow,
      bgSidebar: bgSidebar ?? this.bgSidebar,
      bgToolbar: bgToolbar ?? this.bgToolbar,
      bgEditor: bgEditor ?? this.bgEditor,
      bgPreview: bgPreview ?? this.bgPreview,
      bgCodeBlock: bgCodeBlock ?? this.bgCodeBlock,
      bgHover: bgHover ?? this.bgHover,
      bgSelected: bgSelected ?? this.bgSelected,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      textAccent: textAccent ?? this.textAccent,
      textLink: textLink ?? this.textLink,
      separator: separator ?? this.separator,
      separatorSoft: separatorSoft ?? this.separatorSoft,
      syntaxTitle: syntaxTitle ?? this.syntaxTitle,
      syntaxStrong: syntaxStrong ?? this.syntaxStrong,
      syntaxLink: syntaxLink ?? this.syntaxLink,
      syntaxCodeInline: syntaxCodeInline ?? this.syntaxCodeInline,
      syntaxQuote: syntaxQuote ?? this.syntaxQuote,
      syntaxList: syntaxList ?? this.syntaxList,
      syntaxTable: syntaxTable ?? this.syntaxTable,
    );
  }

  @override
  MarkerColors lerp(ThemeExtension<MarkerColors>? other, double t) {
    if (other is! MarkerColors) return this;
    return MarkerColors(
      bgWindow: Color.lerp(bgWindow, other.bgWindow, t)!,
      bgSidebar: Color.lerp(bgSidebar, other.bgSidebar, t)!,
      bgToolbar: Color.lerp(bgToolbar, other.bgToolbar, t)!,
      bgEditor: Color.lerp(bgEditor, other.bgEditor, t)!,
      bgPreview: Color.lerp(bgPreview, other.bgPreview, t)!,
      bgCodeBlock: Color.lerp(bgCodeBlock, other.bgCodeBlock, t)!,
      bgHover: Color.lerp(bgHover, other.bgHover, t)!,
      bgSelected: Color.lerp(bgSelected, other.bgSelected, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      textAccent: Color.lerp(textAccent, other.textAccent, t)!,
      textLink: Color.lerp(textLink, other.textLink, t)!,
      separator: Color.lerp(separator, other.separator, t)!,
      separatorSoft: Color.lerp(separatorSoft, other.separatorSoft, t)!,
      syntaxTitle: Color.lerp(syntaxTitle, other.syntaxTitle, t)!,
      syntaxStrong: Color.lerp(syntaxStrong, other.syntaxStrong, t)!,
      syntaxLink: Color.lerp(syntaxLink, other.syntaxLink, t)!,
      syntaxCodeInline: Color.lerp(
        syntaxCodeInline,
        other.syntaxCodeInline,
        t,
      )!,
      syntaxQuote: Color.lerp(syntaxQuote, other.syntaxQuote, t)!,
      syntaxList: Color.lerp(syntaxList, other.syntaxList, t)!,
      syntaxTable: Color.lerp(syntaxTable, other.syntaxTable, t)!,
    );
  }
}
