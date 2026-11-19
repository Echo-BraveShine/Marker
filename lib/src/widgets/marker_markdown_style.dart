import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:marker/src/theme/marker_colors.dart';

/// Markdown 样式构建器：Apple 风格的排版规范
class MarkerMarkdownStyle {
  const MarkerMarkdownStyle._();

  /// 根据当前主题构建 MarkdownStyleSheet
  static MarkdownStyleSheet build(BuildContext context) {
    final colors = Theme.of(context).extension<MarkerColors>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 标题颜色跟随主题
    final titleColor = colors.syntaxTitle;
    // 正文颜色
    final bodyColor = colors.textPrimary;
    // 次要文本（引用、列表符号、表格）
    final secondary = colors.textSecondary;
    // 链接颜色
    final link = colors.textLink;

    return MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
      // ── 链接 ──
      a: TextStyle(color: link, decoration: TextDecoration.none),
      // ── 行内代码 ──
      code: TextStyle(
        fontFamily: 'Menlo',
        fontFamilyFallback: const ['Consolas', 'Noto Sans SC'],
        fontSize: 13,
        color: colors.syntaxCodeInline,
        backgroundColor: colors.bgCodeBlock,
      ),
      codeblockPadding: const EdgeInsets.all(16),
      codeblockDecoration: BoxDecoration(
        color: colors.bgCodeBlock,
        borderRadius: BorderRadius.circular(10),
      ),
      // ── 标题 ──
      h1: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: titleColor,
        height: 1.3,
      ),
      h1Padding: const EdgeInsets.only(top: 24, bottom: 12),
      h2: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: titleColor,
        height: 1.3,
      ),
      h2Padding: const EdgeInsets.only(top: 20, bottom: 10),
      h3: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: titleColor,
        height: 1.35,
      ),
      h3Padding: const EdgeInsets.only(top: 16, bottom: 8),
      h4: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: titleColor,
        height: 1.4,
      ),
      h4Padding: const EdgeInsets.only(top: 14, bottom: 6),
      h5: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: titleColor,
        height: 1.4,
      ),
      h5Padding: const EdgeInsets.only(top: 12, bottom: 4),
      h6: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: colors.textSecondary,
        height: 1.4,
      ),
      h6Padding: const EdgeInsets.only(top: 12, bottom: 4),
      // ── 正文 ──
      p: TextStyle(fontSize: 15, height: 1.7, color: bodyColor),
      pPadding: const EdgeInsets.only(bottom: 12),
      blockSpacing: 12.0,
      // ── 强调 ──
      strong: TextStyle(fontWeight: FontWeight.w700, color: bodyColor),
      em: TextStyle(fontStyle: FontStyle.italic, color: bodyColor),
      del: TextStyle(decoration: TextDecoration.lineThrough, color: secondary),
      // ── 引用 ──
      blockquote: TextStyle(color: secondary, fontSize: 15, height: 1.6),
      blockquotePadding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
      blockquoteDecoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: isDark ? colors.separator : const Color(0xFFD2D2D7),
            width: 3,
          ),
        ),
      ),
      // ── 列表 ──
      listBullet: TextStyle(color: secondary, fontSize: 15),
      listIndent: 24.0,
      listBulletPadding: const EdgeInsets.only(right: 8),
      // ── 表格 ──
      tableHead: TextStyle(fontWeight: FontWeight.w600, color: bodyColor),
      tableBody: TextStyle(color: bodyColor),
      tableHeadAlign: TextAlign.left,
      tableBorder: TableBorder(
        horizontalInside: BorderSide(color: colors.separatorSoft, width: 1),
        bottom: BorderSide(color: colors.separator, width: 1),
      ),
      tableCellsPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      tableCellsDecoration: BoxDecoration(
        border: Border(top: BorderSide(color: colors.separatorSoft, width: 1)),
      ),
      // ── 分隔线 ──
      horizontalRuleDecoration: BoxDecoration(
        border: Border(top: BorderSide(color: colors.separator, width: 1)),
      ),
      // ── 图片 ──
      img: TextStyle(color: bodyColor),
      // ── 复选框 ──
      checkbox: TextStyle(color: link),
    );
  }
}
