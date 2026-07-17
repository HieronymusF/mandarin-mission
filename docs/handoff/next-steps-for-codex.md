# 给后续 AI 代理（codex 等）的交接提示

> 这份文档是为"接手 Mandarin Mission 下一步开发"的 AI 代理写的精炼指令。
> 完整的项目现状和代码审视见 [`docs/project-status.md`](../project-status.md)；本文件只摘出**该做什么、别踩什么坑、必须守什么约束**。
> 先读 `AGENTS.md`，再读本文件，最后按需读 `docs/project-status.md`。

---

## 你现在该做什么

当前最高优先级是 **`AGENTS.md` 第 1 节"当前下一小模块"**：

> 先在 Figma 确认复习入口、四维题型与忘记/模糊/记得反馈流程，再实现本地到期复习 UI。

按 `docs/development-workflow.md` 的七阶段流程推进。复习 UI 的特殊性：**它是纯本地特性，没有后端**，所以跳过阶段 3b（后端），接口契约就是 `ReviewQueueRepository` 的现有方法（`dueItems` / `submitAttempt`）。

**已经就绪、你不用重做的**：
- 分箱算法 `packages/learning_core/lib/src/review_scheduler.dart`（纯函数，有完整测试）
- 队列数据层 `apps/mobile/lib/data/review/review_queue_repository.dart`（`dueItems` 已按"失败 > listening/tone > 到期"排序）
- Drift 表 `MasteryStates` / `ReviewAttempts`（含 `dueAt` 索引）
- Riverpod provider `reviewSchedulerProvider` / `reviewQueueRepositoryProvider`

**你要补的缺口**：
- `features/review/presentation/`（页面 + widget，参照 `features/lesson/` 的分层）
- `app/router.dart` 加 `/review` 路由
- `features/journey/presentation/journey_page.dart` 加复习入口卡片
- Widget 测试

---

## 必须守的硬约束（违反会被打回）

1. **Figma 前置**（`AGENTS.md` 前端任务的 Figma 前置流程）：用户可见页面必须先在 Figma `Learn Chinese` 文件 `Page 1` 画原型，**节点级链接发给用户确认后才能写 UI 代码**。未确认不得进入实现。草稿 PR 必须带 Figma 节点链接 + 差异说明。
2. **视觉系统必须严格按设计规范走**，不要自造配色/字号/圆角。规范沉淀在 `docs/design-system.md`（如已建）和 Figma 文件内——二者必须双向对齐。
3. **本地优先不变量**（`AGENTS.md` 第 6 节）：复习功能必须断网可用，不能等云端。`ReviewQueueRepository` 已经是纯本地，保持这样。
4. **业务逻辑不能写进 Widget 按钮回调**（这是上一轮代码的最大架构债，见下文"前车之鉴"）。
5. **复习算法不能改**（`AGENTS.md` 第 8 节）——除非先补测试并说明对已有进度数据的迁移影响。
6. **Git**（`AGENTS.md` 第 11 节）：独立功能分支 `feat/review-ui`，Conventional Commits，草稿 PR，不直接提交 main，不 `git add -A`。
7. **文件安全**（`AGENTS.md` 第 10 节）：禁止 `rm -rf` / 批量删除，一次只删一个明确文件。

---

## 前车之鉴：上一轮代码踩的坑，你别重蹈

这些都在 `docs/project-status.md` 第五节有 `文件:行号` 证据，实现新代码时**主动避免**：

1. **不要把 1100 行塞进一个文件**。`lesson_overview_page.dart` 1103 行 14 个 Widget 类是反面教材。复习 UI 按 step 维度/组件拆成独立文件，用一个工厂方法分发，别用 165 行的大 switch。
2. **不要在 `onPressed` 回调里调 Repository / 算 rating / 算 latency**。上一轮把 `progressRepository.recordExerciseAttempt` 直接写进按钮回调（`lesson_overview_page.dart:235-265`），rating 和 latency 硬编码在 UI 里。**你要把这些放进 Controller/ViewModel**，Widget 只负责渲染 + 转发意图。
3. **不要手动重建整个 state**。上一轮 `LessonPlayerController` 每个方法都手抄所有字段（`lesson_providers.dart:82-143`），易漏。用 copyWith 或 freezed。
4. **别让纯规则散在 Repository 里**。`_confidenceFor`、`_compareQueueItems` 这些纯函数应该在 `learning_core`，带单元测试。复习 UI 如果有新的纯规则（比如"过多时怎么拆今日必做/额外巩固"），一开始就放 domain 层。
5. **别硬编码 UI 文案**。上一轮 `'Replay the order'`、`'Played once'` 全是字面量（`lesson_overview_page.dart:659` 等）。复习 UI 的文案如果要本地化或可配置，从设计规范/fixture 走。
6. **fire-and-forget Future 会吞异常**。`onPressed: () async => ...` 但不 await，异常被吞。复习里 `submitAttempt` 这种持久化操作要正确处理错误并反馈 UI。
7. **有一个已知潜在 bug 要注意**：`lesson_overview_page.dart:262` 答错时 `usedHint` 硬编码 false，但 state 里 `usedListeningHint` 可能为 true——会污染 confidence 计算。你写复习的 attempt 记录时，把 usedHint 从 state 正确透传。

---

## 复习 UI 的设计要点（算法约束 → UI 约束）

这些是算法层（`AGENTS.md` 第 8 节、`docs/开发方案.md` 第 9.3 节）对 UI 的直接要求，设计原型时必须体现：

- **复习 ≠ 课程练习**。课程练习只判对错；复习要调箱位，所以**必须让用户表达"模糊"这个中间态**——核心交互是 **忘记 / 模糊 / 记得** 三选一，对应算法的 −2 箱 / 不变次日 / +1 箱。
- **单次复习 3–5 分钟**，到期项过多时**拆成"今日必做 + 额外巩固"，不向用户展示巨大数字**（`开发方案.md` 第 9.3 节）。
- **同日补救上限 2 次/项**——忘记的题会在本次尾部再出现，UI 要有相应提示（如"We'll see X once more before we finish"）。
- **四维题型**：meaning / listening（客观选择 + 即时对错 + 记忆自评），tone / hanzi（翻卡自评，因为一期 tone 精细评分不上）。
- **状态覆盖**（`AGENTS.md` 前端流程要求）：正常、加载、空（无到期）、错误、音频不可用降级。

---

## 协作分工（别越界）

- **Figma 上设计、画原型、确认 UI**：由具备 Figma 插件能力的代理（你 codex / Claude）主导，人类辅助。
- **读 Figma 设计稿 → 实现代码**：任何代理都能做。
- **不主动在 Figma 之外另起替代性 HTML mockup 或独立视觉原型**——这是上一轮的教训。

---

## 下一步建议顺序

1. 先读 `docs/project-status.md` 第二节，确认你对现状的理解和文档一致。
2. 按七阶段流程，先出 `docs/requirements/review-ui.md`（阶段 1），让用户审核。
3. 在 Figma 画设计规范 + 复习原型（阶段 2、3a），节点链接发用户确认。
4. 实现 presentation + 路由（阶段 4），严格按已确认的 Figma 还原。
5. Widget 测试 + 集成测试（阶段 6），草稿 PR 带 Figma 链接（阶段 7）。

如果发现代码和任何文档对不上，**以代码为准，然后修文档**（`AGENTS.md` 第 2 节）。
