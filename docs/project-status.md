# Mandarin Mission 项目现状与代码审视

> 本文档是对**已落地代码**的盘点和质量审视，作为后续开发的对照基线。以代码和测试为唯一事实来源，不轻信文档描述。证据格式为 `文件:行号`。
> 维护原则：发现代码与本文档不符时，以代码、测试和运行证据为准并更新本文档（参考根 `AGENTS.md` 的开始任务与知识路由）。
> 最近核对基线：`main@45a2776` + 当前工作树（2026-07-27）；当前工作树继续补齐与 `0.2.0+3` 绑定的隐私数据清单，同时保留 M2 内容完成与公开 MVP 产品完成的边界。

---

## 一、总览

| 模块 | 状态 | 一句话评价 |
|---|---|---|
| 纯 Dart 核心 `packages/learning_core` | ✅ 已实现 | 项目最扎实的部分，纯函数 + 完整测试 |
| 课程内容工程 `content/` | ✅ 已实现 | schema + validator + 默认 M2 Release Fixture + M1 Café 回归 Fixture，校验严谨 |
| 移动端 `apps/mobile` 数据层 | ✅ 已实现 | Drift 6 表约束扎实，Repository 全事务化 |
| 移动端 UI/课程播放器 | ✅ 基线已实现 | shadcn 主题、Journey 和数据驱动 11 步自动流程走通；含简单汉字书写，步骤组件与提交逻辑已分层 |
| 移动端复习功能 | ✅ 本地闭环已实现 | Journey 真实入口、四维题型、自评、补救和失败重试均已接入本地队列 |
| 移动端音频/录音 | ✅ 主路径已实现 | 播放、录音、权限、回放和降级已接线；默认 M2 的正式音频及课程入口已有自动、人工听感和 Sony 真机证据，仅留无 SIM 真实来电边界 |
| App 外壳、客服与法律 | ⚠️ 四个切片完成 | 已有首次引导、Journey/Review/Settings 主导航、偏好/服务状态、帮助/隐私/条款、本地数据清理、版本信息和 `0.2.0+3` 数据清单；真实通知投递、诊断服务、支持/法律资源及完整设置仍缺 |
| 账号与同步 | ❌ 未实现 | 客户端无认证/API 接线；Go 服务无 DB、身份、会话、同步或删除账号 |
| 订阅、分析与完整游戏化 | ❌/⚠️ | 地点解锁和复习已接线；订阅/权益/分析/崩溃未实现，每日任务/连胜/印章未形成真实闭环 |
| Go 后端 `services/api` | ❌ 仅骨架 | 只有 healthz/readyz/meta，无 DB/认证/业务 |
| CI | ✅ 已实现 | 三 job 覆盖 mobile/learning-core/api，有生成文件门禁 |
| 文档 | ✅ 较全 | 开发方案 + 代码优先 UI 系统 + ADR + 分级流程齐全 |

---

## 二、各模块详情

### 1. 纯 Dart 核心 `packages/learning_core` ✅

**已实现**：
- `review_scheduler.dart` — 0–5 分箱调度，纯函数 `apply()`，严格对应 `docs/architecture.md` 的复习算法 v1。interval 表、忘记 −2/模糊不变/记得 +1/hint 不升、同日补救上限 2，全部落地。
- `content_validator.dart`（540 行）— 覆盖：schemaVersion、status 枚举、稳定 ID kebab-case 正则 + 全局去重、location/lesson/item/asset 引用完整性、pinyinSyllables 与汉字数对齐（CJK 区段过滤标点）、对话可达性 + 环检测 + 不可达节点检测、release 资产必须 ready + license/credit。
- `learning_core_base.dart` — `LearningDimension`、`ReviewRating` 两个枚举。

**测试**：`learning_core_test.dart` 119 行，覆盖 remembered/hint/vague/forgotten/补救上限/四维独立/UTC 拒绝。`content_validator_test.dart` 196 行。**这是测试最扎实的模块。**

**审视点（轻）**：
- `content_validator.dart` 只校验 asset 的 `path`，**不校验 `sha256`**——但 `course-package.schema.json:209,217` 要求 ready 资产必须有 sha256。**校验器与 schema 不一致**，二选一对齐。
- 校验器有几条规则（status 非法值、stableId 格式、location 引用未知 lesson、duplicate step id）代码里有但缺专门测试 case。

---

### 2. 内容工程 `content/` ✅

- `schema/course-package.schema.json` — JSON Schema Draft 2020-12，`additionalProperties:false` 全开，定义 10 种 step 类型。
- `fixtures/cafe-course.json` — 1 location / 3 知识点 / 1 lesson（11 步）/ 1 dialogue / 4 assets。咖啡场景图已通过真机构图确认；三条包内 CosyVoice 音频含 path/SHA-256/Apache-2.0 来源与生成参数，并通过整组人工试听、APK 打包和 Sony 真机播放。整个包已升为 `release`。
- `fixtures/m2-course.json` — `0.2.7` / `release`，3 locations / 52 知识点 / 12 lessons / 15 dialogues / 53 ready assets。11 节新增课程和 3 个地点终局已完成英文编辑 Agent、中文教学 Agent 双审及主 Agent 集成，14/14 均复核通过并 language lock；49 条新增普通话音频已完成用户试听、唯一选择、App asset 复制、path/SHA-256/credit 写回、Flutter 资源加载测试与 APK 内哈希核对。Sony `XQ-DQ72` 已逐条完成 49 条新增音频的 Android 播放，通过课程控制器完成 12 课、3 个终局、208 条掌握度状态、一次到期复习和 Provider 重载，并由不同 Android PID 从同一独立 Drift 文件恢复全部记录与解锁。新增范围 14/14 单元人工逐页 UX 已完成。2026-07-26 用户批准后，M2 已成为默认 Provider 输入，旧 `MM_USE_M2_DRAFT` 构建开关已移除；`fixtures/cafe-course.json` 保留作 M1 回归基线。
- `lib/mandarin_mission_content.dart` — 5 行，暴露 asset 路径常量。

**审视点**：
- **schema 定义的 10 种 step 类型均已实现**。2026-07-24 补齐 `image_choice / tone_contrast / order_tokens`，内容契约、错误重试、本地保存、11 步端到端流程、200% 文字缩放、Android 模拟器和 Sony 真机验收通过；完整完成页与冷启动进度保留也已复验。

---

### 3. 移动端 `apps/mobile`

#### 3.1 数据层 ✅（质量良好）

**`data/local/tables.dart`**（106 行）— 6 张表，CHECK 约束用足（`box.isBetweenValues(0,5)`、`sameDayRetryCount.isBetweenValues(0,2)`、enum 字符串集合），索引合理（`mastery_states_due_at` 等）。schemaVersion=1，首版无迁移路径（合理）。

**`data/progress/lesson_progress_repository.dart`**（339 行）— `startLesson/recordExerciseAttempt/recordReviewAttempt/recordSpeakingAttempt/completeLesson` 全部用 `_database.transaction` 包裹，同步 Outbox 一并写入。`completeLesson` 用 `InsertMode.insertOrIgnore` 为每个 item × 4 维度初始化 box 0。**设计正确，符合本地优先不变量。**

**`data/review/review_queue_repository.dart`**（121 行）— `dueItems` 先 SQL 过滤再 Dart 排序，优先级：失败 > listening/tone > 到期时间 > itemId。

**审视点**：
- `dueItems` 在 SQL 层**没有 limit**（`review_queue_repository.dart:42-46`），全表拉回内存再 `.take(limit)`。内容多了之后是性能隐患（MVP 阶段可接受）。
- **纯规则散落在非 domain 层**，偏离 `docs/architecture.md` 的代码边界：
  - `_confidenceFor`（`lesson_progress_repository.dart:326-338`）— forgotten/vague/remembered/hint 四象限 confidence 规则，只通过 Repository 测试间接覆盖，**无单元测试**。
  - `_compareQueueItems`（`review_queue_repository.dart:84-109`）— 复杂排序规则，同样只间接覆盖。
  - 应迁移到 `learning_core` 并补单元测试。

#### 3.2 代码优先 UI 与课程播放器 ✅（基线完成）

- `core/theme/app_theme.dart` 定义 shadcn/Material 共用的语义色、圆角和反馈状态；`core/theme/app_layout.dart` 定义统一 spacing、最大内容宽度、卡片 padding、图标槽和控件高度；`core/theme/app_text_styles.dart` 固定字体尺寸、字重、行高和中文回退；`app/app.dart` 通过 `ShadApp.custom` 保留 Material/go_router 兼容。
- Journey 与课程播放器已经使用 `ShadButton`、`ShadCard`、`ShadBadge`、`ShadProgress` 和 Lucide 图标。
- 根目录 `WIDGET_LIBRARY.md` 是 AI 可直接执行的 UI 对齐与视觉 QA 准则；`app_widgets.dart` 统一导出项目组件。`AppContentFrame`、`AppPageScrollView`、`AppSection`、`AppListRow` 当前仅由测试/文档引用，尚未通过真实生产页面调用验证，不能作为已完成抽象继续扩展。
- 全宽卡片不再使用会分配不稳定空白的 `ShadCard.leading/trailing`，图标与正文统一通过固定槽布局；汉字拼音行按父容器居中。
- `features/lesson/presentation/steps/` 按 scene/teach/hanzi writing/listen/repeat/dialogue/summary 拆分，不再把全部 Widget 塞进一个 1100 行文件。
- `LessonPlayerController` 负责听力尝试、汉字书写自评、口语自评、课程完成、提交中和保存失败；View 只组合展示和转发意图。
- `LessonPlayerState.copyWith` 代替每个动作手工重建全部字段。
- `usedListeningHint` 正确透传到 Repository，`app_test.dart` 增加回归断言。
- Widget 回归覆盖 Journey 共用内容网格及 `768/1024/1280/1440` 逻辑像素宽度；Android 模拟器已复核 Journey、汉字临摹/默写/对照自评、听力反馈、口语重复、降级自评、对话和总结页面。

**剩余审视点**：

- `LessonPlayerState.score` 仍缺独立单元测试；
- schema 定义的 10 种步骤均已实现；新增三种步骤已过模拟器与 Sony 真机；
- 课程通用文案尚未接入 i18n，但内容标题与教学数据继续来自 Fixture；
- `shadcn_ui` 为 `0.x` 依赖，必须按 ADR 0002 单独升级并做截图回归。

#### 3.3 Journey 页 ⚠️（课程、终局、线性解锁与复习已接线）

`journey_page.dart` 已迁移代码优先 UI。课程入口按内容包 location `order` 与 `lessonIds` 生成，标题、步骤数和路由 ID 来自内容；未内嵌的 location `challengeId` 会成为独立终局卡。`journeyProgressProvider` 汇总 `lesson_progress_entries`：先修课完成后开放下一课，四课完成后开放终局，终局完成后开放下一个地点；重新创建 ProviderScope 后仍从数据库恢复。默认 M2 Release Fixture 显示 Café、Market、Metro 的 12 节课和 3 个地点终局。到期复习摘要也来自真实队列；连胜和每日任务仍是静态外壳。

#### 3.4 复习功能 ✅（本地闭环）

- `features/review/application/review_providers.dart` 提供到期摘要、8 项必做会话上限、异步加载、逐项保存和保存失败重试状态。
- `features/review/presentation/` 与 `/review` 路由覆盖 `meaning/listening/tone/hanzi` 四维题型、忘记/模糊/记得反馈、同轮补救、空队列和完成态。
- Journey 直接查询真实到期队列，并把超出必做上限的项目显示为额外巩固。
- 课程与复习 listening 题都从内容元数据解析同一条 `ready` 音频路径；只有 planned/缺失资产才进入书面降级并记录 `usedHint`。

#### 3.5 测试覆盖

| 测试 | 质量 |
|---|---|
| `app_test.dart`（端到端跑完整节课、校验落库与提示透传） | ⭐ 优秀 |
| `learning_core_test.dart` | ⭐ 扎实 |
| Repository 各测试 | ✅ 良好 |
| `review_provider_test.dart` + `review_flow_test.dart` | ⭐ 扎实；真实内存 DB 覆盖四维写入、Outbox、失败重试、补救、空/错误态与响应式布局 |
| `LessonPlayerController` 状态机 | ⚠️ 仅覆盖汉字书写保存失败，其余动作缺独立单元测试 |
| 各 step presentation 组件 | ⚠️ 汉字书写有独立状态/无障碍/200% 字号测试，其余多依赖端到端覆盖 |

#### 3.6 音频/录音 ⚠️（核心架构已实现）

- `data/audio/` 已提供音频与录音 Service、Riverpod Provider 和 Controller；UI 已接入播放进度、权限说明、录音时长、dBFS 音量归一化、回放、重录和不可用降级。
- `record` 固定为与 Flutter 3.44 / Dart 3.12 匹配的 `7.1.1`；`record_linux 2.1.1` 与 `record_platform_interface 2.1.0` 已消除旧版传递依赖冲突。
- 课程播放器从 `knowledgeItems[].audioAssetId` 解析 `assets[].path`；资源不是 `ready` 时明确显示不可用，不硬编码或伪造音频存在。
- 课程页在 App 进入非 `resumed` 状态或页面离开时结束媒体会话，停止播放器、取消录音或回放并清理当前临时文件；重录前也会删除旧文件。
- 播放、录音和录音回放失败后会在当前步骤显示对应重试按钮：课程播放重用当前 asset 路径，录音重新进入录制状态，录音回放保留当前临时文件并重试同一路径，不要求用户退出课程。
- 用户普通拒绝麦克风权限后会看到独立拒绝状态、再次授权入口和无录音自评说明；它不会再退回成看似从未请求过的初始权限卡。
- 三条 CosyVoice WAV 已放入 `assets/audio/cosyvoice/`，使用 `CosyVoice-300M-SFT` 内置 `中文女`、seed 1986，速度为 0.94/0.89；内容资产记录了路径、SHA-256、Apache-2.0 来源、合成文本差异和 PCM16 兼容转换。文件为 22.05 kHz/16-bit/mono，未使用真人克隆或声学后处理。
- 自动验证：Flutter format、analyze、49 tests、debug APK 通过；包含 6 项媒体组件 Widget 测试、6 项录音 Controller 测试、1 项课程媒体生命周期 Widget 测试和 ready 音频路径解析测试。
- 新 CosyVoice APK 已安装到 Sony `XQ-DQ72`；“我要”、“咖啡”和“我要一杯咖啡”均从真实课程入口播放，Android 日志确认 22.05 kHz 单声道音轨正常完成并释放音频焦点。
- Sony `XQ-DQ72` 已在课程第 6 步验证首次授权、普通拒绝/重试、永久拒绝/设置恢复、录音/回放/重录、Home 和步骤返回清理。
- 尚未完成：真实来电中断/恢复；该 Sony 无 SIM，来电分支当前无法执行。服务不可用分支已由自动测试覆盖，但没有可控的真机制造证据。

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

- `docs/开发方案.md` — 长期参考价值高，但与代码差距扩大（如第 13.1 节 cloud tables 完全未实现）。
- `docs/decisions/0001-managed-container-backend.md` — **质量最高的文档**，真实成本估算 + 护栏。
- `docs/development-workflow.md` — 代码优先、按 S/M/L 分级的六阶段开发流程。
- 根目录 `WIDGET_LIBRARY.md` — AI 调用 Widget 库、令牌、系统性对齐修复和响应式视觉 QA 的执行准则。
- `docs/design-system.md` — shadcn 语义令牌、组件白名单、页面状态与升级规则。
- `docs/handoff/ai-agent-handoff.md` — 当前环境、架构、里程碑、协作边界和新 agent 开工入口。
- `docs/decisions/0002-code-first-shadcn-ui.md` — UI 流程和依赖决策。
- `docs/content-authoring.md` — 内容制作指南。

---

## 三、整体进度对照（根 `HANDOFF.md` 的当前里程碑）

| # | 任务 | 状态 | 关键证据 |
|---|---|---|---|
| 1 | Flutter 工程 | ✅ | `apps/mobile/pubspec.yaml` |
| 2 | CI | ✅ | `core-ci.yml` 三 job |
| 3 | Schema + Fixture + validator | ✅ | `content/schema`、`content_validator.dart` |
| 4 | Drift 表 + migration 测试 | ⚠️ 部分 | 6 表完整；migration 测试只验 v1 自洽，无真实迁移 |
| 5 | Journey 外壳 | ✅ | shadcn 视觉、真实到期摘要、课程/终局进度和 Café → Market → Metro 线性解锁已接线；连胜/每日任务待后续接线 |
| 6 | 数据驱动课程步骤 | ✅ 已实现 | 10/10 step 类型已实现，并通过自动测试、Android 模拟器与 Sony 真机验收 |
| 7 | 持久化练习和掌握度 | ✅ | `lesson_progress_repository.dart` + 集成测试 |
| 8 | 复习分箱算法与本地 UI | ✅ | `review_scheduler.dart`、队列、Journey 入口和四维会话闭环 |
| 9 | 音频/录音/回放/降级 | ✅ 主路径完成 | CosyVoice 音频放行、Sony 真机播放、权限、录音/回放与降级通过；仅留无 SIM 来电边界 |
| 10 | 点咖啡端到端 | ✅ 已实现 | Sony 已通过 11 步课程、冷启动进度保留、到期复习、飞行模式与最终内容音频放行 |
| 11 | M2 可玩内容 | ✅ 已实现 | 默认 3 个地点、12 节课、3 个终局已通过内容、资产、自动化和 Sony 逐页验收 |
| 12 | App 外壳、设置、客服、隐私/条款和数据管理 | ⚠️ 本地控制与披露切片完成 | `features/onboarding/` 与 `features/settings/` 已进入生产路径；通知和可选诊断选择可在本机持久化/撤回，Privacy 页面展示 `0.2.0+3` 数据清单且仍如实标出服务未接入；真实通知投递、诊断服务、支持/法律资源和完整客服仍缺 |
| 13 | 账号、同步与删除 | ❌ | Go API 只有 3 个非业务端点，客户端无远端接线 |
| 14 | 订阅、分析、崩溃、每日任务/连胜/印章 | ❌/⚠️ | 仅地点解锁和本地学习数据可用 |
| 15 | 6 个地点、约 30 节公开 MVP及完整发布质量 | ❌ | 当前只有 3 个地点、12 节；跨平台、购买、弱网、无障碍和客服运营未验收 |

**里程碑判定**：M1 与 M2 的本地学习/内容里程碑已达成；这不等于公开 MVP 已完成。当前必须按 [`docs/requirements/public-mvp-completion.md`](requirements/public-mvp-completion.md) 补齐 App 产品，G1—G6 关闭前不进入商店发布阶段。

---

## 四、做得好的

1. **`learning_core` 纯函数化 + 测试扎实**——项目最可靠的基石，复习算法可解释、可测。
2. **Drift schema 约束用足 + Repository 全事务化 + Outbox 设计完整**——符合本地优先不变量。
3. **端到端 Widget 测试**（`app_test.dart`）真实跑完整节课并校验 DB 落库，远超一般 MVP。
4. **content_validator 对话可达性、ID 全局唯一、pinyin/汉字对齐**——比同类项目严谨。
5. **CI 把"生成文件必须提交"作为门禁**——防止生成代码漂移。
6. **ADR 0001 是真实可执行的成本决策**，不是模板填空。
7. **UI 已形成可执行单一来源**——主题令牌在代码中，组件边界与升级规则在设计系统和 ADR 中。

---

## 五、需要改进的（按优先级）

### P0 — 阻塞里程碑
1. **信任外壳仍未闭环**——首次引导、主导航、偏好/服务状态页、本地通知/诊断选择、版本化数据清单、信任状态页和本地数据清理已落地；真实通知投递与诊断服务、客服/法律资源、完整偏好与新外壳真机验收仍是公开产品门禁。
2. **账号全生命周期与同步缺失**——无身份、会话、匿名迁移、跨设备同步、退出或删除账号，后端仍是骨架。
3. **公开 MVP 功能范围未完成**——内容只有 3 个地点/12 节；订阅、分析、崩溃、每日任务、连胜和印章未完成。
4. **系统级产品验收未开始**——购买/恢复、弱网、升级迁移、无障碍、跨平台、安全、客服和封闭测试均没有完整证据。

### P1 — 架构债（扩大规模前必须纠正）
5. **纯规则散落在非 domain 层**——`_confidenceFor`、`_compareQueueItems`、`score` 应迁移到 `learning_core` 并补单元测试。
6. **Journey 动态状态仍只完成一部分**——课程完成、地点终局、线性解锁与到期摘要已接线；连胜和每日任务仍是静态外壳。

### P2 — 一致性与健壮性
7. **schema 与 validator 不一致**——补 sha256 校验，或在 schema 去掉。
8. **Go handler `panic`**，`/readyz` 仍缺测试。
9. **测试盲点**：除汉字书写外，`LessonPlayerController` 状态机、各 step 独立状态和 Golden 回归仍不足。

---

## 六、文档与代码的已知偏差

| 文档说法 | 代码实际 |
|---|---|
| `docs/architecture.md`：纯规则放 `lib/domain` | `lib/domain` 目录不存在，规则散在 data/presentation |
| `course-package.schema.json`：ready 资产必须有 sha256 | validator 只检查 path，不检查 sha256 |
| schema 定义 10 种 step 类型 | 播放器已实现 10 种；新增三种已有自动测试、模拟器和 Sony 真机证据 |
| `docs/开发方案.md` 第 13.1 节：cloud tables | `services/api` 无 DB |
| `docs/开发方案.md` 规划 onboarding、账号、同步、订阅等公开 MVP 能力 | 生产 App 目前只有 Journey、课程和复习 Feature |

这些偏差不一定是 bug——有些是"计划 vs 现状"的正常差距。但应在此文档或 ADR 里明确标注，避免后续 agent 误判。
