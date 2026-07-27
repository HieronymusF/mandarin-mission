# 一次真实运行：完成点咖啡课程并进入复习

场景很具体：用户在 Journey 点击咖啡地点，完成“Order one coffee”课程，回到首页，并在知识点到期后进入复习。输入是一份随 App 打包的课程 JSON；成功输出是本地课程进度、答题记录、四维掌握度和待同步事件。

难点在于一次课程不只是翻八张卡片。内容引用必须先有效，答题失败不能丢失当前页面，完成动作要原子写入多张表，四个学习维度要独立安排复习；音频仍未就绪时，课程也必须走得完。

## Step 1: 用户从 Journey 打开一个任务

App 启动后先进入 Journey。页面按默认 M2 Release 内容包中的地点顺序读取每个 `lessonIds`，为 Café、Market、Metro 的 12 节课生成入口，并为三个地点生成独立终局。点击课程卡后，Journey 把对应稳定课程 ID 交给课程路由。路由只负责选择页面，不在这里拼课程内容或保存进度。

[Journey 的课程入口](../../apps/mobile/lib/features/journey/presentation/journey_page.dart) 和 [App 路由](../../apps/mobile/lib/app/router.dart) 共同证明了这一步。每张卡分别读取对应 lesson ID 的持久化课程进度；`cafe-01` 完成后会显示 100% 与 `Practice again`，冷启动后仍保留。Journey 也继续读取本地到期摘要。多地点 Widget 测试用顺序相反的 Café 与 Market 输入，确认页面按 `order` 显示两张课程卡，而不是继续依赖 `cafe-01` 硬编码。

## Step 2: 内容包先通过校验，再变成课程对象

课程页不能直接相信 JSON。Repository 先从安装包读取 Fixture，解析顶层对象，再调用纯 Dart 校验器检查稳定 ID、跨对象引用、步骤要求、拼音与汉字对齐、对话可达性和 release 资产状态。只有问题列表为空时，数据才会变成 App 使用的课程对象。

默认 [M2 正式课程数据](../../content/fixtures/m2-course.json) 包含 3 个地点、52 个知识点、12 节课、15 段对话和 53 个 `ready` 资产。49 条新增普通话音频已完成试听、资源写回、APK 核对和 Sony 技术播放；新增范围 14/14 单元也已完成人工逐页 UX。M1 [点咖啡课程数据](../../content/fixtures/cafe-course.json) 继续保留为单课回归基线。

Repository 默认资产常量直接指向 M2 Release，不再读取 `MM_USE_M2_DRAFT` 编译标志。Journey 会显示按先修关系锁定的课程和三个地点终局；自动测试覆盖四课后开放终局、完成终局后开放下一地点和冷启动恢复。本文继续用 `cafe-01` 作为最小代表案例，因为它完整展示 11 步学习闭环；这不表示 App 默认范围仍只有一课。

这段入口位于 [内容 Repository](../../apps/mobile/lib/data/content/course_content_repository.dart)，交叉引用规则位于 [内容校验器](../../packages/learning_core/lib/src/content_validator.dart)。无效 JSON、缺失引用或不可达对话会在 UI 建模前变成明确错误。

## Step 3: 页面状态推进十一个数据驱动步骤

课程 Controller 保存当前步骤、选择结果、提示使用、自评、错误和提交中状态。页面根据每个 step 的 `type` 选择展示组件，并把用户意图交回 Controller；保存、判分和 Repository 调用不放在按钮回调里散开。

当前 Fixture 的主序列是：

| 顺序 | 用户动作 | step type | 主要学习维度 |
| ---: | --- | --- | --- |
| 1 | 接受场景任务 | `scene_intro` | 综合入口 |
| 2—3 | 学习“我要”和“咖啡” | `teach_card` | `meaning` |
| 4 | 查看咖啡场景图，从整行中文+拼音选项中选择“咖啡” | `image_choice` | `meaning` |
| 5 | 临摹或脱稿写“咖啡” | `hanzi_trace` | `hanzi` |
| 6 | 听“我要”并选择对应带调拼音 | `tone_contrast` | `tone` |
| 7 | 从选项中听辨整句 | `listen_choice` | `listening` |
| 8 | 把词块排成完整订单 | `order_tokens` | `meaning` |
| 9 | 录音、自听或降级自评 | `repeat` | `tone` |
| 10 | 先脱稿说出订单，或打开 phrase ticket 后发送回复；查看系统收尾后继续 | `dialogue_turn` | 综合应用 |
| 11 | 查看总结并完成课程 | `summary` | 完成入口 |

`order_tokens` 的内容数据仍按正确语序保存，但进入该步骤时，词块区只生成一次随机顺序；本次答题内选择或撤回词块不会重新洗牌。三个以上词块还会避开正确顺序和旧的完全倒序，防止用户只靠固定的从右向左模式完成题目。

[课程 Controller](../../apps/mobile/lib/features/lesson/application/lesson_providers.dart) 负责状态和提交，[课程页面](../../apps/mobile/lib/features/lesson/presentation/lesson_overview_page.dart) 负责组合对应步骤 Widget。未知 step type 会显示不可用提示，而不是静默跳过。

第 10 步属于预设对话，不做 AI 语音识别。页面初始隐藏标准答案并禁用发送；用户可以先说出订单并选择 `I said it aloud`，也可以打开 `Use phrase ticket` 查看整句。完成其中一个可观察动作后，`Send reply` 会显示系统终止回复；再点 `Continue` 才进入总结页。相同播放器也能沿 `nextNodeId` 推进多轮对话，并在每个 learner 轮次重新执行动作门禁。

## Step 4: 每次练习先写本地事务

意义选择、声调对比、听力、词块排序、汉字和口语自评提交时，Controller 会进入提交中状态并调用进度 Repository。Repository 在同一 Drift 事务中写练习结果、更新该知识点对应维度的掌握度，并追加一条 Outbox 事件。保存失败时 Controller 保留当前步骤并显示重试文案。

这条设计让 UI 不需要等待尚未实现的云端同步。写入模型可以压缩成：

```text
用户答案
  -> review_attempts 或 speaking_attempts
  -> mastery_states 的一个 item + dimension
  -> sync_outbox_events
  -> 事务成功后才推进 UI
```

[进度 Repository](../../apps/mobile/lib/data/progress/lesson_progress_repository.dart) 是这个写入边界，[本地表定义](../../apps/mobile/lib/data/local/tables.dart) 则约束分数、箱位、置信度、维度和同日补救次数。

## Step 5: 完成课程建立十二个复习锚点

总结页提交完成动作时，Repository 先检查课程是否已经完成。首次完成会为 3 个知识点各建立 `meaning`、`listening`、`tone`、`hanzi` 四条掌握度，共 12 条；初始箱位为 0，到期时间是完成后 10 分钟。随后课程状态写成 `completed`，并追加课程进度 Outbox 事件。

重复完成会提前返回，因此不会反复初始化掌握度。完成事务成功后，课程进度查询会失效并重新读取数据库，Journey 卡片不再硬编码为 `Not started`。这个幂等边界可以从 [完成课程实现](../../apps/mobile/lib/data/progress/lesson_progress_repository.dart) 和 [完整课程端到端测试](../../apps/mobile/test/app/app_test.dart) 同时核对。

## Step 6: 到期项目重新出现在 Journey

Journey 用当前 UTC 时间查询 `dueAt <= now` 的掌握度。失败项目优先，听力与声调优先于意义与汉字；一次会话最多取 8 个必做项目，多出的保留为可选巩固。

用户提交“忘记、模糊、记得”后，纯 Dart 调度器决定新箱位、下次到期时间和是否在同一会话补救。错误或忘记会降两箱并在 10 分钟后到期；模糊保持箱位并延后 1 天；无提示记得会升一箱。

[复习队列 Repository](../../apps/mobile/lib/data/review/review_queue_repository.dart) 负责查询与排序，[复习调度器](../../packages/learning_core/lib/src/review_scheduler.dart) 负责确定性规则，[复习流程测试](../../apps/mobile/test/app/review_flow_test.dart) 覆盖四维写入、补救、保存失败和空队列。

听力复习条目会从内容元数据解析 `ready` 音频并显示共享播放器；如果资产为 `planned`、缺失或没有路径，则显示书面降级。书面降级揭晓答案会保存 `usedHint: true`，正常音频路径不会被误记为提示。

## 验证这条路径

在仓库根目录运行：

```powershell
Set-Location apps/mobile
flutter test test/app/app_test.dart test/app/review_flow_test.dart
Set-Location ../../packages/learning_core
dart test test/learning_core_test.dart test/repository_content_test.dart
```

端到端课程测试的关键结果是 1 条 `completed` 进度、12 条掌握度、4 条复习尝试、1 条口语尝试和 6 条 Outbox 事件。若这些结果改变，应先回到 [源码证据中的反证检查](../references/source-evidence.md#会改变当前解释的检查)，再更新本 walkthrough。

真机证据（2026-07-23）：Sony `XQ-DQ72` 完成八步课程后，Journey 显示 `Completed`、100% 与 `Practice again`；覆盖安装和两次冷启动后状态仍保留。设备完成 8 项必做到期复习并显示 `Review saved`，返回后只剩 2 项可选巩固；再次冷启动结果仍保留。随后开启飞行模式完整重走八步课程并返回 completed Journey，验证结束后已关闭飞行模式。

十一步复验证据（2026-07-24）：同一 Sony 真机通过 `image_choice`、`tone_contrast`、`order_tokens` 三个新增步骤，随后从第 9 步无录音降级继续，经第 10 步口语回复到第 11 步完成页；返回 Journey 显示 `Completed · 11 short steps`，杀进程冷启动后状态仍保留。接着完成 6 项到期复习，Journey 显示 `Review done · Review is up to date`，再次杀进程冷启动后仍保留。第 4 步后来接入 `ready` 咖啡场景图并把英文释义选项改为中文+拼音；第一版构图因杯子过大被否决，第二版缩小杯子、放大人物后获用户真机确认。

理解行为后，可用 [代码地图定位每类修改的入口](../code-map.md)，再进入内容、本地闭环或媒体模块查看机制细节。

证据状态：除特别标注外，本页基于当前源码已确认。
