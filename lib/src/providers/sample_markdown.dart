const defaultMarkdown = r'''# Marker · 把想法写成作品

> 从一段文字，到一份清晰的文档。左侧写作，右侧预览，让注意力回到内容本身。

![山间晨光](https://images.unsplash.com/photo-1470252649378-9c29740c9fa8?fm=jpg&fit=crop&w=1200&q=80 "给写作留一点空间")

## 01 · 开始你的第一份文档

桌面端点击**新建**，选择磁盘位置后开始写作；手机端的文档保存在应用的文档空间中。打开已有文件时，请保留它旁边的图片文件夹。

| 模式 | 适合做什么 | 使用建议 |
| :--- | :---: | ---: |
| 编辑 | 专注输入 | 长文起草 |
| 分屏 | 边写边看 | 调整结构 |
| 预览 | 通读成稿 | 检查排版 |

内容修改后会自动保存。自动保存不是云同步；请自行备份重要文档。设置中可以切换深浅外观、字体与文本高亮，高亮默认关闭。

### 一个轻量的写作清单

- [x] 新建文档并确定标题
- [x] 切换分屏观察排版
- [ ] 加入图片、公式或图表
- [ ] 预览全文并导出

1. 先写提纲。
2. 再补充内容。
   1. 每段表达一个观点。
   2. 用列表组织并列信息。
3. 最后检查链接和图片。

- 项目资料
  - 文档：`旅行计划.md`
  - 图片：`旅行计划.assets/`

## 02 · 让文字有层次

**粗体**和__粗体__强调重点，*斜体*和_斜体_补充语气，***粗斜体***突出结论，~~删除线~~标记舍弃的想法。`行内代码`适合按钮名、路径与命令。

<span style="color:#23B9B0">这一句使用与 Marker 气质相近的青色。</span>

需要显示标记本身时，可以转义：\*星号\*、\# 标题符号、\[方括号\]。普通换行属于同一段；空一行开始新段落。

这一行使用反斜杠强制换行。\
现在开始下一行。

> 提示：编辑区中按 Tab 缩进，Shift + Tab 减少缩进。
>
> > 引用也可以嵌套，用于补充说明。

下面展示完整的标题层级；实际写作建议按内容结构逐级使用。

### 三级 · 章节
#### 四级 · 小节
##### 五级 · 细节
###### 六级 · 注释

Setext 一级标题示例
==================

Setext 二级标题示例
------------------

---

## 03 · 链接、图片与资源

点击[Marker 项目](https://github.com/Echo-BraveShine/Marker "Marker GitHub")打开链接，也可以使用[参考链接][marker]、[快捷引用]或自动链接：<https://github.com/Echo-BraveShine/Marker>。邮箱示例：<hello@example.com>。

[marker]: https://github.com/Echo-BraveShine/Marker
[快捷引用]: https://github.com/Echo-BraveShine/Marker

![森林中的光][forest]

[forest]: https://images.unsplash.com/photo-1441974231531-c6227db76b6e?fm=jpg&fit=crop&w=1200&q=80 "网络图片示例 · Unsplash"

以上图片来自 Unsplash，需要联网加载。网络链接可能变化；需要离线携带时，请导入本地图片。

桌面端可以拖入图片，手机端可以从相册或相机选取。应用管理的图片使用相对路径，移动文档时应同时携带对应资源文件夹。下面只是路径写法示范，不会加载不存在的图片：

```markdown
![界面截图](旅行计划.assets/screenshot.png)
![带空格的文件](旅行计划.assets/my%20photo.png)
```

在手机上从其他应用选择“用 Marker 打开”可导入支持的文档；若文档包含本地图片，建议将 Markdown 与资源文件夹一起打包为 ZIP 再导入。外部来源的可用菜单由系统与来源应用决定。

## 04 · 代码与技术笔记

围栏代码可指定语言：

```dart
String welcome(String name) {
  return 'Hello, $name!';
}
```

波浪线也可以作为围栏：

~~~text
写作 → 整理 → 预览 → 分享
~~~

四个空格开头形成缩进代码块：

    note.md
    note.assets/
        cover.png

## 05 · 把公式写进说明

行内公式适合短表达：$E=mc^2$，或 $a^2+b^2=c^2$。独立公式适合推导：

$$
\sum_{k=1}^{n} k = \frac{n(n+1)}{2}
$$

$$
\int_0^1 x^2\,dx=\frac{1}{3},\qquad
\lim_{n\to\infty}\frac{1}{n}=0
$$

$$
A=\begin{pmatrix}a&b\\c&d\end{pmatrix}
$$

$$
f(x)=\begin{cases}x^2 & x\geq 0\\-x & x<0\end{cases}
$$

公式支持常用 TeX 数学语法，并非完整的 LaTeX 文档系统。

## 06 · 用 Mermaid 讲清楚流程

### 从打开文档到完成分享

```mermaid
flowchart TD
    Start([开始写作]) --> Source{文档来自哪里?}
    Source -->|新建| New[选择位置或应用文档空间]
    Source -->|已有文件| Open[打开 Markdown]
    Source -->|文档与图片| Zip[导入 ZIP 资源包]
    New --> Edit
    Open --> Edit
    Zip --> Edit
    subgraph Writing[写作工作区]
        Edit[编辑内容] --> Preview[分屏预览]
        Preview --> Check{内容是否完整?}
        Check -->|继续完善| Edit
        Check -->|可以交付| Review[检查图片和链接]
    end
    Edit -.内容变化.-> Save[自动保存]
    Save --> Disk{磁盘写入结果}
    Disk -->|成功| Saved[保存完成]
    Disk -->|异常| Resolve[处理提示后重试]
    Resolve --> Edit
    Review --> Format{导出格式}
    Format --> PDF[PDF 文档]
    Format --> PNG[PNG 图片]
    Format --> HTML[HTML 页面]
    PDF --> Done([分享成果])
    PNG --> Done
    HTML --> Done
```

### 自动保存的交互顺序

```mermaid
sequenceDiagram
    autonumber
    actor Writer as 作者
    participant Editor as 编辑区
    participant Preview as 预览区
    participant Storage as 文档存储
    Writer->>Editor: 输入 Markdown
    loop 持续写作
        Editor-->>Preview: 更新内容
        Preview-->>Writer: 展示排版与图表
    end
    Editor->>Storage: 提交自动保存
    alt 写入成功
        Storage-->>Editor: 保存完成
    else 文件不可访问
        Storage-->>Editor: 返回失败原因
        Editor-->>Writer: 提示处理文件状态
    end
    opt 需要交付
        Writer->>Preview: 检查完整文档
        Writer->>Editor: 选择导出格式
        Editor-->>Writer: 生成导出文件
    end
```

### 文档的状态变化

```mermaid
stateDiagram-v2
    [*] --> Ready
    Ready: 已打开
    Editing: 正在编辑
    Saving: 正在保存
    Saved: 已保存
    Attention: 需要处理
    Ready --> Editing: 输入文字
    Editing --> Saving: 自动保存
    Saving --> Saved: 写入成功
    Saving --> Attention: 写入失败
    Attention --> Editing: 处理后继续
    Saved --> Editing: 再次修改
    Saved --> [*]: 关闭文档
```

### 一份文档的组织方式

```mermaid
mindmap
  root((写好一份文档))
    结构
      标题层级
      清单与表格
      引用与脚注
    表达
      图片
      数学公式
      Mermaid 图表
    工作区
      编辑
      分屏
      预览
    交付
      PDF
      PNG
      HTML
```

### 一次写作安排

```mermaid
gantt
    title 示例 · 写作与审阅计划
    dateFormat YYYY-MM-DD
    section 起草
    收集材料 :a1, 2026-11-23, 2d
    完成提纲 :a2, after a1, 1d
    section 编辑
    撰写正文 :b1, after a2, 3d
    补充图表 :b2, after a2, 2d
    section 交付
    通读审阅 :c1, after b1, 1d
    导出分享 :milestone, after c1, 0d
```

## 07 · 检索、整理与交付

用搜索定位文字，用替换统一术语。桌面端快捷键可以在设置中查阅；手机端通过菜单完成相应操作。侧栏用于切换文档，更多菜单提供文档操作。

导出前建议检查：

- [ ] 网络图片已经加载。
- [ ] 公式与 Mermaid 图表显示完整。
- [ ] 文档标题、链接与脚注正确。
- [ ] 已选择需要的导出外观与格式。

PDF 适合阅读与打印，PNG 适合分享视觉内容，HTML 适合浏览器打开。不同格式的分页和呈现方式可能不同，请检查最终文件。

## 08 · 脚注与最后一点建议

让正文保持简洁，把补充信息放进脚注[^writing]。同一脚注可以重复引用[^writing]，也可以使用另一条说明[^resources]。

[^writing]: 先完成内容，再统一调整结构和排版，通常比逐句反复修饰更容易推进写作。
[^resources]: Markdown 中的本地图片依赖资源文件。分享源文件时，请同时携带对应目录，或使用包含资源的 ZIP。

***

> 这份指南本身就是可编辑的语法示例。保留喜欢的部分，删去不需要的内容，开始你的下一篇作品。
''';

const legacyDefaultMarkdown = r'''# 欢迎使用 Marker

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
