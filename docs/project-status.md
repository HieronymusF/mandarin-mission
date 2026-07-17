# Mandarin Mission 项目现状与代码审视

> 本文档是对**已落地代码**的盘点和质量审视，作为后续开发的对照基线。以代码和测试为唯一事实来源，不轻信文档描述。证据格式为 `文件:行号`。
> 维护原则：发现代码与本文档不符时，以代码为准并更新本文档（参考 `AGENTS.md` 第 2 节）。
> 最近核对提交：`0eddd31`（2026-07-17）。

---

## 一、总览

| 模块 | 状态 | 一句话评价 |
|---|---|---|
| 纯 Dart 核心 `packages/learning_core` | ✅ 已实现 | 项目最扎实的部分，纯函数 + 完整测试 |
| 课程内容工程 `content/` | ✅ 已实现 | schema + validator + 1 套 fixture，校验严谨 |
| 移动端 `apps/mobile` 数据层 | ✅ 已实现 | Drift 6 表约束扎实，Repository 全事务化 |
| 移动端课程播放器 | ⚠️ 已实现（有架构债） | 数据驱动 7 步走通，但业务逻辑泄漏到 Widget |
| 移动端复习功能 | ⚠️ 仅数据层 | 算法+队列就绪，**UI 完全没开始** |
| 移动端音频/录音 | ❌ 仅占位 | 按钮全弹 SnackBar，无真实音频 |
| Go 后端 `services/api` | ❌ 仅骨架 | 只有 healthz/readyz/meta，无 DB/认证/业务 |
| CI | ✅ 已实现 | 三 job 覆盖 mobile/learning-core/api，有生成文件门禁 |
| 文档 | ✅ 较全 | 开发方案 + ADR + 流程文档齐全 |

---

## 二、各模块详情

### 1. 纯 Dart 核心 `packages/learning_core` ✅

**已实现**：
- `review_scheduler.dart` — 0–5 分箱调度，纯函数 `apply()`，严格对应 `AGENTS.md` 第 8 节算法。interval 表、忘记 −2/模糊不变/记得 +1/hint 不升、同日补救上限 2，全部落地。
- `content_validator.dart`（540 行）— 覆盖：schemaVersion、status 枚举、稳定 ID kebab-case 正则 + 全局去重、location/lesson/item/asset 引用完整性、pinyinSyllables 与汉字数对齐（CJK 区段过滤标点）、对话可达性 + 环检测 + 不可达节点检测、release 资产必须 ready + license/credit。
- `learning_core_base.dart` — `LearningDimension`、`ReviewRating` 两个枚举。

**测试**：`learning_core_test.dart` 119 行，覆盖 remembered/hint/vague/forgotten/补救上限/四维独立/UTC 拒绝。`content_validator_test.dart` 196 行。**这是测试最扎实的模块。**

**审视点（轻）**：
- `content_validator.dart` 只校验 asset 的 `path`，**不校验 `sha256`**——但 `course-package.schema.json:209,217` 要求 ready 资产必须有 sha256。**校验器与 schema 不一致**，二选一对齐。
- 校验器有几条规则（status 非法值、stableId 格式、location 引用未知 lesson、duplicate step id）代码里有但缺专门测试 case。

---

### 2. 内容工程 `content/` ✅

- `schema/course-package.schema.json` — JSON Schema Draft 2020-12，`additionalProperties:false` 全开，定义 9 种 step 类型。
- `fixtures/cafe-course.json` — 1 location / 3 知识点 / 1 lesson（7 步）/ 1 dialogue / 4 assets。所有 asset `status:"planned"`（无 path/sha256，是合法 draft，不能 release）。
- `lib/mandarin_mission_content.dart` — 5 行，暴露 asset 路径常量。

**审视点**：
- **schema 定义 9 种 step 类型，但播放器只实现 6 种**（scene_intro/teach_card/listen_choice/repeat/dialogue_turn/summary）。`image_choice / tone_contrast / order_tokens` 未实现，落入 `lesson_overview_page.dart:339-345` 的 default 分支显示 "Unsupported lesson step"。文档未说明这个缺口。

---

### 3. 移动端 `apps/mobile`

#### 3.1 数据层 ✅（质量良好）

**`data/local/tables.dart`**（106 行）— 6 张表，CHECK 约束用足（`box.isBetweenValues(0,5)`、`sameDayRetryCount.isBetweenValues(0,2)`、enum 字符串集合），索引合理（`mastery_states_due_at` 等）。schemaVersion=1，首版无迁移路径（合理）。

**`data/progress/lesson_progress_repository.dart`**（339 行）— `startLesson/recordExerciseAttempt/recordReviewAttempt/recordSpeakingAttempt/completeLesson` 全部用 `_database.transaction` 包裹，同步 Outbox 一并写入。`completeLesson` 用 `InsertMode.insertOrIgnore` 为每个 item × 4 维度初始化 box 0。**设计正确，符合本地优先不变量。**

**`data/review/review_queue_repository.dart`**（121 行）— `dueItems` 先 SQL 过滤再 Dart 排序，优先级：失败 > listening/tone > 到期时间 > itemId。

**审视点**：
- `dueItems` 在 SQL 层**没有 limit**（`review_queue_repository.dart:42-46`），全表拉回内存再 `.take(limit)`。内容多了之后是性能隐患（MVP 阶段可接受）。
- **纯规则散落在非 domain 层**，违反 `AGENTS.md` 第 12 节"纯规则放 `lib/domain`"：
  - `_confidenceFor`（`lesson_progress_repository.dart:326-338`）— forgotten/vague/remembered/hint 四象限 confidence 规则，只通过 Repository 测试间接覆盖，**无单元测试**。
  - `_compareQueueItems`（`review_queue_repository.dart:84-109`）— 复杂排序规则，同样只间接覆盖。
  - 应迁移到 `learning_core` 并补单元测试。

#### 3.2 课程播放器 ⚠️（功能完成，架构债重）

**`features/lesson/application/lesson_providers.dart`**（148 行）— 有 `LessonPlayerController`（Notifier）+ `LessonPlayerState`。

**`features/lesson/presentation/lesson_overview_page.dart`（1103 行）** — 数据驱动 7 步播放器走通，端到端集成测试 `app_test.dart` 验证落库。

**审视点（这是最大的架构债）**：
1. **单一文件 1103 行塞了 14 个 Widget 类**（`LessonOverviewPage`、`_SceneIntro`、`_TeachCard`、`_ListenChoice`、`_AnswerCard`、`_RepeatStep`、`_SpeakingFallback`、`_DialogueStep`、`_SummaryStep` 等）。应按 step 类型拆成独立文件 + 工厂。
2. **业务逻辑泄漏到 Widget 按钮回调**，违反 `AGENTS.md` 第 6 节 MVVM 不变量：
   - `lesson_overview_page.dart:235-265` — listen_choice 的对错分支**直接在 `onPrimary` 里调用** `progressRepository.recordExerciseAttempt`，硬编码 rating、latency 计算。
   - `lesson_overview_page.dart:283-301` — repeat 的 self-check 直接调 `recordSpeakingAttempt`。
   - `lesson_overview_page.dart:326-338` — summary 的 `completeLesson` 写在按钮里。
   - 这些应移到 Controller。
3. **`LessonPlayerController` 每个方法手动重建整个 state**（`lesson_providers.dart:82-143`），不用 copyWith/freezed，易漏字段。
4. **`LessonPlayerState.score` 打分逻辑（`lesson_providers.dart:72-75`）零单元测试**。
5. **UI 文案全是字面量**（`lesson_overview_page.dart:659` 等），没走 i18n，也没从 fixture 读——违反内容工程规则。
6. 三处音频占位 SnackBar 文案重复（`:549,608,826`）。

**潜在 bug**：`recordExerciseAttempt` 答错时硬编码 `usedHint: false`（`lesson_overview_page.dart:262`），但 state 里 `usedListeningHint` 可能为 true——**会影响 confidence 计算**。

#### 3.3 Journey 页 ⚠️

`features/journey/presentation/journey_page.dart`（161 行）是**纯 StatelessWidget，无 ViewModel/Riverpod**。`'cafe-01'` 硬编码（`:151`），所有文案字面量。**无法接入进度、连胜、解锁**。应改为 ConsumerWidget + ViewModel。

#### 3.4 复习功能 ⚠️（仅数据层）

- `features/review/application/review_providers.dart`（15 行）— 只有 2 个 Provider。
- **没有 presentation 层、没有 review_page、没有 `/review` 路由**。
- 这是 `AGENTS.md` 第 1 节"当前下一小模块"，是当前最高优先级缺口。

#### 3.5 测试覆盖

| 测试 | 质量 |
|---|---|
| `app_test.dart`（98 行，端到端跑完整节课校验落库） | ⭐ 优秀 |
| `learning_core_test.dart` | ⭐ 扎实 |
| Repository 各测试 | ✅ 良好 |
| `review_provider_test.dart`（15 行） | ⚠️ 过弱，只验接线 |
| `LessonPlayerController` 状态机 | ❌ 零单元测试 |
| `_presentationFor` 各 step 分支 | ❌ 无独立 widget 测试 |

#### 3.6 音频/录音 ❌

音频按钮全是占位 SnackBar（"Course audio will be added in the audio module."）。repeat 步骤的录音按钮直接跳 self-check fallback（`lesson_overview_page.dart:307`），**无真实录音**。`AGENTS.md` 第 14 节第 9 步几乎未动。

---

### 4. Go 后端 `services/api` ❌（仅骨架）

- `cmd/api/main.go`（59 行）— 标准库 net/http，优雅退出 + 超时配置，写得干净。
- `internal/httpapi/handler.go`（34 行）— 只有 `GET /healthz`、`GET /readyz`、`GET /v1/meta`。**无 v1 业务接口、无 DB、无认证、无同步 outbox 消费、无 R2、无语音代理。**
- **无 migrations/ 目录、无 internal/db/**——ADR 0001 承诺的 Neon PostgreSQL 完全未接入。

**审视点**：
- `handler.go:31` 用 `panic(err)` 处理 JSON 写入错误——**生产代码不应 panic**，应日志后返回 500。
- `/readyz` 永远返回 ready（`handler.go:15-17`），接入 DB 后必须扩展。
- `/readyz` 没有 Go 测试。

---

### 5. CI `.github/workflows/core-ci.yml` ✅

三 job：mobile（Flutter，含 build_runner + **生成文件门禁 `git diff --exit-code`**）、learning-core（Dart + content validator）、api（go vet/test/docker build）。权限最小化。

**审视点（轻）**：文件名 `core-ci.yml` 与 workflow 名 "Project CI" 不一致；无 path filter / cron / release 工作流；Go `cache: false`。

---

### 6. 文档

- `docs/开发方案.md`（628 行，24 节）— 长期参考价值高，但与代码差距扩大（如第 13.1 节 cloud tables 完全未实现）。
- `docs/decisions/0001-managed-container-backend.md` — **质量最高的文档**，真实成本估算 + 护栏。
- `docs/development-workflow.md` — 七阶段开发流程（本次新增）。
- `docs/content-authoring.md` — 内容制作指南。

---

## 三、整体进度对照（`AGENTS.md` 第 14 节开工顺序）

| # | 任务 | 状态 | 关键证据 |
|---|---|---|---|
| 1 | Flutter 工程 | ✅ | `apps/mobile/pubspec.yaml` |
| 2 | CI | ✅ | `core-ci.yml` 三 job |
| 3 | Schema + Fixture + validator | ✅ | `content/schema`、`content_validator.dart` |
| 4 | Drift 表 + migration 测试 | ⚠️ 部分 | 6 表完整；migration 测试只验 v1 自洽，无真实迁移 |
| 5 | Journey 外壳 | ✅ | `journey_page.dart`（但纯静态无 ViewModel） |
| 6 | 数据驱动课程步骤 | ⚠️ 有泄漏 | `lesson_overview_page.dart`，只实现 6/9 step 类型 |
| 7 | 持久化练习和掌握度 | ✅ | `lesson_progress_repository.dart` + 集成测试 |
| 8 | 复习分箱算法 | ⚠️ 核心 done | `review_scheduler.dart` + 数据层；**UI 未开始** |
| 9 | 音频/录音/回放/降级 | ❌ 仅占位 | 全是 SnackBar |
| 10 | 点咖啡端到端 | ⚠️ 部分 | 播放器走通，缺音频/语音/复习闭环 |

**里程碑判定**（`AGENTS.md` 第 14 节末段）：真实设备完成课程 ✅、重启保留进度 ✅、**正确时间出现复习 ❌**（无 UI）→ 里程碑**未达成**。

---

## 四、做得好的

1. **`learning_core` 纯函数化 + 测试扎实**——项目最可靠的基石，复习算法可解释、可测。
2. **Drift schema 约束用足 + Repository 全事务化 + Outbox 设计完整**——符合本地优先不变量。
3. **端到端 Widget 测试**（`app_test.dart`）真实跑完整节课并校验 DB 落库，远超一般 MVP。
4. **content_validator 对话可达性、ID 全局唯一、pinyin/汉字对齐**——比同类项目严谨。
5. **CI 把"生成文件必须提交"作为门禁**——防止生成代码漂移。
6. **ADR 0001 是真实可执行的成本决策**，不是模板填空。

---

## 五、需要改进的（按优先级）

### P0 — 阻塞里程碑
1. **复习 UI 完全没开始**（当前下一小模块）。数据层和算法已就绪，缺 presentation + `/review` 路由。
2. **音频/录音是纯占位**——不解决无法达成"说得出"承诺。

### P1 — 架构债（扩大规模前必须纠正）
3. **`lesson_overview_page.dart` 1103 行 + 业务逻辑泄漏到 Widget**——拆成 step 工厂 + 独立 widget，把 attempt 记录移到 Controller。违反自定 MVVM 不变量（`AGENTS.md` 第 6 节）。
4. **纯规则散落在非 domain 层**——`_confidenceFor`、`_compareQueueItems`、`score` 应迁移到 `learning_core` 并补单元测试（`AGENTS.md` 第 12 节要求 `lib/domain`，但该目录不存在）。
5. **`journey_page.dart` 无 ViewModel**——无法接入进度/解锁。

### P2 — 一致性与健壮性
6. **schema 与 validator 不一致**——补 sha256 校验，或在 schema 去掉。
7. **schema 定义 9 种 step 但只实现 6 种**——文档需说明 `image_choice/tone_contrast/order_tokens` 的实现计划。
8. **Go handler `panic`**、**fire-and-forget Future 吞异常**、**State 手动重建易漏字段**。
9. **潜在 bug**：`recordExerciseAttempt` 答错时 `usedHint` 硬编码 false（`lesson_overview_page.dart:262`）。
10. **测试盲点**：`LessonPlayerController` 状态机、`_presentationFor` 各分支、`/readyz` 无测试。

---

## 六、文档与代码的已知偏差

| 文档说法 | 代码实际 |
|---|---|
| `AGENTS.md` 第 12 节：纯规则放 `lib/domain` | `lib/domain` 目录不存在，规则散在 data/presentation |
| `course-package.schema.json`：ready 资产必须有 sha256 | validator 只检查 path，不检查 sha256 |
| schema 定义 9 种 step 类型 | 播放器只实现 6 种 |
| `docs/开发方案.md` 第 13.1 节：cloud tables | `services/api` 无 DB |

这些偏差不一定是 bug——有些是"计划 vs 现状"的正常差距。但应在此文档或 ADR 里明确标注，避免后续 agent 误判。
