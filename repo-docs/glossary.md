# 项目术语

| 术语 | 项目里的意思 | 延伸阅读 |
| --- | --- | --- |
| 本地学习闭环 | 课程、答题、掌握度和到期复习都能在本地完成，不等待云端 | [一次真实课程运行](walkthroughs/one-real-run.md) |
| 知识点（knowledge item） | 带稳定 ID 的学习单位；分别维护意义、听力、声调和汉字状态 | [课程内容契约](modules/course-content.md) |
| 学习维度（learning dimension） | `meaning`、`listening`、`tone`、`hanzi` 四条独立掌握度 | [本地学习闭环](modules/local-learning-loop.md) |
| 掌握度（mastery state） | 一个知识点在一个维度上的箱位、置信度、到期时间和最近结果 | [本地学习闭环](modules/local-learning-loop.md) |
| 箱位（box） | 0—5 的可解释复习阶段；箱位决定下次间隔 | [复习规则](modules/local-learning-loop.md#四维状态与-05-箱) |
| 同轮补救 | 答错后在当前会话尾部再次出现，单日最多两次 | [复习规则](modules/local-learning-loop.md#四维状态与-05-箱) |
| Outbox | 与本地业务写入同事务追加的待同步事件；当前还没有远端消费者 | [事务边界](modules/local-learning-loop.md#一个事务包含什么) |
| Fixture | 随仓库版本控制、随 App 打包的真实课程 JSON | [课程内容契约](modules/course-content.md) |
| 稳定 ID | 内容对象的持久标识；显示文案或排序变化时不应随意更换 | [课程内容契约](modules/course-content.md) |
| `cafe-01` | 当前唯一完整课程的稳定 lesson ID | [一次真实课程运行](walkthroughs/one-real-run.md) |
| `audioAssetId` | 知识点指向媒体资产的稳定引用；App 不根据 item ID 猜文件名 | [媒体能力与降级](modules/media-fallback.md) |
| 到期条件（`dueAt <= now`） | 掌握度进入本地复习队列的时间判断 | [本地学习闭环](modules/local-learning-loop.md#到期队列和当前边界) |
| 降级路径 | 音频、录音或网络不可用时仍能完成课程的本地替代交互 | [媒体能力与降级](modules/media-fallback.md) |
| Journey | App 首页和城市旅行入口；当前提供咖啡课程与到期复习入口 | [一次真实课程运行](walkthroughs/one-real-run.md#step-1-用户从-journey-打开一个任务) |

需要按源码职责定位术语对应实现时，使用 [代码地图](code-map.md)。

证据状态：除特别标注外，本页基于当前源码已确认。
