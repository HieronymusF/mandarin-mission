# Mandarin Mission 源码证据

本页记录中文 repo guide 的取证过程。它用于审计文档结论，不承担主流程教学。

## Evidence Traversal Log

| Pass | 检查范围 | 得到的结论 | 改变或限制了什么说法 |
| --- | --- | --- | --- |
| Pass 1 | App 入口与路由、课程内容加载、课程 Controller、Drift Repository、复习调度、端到端测试 | “点咖啡”课程从包内 JSON 出发，经运行时校验和 Riverpod 状态流，最终在一个本地事务中写入课程进度、四维掌握度和 Outbox；Journey 从同一数据库读取到期复习 | 主 walkthrough 可以追踪完整本地闭环，但不能把尚未接入的 Go API 写进这条运行路径 |
| Pass 2 | 内容校验反例、调度边界、重复完成、媒体状态与测试、CI、Go handler、全仓一方源码目录 | 内容引用、稳定 ID、对话可达性和 release 资产状态有校验；调度要求 UTC 并限制箱位与同日补救；包内 CosyVoice 音频已通过许可、哈希、人工试听、APK 打包和 Sony 真机播放，媒体仍有本地降级；真实来电恢复因设备无 SIM 未完成；CI 分为 mobile、learning-core、api 三个 job | 文档必须把文件许可/哈希/打包证据、人工听感证据与仍未完成的真机平台边界分开，把 `services/api` 标为独立骨架，并明确生成文件、研究资料与当前主流程的边界 |
| Pass 3 | M2 内容选择、终局合成、Journey 解锁、持久化测试、Debug APK 与模拟器冒烟 | 默认构建继续使用 Café Release；`MM_USE_M2_DRAFT` 构建才显示 M2。四课完成开放终局，终局完成沿用课程进度表并开放下一地点 | 可以把 M2 写成“draft-only 可达”，但不能把一个音频的模拟器播放冒烟扩大为 49 条运行时播放或完整设备验收 |
| Pass 4 | Sony 真机集成测试、M2 初始 Journey 截图、默认 Café 恢复与移动端全量回归 | 49 条新增音频均在 Android 播放链从 `playing` 到 `stopped`；12 课、3 个终局、208 条掌握度状态、一次到期复习和 Provider 重载通过；M2 初始锁定界面正确，随后已用 `install -r` 恢复默认 Café Debug | 可以关闭 M2 真机技术播放与控制器闭环，但仍要把人工逐页 UX、真实进程冷启动和发布批准列为独立边界 |
| Pass 5 | M2 磁盘验收入口、Sony 两次启动 PID、Drift 文件、Journey UI hierarchy 与截图 | 首次 PID `21038` 写入 15 条完成记录、208 条掌握度和一次复习；`force-stop` 后 PID 为空，第二次 PID `21209` 从同一文件恢复全部记录、解锁和真实完成页面 | 可以关闭真实磁盘/进程冷启动门禁；人工逐页 UX 与发布批准仍是独立边界 |
| Pass 6 | Sony Café 02—03 逐页截图、共享步骤 Widget 失败/通过测试、双专业 Agent 复核、最终 M2 APK | 共享教学卡、听辨/排序反馈、对话状态支持和总结页不再写死或推断 Café 01 语义；Café 02 Step 4—10 与 Café 03 Step 1—10 在真机通过 | 只能确认 Café 02—03 的逐页 UX；Café 04 及后续课程/终局仍是独立发布边界 |
| Pass 7 | Sony Café 04 Step 1—10、`scene_intro` 修复前后截图、Market/Metro Widget 回归、双专业 Agent 复核与 M2 Draft `0.2.7` APK | 场景引入只呈现 location Badge 与 authored `step.text`，不再写死 Café 01 内容或从地点名推导场景句；Café 04 全课在真机通过并解锁 Café final challenge | 只能把人工逐页 UX 扩展到 Café 02—04；地点终局、Market、Metro 与发布批准仍是独立边界 |
| Pass 8 | Sony Café final challenge 的 5 个 learner 回合、phrase ticket 状态、总结页、返回 Journey 与 Market 01 Step 1 截图 | 每个 learner 回合动作门禁正确重置；终局完成记录持久化为 `Completed`，并按先修规则开放 Market 01 | 可以关闭 Café 地点的人工逐页 UX；Market、Metro、两个地点终局与发布批准仍是独立边界 |
| Pass 9 | Sony Market 01 Step 1—11、五条教学音频入口、听辨/语序正确路径、无录音降级、两轮 learner 对话、总结页与返回 Journey 截图 | 五张教学卡和长句无溢出；练习反馈与对话动作门禁正确；Market 01 完成后 Market 02 开放且 Market 03 继续锁定 | 可以关闭 Market 01 的人工逐页 UX；Market 02—04、Market final challenge、Metro 01—04、Metro final challenge 与发布批准仍是独立边界 |
| Pass 10 | Sony Market 02 Step 1—10、四条教学音频入口、听辨/语序正确路径、无录音降级、单轮 learner 对话、总结页与返回 Journey 截图 | 四张教学卡和完整长句无溢出；听辨、排序、phrase ticket 与终止回复正确；Market 02 完成后 Market 03 开放且 Market 04 继续锁定 | 可以关闭 Market 02 的人工逐页 UX；Market 03—04、Market final challenge、Metro 01—04、Metro final challenge 与发布批准仍是独立边界 |
| Pass 11 | Sony Market 03 Step 1—11、五条教学音频入口、听辨/语序正确路径、无录音降级、两轮 learner 对话、总结页与返回 Journey 截图 | 五张教学卡和完整长句无溢出；7 次 AudioTrack、听辨、排序、phrase ticket、每轮动作门禁与终止回复正确；Market 03 完成后 Market 04 开放且地点终局继续锁定 | 可以关闭 Market 03 的人工逐页 UX；Market 04、Market final challenge、Metro 01—04、Metro final challenge 与发布批准仍是独立边界 |
| Pass 12 | Sony Market 04 Step 1—10、四条教学音频入口、听辨/语序正确路径、无录音降级、两轮 learner 对话、总结页、返回 Journey 与 Market final challenge Step 1 截图 | 四张教学卡无溢出；6 次 AudioTrack、听辨、排序、phrase ticket 和每轮动作门禁正确；学习者“谢谢。”终止后直接进入总结；Market 04 完成后地点终局开放且 Metro 01 继续锁定 | 可以关闭 Market 04 的人工逐页 UX；Market final challenge、Metro 01—04、Metro final challenge 与发布批准仍是独立边界 |
| Pass 13 | Sony Market final challenge 的 6 个 learner 回合、连续 system 节点、phrase ticket 状态、总结页与返回 Journey 截图 | 每个 learner 回合动作门禁都重新锁定；“三块。”后的“这个可以吗？”按同轮连续 system 节点呈现；学习者“谢谢。”终止后进入 `Market challenge complete`，Market 终局持久化为 `Completed` 并开放 Metro 01 | 可以关闭 Market 地点的人工逐页 UX；Metro 01—04、Metro final challenge 与发布批准仍是独立边界 |
| Pass 14 | Sony Metro 01—04 共 43 个步骤、教学/听辨/跟读音频入口、听辨/语序正确路径、四次无录音自评、2/2/3/3 个 learner 对话、总结页与逐课 Journey 截图 | 27 个教学/听辨/跟读入口均逐项触发；长句卡片与总结页无溢出；系统/学习者终止、每轮门禁重置和 Metro 01 → 04 线性解锁正确 | 可以关闭四节 Metro 课程的人工逐页 UX；Metro final challenge 与发布批准仍是独立边界。最终 logcat 环形缓冲不能用于重建 27 次完整 AudioTrack 创建计数 |
| Pass 15 | Sony Metro final challenge 的 8 个 learner 回合、phrase ticket 状态、总结页、最终 Journey UI hierarchy 与截图、清空后的 PID logcat | 询路、购票、问线路与请求重复完整走通；每个 learner 回合动作门禁都重新锁定；“明白了。”终止后进入 `Metro challenge complete`，最终 Journey 的 12 课与 3 个地点终局全部为 `Completed`；rendering/fatal 模式计数为 0 | 新增范围 14/14 单元人工逐页 UX 已关闭；默认 Provider 与 `release` 仍需单独产品批准，本轮未改代码、未录音、未重跑自动化门禁 |
| Pass 16 | 用户发布决定、M2 Fixture 状态与名称、默认 Repository、内容/核心/移动端门禁、Release APK | `m2-course.json` 现为 `0.2.7` / `release`；默认 Repository 直接加载 M2，Draft 编译开关已移除；内容校验 2 包、核心 23 tests、移动端 68 tests 与 Release APK 构建通过 | 可以把 M2 写成默认正式内容包；本轮没有连接真机，APK 仍使用 debug key，且未提交、推送或发布 GitHub Release |
| Pass 17 | App 生产路由与 Feature、客户端依赖、Android manifest、Go handler、README 公开 MVP 范围 | 生产 App 只有 Journey/课程/复习，客户端没有远端认证或支付接线，Go API 只有健康/就绪/元数据；公开 MVP 另有设置/客服/法律、账号/同步/删除、订阅、分析/崩溃、完整游戏化和 6 个地点/约 30 节要求 | M2 Release 与 GitHub Pre-release 只能表述为可玩内容原型完成，不能推导为公开 MVP 或商店候选；当前下一步必须是 App 产品完成门禁 |
| Pass 18 | Settings 生产路由、主导航、包信息/外链边界、本地数据清理、Widget/Repository 测试、Debug APK 与 Android 模拟器 UI hierarchy | Journey/Review/Settings 主导航和设置首切片已进入生产路径；未配置真实资源时没有假外链；清理动作删除学习者数据并保留课程包；77 个 Flutter 测试与 Debug APK 通过 | 只能关闭设置与信任中心首切片的自动门禁和模拟器视觉；真实支持/法律资源、完整 G1/G2、Sony 真机和公开 MVP 仍未关闭 |
| Pass 19 | 首次使用生产门禁、异步偏好存储、Settings 重看路由、Widget 测试、Debug APK、Android 模拟器冷启动与 UI hierarchy | 首次启动只显示引导；完成后进入 Journey 并在新进程启动时保持完成；Settings 重看不改写标记；83 个 Flutter 测试与 Debug APK 通过 | 可以关闭首次引导首切片的自动门禁和 Android 模拟器视觉；Sony 真机、完整设置、真实支持/法律资源与完整 G1/G2 仍未关闭 |
| Pass 20 | 通知/诊断偏好 Store 与 Controller、Settings Widget 测试、89 个 Flutter 测试、Debug APK、Android 模拟器跨进程恢复与 UI hierarchy | 两个选择默认关闭，写入成功后更新；读取/保存失败不虚报成功；开启和撤回均跨 App 进程保留，44×44dp 开关语义在模拟器可点击；页面没有请求通知权限或发送诊断数据 | 可以关闭本地选择控制的自动门禁和模拟器视觉；通知投递、分析/崩溃服务、逐版本数据披露、Sony 真机和完整 G1/G2 仍未关闭 |
| Pass 21 | `privacy_data_inventory.dart`、Privacy 页面、Drift/Shared Preferences/录音生命周期、Android/iOS 平台声明、客户端依赖、Go handler、版本与 Widget 测试、93 个 Flutter 测试、Debug APK、Android 模拟器页面/UI hierarchy/日志 | `0.2.0+3` 清单明确区分本机学习数据、临时录音、当前不发送的数据和清除边界；清单版本与 `pubspec.yaml` 绑定；模拟器可从 Privacy 顶部滚到未发布政策状态且无 overflow/FlutterError/fatal | 可以关闭当前 Android 源码的 App 内数据清单、自动门禁和模拟器视觉；正式隐私政策、商店披露、iOS、真实通知/诊断服务、Sony 真机和完整 G2 仍未关闭 |

## 理解摘要

| 字段 | 当前证据支持的答案 |
| --- | --- |
| 场景 | 英语使用者从 Journey 打开 `cafe-01`，完成十一个课程步骤，再回到 Journey 等待四维复习到期 |
| 输入 | 默认包内 [M2 正式课程数据](../../content/fixtures/m2-course.json)；当前为 `schemaVersion: 1`、`status: release`、版本 `0.2.7`。本页以其中 `cafe-01` 作为最小代表案例 |
| 成功输出 | `lesson_progress_entries` 变为 `completed`；三个知识点各建立四个 `mastery_states`；答题与课程事件进入 `sync_outbox_events` |
| 难点 | 一次学习动作要同时保持内容引用有效、UI 状态可恢复、本地事务一致、四个学习维度独立调度，并在媒体或网络能力缺失时仍能完成课程 |
| 边界或失败 | 无效内容在建模前被拒绝；保存失败保留当前步骤并提供重试；非 UTC 调度输入抛错；`planned` 或缺失音频返回不可用；开发占位音频在最终听感审核前不能把内容包升为 `release` |
| Falsifying check | 若 [端到端课程测试](../../apps/mobile/test/app/app_test.dart) 不再得到 1 条 completed 进度、12 条掌握度、7 条复习尝试和 9 条 Outbox 事件，本 guide 对本地闭环的描述就需要重查 |
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
| Journey 按 location `order` 与 `lessonIds` 生成课程入口；先修课程、地点终局和下一地点都由持久化完成状态决定 | [Journey 进度](../../apps/mobile/lib/features/journey/application/journey_progress.dart)、[Journey 入口](../../apps/mobile/lib/features/journey/presentation/journey_page.dart)、[课程页面](../../apps/mobile/lib/features/lesson/presentation/lesson_overview_page.dart)、[解锁与持久化测试](../../apps/mobile/test/features/journey/journey_page_test.dart)、[端到端测试](../../apps/mobile/test/app/app_test.dart) | 已确认 | 默认 M2 Release 有 12 节课与 3 个独立终局；连胜和每日任务仍未接线 | walkthrough、code map、内容模块、本地闭环模块 |
| 课程包在建模前读取 JSON 并执行交叉引用校验 | [内容 Repository](../../apps/mobile/lib/data/content/course_content_repository.dart)、[内容校验器](../../packages/learning_core/lib/src/content_validator.dart) | 已确认 | 运行时没有直接执行 JSON Schema；Schema 与 validator 仍有 `sha256` 差异 | walkthrough、内容模块 |
| 当前 App 默认加载的 Fixture 有 3 地点、52 知识点、12 课程、15 对话和 53 个 ready 资产 | [M2 正式课程数据](../../content/fixtures/m2-course.json)、[内容 Repository](../../apps/mobile/lib/data/content/course_content_repository.dart)、[默认内容测试](../../apps/mobile/test/data/content/course_content_repository_test.dart) | 已确认 | 数据包是 `release`；M1 [点咖啡课程数据](../../content/fixtures/cafe-course.json) 只作为专项回归基线 | README、walkthrough、内容模块 |
| `dialogue_turn` 按 `nextNodeId` 推进完整对话图；连续系统节点按顺序显示，每个 learner 节点重新要求可观察动作，并区分系统/学习者终止 | [对话轮次模型](../../apps/mobile/lib/data/content/course_content_models.dart)、[课程状态](../../apps/mobile/lib/features/lesson/application/lesson_providers.dart)、[对话步骤页面](../../apps/mobile/lib/features/lesson/presentation/steps/dialogue_step.dart)、[多轮对话测试](../../apps/mobile/test/features/lesson/presentation/dialogue_flow_test.dart)、[M2 Repository 测试](../../apps/mobile/test/data/content/course_content_repository_test.dart)、[M2 真机集成测试](../../apps/mobile/integration_test/m2_device_acceptance_test.dart)、[M2 Release Fixture](../../content/fixtures/m2-course.json) | 已确认 | 三个地点终局都能合成为课程、遍历完整对话图并在 Sony 真机控制器链路中完成；Café final 的 5 个、Market final 的 6 个和 Metro final 的 8 个 learner 回合均有逐状态真机证据。Market final 验证连续 system 节点，Metro 01—04 分别完成 2、2、3、3 个 learner 回合；每轮门禁重置及两类终止节点均已人工覆盖 | walkthrough、code map、内容模块 |
| 课程答题与完成通过 Drift 事务写入本地数据和 Outbox | [进度 Repository](../../apps/mobile/lib/data/progress/lesson_progress_repository.dart)、[本地表定义](../../apps/mobile/lib/data/local/tables.dart) | 已确认 | Outbox 尚无远端消费者 | walkthrough、本地闭环模块 |
| 完成课程会为 3 个知识点分别建立 4 个学习维度，共 12 条掌握度 | [完成课程实现](../../apps/mobile/lib/data/progress/lesson_progress_repository.dart)、[端到端断言](../../apps/mobile/test/app/app_test.dart) | 已确认 | 重复完成会提前返回，避免重复初始化 | walkthrough、本地闭环模块 |
| 复习采用 0—5 箱，间隔为 10 分钟、1/3/7/14/30 天 | [复习调度器](../../packages/learning_core/lib/src/review_scheduler.dart)、[调度测试](../../packages/learning_core/test/learning_core_test.dart) | 已确认 | `ReviewQueueRepository` 的排序规则仍在 App data 层 | 本地闭环模块、glossary |
| 复习入口从本地到期队列读取，单次必做上限为 8 | [复习 Provider](../../apps/mobile/lib/features/review/application/review_providers.dart)、[复习流程测试](../../apps/mobile/test/app/review_flow_test.dart) | 已确认 | 超出部分显示为可选巩固 | walkthrough、本地闭环模块 |
| `ready` 音频路径必须由 `audioAssetId` 解析，课程与复习 listening 题共用该路径；`planned` 或缺失资源进入书面降级并记录提示 | [内容模型](../../apps/mobile/lib/data/content/course_content_models.dart)、[复习 Provider](../../apps/mobile/lib/features/review/application/review_providers.dart)、[复习流程测试](../../apps/mobile/test/app/review_flow_test.dart)、[M2 真机集成测试](../../apps/mobile/integration_test/m2_device_acceptance_test.dart) | 已确认 | M1 三条 CosyVoice 已过 Sony 真机；M2 49 条在音量为 0 的 Sony 真机测试中逐条完成 Android 播放，技术播放证据与此前人工听感证据分开 | walkthrough、媒体模块 |
| 媒体 UI 区分播放状态、资产降级、权限分支、服务不可用、录音和回放 | [媒体组件测试](../../apps/mobile/test/shared/presentation/media_controls_test.dart)、[媒体 Controller 测试](../../apps/mobile/test/data/audio/audio_controller_test.dart) | 已确认 | Sony 真机已覆盖授权、普通/永久拒绝、设置返回恢复、录音、音量提示、回放、重录、Home 和步骤返回清理；服务不可用真机分支及来电恢复仍待验证 | 媒体模块、quality review |
| 本地学习闭环跨冷启动保留，并可在飞行模式完成 | [进度 Repository](../../apps/mobile/lib/data/progress/lesson_progress_repository.dart)、[Journey 页面](../../apps/mobile/lib/features/journey/presentation/journey_page.dart)、[复习流程](../../apps/mobile/lib/features/review/application/review_providers.dart)、[M2 磁盘冷启动验收](../../apps/mobile/integration_test/m2_process_persistence_app.dart) | 已确认 | M1 已验证完成、复习与飞行模式；M2 由不同 Android PID 从同一独立 Drift 文件恢复 15 条完成、208 条掌握度、一次复习和完整解锁。人工走查又依次确认 Café 终局开放 Market、Market 终局开放 Metro、Metro 01—04 逐课开放，并在完成 Metro final challenge 后看到 12 课与 3 个地点终局全部为 `Completed`。2026-07-27 无 `dart-define` 的 `0.2.0+3` 默认 Release APK 在 Sony `XQ-DQ72` 覆盖安装并冷启动，UI hierarchy 再次核对 12 节课与 3 个终局完整存在；该包仍为 debug key 签名的 Pre-release 验收包 | walkthrough、本地闭环模块 |
| Go 服务当前只提供 `/healthz`、`/readyz`、`/v1/meta` | [HTTP handler](../../services/api/internal/httpapi/handler.go)、[handler 测试](../../services/api/internal/httpapi/handler_test.go) | 已确认 | `/readyz` 仍是固定 ready；无 DB、认证、同步或语音代理 | code map、README |
| 当前生产 App 已有 Settings 入口、帮助/隐私/条款状态页、本地数据清理和版本信息 | [App 路由](../../apps/mobile/lib/app/router.dart)、[Settings Feature](../../apps/mobile/lib/features/settings/)、[设置测试](../../apps/mobile/test/features/settings/settings_page_test.dart)、[数据清理测试](../../apps/mobile/test/features/settings/local_data_repository_test.dart) | 已确认 | 真实支持邮箱/网页、正式隐私政策/条款、完整客服、账号和订阅仍未实现；不得把首切片写成 G1/G2 已通过 | README、项目现状、公开 MVP 完成门禁 |
| Android 本地每日提醒默认关闭；选择时间后先检查后台限制，再请求权限，以稳定 ID 在设备内调度并可撤回，不建立推送 Token 或发送数据 | [Android 平台桥接](../../apps/mobile/android/app/src/main/kotlin/com/hieronymusf/mandarin_mission/MainActivity.kt)、[时区重排接收器](../../apps/mobile/android/app/src/main/kotlin/com/hieronymusf/mandarin_mission/LearningReminderTimezoneReceiver.kt)、[偏好状态](../../apps/mobile/lib/features/settings/application/app_preferences_providers.dart)、[本地提醒 Adapter](../../apps/mobile/lib/features/settings/data/local_learning_reminder_service.dart)、[设备集成测试](../../apps/mobile/integration_test/learning_reminder_device_test.dart)、[偏好页面](../../apps/mobile/lib/features/settings/presentation/app_preferences_page.dart)、[设置测试](../../apps/mobile/test/features/settings/settings_page_test.dart) | 部分确认 | 自动测试覆盖后台受限、时间持久化、权限拒绝/永久拒绝/不可用、取消、调度失败和撤回；Android 模拟器已验证正常 schedule/cancel。Sony `XQ-DQ72` 在 `RUN_ANY_IN_BACKGROUND: ignore` 时曾让 18:50 Alarm 逾期约 10 分钟，直到 App 前台才显示；修复后同一设备能识别 `ActivityManager.isBackgroundRestricted()`，保持 Off、缓存 `[]`、无 Alarm，并打开本 App 系统设置。用户解除限制后，19:30 Alarm 在 App 退到桌面、手机熄屏且保持 Dozing 时于约 19:33:43 投递，并自动续排次日 19:30；后台真实到点已验证。模拟器在 App 未启动时重启后恢复同一当地 Alarm；首次 GMT → Asia/Hong_Kong 测试暴露绝对时刻未更新，加入时区接收器后，HKT → GMT 与 GMT → HKT 均保持当地 12:30 并在当天已过时排到次日。诊断服务仍未接入 | README、代码地图、公开 MVP 完成门禁 |
| Privacy 页面按 App 版本说明本机存储、临时录音、当前不发送和清除边界 | [隐私数据清单](../../apps/mobile/lib/features/settings/data/privacy_data_inventory.dart)、[信任信息页](../../apps/mobile/lib/features/settings/presentation/trust_info_page.dart)、[清单版本测试](../../apps/mobile/test/features/settings/privacy_data_inventory_test.dart)、[设置测试](../../apps/mobile/test/features/settings/settings_page_test.dart) | 已确认 | 结论只覆盖 `0.2.0+3` 当前源码与 Android 模拟器；不是正式政策、商店披露、法律审查、iOS 或真机结果 | README、代码地图、公开 MVP 完成门禁 |
| 当前生产 App 首次启动会显示单页引导，完成后持久化进入 Journey，并可从 Settings 重看 | [App 启动门禁](../../apps/mobile/lib/app/app.dart)、[引导 Feature](../../apps/mobile/lib/features/onboarding/)、[引导测试](../../apps/mobile/test/features/onboarding/onboarding_page_test.dart) | 已确认 | Android 模拟器已验证完成与冷启动；Sony 真机视觉、完整 G1/G2 和产品负责人最终验收仍未完成 | README、代码地图、公开 MVP 完成门禁 |
| CI 会验证生成文件、Flutter、纯 Dart 内容与调度、Go API 和容器构建 | [Project CI](../../.github/workflows/core-ci.yml) | 已确认 | 本轮只检查了 workflow 定义；未在此次文档构建中重跑整套 CI | README、code map |

## 会改变当前解释的检查

以下任何一项出现，都应触发 repo-docs 同步：

1. `cafe-course.json` 或 `m2-course.json` 的范围、状态、步骤、知识点、资产状态或 App 加载关系变化。
2. `LessonProgressRepository.completeLesson` 不再原子写入进度、掌握度与 Outbox。
3. Go API 开始消费 Outbox 或参与课程/复习主路径。
4. TTS Provider、声线、参数、合成文本、音频文件或 Android 媒体生命周期行为变更。
5. 默认课程资产、Journey 解锁规则、`app_test.dart`、`journey_page_test.dart`、`review_flow_test.dart` 或 CI 命令改变主闭环的可观察结果。
6. 设置/客服/法律、账号/同步/删除、订阅、分析/崩溃或完整游戏化进入生产路由与数据路径。

证据状态：除特别标注外，本页基于当前源码已确认。
