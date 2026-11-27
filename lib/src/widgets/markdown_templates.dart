import '../l10n/message_catalog.dart';
import 'markdown_commands.dart';

class MarkdownTemplate {
  const MarkdownTemplate(
    this.id,
    this.message,
    this.source, {
    this.inline = false,
  });
  final String id, source;
  final AppMessage message;
  String get label => localizedMessage('zh', message);
  String get englishLabel => localizedMessage('en', message);
  String labelFor(Object chinese) => messageForLanguage(chinese, message);
  final bool inline;
  MarkdownCommand get command => MarkdownCommand(
    label,
    id.startsWith('math-') ? (inline ? r'$' : '\$\$\n') : '```mermaid\n',
    id.startsWith('math-') ? (inline ? r'$' : '\n\$\$') : '\n```',
    source,
    block: !inline,
  );
}

const mathTemplates = [
  MarkdownTemplate(
    'math-inline',
    AppMessage.inlineEquation,
    r'E = mc^2',
    inline: true,
  ),
  MarkdownTemplate('math-fraction', AppMessage.fraction, r'\frac{a+b}{c+d}'),
  MarkdownTemplate('math-root', AppMessage.root, r'\sqrt{x^2+y^2}'),
  MarkdownTemplate(
    'math-sum',
    AppMessage.summation,
    r'\sum_{i=1}^{n} i = \frac{n(n+1)}{2}',
  ),
  MarkdownTemplate(
    'math-integral',
    AppMessage.integral,
    r'\int_0^1 x^2\,dx = \frac{1}{3}',
  ),
  MarkdownTemplate(
    'math-limit',
    AppMessage.limit,
    r'\lim_{x\to 0}\frac{\sin x}{x}=1',
  ),
  MarkdownTemplate(
    'math-matrix',
    AppMessage.matrix,
    r'\begin{pmatrix} a & b \\ c & d \end{pmatrix}',
  ),
  MarkdownTemplate(
    'math-cases',
    AppMessage.piecewiseFunction,
    r'f(x)=\begin{cases} x^2 & x\ge 0 \\ -x & x<0 \end{cases}',
  ),
  MarkdownTemplate(
    'math-aligned',
    AppMessage.alignedEquations,
    r'\begin{aligned} a+b &= c \\ x-y &= z \end{aligned}',
  ),
  MarkdownTemplate(
    'math-symbols',
    AppMessage.scriptsGreekLetters,
    r'x_i^2 + \alpha + \beta = \gamma',
  ),
];
const mermaidTemplates = [
  MarkdownTemplate(
    'mermaid-flow',
    AppMessage.flowchart,
    'flowchart TD\n  A[Start] --> B{Ready?}\n  B -->|Yes| C[Continue]\n  B -->|No| D[Review]',
  ),
  MarkdownTemplate(
    'mermaid-sequence',
    AppMessage.sequenceDiagram,
    'sequenceDiagram\n  participant U as User\n  participant S as Server\n  U->>S: Request\n  S-->>U: Response',
  ),
  MarkdownTemplate(
    'mermaid-class',
    AppMessage.classDiagram,
    'classDiagram\n  class Document {\n    +String title\n    +save()\n  }\n  class Editor\n  Editor --> Document',
  ),
  MarkdownTemplate(
    'mermaid-state',
    AppMessage.stateDiagram,
    'stateDiagram-v2\n  [*] --> Draft\n  Draft --> Saved: save\n  Saved --> Draft: edit\n  Saved --> [*]',
  ),
  MarkdownTemplate(
    'mermaid-er',
    AppMessage.entityRelationship,
    'erDiagram\n  USER ||--o{ DOCUMENT : owns\n  USER {\n    int id\n    string name\n  }\n  DOCUMENT {\n    int id\n    string title\n  }',
  ),
  MarkdownTemplate(
    'mermaid-gantt',
    AppMessage.ganttChart,
    'gantt\n  title Project plan\n  dateFormat YYYY-MM-DD\n  section Delivery\n  Design :a1, 2026-01-01, 3d\n  Build :after a1, 5d',
  ),
  MarkdownTemplate(
    'mermaid-pie',
    AppMessage.pieChart,
    'pie title Work distribution\n  "Design" : 30\n  "Build" : 50\n  "Test" : 20',
  ),
  MarkdownTemplate(
    'mermaid-mindmap',
    AppMessage.mindMap,
    'mindmap\n  root((Project))\n    Design\n      Layout\n      Theme\n    Build\n    Test',
  ),
  MarkdownTemplate(
    'mermaid-journey',
    AppMessage.userJourney,
    'journey\n  title Writing journey\n  section Write\n    Open document: 5: User\n    Edit content: 4: User\n    Save: 5: User',
  ),
];
