# Mandarin Mission Widget Library

涉及稳定 UI 行为或组件代码变更时，按根 `AGENTS.md` 的 Repo docs sync gate 核对并最小更新 `repo-docs/`。

本文件是 AI 主导 Flutter UI 开发的根目录执行准则。详细视觉语义见 `docs/design-system.md`；可执行源码位于 `apps/mobile/lib/core/theme/` 和 `apps/mobile/lib/shared/presentation/`。UI 任务必须先读本文件，再修改页面。

## 1. 固定技术组合

- 基础原语：`shadcn_ui: 0.55.0`。
- 项目令牌：`AppSpacing`、`AppRadius`、`AppLayout`、`AppTextStyles`。
- 项目布局组件：`AppContentFrame`、`AppPageScrollView`、`AppSection`、`AppLeadingRow`、`AppIconTile`、`AppListRow`。
- 汉字专用组件：`HanziPinyinText`。
- 统一入口：`package:mandarin_mission/shared/presentation/app_widgets.dart`。
- Material 只承担 `Scaffold`、`SafeArea`、滚动、约束、平台反馈等 Flutter 外壳；业务控件优先使用 shadcn。
- 不引入第二套完整 UI 框架，不复制 React/Tailwind/Radix 代码。

## 2. 令牌

### Spacing

只使用 `AppSpacing`：

| Token | px |
|---|---:|
| `xxs` | 4 |
| `xs` | 8 |
| `sm` | 12 |
| `md` | 16 |
| `lg` | 20 |
| `xl` | 24 |
| `xxl` | 32 |

禁止无设计依据的 `13 / 17 / 19 / 23` 等随机间距。新间距必须先证明不能由现有 scale 表达，再修改令牌和本文档。

### Radius

只使用 `AppRadius.xs/sm/md/lg/pill`，对应 `4 / 8 / 12 / 16 / 999`。卡片默认 `md`；按钮和输入框跟随 shadcn theme；胶囊才使用 `pill`。

### Typography

`AppTextStyles` 是字体尺寸、字重、行高和中英文字体回退的唯一来源。业务页面通过 `ShadTheme.of(context).textTheme` 使用以下映射：

| 语义 | shadcn 名称 | 项目源码名称 |
|---|---|---|
| 页面标题 | `h2` | `pageTitle` |
| Section 标题 | `h3` | `sectionTitle` |
| 小标题 | `h4` | `subsectionTitle` |
| 正文 | `p` | `body` |
| 强调正文 | `large` | `emphasized` |
| 标签 | `small` | `label` |
| 辅助文字 | `muted` | `supporting` |

不得在业务 Widget 内随意创建 `TextStyle(fontSize: ...)`。汉字教学、拼音对齐、画布标注等特殊排版可以例外，但必须集中在专用组件内，并解释视觉依据。

## 3. 布局组件调用规则

### `AppContentFrame`

用于页面的单一内容列：最大宽度 `640`，宽屏居中。不要在每个页面重复 `Center + ConstrainedBox + SizedBox`。

### `AppPageScrollView`

用于标准滚动页：自动复用内容最大宽度和 `AppLayout.pagePadding`。所有同级标题、正文、按钮、卡片、输入框因此共享左右边界。

### `AppSection`

用于“标题 + 可选说明 + 内容”。标题、说明、内容固定同一左边界，内部 gap 只取 spacing token。

### `AppLeadingRow` / `AppIconTile`

用于图标 + 多行文字。图标占固定槽，文字使用 `Expanded`，避免多行文字推动图标或下一层内容。全宽业务卡片不要使用当前 `ShadCard.leading/trailing` 排首行内容。

### `AppListRow`

用于列表项或卡片内“图标 + 多行文字 + 右侧操作”。默认最小高度 `72`，图标槽 `48`，右侧操作最小触控区域 `44 × 44`，三列垂直居中。

### 何时新增共享组件

同一稳定组合第二次出现后才提取。新组件必须解决重复的布局或状态问题，不得只包装一层无语义 `Container`。组件参数使用语义名称，不暴露随意坐标修补入口。

## 4. 页面构造基线

标准页面结构：

```dart
Scaffold(
  body: SafeArea(
    child: AppPageScrollView(
      children: [
        AppSection(
          title: Text('Title', style: ShadTheme.of(context).textTheme.h2),
          description: Text(
            'Description',
            style: ShadTheme.of(context).textTheme.muted,
          ),
          child: ShadCard(width: double.infinity, child: ...),
        ),
      ],
    ),
  ),
);
```

固定底部动作页可使用 `AppContentFrame + Column`：Header、`Expanded` 内容区、统一 action bar。底部按钮高度使用 `AppLayout.controlHeight`，左右 padding 必须与正文基准一致。

## 5. 系统性 UI 对齐检查

发现错位时，不得只针对截图中明显元素逐个增加 margin、padding 或 transform。

### 第零步：建立失败证据

1. 记录真实入口、页面状态、viewport、设备像素比、文字缩放和长文案条件。
2. 在修改前复现问题并保存截图；无法复现时不得用猜测性布局改动冒充修复。
3. 写出一个根因假设和可观察成功标准，例如“标题、正文和卡片左边缘误差为 0”“200% 字号无溢出”。
4. 先检查现有 Widget 和 token 能否解决；单个页面问题不新增共享抽象。

### 第一步：分析整体结构

1. 画出页面父子层级，检查 `Row`、`Column`、`Wrap`、`GridView`、`Stack/Positioned` 是否符合内容关系。
2. 检查父容器的宽度、高度、constraints、padding、gap、margin 是否一致。
3. 搜索魔法数字、负 margin、`Transform.translate`、`Positioned`；确认它们是否制造跨分辨率偏差。
4. 优先修父容器和布局规则，不逐个移动子元素坐标。

### 第二步：统一对齐基准

- 同级内容使用相同左右边界。
- 同级标题、正文、按钮、卡片、输入框使用相同 horizontal padding。
- 卡片内部统一 padding 和 gap。
- 列表项高度、图标槽、文字列、文字基线、右侧操作区保持一致。
- 同类组件只使用同一尺寸和 spacing token，不允许多个相近值。

### 第三步：重点排查

- 图标和文字是否真正垂直居中。
- 多行文字是否推动右侧按钮或图标。
- Button 文字是否在实际 content box 中居中。
- 输入框、下拉框、按钮是否统一为 `AppLayout.controlHeight`。
- 标题和正文左边缘是否一致。
- 卡片宽度、左右 margin 是否一致。
- `Row/Column/Grid` 子元素是否因 `Expanded/Flexible`、constraints、最小宽度而漂移或溢出。
- border 和 padding 是否改变实际尺寸；Flutter 中重点检查 `BoxConstraints` 和父级可用空间。
- SVG/icon 的 viewBox 是否带视觉留白；必要时修资产或图标槽，不用 translate 掩盖。
- line-height 是否导致文字视觉偏上或偏下。
- `Stack/Positioned` 是否在不同屏幕、文字缩放或多语言时错位。

### 第四步：按优先级修复

1. 修正整体 layout/container。
2. 修正 Flex/Grid/constraints 对齐规则。
3. 统一组件尺寸、padding、gap。
4. 修正 typography line-height。
5. 最后才对有明确视觉依据的特殊元素微调。

默认禁止：`Positioned` 截图级坐标、`Transform.translate`、负 margin、只适配单一宽度的 magic number。真实叠放、绘图或动画场景可用 `Stack/Positioned`，但必须说明约束和响应式行为。

修复完成后必须在与失败证据相同的状态下重新截图，并比较前后结果。`flutter analyze`、Widget 测试和 APK 构建不能代替视觉验收；它们只负责证明代码、行为与构建没有回归。

## 6. 响应式与视觉 QA

每次页面级 UI 修改至少验证逻辑宽度：`768 / 1024 / 1280 / 1440`。移动端主目标还要检查常见 Android 小屏、200% 字体和安全区。

自动测试至少断言：

- 内容列在宽屏最大为 `640` 且水平居中；
- 同级元素左右边缘一致；
- 同类组件宽高一致；
- 图标、文字和右侧操作视觉居中；
- 多行文字不造成操作区位移或溢出；
- 卡片间距和 Section spacing 只来自 token。

人工视觉 QA 逐项检查：

- 左右边缘形成统一垂直线；
- 相同组件宽高一致；
- 图标与文本视觉居中；
- 卡片间距一致；
- 上下 Section spacing 有规律；
- 不同宽度、文字缩放和长文案下仍然对齐；
- 正常、加载、空、错误、不可用、提交中状态没有布局跳动。

若没有可连接设备，可用受控 Widget/Golden 截图作为临时证据，并在交付中明确标记“真机未验证”；不得写成视觉 QA 已完成。

UI 任务交付前运行：

```powershell
Set-Location apps/mobile
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build apk --debug
Set-Location ../..
git diff --check
```
