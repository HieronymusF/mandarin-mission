# Mandarin Mission 代码优先 UI 系统

本文档定义移动端 UI 的单一开发基线。目标是让独立开发者和 AI 代理直接组合稳定组件完成页面，减少“先画原型、再逐像素还原”的重复工作和 Token 消耗。

## 1. 来源与优先级

1. 可执行令牌：`apps/mobile/lib/core/theme/app_theme.dart` 与 `apps/mobile/lib/core/theme/app_layout.dart`。
2. 本文档：组件选择、页面结构和使用边界。
3. Flutter 组件实现：[shadcn_ui](https://pub.dev/packages/shadcn_ui)。
4. 视觉原则与组件目录：[shadcn/ui](https://ui.shadcn.com/docs)。
5. 扩展模式与素材发现目录：[awesome-shadcn-ui](https://github.com/birobirobiro/awesome-shadcn-ui)。

`ui.shadcn.com` 的官方代码面向 React，不能直接放入 Flutter App。项目实际依赖 Flutter 移植版 `shadcn_ui: 0.55.0`，版本固定在 `apps/mobile/pubspec.yaml` 和 lockfile 中；官方站点用于选择组件、命名状态和理解组合方式。

`awesome-shadcn-ui` 是收录组件、Registry、主题、动画、模板和跨框架移植的导航目录，不是可整体安装到 App 的 Flutter 素材包。优先查看其中的 `Libs and Components`、`Registries`、`Colors and Customizations`、`Animations`、`Design System` 和 `Ports`；Web/SaaS 模板只在当前移动端需求确实匹配时参考。目录仓库自身的 MIT 许可证不覆盖其外链项目，采用候选前必须打开原始来源单独核验许可证。

Figma 不再是开始前端开发的必经门槛。品牌插画、商店素材、全新复杂交互或需要多人评审的高风险视觉方向，才按任务需要使用 Figma 或静态视觉稿。

## 2. 设计原则

- **内容优先**：页面只突出当前学习目标、进度和一个主动作。
- **语义令牌**：业务 Widget 不自行发明背景色、边框色、错误色或圆角。
- **组件组合**：先用 shadcn 原语，再建立项目级组合组件；不复制一套近似按钮或卡片。
- **本地优先**：加载和错误状态不能暗示核心课程依赖云端。
- **低维护**：一期只维护一套浅色主题；深色模式在真实需求出现后再做。
- **真实资产**：图标使用 Lucide；场景插画必须是已授权资产或内部生成资产，不用 emoji、字符画或临时几何图冒充正式素材。

## 3. 语义令牌

颜色与字体令牌以 `app_theme.dart` 为准，布局与尺寸令牌以 `app_layout.dart` 为准。

| 令牌 | 当前值 | 用途 |
|---|---|---|
| `background` | `#F7F9F7` | 页面底色 |
| `foreground` | `#17201D` | 主文本与图标 |
| `card` | `#FFFFFF` | 卡片和浮层 |
| `primary` | `#176B52` | 唯一高强调动作、当前进度 |
| `primaryForeground` | `#FFFFFF` | 主色表面上的内容 |
| `secondary` / `muted` | `#F0F3F1` | 次级按钮、说明区和未激活状态 |
| `mutedForeground` | `#66736E` | 辅助文案 |
| `accent` | `#E4F3EC` | 学习提示、选中和支持状态 |
| `border` / `input` | `#DDE4E0` | 边框和输入控件 |
| `destructive` | shadcn 默认红色 | 错误和破坏性动作 |
| `success` | `#DDF4E8` | 正确反馈 |
| `warning` | `#FFF2CC` | 降级、提醒和待确认状态 |

基础圆角为 `12`。间距统一使用 `4 / 8 / 12 / 16 / 20 / 24 / 32`，不要在单个页面引入新的随机间距阶梯。

页面和卡片使用同一组布局基准：

- 页面左右 padding 为 `20`，大屏内容最大宽度为 `640`，超出后水平居中；
- 标准卡片 padding 为 `20`，紧凑型卡片 padding 为 `16`；
- 卡片内图标与正文之间优先使用 `12`，内容组之间优先使用 `16` 或 `20`；
- 标准图标容器为 `48 × 48`，最小触控目标为 `44 × 44`；
- 按钮和常规控件高度为 `48`，选择项高度为 `72`，媒体练习区高度为 `80`。

字体使用 `shadcn_ui` 随包提供的 Geist；汉字由系统中文字体回退。页面标题使用 `h2`，区块标题使用 `h3`/`h4`，正文使用 `p`/`small`，辅助文案使用 `muted`。

## 4. 组件白名单

| 需求 | 默认组件 | 规则 |
|---|---|---|
| 主动作 | `ShadButton` | 一个视口原则上只有一个主按钮 |
| 次动作 | `ShadButton.secondary` / `.outline` | 不与主动作争夺视觉权重 |
| 弱动作 | `ShadButton.ghost` | 返回、关闭或低优先动作 |
| 信息容器 | `ShadCard` | 作为表面容器；复杂内容在 `child` 中显式布局 |
| 状态标签 | `ShadBadge` | 短文本，不放句子 |
| 连续进度 | `ShadProgress` | 必须提供语义标签和值 |
| 反馈 | `ShadCard` + 语义状态色 | 正确、错误、降级分别使用 success/destructive/warning |
| 图标 | `LucideIcons` | 同一动作保持同一图标 |

Material 继续负责 `Scaffold`、`SafeArea`、滚动、布局、`MaterialApp.router` 和当前 SnackBar 兼容层。不要为了“纯 shadcn”重写 Flutter 平台能力。

当前固定版本的 `ShadCard` 会用 `spaceBetween` 排列 `leading`、内容列和 `trailing`。全宽业务卡片不得使用这些槽位承载首行图标或操作，否则剩余空间会被分配成不稳定的空白，并使后续内容整体缩进。需要“图标 + 文案”的卡片统一在 `child` 中使用 `AppLeadingRow` 和 `AppIconTile`；需要右侧操作时使用显式 `Row`、`Expanded` 与固定操作区宽度。除浮层等真实叠放场景外，不使用绝对定位、位移或负 margin 修正对齐。

## 5. 页面与状态模板

标准学习页从上到下包含：

1. 返回动作、任务名和步数；
2. 连续进度；
3. 状态徽章、页面标题和一段必要说明；
4. 单一任务内容；
5. 固定在底部的主动作。

新增用户可见页面至少处理：

- 正常；
- 加载（不闪烁旧数据）；
- 空（说明为何为空，并给出下一步）；
- 错误（保留用户进度，提供可重试动作）；
- 不可用/降级（尤其音频、录音和网络）；
- 提交中（禁用重复提交并显示明确进度）。

## 6. 无障碍与设备适配

- 触控目标最小 `44 × 44`。
- 颜色不能是正确/错误的唯一信号，必须配合图标或文字。
- 进度条、图标按钮和录音动作必须提供语义说明。
- 先验证常见 Android 尺寸，再验证小屏和 200% 字体。
- 布局回归至少覆盖 `768 / 1024 / 1280 / 1440` 逻辑像素宽度，确认内容列仍保持 `640` 最大宽度、卡片同边界、正文可扩展。
- 页面允许垂直滚动；主动作不能被系统底部区域遮挡。
- 动画遵循系统“减少动态效果”，且不得阻断学习流程。

## 7. 新增组件流程

1. 在 shadcn 官方组件目录和当前 Flutter 移植版中搜索现有组件。
2. 官方组件没有合适组合时，再从 `awesome-shadcn-ui` 搜索候选模式；先判断它是视觉参考、代码参考还是需要分发的真实资产。
3. 对候选原始来源记录 URL、许可证、核验日期、维护状态和 Flutter 映射方式。聚合目录的许可证不能代替原始来源许可证。
4. 能通过现有原语组合完成时，使用 `shadcn_ui`、Lucide、`AppLayout` 和语义主题重新实现；不复制 React/Tailwind/Radix/Framer Motion 代码。
5. 同一组合在两个功能中重复后，再放入 `lib/shared`。
6. 只有组件缺失且确有产品需要时才新增依赖；不得混入 Forui 等第二套完整 Flutter UI 框架。新增依赖要记录包体积影响、维护状态和回滚方式。
7. UI PR 附采用来源、组件映射、关键状态截图、测试结果和已知差异，不再要求 Figma 节点链接。

第三方 UI 来源记录至少包含：

| 字段 | 说明 |
|---|---|
| 原始来源 | 具体组件或资产页面，不只填 `awesome-shadcn-ui` 目录 |
| 用途 | 视觉参考、交互参考、代码参考或正式分发资产 |
| 许可证 | 原项目许可证与必要署名；无法确认时不得进入正式 App |
| Flutter 映射 | 使用的 `shadcn_ui` 原语、Lucide 图标、项目组合组件或原生动画 |
| 核验日期 | 防止维护状态和许可信息长期失真 |
| 已知差异 | Web 到移动端的交互、响应式、无障碍和性能差异 |

`shadcn_ui` 仍是 `0.x` 版本。升级时只允许单独 PR：阅读 changelog，更新锁文件，运行移动端全量测试和 APK 构建，并对 Journey、课程步骤和复习页做截图回归；不得把版本升级混入业务功能。
