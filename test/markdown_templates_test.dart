import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:marker/src/widgets/markdown_templates.dart';

void main() {
  test('templates insert correct fences and retain selected source', () async {
    for (final template in [...mathTemplates, ...mermaidTemplates]) {
      final result = template.command.apply(
        const TextEditingValue(
          text: '',
          selection: TextSelection.collapsed(offset: 0),
        ),
      );
      expect(result.text, contains(template.source));
      expect(
        result.text.startsWith(
          template.id.startsWith('mermaid') ? '```mermaid\n' : r'$',
        ),
        isTrue,
      );
    }
    const export = String.fromEnvironment('TEMPLATE_EXPORT');
    if (export.isNotEmpty) {
      await File(export).writeAsString(
        jsonEncode([
          for (final t in mermaidTemplates) {'id': t.id, 'source': t.source},
        ]),
      );
    }
  });
  testWidgets('all math samples render without parser errors', (tester) async {
    final errors = <String>[];
    await tester.pumpWidget(
      MaterialApp(
        home: SingleChildScrollView(
          child: Column(
            children: [
              for (final template in mathTemplates)
                Math.tex(
                  template.source,
                  mathStyle: MathStyle.display,
                  onErrorFallback: (error) {
                    errors.add('${template.id}: $error');
                    return const Text('Invalid');
                  },
                ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(errors, isEmpty);
    expect(tester.takeException(), isNull);
  });
}
