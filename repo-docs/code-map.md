# Mandarin Mission 代码地图

本页覆盖仓库的一方运行时代码、内容契约、Agent 工作流和 CI。建议先读 [点咖啡课程的真实运行路径](walkthroughs/one-real-run.md)，再用这里回答“这类修改从哪里开始”。

| 路径 | 职责 | 关键代码 | 与主流程的关系 |
| --- | --- | --- | --- |
| `apps/mobile/lib/app/` | 组装 App 与页面路由 | `MandarinMissionApp`、`appRouterProvider` | 把 Journey、课程和复习三个入口连起来 |
| `apps/mobile/lib/core/` | 保存可执行主题、字体与布局令牌 | `AppLayout`、`AppTextStyles`、`buildAppTheme` | 统一主流程各页面的尺寸和视觉语义 |
| `apps/mobile/lib/data/` | 读取内容、包装媒体、持久化进度、查询复习 | `CourseContentRepository`、`LessonProgressRepository`、`ReviewQueueRepository` | 是课程数据与本地事务的边界 |
| `apps/mobile/lib/features/` | 按 Journey、lesson、review 组织状态与页面 | `LessonPlayerController`、`ReviewSessionController` | 推进 walkthrough 中的用户可见状态 |
| `apps/mobile/lib/shared/` | 提供已复用或正在验证的跨功能 Widget | `AudioPlayerBar`、`RecordingControls`、`AppLeadingRow` | 支撑媒体交互和统一布局 |
| `apps/mobile/integration_test/` | 在真实 Android 设备验证跨层课程、媒体和磁盘恢复 | `m2_device_acceptance_test.dart`、`m2_process_persistence_app.dart` | 逐条播放 M2 音频、跑通课程链路，并用不同 Android 进程读取同一 Drift 文件 |
| `packages/learning_core/lib/` | 保存不依赖 Flutter 的学习规则与内容校验 | `ReviewScheduler`、`ContentValidator` | 决定内容能否进入 App、复习何时到期 |
| `content/` | 保存版本化课程 Fixture、Schema 与 Flutter asset 常量 | `m2-course.json`、`cafe-course.json`、`course-package.schema.json` | 提供默认 M2 Release 与 M1 回归基线 |
| `services/api/` | 提供 Go 容器与最小 HTTP 骨架 | `main`、`httpapi.New` | 当前不进入本地学习闭环，只提供运维端点 |
| `.agents/skills/` | 保存仓库可共享的 Codex 重复工作流 | `verify-mandarin-mission` | 根据 diff 选择风险匹配验证 |
| `.codex/` | 保存可信仓库内的 Codex 配置与工具前护栏 | `config.toml`、`pre_tool_use_policy.py` | 在执行前阻止已知批量删除方式 |
| `tools/scripts/` | 保存人工和 Skill 共用的确定性命令入口 | `verify.ps1` | 统一 mobile/core/content/api/docs 验证 |
| `.github/workflows/` | 执行三条 CI 验证链 | `core-ci.yml` | 检查生成文件、App、规则、内容、API 和镜像 |

## `apps/mobile/lib/app/`

| 重要代码 | 功能 | 关键符号 | 调用方 / 使用方 |
| --- | --- | --- | --- |
| [App 入口组装](../apps/mobile/lib/app/app.dart) | 把 shadcn 主题与 Material 路由外壳组合起来 | `MandarinMissionApp` | `main.dart` |
| [页面路由](../apps/mobile/lib/app/router.dart) | 定义 `/`、`/lessons/:lessonId`、`/review` | `appRouterProvider` | App 外壳、Journey |

最接近的回归入口是 [完整 App Widget 测试](../apps/mobile/test/app/app_test.dart)。

## `apps/mobile/lib/core/`

| 重要代码 | 功能 | 关键符号 | 调用方 / 使用方 |
| --- | --- | --- | --- |
| [布局令牌](../apps/mobile/lib/core/theme/app_layout.dart) | 定义页面宽度、控件高度、间距和圆角 | `AppLayout`、`AppSpacing`、`AppRadius` | 所有页面与共享 Widget |
| [字体语义](../apps/mobile/lib/core/theme/app_text_styles.dart) | 统一标题、正文与中英文字体回退 | `AppTextStyles` | App 主题 |
| [主题组装](../apps/mobile/lib/core/theme/app_theme.dart) | 提供 shadcn 颜色和字体主题 | `buildAppTheme` | `MandarinMissionApp` |

UI 规则的文字入口仍是根目录 `WIDGET_LIBRARY.md` 与 `docs/design-system.md`。

## `apps/mobile/lib/data/`

| 重要代码 | 功能 | 关键符号 | 调用方 / 使用方 |
| --- | --- | --- | --- |
| [内容读取](../apps/mobile/lib/data/content/course_content_repository.dart) | 读取、解析、校验并缓存课程包；默认直接选择 M2 Release，也允许测试显式选择 M1 Café 基线 | `CourseContentRepository`、`bundledM2CourseAsset`、`bundledCafeCourseAsset` | lesson/review providers |
| [内容模型](../apps/mobile/lib/data/content/course_content_models.dart) | 建立按稳定 ID 查询的课程对象、解析 ready 音频、合成独立地点终局，并从当前节点聚合一个可播放对话轮次 | `CoursePackage.locationChallenge`、`CourseDialogue.turnFrom` | Journey、课程与复习 UI |
| [本地数据库](../apps/mobile/lib/data/local/app_database.dart) | 打开 Drift 数据库并声明 schema v1 | `AppDatabase` | data providers、Repositories |
| [本地表契约](../apps/mobile/lib/data/local/tables.dart) | 约束进度、掌握度、尝试、口语与 Outbox | `MasteryStates`、`SyncOutboxEvents` | Drift 生成代码、Repositories |
| [进度写入](../apps/mobile/lib/data/progress/lesson_progress_repository.dart) | 在事务内保存练习、课程完成和 Outbox | `LessonProgressRepository` | lesson/review controllers |
| [复习查询](../apps/mobile/lib/data/review/review_queue_repository.dart) | 查找到期项并按失败与维度排序 | `ReviewQueueRepository` | `ReviewSessionController` |
| [媒体状态入口](../apps/mobile/lib/data/audio/audio_providers.dart) | 注入播放/录音服务与 Controller | `audioControllerProvider`、`recordingControllerProvider` | 媒体 Widget |

修改数据契约时先跑 `apps/mobile/test/data/` 和迁移测试；修改媒体状态先跑 `apps/mobile/test/data/audio/`。

## `apps/mobile/lib/features/`

| 重要代码 | 功能 | 关键符号 | 调用方 / 使用方 |
| --- | --- | --- | --- |
| [Journey 进度](../apps/mobile/lib/features/journey/application/journey_progress.dart) | 汇总课程与地点终局进度，计算先修课程、终局和下一地点是否开放 | `journeyProgressProvider`、`JourneyProgress` | Journey 页面、`lesson_progress_entries` |
| [Journey 页面](../apps/mobile/lib/features/journey/presentation/journey_page.dart) | 按内容包生成普通课程和独立终局卡，并显示锁定、进行中与完成状态 | `JourneyPage`、`_LocationLessonCards` | `/` 路由、Journey 进度 Provider |
| [课程状态](../apps/mobile/lib/features/lesson/application/lesson_providers.dart) | 管理步骤、答题、自评、对话当前节点、提交与完成 | `LessonPlayerController`、`advanceDialogue` | 课程页面 |
| [课程页面](../apps/mobile/lib/features/lesson/presentation/lesson_overview_page.dart) | 按 step type 组合步骤 Widget，并为 `dialogue_turn` 选择发送或终止动作 | `LessonOverviewPage` | lesson 路由 |
| [对话步骤](../apps/mobile/lib/features/lesson/presentation/steps/dialogue_step.dart) | 顺序显示一个或多个系统节点，并为当前 learner 节点提供脱稿自报与 phrase ticket | `DialogueStep` | 课程页面 |
| [复习状态](../apps/mobile/lib/features/review/application/review_providers.dart) | 建立最多 8 项会话并处理补救、失败重试 | `ReviewSessionController` | 复习页面、Journey 摘要 |
| [复习页面](../apps/mobile/lib/features/review/presentation/review_page.dart) | 呈现加载、空、错误、题目与完成状态 | `ReviewPage` | `/review` 路由 |

课程主路径由 [课程端到端测试](../apps/mobile/test/app/app_test.dart) 覆盖，多轮对话由 [对话流程测试](../apps/mobile/test/features/lesson/presentation/dialogue_flow_test.dart) 覆盖，多地点入口由 [Journey 内容驱动测试](../apps/mobile/test/features/journey/journey_page_test.dart) 覆盖，复习主路径由 [复习流程测试](../apps/mobile/test/app/review_flow_test.dart) 覆盖。

## `apps/mobile/lib/shared/`

| 重要代码 | 功能 | 关键符号 | 调用方 / 使用方 |
| --- | --- | --- | --- |
| [媒体播放条](../apps/mobile/lib/shared/presentation/audio_player_bar.dart) | 呈现加载、播放、暂停、进度与错误 | `AudioPlayerBar` | 听力与教学步骤 |
| [录音控件](../apps/mobile/lib/shared/presentation/recording_controls.dart) | 呈现权限、录音、音量、回放和重录 | `RecordingControls` | 口语步骤 |
| [Widget 统一入口](../apps/mobile/lib/shared/presentation/app_widgets.dart) | 导出项目共享 Widget | library exports | 新页面与测试 |
| [布局候选](../apps/mobile/lib/shared/presentation/app_page_layout.dart) | 提供内容框、滚动页与 Section | `AppContentFrame`、`AppPageScrollView` | 当前主要由测试和文档引用 |

`app_page_layout.dart` 尚缺两个真实生产调用点，继续抽象前先核对根目录交接；媒体组件的近期验证入口是 `apps/mobile/test/shared/`。

## `apps/mobile/integration_test/`

| 重要代码 | 功能 | 关键符号 | 调用方 / 使用方 |
| --- | --- | --- | --- |
| [M2 真机验收](../apps/mobile/integration_test/m2_device_acceptance_test.dart) | 使用实际 M2 包和 Android 插件执行跨层验收 | `_playToCompletion`、`_completeThroughController` | Sony `XQ-DQ72`，隔离内存数据库 |
| [M2 磁盘冷启动验收](../apps/mobile/integration_test/m2_process_persistence_app.dart) | 只安装一次验收 APK，首次启动写入隔离 Drift 文件，强制停止后由新进程恢复 | `_bootstrap`、`_seed`、`_verifyDiskState` | Sony `XQ-DQ72`，ADB `force-stop` 与不同 PID |

两个入口都不修改手机的正式学习数据库：前者验证真实设备技术链路，后者验证真实磁盘与进程边界。人工逐页 UX 仍是独立发布门槛。理解课程状态如何写入数据库，可继续阅读[本地学习闭环](modules/local-learning-loop.md)。

## `packages/learning_core/lib/`

| 重要代码 | 功能 | 关键符号 | 调用方 / 使用方 |
| --- | --- | --- | --- |
| [复习规则](../packages/learning_core/lib/src/review_scheduler.dart) | 计算箱位、到期时间和同轮补救 | `ReviewScheduler`、`ReviewState` | App 进度 Repository、复习 providers |
| [内容校验](../packages/learning_core/lib/src/content_validator.dart) | 检查跨对象引用和 JSON Schema 难以表达的规则 | `ContentValidator` | App 内容 Repository、内容 CLI |
| [公开导出](../packages/learning_core/lib/learning_core.dart) | 暴露稳定的纯 Dart API | library exports | Flutter App、测试、CLI |

最接近的验证是 `dart test` 和 [内容验证 CLI](../packages/learning_core/bin/validate_content.dart)。

## `content/`

| 重要代码 | 功能 | 关键符号 | 调用方 / 使用方 |
| --- | --- | --- | --- |
| [M2 Release Fixture](../content/fixtures/m2-course.json) | 定义当前 App 默认加载的 3 地点、12 课、线性先修关系和 53 个 ready 资产 | `cafe-01`—`metro-04`、3 个地点终局 | App 内容 Repository、ContentValidator 与 Journey 测试 |
| [M1 Café Fixture](../content/fixtures/cafe-course.json) | 保留“点咖啡”单课正式基线 | `cafe-01`、稳定 ID | 专项流程与回归测试 |
| [课程 Schema](../content/schema/course-package.schema.json) | 声明课程包结构和允许的 step type | `$defs.lessonStep` | 内容作者、CI 辅助检查 |
| [Flutter asset 常量](../content/lib/mandarin_mission_content.dart) | 提供包内 Fixture 路径 | `MandarinMissionContentAssets` | App 内容 Repository |

修改内容后应从 `packages/learning_core` 运行 `dart run bin/validate_content.dart ../../content/fixtures`。

## `services/api/`

| 重要代码 | 功能 | 关键符号 | 调用方 / 使用方 |
| --- | --- | --- | --- |
| [服务进程入口](../services/api/cmd/api/main.go) | 读取端口与版本，配置超时并优雅退出 | `main`、`envOrDefault` | Cloud Run 容器 |
| [HTTP 路由](../services/api/internal/httpapi/handler.go) | 返回 health、ready 和 meta JSON | `httpapi.New`、`writeJSON` | Go server |
| [handler 测试](../services/api/internal/httpapi/handler_test.go) | 验证 health 与 meta | `TestHealth`、`TestMeta` | CI api job |

当前没有业务接口、数据库、认证或 Outbox 消费。`/readyz` 固定返回 ready；`writeJSON` 编码失败仍会 panic。

## `.github/workflows/`

| 重要代码 | 功能 | 关键符号 | 调用方 / 使用方 |
| --- | --- | --- | --- |
| [Project CI](../.github/workflows/core-ci.yml) | 分别运行 Flutter、learning_core/content、Go/API 验证 | `mobile`、`learning-core`、`api` jobs | push main、pull request |

CI 还会重新生成 Drift 文件并要求 `git diff --exit-code`，防止 schema 与生成代码漂移。

## `.agents/skills/`

| 重要代码 | 功能 | 关键符号 | 调用方 / 使用方 |
| --- | --- | --- | --- |
| [项目验证 Skill](../.agents/skills/verify-mandarin-mission/SKILL.md) | 根据改动区域选择最小验证范围，并要求补充 UI、真机、媒体或资产证据 | `$verify-mandarin-mission` | Codex 与项目维护者 |

Skill 使用 Codex `skill-creator` 的校验器验证；Codex 从仓库根或子目录启动时会扫描根 `.agents/skills/`。

## `.codex/`

| 重要代码 | 功能 | 关键符号 | 调用方 / 使用方 |
| --- | --- | --- | --- |
| [Codex 项目配置](../.codex/config.toml) | 注册 `PreToolUse` 文件安全 Hook | `hooks.PreToolUse` | 可信仓库中的 Codex 会话 |
| [文件安全 Hook](../.codex/hooks/pre_tool_use_policy.py) | 阻止已知递归强制删除命令和多文件删除补丁 | `_blocked_reason` | Codex 工具调用 |

Hook 脚本自带 `--self-test`；项目 Hook 只有在仓库受信任且用户在 `/hooks` 复核当前定义后才运行。

## `tools/scripts/`

| 重要代码 | 功能 | 关键符号 | 调用方 / 使用方 |
| --- | --- | --- | --- |
| [统一验证脚本](../tools/scripts/verify.ps1) | 执行 mobile、core、content、api、docs 或 all 范围 | `Scope`、`BuildApk`、`BuildContainer` | Skill、开发者、本地交付检查 |

脚本语法可用 PowerShell Parser 检查；每个 scope 的结果仍需按 UI、真机、媒体和远端 CI 边界解释。根 `AGENTS.md` 只保存稳定规则和知识路由；`apps/mobile`、`content`、`packages/learning_core`、`services/api` 与 `docs` 使用局部 `AGENTS.md` 追加各自上下文。

## 覆盖范围

- 已覆盖：上表列出的全部一方运行时代码、内容输入、Agent 工作流和 CI 入口。
- 汇总而未展开：Drift 生成文件、迁移快照、Flutter 平台模板；它们由生成门禁或目标平台构建验证。
- 排除：`new-chat/` 研究资料、历史方案与普通项目文档；它们提供背景，不直接决定当前运行行为。
- 暂缓：未来 Neon、R2、身份、订阅和 Azure Speech 适配器，因为对应一方实现尚不存在。

需要理解“为什么这样流动”时返回 [一次真实课程运行](walkthroughs/one-real-run.md)；需要审计结论时查看 [两轮源码证据](references/source-evidence.md)。

证据状态：除特别标注外，本页基于当前源码已确认。
