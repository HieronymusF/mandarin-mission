# 课程内容契约：一份数据驱动页面与复习

课程内容的职责是让新增课程尽量不改客户端业务逻辑。地点、知识点、步骤、对话和资产都使用稳定 ID；App 根据 step type 选择已有页面组件，而不是为每节课写一套专用页面。

## 一份真实输入长什么样

当前 Fixture 的代表性形状是：

| 对象 | 数量 | 代表 ID | 进入运行时后的用途 |
| --- | ---: | --- | --- |
| location | 1 | `cafe` | Journey 的地点概念 |
| knowledge item | 3 | `phrase-wo-yao` | 四维掌握度与练习目标 |
| lesson | 1 | `cafe-01` | 八步课程播放器输入 |
| dialogue | 1 | `cafe-challenge` | 预设对话步骤 |
| asset | 4 | `audio-wo-yao` | 图片或音频来源与许可状态 |

课程的三个 `itemIds` 在完成时各生成四个学习维度。这就是内容数据与复习数据之间最重要的契约。

## 数据进入 App 前经过两层约束

[JSON Schema](../../content/schema/course-package.schema.json) 描述字段形状、必填项和十种允许的 step type。运行时 [内容校验器](../../packages/learning_core/lib/src/content_validator.dart) 继续处理 Schema 不擅长的关系：

- 全局稳定 ID 不能重复；
- lesson 引用的 location、item、dialogue 和 asset 必须存在；
- 汉字与 `pinyinSyllables` 数量必须对齐；
- 对话节点必须从起点可达，且不能形成无终点循环；
- `release` 内容的资产必须全部为 `ready`；
- `hanzi_trace` 等步骤必须带匹配的 item 和 dimension。

[内容 Repository](../../apps/mobile/lib/data/content/course_content_repository.dart) 会先解析 JSON，再运行校验器，最后才调用 `CoursePackage.fromJson`。因此一个未知 item 引用不会拖到课程中途才崩溃。

## 资产状态决定能力是否可用

知识点只保存 `audioAssetId`。App 再从资产表解析路径，并同时检查：资产存在、`kind == audio`、`status == ready`。任何一个条件不满足都返回 `null`，UI 进入明确降级。

当前三个音频资产是 `ready` Kokoro TTS 开发占位，`path`、SHA-256、模型/工具版本、中文声线和 Apache-2.0 来源均已填写；图片仍为 `planned`，内容包继续保持 `draft`。`ready` 只说明文件可用，当前声线没有通过最终听感验收。后续可替换为商用 TTS；TTS 不能称为真人发音，替换后要重新核验许可、更新文件/署名/哈希、运行内容校验，并由普通话审核者逐条确认声调、变调、停顿和自然度。

## 修改内容时从哪里验证

```powershell
Set-Location packages/learning_core
dart test test/content_validator_test.dart test/repository_content_test.dart
dart run bin/validate_content.dart ../../content/fixtures
```

[校验器测试](../../packages/learning_core/test/content_validator_test.dart) 已覆盖缺失引用、重复 ID、拼音错位、不可达节点、循环对话和 release 资产未就绪。若要继续追踪内容如何变成本地进度，进入 [本地学习闭环](local-learning-loop.md)。

证据状态：除特别标注外，本页基于当前源码已确认。
