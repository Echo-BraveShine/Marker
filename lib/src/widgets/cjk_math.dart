import 'package:flutter/widgets.dart';
import 'package:flutter_math_fork/ast.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_math_fork/tex.dart';
// The public AST extension API uses BuildResult but omits its export.
// Keep this dependency isolated; nested-formula regression tests cover upgrades.
// ignore: implementation_imports
import 'package:flutter_math_fork/src/ast/syntax_tree.dart' show BuildResult;
import '../theme/marker_fonts.dart';

final _cjk = RegExp(
  r'[\u2e80-\u9fff\uf900-\ufaff\ufe30-\ufe4f\uff00-\uffef]|[\u{20000}-\u{2fa1f}]',
  unicode: true,
);

/// KaTeX symbol widgets bypass inherited TextStyle and have no CJK fallback.
/// Replace only CJK leaves; retain the original math fonts, metrics and layout.
Math markerMath(
  String source, {
  required MathStyle mathStyle,
  TextStyle? textStyle,
  OnErrorFallback onErrorFallback = Math.defaultOnErrorFallback,
}) {
  if (!_cjk.hasMatch(source)) {
    return Math.tex(
      source,
      mathStyle: mathStyle,
      textStyle: textStyle,
      onErrorFallback: onErrorFallback,
    );
  }
  try {
    final root = _withCjk(TexParser(source, const TexParserSettings()).parse());
    return Math(
      ast: SyntaxTree(greenRoot: root as EquationRowNode),
      mathStyle: mathStyle,
      textStyle: textStyle,
      onErrorFallback: onErrorFallback,
    );
  } catch (_) {
    // Preserve the package's normal parse-error handling.
    return Math.tex(
      source,
      mathStyle: mathStyle,
      textStyle: textStyle,
      onErrorFallback: onErrorFallback,
    );
  }
}

GreenNode _withCjk(GreenNode node) {
  if (node is SymbolNode && _cjk.hasMatch(node.symbol)) return _CjkSymbol(node);
  if (node.children.isEmpty) return node;
  if (node is MatrixNode) {
    // Rebuild by cell: the package's flat updateChildren path loses row bounds.
    return node.copyWith(
      body: [
        for (final row in node.body)
          [
            for (final cell in row)
              cell == null ? null : _withCjk(cell) as EquationRowNode,
          ],
      ],
    );
  }
  final children = [
    for (final child in node.children) child == null ? null : _withCjk(child),
  ];
  // Slot nodes accept equation rows; transparent/row nodes accept general leaves.
  if (children.every((child) => child == null || child is EquationRowNode)) {
    return node.updateChildren(
      children.any((child) => child == null)
          ? children.cast<EquationRowNode?>()
          : children.cast<EquationRowNode>(),
    );
  }
  return node.updateChildren(children.cast<GreenNode>());
}

class _CjkSymbol extends SymbolNode {
  _CjkSymbol(SymbolNode original)
    : super(
        symbol: original.symbol,
        variantForm: original.variantForm,
        overrideAtomType: original.overrideAtomType,
        overrideFont: original.overrideFont,
        mode: original.mode,
      );

  @override
  BuildResult buildWidget(
    MathOptions options,
    List<BuildResult?> childBuildResults,
  ) => BuildResult(
    options: options,
    widget: RichText(
      text: TextSpan(
        text: symbol,
        style: TextStyle(
          fontFamily: MarkerFonts.cjkFamily,
          fontFamilyFallback: MarkerFonts.fallback,
          fontSize: options.fontSize * options.sizeMultiplier,
          color: options.color,
          fontWeight: options.textFontOptions?.fontWeight ?? FontWeight.normal,
        ),
      ),
      softWrap: false,
    ),
  );
}
