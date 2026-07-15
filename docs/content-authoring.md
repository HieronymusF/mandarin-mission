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

当前 `cafe-course.json` 中的图片和音频仍是 `planned`，不能作为正式课程发布。

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
- 缺少汉字、拼音、英文解释或音频引用；
- Release 内容仍引用 planned 资产；
- Ready 资产没有路径、授权或署名。

后续增加新的步骤类型时，必须同步修改 JSON Schema、校验器、Fixture 和测试。
