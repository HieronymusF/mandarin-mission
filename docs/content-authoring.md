# 课程内容制作指南

> 当前状态：内容工具同时支持 `draft` 与 `release`；App 默认加载 M2 `0.2.7` 正式课程包。

M2 的 3 个地点、12 节课、稳定 ID、先修关系和每课学习目标统一定义在 [M2 课程蓝图](requirements/m2-curriculum.md)。M2 `0.2.7` 保留已双审并 language lock 的课程文本；49 条新增音频已完成用户试听、唯一选择、App asset 复制、元数据写回和 APK 资源核对，地点终局多轮播放与新增范围 14/14 单元人工逐页 UX 也已完成。2026-07-26 用户批准后，该包已提升为 `release` 并成为默认入口。

## 目录

- `content/schema/course-package.schema.json`：课程包 JSON Schema。
- `content/fixtures/m2-course.json`：App 默认加载的 M2 `0.2.7` Release Fixture。
- `content/fixtures/cafe-course.json`：保留用于 M1 回归和专项测试的“点咖啡”Release Fixture。
- `packages/learning_core/bin/validate_content.dart`：跨引用与发布状态校验器。

## 本地校验

先进入学习核心包：

```bash
cd packages/learning_core
dart pub get
dart run bin/validate_content.dart ../../content/fixtures
```

成功输出：

```text
Validated 2 content package(s).
```

CI 还会执行格式检查、静态分析和全部单元测试。

移动端通过本地 `mandarin_mission_content` package asset 和 `CourseContentRepository` 把根目录 Fixture 打入安装包，加载时再次运行跨引用校验。因此修改 Fixture 后不需要在 `apps/mobile` 复制文件，但必须同时通过内容校验和移动端 Repository 测试。

## 内容包结构

一个开发内容包包含：

- `locations`：地图地点、课程顺序和终局挑战；
- `knowledgeItems`：词、短语和句子；
- `lessons`：课程步骤和引用的知识点；
- `dialogues`：预设分支场景对话；
- `assets`：音频与图片的状态、授权和署名。

所有对象使用稳定的 kebab-case ID，例如：

- `cafe`
- `cafe-01`
- `phrase-wo-yao`
- `audio-wo-yao`

显示文案、排序或文件路径变化时不要更换稳定 ID。ID 一旦进入测试数据，就可能已绑定用户进度。

## Draft 与 Release

内容包状态只有：

- `draft`：允许资产为 `planned`，只用于开发和内容审核；
- `release`：所有资产必须为 `ready`，并提供资源路径和 SHA-256。

当前 `cafe-course.json` 已为 `release`：咖啡场景图和三个音频均为 `ready`。图片已记录包内路径、SHA-256、内部生成许可与署名，第二版构图已获用户真机确认；三个包内 CosyVoice 中文音频已记录来源、许可、生成参数、合成文本差异和 SHA-256，并通过整组普通话人工试听、APK 打包与 Sony 真机逐条播放。

`m2-course.json` 为 `0.2.7` / `release`：包含 3 个地点、12 节课、52 个知识点、15 段对话和 53 个 `ready` 资产。Café 02—04、Market 01—04、Metro 01—04 和三个地点终局共 14 个审核单元已完成独立英文编辑 Agent、中文教学 Agent 双审及主 Agent 集成，课程文本已 language lock；`0.2.6` 的共享反馈文案与 `0.2.7` 的数据驱动场景引入又由两名原 Agent 对 12 课和 3 个合成终局复核为 15/15 通过。场景引入只呈现 location Badge 与本步 authored `step.text`，不得从地点名推导 `At the ...` 等场景句。两名专业 Agent 都以 AI 身份审核，不冒充真人或母语者；49 条新增普通话音频已从各轮用户可接受候选中收敛为唯一选择，复制到 `apps/mobile/assets/audio/cosyvoice/`，并写回 path、SHA-256、Apache-2.0 来源和生成参数。该 Fixture 已进入 `content/pubspec.yaml`，`CourseContentRepository` 默认直接加载它；不再存在 `MM_USE_M2_DRAFT` 入口开关。`cafe-course.json` 继续作为 M1 回归基线。

### TTS 课程音频

TTS 可以作为开发预览，也可以在许可和内容审核完整时作为正式课程资产。正式候选必须同时满足：

- 模型、声线和生成工具的许可证允许当前用途；
- `license` 记录许可，`credit` 记录模型、版本、声线、生成日期和必要的发音处理；
- `path` 与实际 App asset 一致，`sha256` 与文件内容一致；
- TTS 不得称为真人音频；
- 普通话母语者或国际中文教师逐条审核声调、变调、轻声、儿化、停顿和自然度；长句还要逐分句检查语速是否均匀，对话音频要与前后轮次连续试听，确认信息焦点、对比重音和句末语气符合角色意图；用户指出过快、吞音或韵律问题后，重生成候选必须先围绕该问题预筛，若只调整一个分句，还要检查拼接点、音色和整句连续性，明显没有改善的版本不再转交用户；同一 speaker 标签在 seed、文本边界或分段合成变化后也必须与已批准声线参考连续比较，自动音高/频谱指标只用于排除明显离群项，不能断言性别或替代人工确认说话人身份、音色与发音；
- 任何重新生成或后处理都必须重新计算哈希并复测打包播放。

MeloTTS 0.1.2 与官方中文模型曾作为免费本地候选，但因短音发音不完整、跨片段音色不一致和确定性长句电音而在三轮人工试听中被淘汰。最终音频使用 Apache-2.0 `CosyVoice-300M-SFT` 内置 `中文女`、seed 1986 生成：“我要”与长句速度 0.94，“咖啡”速度 0.89。为稳定 `kā fēi` 的一声和复合韵母，“咖啡”的合成文本为同音“喀飞”，显示文本仍为“咖啡”；该差异已写入资产 credit。原始 22.05 kHz 单声道 float WAV 仅做 PCM16 容器兼容转换，没有真人克隆或声学后处理；最终三条已通过整组人工试听和新 APK 真机逐条播放。

## 制作顺序

1. 确定本节课只解决一个场景任务。
2. 建立 5—7 个新词句以内的知识点集合。
3. 为每个知识点填写汉字、带声调拼音、英文解释和音频资产 ID。
4. 按场景引入、教学卡、意义/听音、跟读、对话和总结组织步骤。
5. 终局挑战只引用已学习的词句，并保证从开始节点可到达终止节点。
6. 运行内容校验器。
7. 由主 Agent 按 [M2 课程蓝图的专业 Agent 双审记录](requirements/m2-curriculum.md#52-专业-agent-双审记录) 分别编排英文编辑 Agent 与中文教学 Agent，集成修订并复核；language lock 后再完成普通话音频审核。
8. 资产全部就绪后才把状态改为 `release`。

首批互动步骤的内容约束：

- `image_choice` 使用一张场景图和至少两个知识点选项，`itemId` 必须出现在 `optionItemIds` 中；图片 `planned` 时 App 会明确降级为中文+拼音文字选择，但不能据此放行正式内容。当前咖啡场景图已为 `ready`。
- `tone_contrast` 的 `optionTexts` 是同一目标的带调拼音候选，必须包含目标知识点的准确 `pinyin`；不要用不同词义冒充声调干扰项。
- `order_tokens` 按正确顺序保存词块；拼接后必须能重建目标汉字，句末标点可省略。
- 当前 `dialogue_turn` 页面沿 `nextNodeId` 逐轮推进，连续 `system` 节点会在同一轮依次显示，每个 `learner` 节点重新要求 `I said it aloud` 或 phrase ticket 后才可发送；两类终止节点都有明确完成态。M2 的 11 节新增课程和 3 个地点终局共用该播放器，自动测试覆盖完整图、每轮门禁与终止状态。

## 校验器当前阻止的问题

- 不符合 kebab-case 的 ID；
- 集合内或全局重复 ID；
- 不存在的地点、课程、知识点、对话或资产引用；
- 重复课程步骤 ID；
- 对话不可达节点、未知节点或无终止节点的循环；
- 缺少汉字、拼音、逐字 `pinyinSyllables`、英文解释或音频引用；
- `pinyinSyllables` 数量与汉字数量不一致；标点不得占用拼音音节；
- Release 内容仍引用 planned 资产；
- Ready 资产没有路径、授权或署名。
- 互动选择题缺少正确选项、维度不匹配，或词块不能重建目标汉字。

后续增加新的步骤类型时，必须同步修改 JSON Schema、校验器、Fixture 和测试。
