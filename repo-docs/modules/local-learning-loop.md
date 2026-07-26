# 本地学习闭环：一次答题如何变成到期复习

App 的核心不变量是离线可学。用户动作先写本地事务，UI 在保存成功后推进；云同步尚未实现，但每次需要同步的变化已经写入 Outbox。

## 代表性状态变化

用户在听力步骤第一次答错、第二次使用提示答对时，状态大致这样变化：

| 阶段 | 本地记录 | 调度含义 | UI 结果 |
| --- | --- | --- | --- |
| 第一次答错 | 新增一条 listening attempt，`correct: false` | 箱位降两级但最低为 0，需要同轮补救 | 保留步骤，清空选择并显示提示 |
| 提示后答对 | 再新增一条 attempt，`usedHint: true` | 不因提示答对而升级 | 允许进入下一步 |
| 完成课程 | 写 `completed` 进度，为 3 item × 4 dimension 初始化掌握度 | 初始箱位 0，10 分钟后到期 | 返回 Journey |
| 到期复习 | 查询 `dueAt <= now` | 失败项、听力/声调优先 | Journey 显示必做数量 |

端到端测试实际断言两条 listening attempt 的 `usedHint` 分别包含 `false` 和 `true`，防止提示信息在 UI 到 Repository 的途中丢失。

## 一个事务包含什么

[进度 Repository](../../apps/mobile/lib/data/progress/lesson_progress_repository.dart) 把一次练习的关联写入放进同一 Drift transaction：

1. 新增 `review_attempts` 或 `speaking_attempts`；
2. 用调度结果更新 `mastery_states`；
3. 把可同步 payload 写入 `sync_outbox_events`；
4. 事务成功后 Controller 才清除提交状态并推进页面。

课程完成也使用同一原则：初始化缺失掌握度、更新 `lesson_progress_entries`、追加课程事件。已完成课程再次提交会直接返回，避免重复初始化。

Journey 通过 `journeyProgressProvider` 汇总每节课和独立地点终局的持久化进度。普通 lesson 只有在所属地点已开放且 `prerequisites` 全部完成时可进入；一个地点的四节课完成后开放终局，终局的 `lesson_progress_entries` 变为 `completed` 后才开放下一个地点。已完成项目始终可再次练习。Journey Widget 测试用 Café 四课和一个真实可路由终局验证这条状态链，并在重新创建 ProviderScope 后确认 Market 仍保持开放。

正式 Café Fixture 没有独立终局卡，因此现有 M1 行为不变：`cafe-01` 完成后返回 Journey 显示 `completed`，冷启动从数据库恢复。Sony `XQ-DQ72` 已验证该完成状态跨 APK 覆盖与冷启动保留，并完成 8 项必做到期复习；飞行模式下完整课程也通过。M2 真机集成测试先用隔离内存数据库完成 12 课、3 个终局和一次到期复习，再重建 ProviderContainer 恢复全部状态。随后[磁盘冷启动验收入口](../../apps/mobile/integration_test/m2_process_persistence_app.dart)把 15 条完成记录、208 条掌握度和一次复习写入独立 Drift 文件；ADB 强制停止后，第二个 Android PID 从同一文件恢复全部记录与 Journey 解锁，并渲染真实完成页面。两种测试都不写生产数据库；前者验证控制器链路，后者验证跨进程磁盘恢复。

## 四维状态与 0—5 箱

每个知识点分别保存 `meaning`、`listening`、`tone`、`hanzi`。 [复习调度器](../../packages/learning_core/lib/src/review_scheduler.dart) 是纯 Dart 确定性规则：

| 输入结果 | 新箱位 | 下次到期 | 同轮补救 |
| --- | --- | --- | --- |
| 错误或 `forgotten` | 当前箱位减 2，最低 0 | 10 分钟后 | 最多两次 |
| `vague` | 不变 | 1 天后 | 否 |
| `remembered` 且用了提示 | 不变 | 当前箱位对应间隔 | 否 |
| `remembered` 且无提示 | 加 1，最高 5 | 新箱位对应间隔 | 否 |

箱位 0—5 的间隔依次为 10 分钟、1 天、3 天、7 天、14 天、30 天。所有调度时间必须是 UTC；箱位和同日补救次数超界会立即抛错。

## 到期队列和当前边界

[复习队列 Repository](../../apps/mobile/lib/data/review/review_queue_repository.dart) 查询所有到期状态后排序，再截取请求上限。应用层一次取最多 9 项，用前 8 项建立必做会话，第 9 项只用来判断是否还有额外巩固。

Outbox 当前只是本地事实日志，没有消费者、重试 worker 或服务端接口。Go API 接入前，不应把“已写 Outbox”描述成“已经同步”。

## 验证规则与事务

```powershell
Set-Location packages/learning_core
dart test test/learning_core_test.dart
Set-Location ../../apps/mobile
flutter test test/data/progress/lesson_progress_repository_test.dart test/data/review/review_queue_repository_test.dart
flutter test test/app/app_test.dart test/app/review_flow_test.dart
flutter test test/features/journey/journey_page_test.dart
```

要理解课程输入如何决定这 12 条状态，返回 [课程内容契约](course-content.md)；要定位所有实现文件，使用 [代码地图](../code-map.md)。

证据状态：除特别标注外，本页基于当前源码已确认。
