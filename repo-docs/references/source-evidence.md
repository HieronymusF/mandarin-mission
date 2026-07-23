# Mandarin Mission 源码证据

本页记录中文 repo guide 的取证过程。它用于审计文档结论，不承担主流程教学。

## Evidence Traversal Log

| Pass | 检查范围 | 得到的结论 | 改变或限制了什么说法 |
| --- | --- | --- | --- |
| Pass 1 | App 入口与路由、课程内容加载、课程 Controller、Drift Repository、复习调度、端到端测试 | “点咖啡”课程从包内 JSON 出发，经运行时校验和 Riverpod 状态流，最终在一个本地事务中写入课程进度、四维掌握度和 Outbox；Journey 从同一数据库读取到期复习 | 主 walkthrough 可以追踪完整本地闭环，但不能把尚未接入的 Go API 写进这条运行路径 |
| Pass 2 | 内容校验反例、调度边界、重复完成、媒体状态与测试、CI、Go handler、全仓一方源码目录 | 内容引用、稳定 ID、对话可达性和 release 资产状态有校验；调度要求 UTC 并限制箱位与同日补救；Kokoro TTS 开发占位已打包，媒体仍有本地降级，Sony 真机主路径、权限分支、Home 和步骤返回生命周期已通过，但最终音色和真实来电恢复未完成；CI 分为 mobile、learning-core、api 三个 job | 文档必须把许可/打包证据、已通过的真机主路径与仍未完成的听感/真机分支分开，把 `services/api` 标为独立骨架，并明确生成文件、研究资料与当前主流程的边界 |

## 理解摘要

| 字段 | 当前证据支持的答案 |
| --- | --- |
| 场景 | 英语使用者从 Journey 打开 `cafe-01`，完成八个课程步骤，再回到 Journey 等待四维复习到期 |
| 输入 | 包内 [点咖啡课程数据](../../content/fixtures/cafe-course.json)；当前为 `schemaVersion: 1`、`status: draft`、版本 `0.1.3` |
| 成功输出 | `lesson_progress_entries` 变为 `completed`；三个知识点各建立四个 `mastery_states`；答题与课程事件进入 `sync_outbox_events` |
| 难点 | 一次学习动作要同时保持内容引用有效、UI 状态可恢复、本地事务一致、四个学习维度独立调度，并在媒体或网络能力缺失时仍能完成课程 |
| 边界或失败 | 无效内容在建模前被拒绝；保存失败保留当前步骤并提供重试；非 UTC 调度输入抛错；`planned` 或缺失音频返回不可用；开发占位音频在最终听感审核前不能把内容包升为 `release` |
| Falsifying check | 若 [端到端课程测试](../../apps/mobile/test/app/app_test.dart) 不再得到 1 条 completed 进度、12 条掌握度、4 条复习尝试和 6 条 Outbox 事件，本 guide 对本地闭环的描述就需要重查 |
| 下一位读者最可能追问 | “云同步在哪里？”当前答案是：Outbox 已写入，但 [Go API](../../services/api/internal/httpapi/handler.go) 只有健康、就绪和元数据端点，消费与同步尚未实现 |

## 覆盖范围

已检查的一方实现区域：

- `apps/mobile/lib/app/`、`core/`、`data/`、`features/`、`shared/`
- `packages/learning_core/lib/` 与对应测试
- `content/lib/`、`content/fixtures/`、`content/schema/`
- `services/api/cmd/`、`services/api/internal/` 与对应测试
- `.github/workflows/`

相邻但未作为主流程逐行追踪的区域：

- `apps/mobile/lib/data/local/app_database.g.dart` 是 Drift 生成代码，只核对其由 schema 生成且受 CI diff 门禁保护。
- `apps/mobile/test/drift/generated/` 是迁移测试快照，作为生成产物汇总处理。
- `new-chat/` 是产品研究与方案材料，不是运行时代码。
- `docs/`、`AGENTS.md`、`HANDOFF.md` 用于项目约束和当前状态；实现结论仍以代码、数据和测试为准。
- Android/iOS 平台工程只核对了音频权限相关入口和构建门禁，没有在本轮逐文件解释原生模板。

## 结论与证据

| Claim | Evidence | Confidence | Caveat | Used by |
| --- | --- | --- | --- | --- |
| App 从 Journey 进入 `cafe-01`，课程结束后返回 Journey 并显示持久化完成状态 | [路由定义](../../apps/mobile/lib/app/router.dart)、[Journey 入口](../../apps/mobile/lib/features/journey/presentation/journey_page.dart)、[课程页面](../../apps/mobile/lib/features/lesson/presentation/lesson_overview_page.dart)、[端到端测试](../../apps/mobile/test/app/app_test.dart) | 已确认 | Journey 仍是单地点外壳；连胜、解锁和每日任务未接线 | walkthrough、code map |
| 课程包在建模前读取 JSON 并执行交叉引用校验 | [内容 Repository](../../apps/mobile/lib/data/content/course_content_repository.dart)、[内容校验器](../../packages/learning_core/lib/src/content_validator.dart) | 已确认 | 运行时没有直接执行 JSON Schema；Schema 与 validator 仍有 `sha256` 差异 | walkthrough、内容模块 |
| 当前 Fixture 有 1 地点、3 知识点、1 课程、8 步、1 对话和 4 资产 | [点咖啡课程数据](../../content/fixtures/cafe-course.json) | 已确认 | 数据包是 `draft`；图片 planned，3 个音频为 Kokoro TTS 开发占位且最终音色待替换或审核 | README、walkthrough、内容模块 |
| 课程答题与完成通过 Drift 事务写入本地数据和 Outbox | [进度 Repository](../../apps/mobile/lib/data/progress/lesson_progress_repository.dart)、[本地表定义](../../apps/mobile/lib/data/local/tables.dart) | 已确认 | Outbox 尚无远端消费者 | walkthrough、本地闭环模块 |
| 完成课程会为 3 个知识点分别建立 4 个学习维度，共 12 条掌握度 | [完成课程实现](../../apps/mobile/lib/data/progress/lesson_progress_repository.dart)、[端到端断言](../../apps/mobile/test/app/app_test.dart) | 已确认 | 重复完成会提前返回，避免重复初始化 | walkthrough、本地闭环模块 |
| 复习采用 0—5 箱，间隔为 10 分钟、1/3/7/14/30 天 | [复习调度器](../../packages/learning_core/lib/src/review_scheduler.dart)、[调度测试](../../packages/learning_core/test/learning_core_test.dart) | 已确认 | `ReviewQueueRepository` 的排序规则仍在 App data 层 | 本地闭环模块、glossary |
| 复习入口从本地到期队列读取，单次必做上限为 8 | [复习 Provider](../../apps/mobile/lib/features/review/application/review_providers.dart)、[复习流程测试](../../apps/mobile/test/app/review_flow_test.dart) | 已确认 | 超出部分显示为可选巩固 | walkthrough、本地闭环模块 |
| `ready` 音频路径必须由 `audioAssetId` 解析，课程与复习 listening 题共用该路径；`planned` 或缺失资源进入书面降级并记录提示 | [内容模型](../../apps/mobile/lib/data/content/course_content_models.dart)、[复习 Provider](../../apps/mobile/lib/features/review/application/review_providers.dart)、[复习流程测试](../../apps/mobile/test/app/review_flow_test.dart) | 已确认 | 当前 Kokoro 音频只是开发占位；Sony 真机播放已通过，最终音色和普通话人工试听尚未完成 | walkthrough、媒体模块 |
| 媒体 UI 区分播放状态、资产降级、权限分支、服务不可用、录音和回放 | [媒体组件测试](../../apps/mobile/test/shared/presentation/media_controls_test.dart)、[媒体 Controller 测试](../../apps/mobile/test/data/audio/audio_controller_test.dart) | 已确认 | Sony 真机已覆盖授权、普通/永久拒绝、设置返回恢复、录音、音量提示、回放、重录、Home 和步骤返回清理；服务不可用真机分支及来电恢复仍待验证 | 媒体模块、quality review |
| 本地学习闭环跨冷启动保留，并可在飞行模式完成 | [进度 Repository](../../apps/mobile/lib/data/progress/lesson_progress_repository.dart)、[Journey 页面](../../apps/mobile/lib/features/journey/presentation/journey_page.dart)、[复习流程](../../apps/mobile/lib/features/review/application/review_providers.dart) | 已确认 | Sony 真机完成课程、覆盖安装/冷启动、8 项必做复习保存和飞行模式完整课程；2 项可选巩固按设计保留 | walkthrough、本地学习闭环 |
| Go 服务当前只提供 `/healthz`、`/readyz`、`/v1/meta` | [HTTP handler](../../services/api/internal/httpapi/handler.go)、[handler 测试](../../services/api/internal/httpapi/handler_test.go) | 已确认 | `/readyz` 仍是固定 ready；无 DB、认证、同步或语音代理 | code map、README |
| CI 会验证生成文件、Flutter、纯 Dart 内容与调度、Go API 和容器构建 | [Project CI](../../.github/workflows/core-ci.yml) | 已确认 | 本轮只检查了 workflow 定义；未在此次文档构建中重跑整套 CI | README、code map |

## 会改变当前解释的检查

以下任何一项出现，都应触发 repo-docs 同步：

1. `cafe-course.json` 的步骤数、知识点或资产状态变化。
2. `LessonProgressRepository.completeLesson` 不再原子写入进度、掌握度与 Outbox。
3. Go API 开始消费 Outbox 或参与课程/复习主路径。
4. Kokoro TTS 通过普通话人工试听，或 Android 真机补齐服务不可用与来电中断/恢复验收。
5. `app_test.dart`、`review_flow_test.dart` 或 CI 命令改变主闭环的可观察结果。

证据状态：除特别标注外，本页基于当前源码已确认。
