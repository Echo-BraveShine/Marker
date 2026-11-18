import 'markdown_commands.dart';

class MarkdownTemplate {
  const MarkdownTemplate(
    this.id,
    this.label,
    this.englishLabel,
    this.source, {
    this.inline = false,
  });
  final String id, label, englishLabel, source;
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
    '行内公式',
    'Inline equation',
    r'E = mc^2',
    inline: true,
  ),
  MarkdownTemplate('math-fraction', '分式', 'Fraction', r'\frac{a+b}{c+d}'),
  MarkdownTemplate('math-root', '根号', 'Root', r'\sqrt{x^2+y^2}'),
  MarkdownTemplate(
    'math-sum',
    '求和',
    'Summation',
    r'\sum_{i=1}^{n} i = \frac{n(n+1)}{2}',
  ),
  MarkdownTemplate(
    'math-integral',
    '积分',
    'Integral',
    r'\int_0^1 x^2\,dx = \frac{1}{3}',
  ),
  MarkdownTemplate(
    'math-limit',
    '极限',
    'Limit',
    r'\lim_{x\to 0}\frac{\sin x}{x}=1',
  ),
  MarkdownTemplate(
    'math-matrix',
    '矩阵',
    'Matrix',
    r'\begin{pmatrix} a & b \\ c & d \end{pmatrix}',
  ),
  MarkdownTemplate(
    'math-cases',
    '分段函数',
    'Piecewise function',
    r'f(x)=\begin{cases} x^2 & x\ge 0 \\ -x & x<0 \end{cases}',
  ),
  MarkdownTemplate(
    'math-aligned',
    '多行对齐',
    'Aligned equations',
    r'\begin{aligned} a+b &= c \\ x-y &= z \end{aligned}',
  ),
  MarkdownTemplate(
    'math-symbols',
    '上下标与希腊字母',
    'Scripts & Greek letters',
    r'x_i^2 + \alpha + \beta = \gamma',
  ),
];
const mermaidTemplates = [
  MarkdownTemplate(
    'mermaid-flow',
    '流程图',
    'Flowchart',
    'flowchart TD\n  A[Start] --> B{Ready?}\n  B -->|Yes| C[Continue]\n  B -->|No| D[Review]',
  ),
  MarkdownTemplate(
    'mermaid-sequence',
    '时序图',
    'Sequence diagram',
    'sequenceDiagram\n  participant U as User\n  participant S as Server\n  U->>S: Request\n  S-->>U: Response',
  ),
  MarkdownTemplate(
    'mermaid-class',
    '类图',
    'Class diagram',
    'classDiagram\n  class Document {\n    +String title\n    +save()\n  }\n  class Editor\n  Editor --> Document',
  ),
  MarkdownTemplate(
    'mermaid-state',
    '状态图',
    'State diagram',
    'stateDiagram-v2\n  [*] --> Draft\n  Draft --> Saved: save\n  Saved --> Draft: edit\n  Saved --> [*]',
  ),
  MarkdownTemplate(
    'mermaid-er',
    '实体关系图',
    'Entity relationship',
    'erDiagram\n  USER ||--o{ DOCUMENT : owns\n  USER {\n    int id\n    string name\n  }\n  DOCUMENT {\n    int id\n    string title\n  }',
  ),
  MarkdownTemplate(
    'mermaid-gantt',
    '甘特图',
    'Gantt chart',
    'gantt\n  title Project plan\n  dateFormat YYYY-MM-DD\n  section Delivery\n  Design :a1, 2026-01-01, 3d\n  Build :after a1, 5d',
  ),
  MarkdownTemplate(
    'mermaid-pie',
    '饼图',
    'Pie chart',
    'pie title Work distribution\n  "Design" : 30\n  "Build" : 50\n  "Test" : 20',
  ),
  MarkdownTemplate(
    'mermaid-mindmap',
    '思维导图',
    'Mind map',
    'mindmap\n  root((Project))\n    Design\n      Layout\n      Theme\n    Build\n    Test',
  ),
  MarkdownTemplate(
    'mermaid-journey',
    '用户旅程',
    'User journey',
    'journey\n  title Writing journey\n  section Write\n    Open document: 5: User\n    Edit content: 4: User\n    Save: 5: User',
  ),
];
