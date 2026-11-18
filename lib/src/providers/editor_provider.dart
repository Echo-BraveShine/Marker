import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part 'editor_provider.freezed.dart';

@freezed
abstract class EditorState with _$EditorState {
  const EditorState._();
  const factory EditorState({
    @Default(defaultMarkdown) String markdown,
    @Default(defaultMarkdown) String saved,
    String? path,
    @Default(true) bool restoring,
    @Default(true) bool sidebar,
    @Default(false) bool busy,
    @Default(14) double fontSize,
    @Default(false) bool serif,
    @Default(1) int mode,
    @Default(false) bool searchVisible,
    @Default(false) bool replaceVisible,
    @Default('') String searchQuery,
    @Default('') String replacement,
    @Default(false) bool searchCaseSensitive,
    @Default(false) bool toolbarExpanded,
    @Default(0) int settingsPage,
    @Default(.5) double ratio,
    @Default(1) int cursorLine,
    @Default(1) int cursorColumn,
  }) = _EditorState;
  bool get dirty => markdown != saved;
}

final editorProvider = NotifierProvider<EditorNotifier, EditorState>(
  EditorNotifier.new,
);

class EditorNotifier extends Notifier<EditorState> {
  @override
  EditorState build() => const EditorState();
  void update(EditorState Function(EditorState) change) =>
      state = change(state);
  void setMarkdown(String text) => state = state.copyWith(markdown: text);
  void markSaved() => state = state.copyWith(saved: state.markdown);
}

const defaultMarkdown = r'''# 欢迎使用 Marker

这是一份可直接编辑的 Markdown 语法模板。标题标记后请加空格。

## 二级标题
### 三级标题
#### 四级标题
##### 五级标题
###### 六级标题

Setext 一级标题
===

Setext 二级标题
---

## 文本与段落

普通文字、**粗体**、__另一种粗体__、*斜体*、_另一种斜体_、***粗斜体***、~~删除线~~、`行内代码`。

这一行末尾有两个空格。  
这里会换行。

空行产生新的段落。转义符号：\*不是斜体\*、\# 不是标题。

## 列表与引用

- 无序列表
  - 嵌套列表
+ 加号列表
* 星号列表

1. 有序列表
2. 第二项

- [x] 已完成任务
- [ ] 待完成任务

> 引用内容
>
> **引用内也可以格式化**。
>> 嵌套引用

---

## 链接与图片

[打开 Flutter 网站](https://flutter.dev)

[引用式链接][flutter]

[flutter]: https://flutter.dev "Flutter"

自动链接：<https://flutter.dev>

邮件：<hello@example.com>

相对图片以当前保存文件的目录为起点。下面的示例图片地址只是占位，请替换成自己的文件。

![本地相对图片](images/example.png)

## 表格

| 左对齐 | 居中 | 右对齐 |
| :--- | :---: | ---: |
| **粗体** | 内容 | 100 |
| 普通文本 | `代码` | 200 |

## 代码块

```dart
void main() {
  print('Hello Marker');
}
```

~~~text
另一种代码围栏。# 不会在代码块中变成标题。
~~~

    四个空格缩进的代码块

## 数学公式

行内公式：$E = mc^2$。

$$
\frac{-b \pm \sqrt{b^2 - 4ac}}{2a}
$$

## Mermaid 图

```mermaid
flowchart LR
  A[Markdown] --> B[Preview]
  B --> C[Save]
```

## 脚注

正文中的脚注引用[^example]。

[^example]: 这是一条包含 **粗体** 的脚注。

## 支持边界

模板包含当前支持的主要语法，不执行原始 HTML。完整 LaTeX 宏包、目录指令、自定义容器和 ==高亮扩展== 尚未支持。
''';
