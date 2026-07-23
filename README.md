# Mandarin Mission

一款面向英语使用者的零基础中文学习 App：用城市地图串联真实生活任务，通过视觉记忆、分维度复习和受控口语练习，帮助用户每天用约 10 分钟学会当天能使用的中文。

> 当前状态：一期工程基础已启动。仓库包含竞品调研、产品与开发方案、纯 Dart 学习核心、课程 Schema、首个“点咖啡”Draft Fixture、Go API 容器、可运行的 Flutter Android/iOS App、Drift v1 本地数据库、安装包内课程 Repository、数据驱动的八步课程播放器、汉字临摹与脱稿书写、练习结果与四维掌握度持久化，以及基于 `shadcn_ui` 的代码优先 UI 基线。

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
- UI：代码优先，使用 `shadcn_ui`、语义主题令牌和 Lucide 图标；Material 保留为平台外壳。
- 架构：按功能拆分的 MVVM；UI、状态、仓储和外部服务分层。
- 本地数据：SQLite/Drift，本地优先保存课程、进度、复习队列和待同步事件。
- 业务后端：单个自研 Go 服务部署到 Google Cloud Run，空闲缩到 0；不使用自管虚拟机或 Kubernetes。
- 云数据：Neon PostgreSQL；Flutter App 只访问 API，不直接连接数据库。
- 资源：Cloudflare R2（S3 兼容）+ 自定义域名 + Cloudflare 全球 CDN，大文件不经过 API。
- 身份与订阅：API 自行维护会话和权益，对接 Apple/Google 身份及商店服务端协议，不依赖 Supabase 或 RevenueCat。
- 语音：真人课程音频；发音评测通过服务端代理接入 Azure Speech，并保留替换供应商的接口。
- 质量与数据：业务事件和最小崩溃报告批量写入自研 API；GitHub Actions 执行静态检查、测试、内容校验与容器构建。

## 设计与前端开发流程

- 组件和主题基线见 [代码优先 UI 系统](docs/design-system.md)。
- 标准 UI 直接从 shadcn 组件组合 Flutter 页面，不再强制先画 Figma 原型。
- [shadcn/ui](https://ui.shadcn.com/docs) 是基础组件与语义来源；[awesome-shadcn-ui](https://github.com/birobirobiro/awesome-shadcn-ui) 作为扩展模式和素材的发现目录。外部候选必须单独核验许可证，并用现有 Flutter `shadcn_ui`、Lucide 和项目令牌重新实现，不能直接复制 React/Tailwind 代码或混入第二套 UI 框架。
- Figma、静态视觉稿或代码实验只用于品牌素材、复杂交互或高风险方向比较。
- UI PR 附关键状态截图、测试结果和已知限制；完整流程见 [功能开发流程](docs/development-workflow.md)。

## 已实现的开发基础

- 四个学习维度共用的 0—5 分箱复习算法；
- 忘记、模糊、记得、使用提示和同日补救上限规则；
- 课程内容 JSON Schema；
- 稳定 ID、跨引用、对话可达性和资产发布状态校验；
- “点咖啡”第一课 Draft 内容包；
- 可部署的 Go API、健康/就绪/版本接口和多阶段 Dockerfile；
- Riverpod + go_router App 外壳、Journey 到点咖啡课程概览的最小导航；
- `shadcn_ui` 语义主题、Journey 和八步课程播放器的代码优先 UI；
- 课程步骤按独立组件拆分，持久化和错误处理收敛到 Controller；
- Flutter Widget 测试和 `learning_core` 路径依赖接入；
- Drift v1 本地表、schema snapshot、数据库约束和迁移验证测试；
- 从安装包加载、校验并按稳定 ID 查询版本化课程内容的 Repository；
- 事务写入课程进度、练习/口语尝试、四维掌握状态和同步 Outbox 的进度 Repository；
- 按失败记录、听力/声调薄弱项和到期时间排序，并通过 v1 分箱调度提交结果的本地复习队列 Repository；
- Journey 真实到期入口、每日 8 项必做上限、四维复习卡、忘记/模糊/记得反馈、同轮补救与本地保存失败重试；
- 在认读后完成字模临摹、隐藏字模默写、对照自评并写入 `hanzi` 掌握度的本地书写步骤；
- GitHub Actions 移动端、学习核心、内容校验和 API 容器构建流程。

## 文档

- [Agent 项目入口](AGENTS.md)
- [产品与架构基线](docs/architecture.md)
- [运行与验收手册](docs/runbooks/README.md)
- [开发方案](docs/开发方案.md)
- [功能开发流程](docs/development-workflow.md)
- [代码优先 UI 系统](docs/design-system.md)
- [项目现状与代码审视](docs/project-status.md)
- [AI agents 项目交接](docs/handoff/ai-agent-handoff.md)
- [自研托管容器后端 ADR](docs/decisions/0001-managed-container-backend.md)
- [代码优先 shadcn UI ADR](docs/decisions/0002-code-first-shadcn-ui.md)
- [课程内容制作指南](docs/content-authoring.md)
- [独立开发者一期产品方案](new-chat/outputs/英语使用者学中文App一期方案.md)
- [竞品机制摘要](new-chat/work/中英语言学习竞品-资料/summary/00-产品机制摘要.md)
- [海外中文学习产品资料](new-chat/work/中英语言学习竞品-资料/raw/01-海外中文学习产品.md)
- [国内英语学习产品资料](new-chat/work/中英语言学习竞品-资料/raw/02-国内英语学习产品.md)

## 仓库结构

```text
.
├─ AGENTS.md                         # 短、准、稳定的项目级 Agent 入口
├─ HANDOFF.md                        # 唯一实时交接状态
├─ AGENT_LESSONS.md                  # 去重后的项目纠错经验
├─ README.md
├─ .agents/skills/                   # 可复用的项目级 Codex 工作流
├─ .codex/
│  ├─ config.toml                    # 可信仓库内的 Codex 配置
│  └─ hooks/                         # 工具调用前的机械护栏
├─ .github/workflows/                # 远端 CI
├─ tools/scripts/                    # 人工可调用的确定性验证脚本
├─ content/                          # 课程 Schema、Fixture 与局部 AGENTS.md
├─ docs/
│  ├─ AGENTS.md                      # 文档区域局部规则
│  ├─ architecture.md                # 稳定产品与架构基线
│  ├─ 开发方案.md
│  ├─ development-workflow.md
│  ├─ design-system.md
│  ├─ handoff/                        # 详细且相对稳定的 Agent 基线
│  ├─ decisions/                      # 架构决策记录
│  ├─ runbooks/                       # 可执行运行与验收步骤
│  └─ content-authoring.md
├─ packages/
│  └─ learning_core/                 # 纯 Dart 学习规则、校验器与局部规则
├─ apps/
│  └─ mobile/                        # Flutter Android/iOS App 与局部规则
├─ services/
│  └─ api/                           # 自研 Go 单体 API、容器与局部规则
└─ new-chat/
   ├─ outputs/                        # 已确认的一期产品方案
   └─ work/中英语言学习竞品-资料/      # 调研原始资料与摘要
```

根 `AGENTS.md` 只负责规则与路由；进入 `apps/mobile`、`content`、`packages/learning_core`、`services/api` 或 `docs` 后，继续应用该目录下的局部 `AGENTS.md`。重复验证优先调用 `$verify-mandarin-mission` 或 `tools/scripts/verify.ps1`。

## 当前使用方式

Flutter App：

```bash
cd apps/mobile
flutter pub get
dart run build_runner build
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build apk --debug
flutter run
```

Android application ID 与 iOS bundle ID 均为 `com.hieronymusf.mandarinmission`。
Android 本地构建基线为 JDK 17、Android SDK/API 36、Build Tools 36.0.0 和 NDK 28.2.13676358；在新电脑上先用 `flutter doctor -v` 确认工具链。

学习核心与内容校验：

```bash
cd packages/learning_core
dart pub get
dart format --output=none --set-exit-if-changed .
dart analyze --fatal-infos
dart test
dart run bin/validate_content.dart ../../content/fixtures
```

API 需要 Go 1.26：

```bash
cd services/api
go test ./...
go run ./cmd/api
```

启动后可访问 `http://127.0.0.1:8080/healthz`、`/readyz` 和 `/v1/meta`。容器构建命令与配置边界见 [API README](services/api/README.md)。

本地验证基线为 Flutter 3.44.6 自带的 Dart 3.12.2。开发前请先阅读 `AGENTS.md`、开发方案和一期产品方案。

## 路线图

- [x] 建立学习核心、复习算法、内容 Schema/校验器和核心 CI。
- [x] 建立自研 Go API 容器骨架与架构成本护栏。
- [x] 建立 Flutter 移动端工程并接入学习核心。
- [x] 建立 Drift 本地表与 migration 测试。
- [x] 建立课程内容 Repository/加载层。
- [x] 实现数据驱动的课程步骤。
- [x] 持久化课程练习结果和四维掌握状态。
- [x] 建立本地到期复习队列数据层并接入 v1 分箱调度。
- [x] 建立代码优先的 shadcn UI 基线并迁移现有页面。
- [x] 实现本地到期复习 UI 与 Journey 入口。
- [x] 为“点咖啡”补齐简单汉字临摹与脱稿书写。
- [ ] 完成“点咖啡”端到端垂直切片。
- [ ] 扩展到 3 个地点、12 节课并开展封闭测试。
- [ ] 根据激活、D1/D7 留存和 7 日回忆率决定是否扩展公开 MVP。
- [ ] 完成 6 个地点、订阅、同步和商店发布。

## 许可

当前仓库尚未选择开源协议。在添加明确的 `LICENSE` 文件前，默认保留所有权利；不要将仓库内容视为已获开源授权。
