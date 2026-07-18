# 本地到期复习 UI

## 1. 任务等级与用户结果

本功能为 M 级、纯本地垂直切片。

完成后，用户可以从 Journey 的今日任务看到真实到期数量，进入一次 3—5 分钟的复习，按 `meaning`、`listening`、`tone`、`hanzi` 四个维度完成题目，并用 Forgotten / Unsure / Remembered 反馈记忆状态。每次反馈立即写入本地数据库；退出、保存失败或 App 中断不会丢失已经成功保存的结果。

## 2. 范围

### 必须实现

- Journey 从本地复习队列读取真实到期数量，并提供 `/review` 入口；
- 单次“今日必做”最多 8 项，超过部分显示为额外巩固，不制造无法完成的巨大数字；
- `meaning`：根据英文含义选择正确中文，再进行记忆自评；
- `listening`：预留客观选择结构；当前音频资产不可用时明确降级为文字揭晓与自评，并标记使用提示；
- `tone`：先尝试说出目标表达，翻卡查看汉字和拼音后自评；
- `hanzi`：先识认汉字，翻卡查看拼音和英文后自评；
- 覆盖加载、无到期项、初始加载失败、保存中、保存失败、重试、音频不可用和完成状态；
- Forgotten 项在本次队列尾部补救，同一知识点同一维度遵守现有每日最多两次补救规则；
- 每次反馈通过 `ReviewQueueRepository.submitAttempt` 立即事务写入 `ReviewAttempts`、`MasteryStates` 和 `SyncOutboxEvents`。

### 明确不做

- 不实现真人音频播放、录音、语音识别或声调评分；
- 不新增后端、登录、云同步或分析接口；
- 不修改 v1 分箱算法、Drift schema 或内容 schema；
- 不新增第二套 UI 框架、Figma 原型、插画或正式媒体资产；
- 不实现独立 Practice 底部导航、每日任务奖励、连胜或记忆星授予。

## 3. 数据来源与契约

### 本地数据

- 到期项：`ReviewQueueRepository.dueItems(now, limit)`；
- 题目内容：`CourseContentRepository.loadPackage()` 中与 `itemId` 对应的 `CourseKnowledgeItem`；
- 提交：`ReviewQueueRepository.submitAttempt(...)`；
- 当前时间：由可覆盖的时钟 Provider 提供，所有 Repository 时间使用 UTC。

### 会话限制

- 加载最多 9 个已排序到期项；
- 前 8 个作为“今日必做”；
- 第 9 个仅用于判断仍有额外巩固；
- 会话完成后重新读取队列，Journey 返回时重新计算到期数量。

### 评分映射

| 用户反馈 | `ReviewRating` | `correct` |
|---|---|---|
| Forgotten | `forgotten` | `false` |
| Unsure | `vague` | 客观题使用选择结果；翻卡题为 `true` |
| Remembered | `remembered` | 客观题使用选择结果；翻卡题为 `true` |

- 客观题选错时，即使用户选择 Unsure 或 Remembered，`correct` 仍为 `false`；
- 音频不可用的 listening 降级题在揭晓后设 `usedHint=true`；
- tone / hanzi 翻卡查看答案不视为明显提示；用户仍通过自评表达是否记住；
- latency 从当前题进入页面开始计算，保存重试沿用同一次作答时间和选择。

## 4. 状态模型

Controller/ViewModel 负责：

- 初始加载内容包与到期队列；
- 当前题、已完成数量、额外巩固提示和完成状态；
- 选项选择、翻卡/揭晓、客观正确性和提示使用；
- 提交去重、保存失败、原状态保留与重试；
- Forgotten 补救项追加到当前会话尾部；
- 完成或退出时刷新 Journey 到期摘要。

View 只负责：

- 渲染 `AsyncValue` 的加载/错误；
- 渲染当前维度对应的题面；
- 转发选择、揭晓、反馈、重试、退出和完成动作；
- 提交中禁用重复操作。

## 5. 页面结构与组件

只使用现有项目基线：

- 页面外壳：`Scaffold`、`SafeArea`、最大宽度 `640`；
- 顶部：返回动作、`Review` 标题、`ShadBadge` 维度标签、`ShadProgress`；
- 题面：`ShadCard`；
- 选择与反馈：`ShadButton`；
- 降级/保存失败：语义 warning/destructive 卡片；
- 完成/空状态：`ShadCard` + Lucide 图标 + 单一主动作。

布局继续使用 `AppLayout` 与 `4/8/12/16/20/24/32` spacing，不新增随机间距、绝对定位、负 margin 或位移修补。

## 6. 验收标准

1. 完成课程并到达到期时间后，Journey 显示真实数量和 Start review；
2. `/review` 可依次呈现四个维度，当前题与进度一致；
3. meaning 客观选择的正确/错误结果进入提交；
4. listening 在无音频时显示明确说明，揭晓后仍能完成且不阻断队列；
5. tone / hanzi 必须先翻卡，之后才能选择三档反馈；
6. 提交期间按钮不可重复触发；
7. 模拟保存失败后，当前题、选择和揭晓状态仍在，Retry 成功后继续；
8. 已成功保存的题目在重新进入复习时不再作为当前到期项；
9. Forgotten 在本次尾部出现补救，且不会绕过现有每日上限；
10. 无到期项显示明确空状态并可返回 Journey；
11. Widget 测试覆盖主路径、四维题型、空/错误/保存失败/音频不可用；
12. Repository 与端到端测试证明本地落库和 Outbox 写入；
13. 常见宽度、小屏和 200% 字体无溢出，Android 模拟器保留关键状态截图。

## 7. 迁移、隐私与回滚

- 无数据库迁移、内容迁移或远端契约变更；
- 不采集或保存录音，不新增隐私权限；
- 回滚只需撤销 presentation、Provider、路由、Journey 入口与对应文档；现有复习数据仍兼容。
