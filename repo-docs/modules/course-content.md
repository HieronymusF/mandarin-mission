# 课程内容契约：一份数据驱动页面与复习

课程内容的职责是让新增课程尽量不改客户端业务逻辑。地点、知识点、步骤、对话和资产都使用稳定 ID；App 根据 step type 选择已有页面组件，而不是为每节课写一套专用页面。

## 一份真实输入长什么样

当前 App 默认加载的 M2 Release Fixture 形状是：

| 对象 | 数量 | 代表 ID | 进入运行时后的用途 |
| --- | ---: | --- | --- |
| location | 3 | `cafe` | Journey 的地点顺序与跨地点解锁 |
| knowledge item | 52 | `phrase-wo-yao` | 四维掌握度与练习目标 |
| lesson | 12 | `cafe-01` | 课程播放器输入 |
| dialogue | 15 | `cafe-challenge` | 课内对话与地点终局 |
| asset | 53 | `audio-wo-yao` | 图片或音频来源与许可状态 |

每节课程的 `itemIds` 在完成时各生成四个学习维度。这就是内容数据与复习数据之间最重要的契约；`cafe-01` 仍是最小可读案例，它的三个知识点会生成 12 条掌握度。

运行时内容模型会保留按 `order` 排序的 location，以及每个 location 的 `lessonIds`。Journey 顺着这两个字段生成课程卡，课程标题、步骤数和路由 ID 都来自对应 lesson；因此增加已有步骤类型组成的新课程时，不需要再为入口修改页面。若 location 的 `challengeId` 指向一段未被普通 lesson 内嵌的对话，运行时会把它合成为两步终局课程：完整 `dialogue_turn` 加完成页。

[M2 Release Fixture](../../content/fixtures/m2-course.json) 的 `0.2.7` 文本已由独立英文编辑 Agent、中文教学 Agent 双审并 language lock；两名专业 Agent 都明确以 AI 身份审核，不冒充真人或母语者。[场景引入页面](../../apps/mobile/lib/features/lesson/presentation/steps/scene_intro_step.dart) 只呈现 location Badge 与本步 authored `step.text`，不再写死 Café 01 内容，也不从地点名推导场景句。49 条新增普通话音频已完成用户试听、唯一选择、App asset 复制、path/SHA-256/credit 写回、Flutter 资源加载测试和 APK 内哈希核对。默认 Repository 直接加载该 Fixture，不再使用 Draft 编译开关。Journey 按 `prerequisites` 逐课解锁，四课完成后开放地点终局，终局完成记录复用 `lesson_progress_entries` 并解锁下一个地点。M1 的 `cafe-challenge` 已内嵌在 `cafe-01`，不会重复生成第二张挑战卡。

当前 [对话步骤页面](../../apps/mobile/lib/features/lesson/presentation/steps/dialogue_step.dart) 会从当前系统节点沿 `nextNodeId` 读取一个完整话轮：连续的系统节点会按顺序共同显示，到达 learner 节点后暂停。学习者每一轮都要重新选择脱稿自报或 phrase ticket，完成可观察动作后才能发送；系统终止节点会先显示收尾再允许继续，学习者终止节点则在该次动作后结束步骤。[课程状态](../../apps/mobile/lib/features/lesson/application/lesson_providers.dart) 保存当前节点，离开课程页后由 `autoDispose` 清理。

[多轮对话测试](../../apps/mobile/test/features/lesson/presentation/dialogue_flow_test.dart) 覆盖连续系统节点、每轮门禁重置、两类终止节点和离页清理，并直接遍历 M2 的 Café、Market、Metro 三个终局，分别完成 5、6、8 个 learner 轮次。Repository 测试证明三个 `challengeId` 都能合成为可路由课程；Journey 测试再覆盖“四课完成 → Café 终局开放 → 完成终局 → Market 开放”，并在重新创建 ProviderScope 后确认解锁仍由数据库恢复。[M2 真机集成测试](../../apps/mobile/integration_test/m2_device_acceptance_test.dart) 在 Sony `XQ-DQ72` 上通过真实课程控制器完成 12 课与 3 个终局，并核对 15 条完成进度、208 条掌握度状态、一次到期复习和 Provider 重载。独立验收还补齐了真实进程冷启动和新增范围 14/14 单元人工逐页 UX。用户已批准内容发布；本轮无设备连接，因此默认 Release APK 的重新安装仍需单独复验。

## 数据进入 App 前经过两层约束

[JSON Schema](../../content/schema/course-package.schema.json) 描述字段形状、必填项和十种允许的 step type。运行时 [内容校验器](../../packages/learning_core/lib/src/content_validator.dart) 继续处理 Schema 不擅长的关系：

- 全局稳定 ID 不能重复；
- lesson 引用的 location、item、dialogue 和 asset 必须存在；
- 汉字与 `pinyinSyllables` 数量必须对齐；
- 对话节点必须从起点可达，且不能形成无终点循环；
- `release` 内容的资产必须全部为 `ready`；
- `hanzi_trace` 等步骤必须带匹配的 item 和 dimension；`image_choice` 的正确 item 必须在选项中，`tone_contrast` 必须包含目标拼音，`order_tokens` 必须能重建目标汉字。

[内容 Repository](../../apps/mobile/lib/data/content/course_content_repository.dart) 会先解析 JSON，再运行校验器，最后才调用 `CoursePackage.fromJson`。因此一个未知 item 引用不会拖到课程中途才崩溃。

## 资产状态决定能力是否可用

知识点只保存 `audioAssetId`。App 再从资产表解析路径，并同时检查：资产存在、`kind == audio`、`status == ready`。任何一个条件不满足都返回 `null`，UI 进入明确降级。图片选择题同样只解析 `image + ready` 资产；图片为 `planned` 时显示中文+拼音文字降级，不用占位图冒充正式资产。当前咖啡场景图已为 `ready`。

当前三个音频资产是 `ready` CosyVoice 文件，`path`、SHA-256、`CosyVoice-300M-SFT`、内置 `中文女`、seed、语速、合成文本差异和 Apache-2.0 来源均已填写；图片也是 `ready`，已记录内部生成许可、署名和 SHA-256，并获用户真机构图确认。三条音频已通过首尾完整性、声母、复合韵母、声调、跨片段音色一致性和声码器伪影的整组人工试听，并通过新 APK 真机播放，因此内容包为 `release`。TTS 仍不能称为真人发音。

## 修改内容时从哪里验证

```powershell
Set-Location packages/learning_core
dart test test/content_validator_test.dart test/repository_content_test.dart
dart run bin/validate_content.dart ../../content/fixtures
```

[校验器测试](../../packages/learning_core/test/content_validator_test.dart) 已覆盖缺失引用、重复 ID、拼音错位、不可达节点、循环对话和 release 资产未就绪。若要继续追踪内容如何变成本地进度，进入 [本地学习闭环](local-learning-loop.md)。

证据状态：除特别标注外，本页基于当前源码已确认。
