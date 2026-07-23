# 课程内容制作指南

> 当前状态：v0.1，只支持开发期 Draft 内容包。

## 目录

- `content/schema/course-package.schema.json`：课程包 JSON Schema。
- `content/fixtures/cafe-course.json`：首个“点咖啡”开发 Fixture。
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
Validated 1 content package(s).
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

当前 `cafe-course.json` 仍是 `draft`：图片为 `planned`，三个音频是可在开发包播放的 `ready` Kokoro TTS 开发占位资源。这里的 `ready` 只表示文件、路径和哈希可用，不表示音色已经通过内容放行。图片未就绪、音频未通过普通话人工听感审核前，都不能把内容包改为 `release`。

### TTS 课程音频

TTS 可以作为开发预览，也可以在许可和内容审核完整时作为正式课程资产。正式候选必须同时满足：

- 模型、声线和生成工具的许可证允许当前用途；
- `license` 记录许可，`credit` 记录模型、版本、声线、生成日期和必要的发音处理；
- `path` 与实际 App asset 一致，`sha256` 与文件内容一致；
- TTS 不得称为真人音频；
- 普通话母语者或国际中文教师逐条审核声调、变调、轻声、儿化、停顿和自然度；
- 任何重新生成或后处理都必须重新计算哈希并复测打包播放。

当前三条候选由 [Kokoro-82M v1.0](https://huggingface.co/hexgrad/Kokoro-82M) 通过 [sherpa-onnx 1.13.4](https://github.com/k2-fsa/sherpa-onnx) 在本地生成，使用中文女声 `zf_xiaoxiao`（speaker ID 47）和 `0.95` 语速。模型和工具均为 Apache-2.0，不需要云端 API 或按字符付费。整句合成输入用同音“义杯”强制实现“一杯”的 `yì bēi` 变调；保存前做去直流、峰值归一化和首尾淡化。课程显示文本仍为“我要一杯咖啡。”。旧候选 `zf_xiaoyi`（speaker ID 48）因用户试听认为机械感明显，已于 2026-07-22 淘汰。

用户已确认当前 `zf_xiaoxiao` 声线“能用但不满意”。它只用于开发、流程验证和早期内部测试，后续仍计划替换，不能因为路径标为 `ready` 就视为最终课程音色。

允许后续改用更自然的商用 TTS。引入前必须核验商业使用与生成音频发布权、声线授权范围、归属与署名要求、输入数据保留/训练条款、地区可用性、价格和限额；免费额度不等于发布授权。替换时保持知识点的 `audioAssetId` 稳定，更新文件、SHA-256、`license` 和 `credit`，重新运行内容校验与 APK 播放验证，并逐条进行普通话人工试听。

## 制作顺序

1. 确定本节课只解决一个场景任务。
2. 建立 5—7 个新词句以内的知识点集合。
3. 为每个知识点填写汉字、带声调拼音、英文解释和音频资产 ID。
4. 按场景引入、教学卡、意义/听音、跟读、对话和总结组织步骤。
5. 终局挑战只引用已学习的词句，并保证从开始节点可到达终止节点。
6. 运行内容校验器。
7. 完成英语母语编辑、普通话音频和国际中文教师审核。
8. 资产全部就绪后才把状态改为 `release`。

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

后续增加新的步骤类型时，必须同步修改 JSON Schema、校验器、Fixture 和测试。
