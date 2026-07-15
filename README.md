# Mandarin Mission

一款面向英语使用者的零基础中文学习 App：用城市地图串联真实生活任务，通过视觉记忆、分维度复习和受控口语练习，帮助用户每天用约 10 分钟学会当天能使用的中文。

> 当前状态：一期工程基础已启动。仓库包含竞品调研、产品与开发方案、纯 Dart 学习核心、课程 Schema、首个“点咖啡”Draft Fixture 和 CI；Flutter App 外壳尚未建立。

## 产品定位

- 目标用户：18—40 岁、以英语为主要使用语言的普通话零基础成人。
- 一期语言范围：英语界面、普通话、简体中文。
- 核心承诺：让用户在真实场景中做到“看得懂、听得出、说得出”。
- 产品形态：城市旅行地图 + 短课 + 四锚复习 + 场景终局挑战。
- 开发原则：适合独立开发者维护，优先完成学习闭环，不建设高维护社交系统。

## 核心机制

每个知识点分别维护四个掌握维度：

| 维度 | 目标 | 典型练习 |
|---|---|---|
| 意义 | 理解词句表达的概念 | 看场景选表达 |
| 声音 | 听懂发音并区分声调 | 听音辨义、声调对比 |
| 文字 | 识认汉字及其读音 | 字词配对、拼音淡出 |
| 场景 | 在真实任务中使用 | 点餐、问路等微对话 |

游戏奖励与学习结果绑定：理解、记忆、开口分别对应三颗能力星；地图、每日任务、连胜、地点印章和终局挑战只用于推动完整学习闭环。

## 版本范围

| 阶段 | 内容范围 | 主要能力 |
|---|---|---|
| 可玩原型 | 3 个地点、12 节课 | 地图、课程播放器、四锚复习、三星、每日任务、预设对话 |
| 公开 MVP | 6 个地点、约 30 节课 | 登录与同步、订阅、基础语音、分析、连胜、印章册 |
| 一期完整版 | 10 个生活场景 | 受控 AI 对话、精细发音反馈、更多收藏内容 |

一期明确不做排行榜、好友、组队、实时 PK、抽卡、复杂商城、完整 HSK、真人教师市场和无限制 AI 聊天。

## 技术方向

- 客户端：Flutter，先 Android 后 iOS。
- 架构：按功能拆分的 MVVM；UI、状态、仓储和外部服务分层。
- 本地数据：SQLite/Drift，本地优先保存课程、进度、复习队列和待同步事件。
- 云服务：Supabase Auth、Postgres、Storage 和 Edge Functions。
- 订阅：RevenueCat 对接 App Store 与 Google Play。
- 语音：真人课程音频；发音评测通过服务端代理接入 Azure Speech，并保留替换供应商的接口。
- 质量与数据：Firebase Crashlytics 和 Analytics；GitHub Actions 执行静态检查、测试与内容校验。

## 已实现的开发基础

- 四个学习维度共用的 0—5 分箱复习算法；
- 忘记、模糊、记得、使用提示和同日补救上限规则；
- 课程内容 JSON Schema；
- 稳定 ID、跨引用、对话可达性和资产发布状态校验；
- “点咖啡”第一课 Draft 内容包；
- GitHub Actions 格式、分析、测试和内容校验流程。

## 文档

- [跨电脑开发记忆准则](AGENTS.md)
- [开发方案](docs/开发方案.md)
- [课程内容制作指南](docs/content-authoring.md)
- [独立开发者一期产品方案](new-chat/outputs/英语使用者学中文App一期方案.md)
- [竞品机制摘要](new-chat/work/中英语言学习竞品-资料/summary/00-产品机制摘要.md)
- [海外中文学习产品资料](new-chat/work/中英语言学习竞品-资料/raw/01-海外中文学习产品.md)
- [国内英语学习产品资料](new-chat/work/中英语言学习竞品-资料/raw/02-国内英语学习产品.md)

## 仓库结构

```text
.
├─ AGENTS.md                         # Codex 跨电脑开发入口与长期约束
├─ README.md
├─ .github/workflows/                 # 自动检查
├─ content/                           # 课程 Schema 与开发 Fixture
├─ docs/
│  ├─ 开发方案.md
│  └─ content-authoring.md
├─ packages/
│  └─ learning_core/                  # 纯 Dart 学习规则与内容校验器
└─ new-chat/
   ├─ outputs/                         # 已确认的一期产品方案
   └─ work/中英语言学习竞品-资料/       # 调研原始资料与摘要
```

开发启动后将按 `apps/mobile`、`content`、`packages`、`supabase` 和 `tooling` 组织代码与课程资产，详细结构见开发方案。

## 当前使用方式

当前可运行学习核心测试和内容校验，但还没有移动端 App：

```bash
cd packages/learning_core
dart pub get
dart format --output=none --set-exit-if-changed .
dart analyze --fatal-infos
dart test
dart run bin/validate_content.dart ../../content/fixtures
```

本地验证基线为 Flutter 3.44.6 自带的 Dart 3.12.2。开发前请先阅读 `AGENTS.md`、开发方案和一期产品方案。

## 路线图

- [x] 建立学习核心、复习算法、内容 Schema/校验器和核心 CI。
- [ ] 建立 Flutter 移动端工程并接入学习核心。
- [ ] 完成“点咖啡”端到端垂直切片。
- [ ] 扩展到 3 个地点、12 节课并开展封闭测试。
- [ ] 根据激活、D1/D7 留存和 7 日回忆率决定是否扩展公开 MVP。
- [ ] 完成 6 个地点、订阅、同步和商店发布。

## 许可

当前仓库尚未选择开源协议。在添加明确的 `LICENSE` 文件前，默认保留所有权利；不要将仓库内容视为已获开源授权。
