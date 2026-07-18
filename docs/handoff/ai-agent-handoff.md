# Mandarin Mission：AI Agents 项目交接

> 本文件适用于 Codex、Claude Code 和其他能修改仓库的 AI agents。
> 最近核验：2026-07-18，分支 `feat/code-first-ui`，已验证 UI 提交 `293e9dd`，草稿 PR [#9](https://github.com/HieronymusF/mandarin-mission/pull/9)。

## 1. 接手顺序

开始修改前依次完成：

1. `git status -sb`，保留用户和其他 agents 的已有改动；
2. `git log -5 --oneline`，确认本文件之后是否已有新提交；
3. 阅读根目录 `AGENTS.md`；
4. 阅读 `README.md`、`docs/project-status.md`；
5. UI 任务阅读 `docs/design-system.md` 和 `docs/development-workflow.md`；
6. 产品或教学机制任务阅读 `docs/开发方案.md` 和 `new-chat/outputs/英语使用者学中文App一期方案.md`；
7. 用 `rg --files` 检查真实目录，不根据本文臆测文件存在；
8. 文档与代码冲突时，以测试、实际运行和最新提交为准，再修正文档。

不要把聊天记录当成项目事实来源。本文件只保存可复现、可验证的当前上下文。

## 2. 项目一句话

Mandarin Mission 是面向英语使用者的零基础简体普通话学习 App。用户每天用约 10 分钟，在城市旅行场景中完成新课、到期复习和开口任务，最终做到“看得懂、听得出、说得出”。

一期边界：

- Flutter 移动端，Android 优先，随后 iOS；
- 英语界面、普通话、简体中文；
- 本地优先，短时断网不得阻断已下载课程和复习；
- 一人独立开发，控制代码量、内容量、云成本和长期维护成本；
- 不做排行榜、好友、公会、实时 PK、抽卡、复杂商城或无限制 AI 对话。

## 3. 当前 Git 状态

- 仓库：`https://github.com/HieronymusF/mandarin-mission`
- 当前功能分支：`feat/code-first-ui`
- 草稿 PR：`https://github.com/HieronymusF/mandarin-mission/pull/9`
- 最近已验证实现提交：`293e9dd fix(ui): unify page alignment and spacing`
- 该提交的 GitHub Actions：`mobile`、`learning-core`、`api` 全部通过；
- 当前分支不要直接合并到 `main`，除非用户明确要求；
- 新工作应按模块独立提交；不要 amend 他人提交，不强制推送。

接手后若分支、PR 或提交已变化，以 `git status`、`git log` 和 GitHub 当前状态更新本节。

## 4. 当前电脑开发环境

当前电脑的开发工具主要位于 D 盘：

| 工具 | 当前路径/版本 |
|---|---|
| 仓库 | `D:\mandarin-mission\mandarin-mission` |
| Flutter | `D:\mandarin-mission\Dev\sdk\flutter`，3.44.6 stable |
| Dart | Flutter 自带 3.12.2 |
| JDK | `D:\mandarin-mission\Dev\sdk\jdk-17`，Temurin 17 |
| Android SDK | `D:\AndroidSDK`，API/Build Tools 36 |
| Android AVD | `flutter_emulator` |
| Pub cache | `D:\mandarin-mission\Dev\pub-cache` |
| Go | `D:\mandarin-mission\Dev\sdk\go\go`，1.26.5 |
| Docker | `D:\mandarin-mission\Dev\docker-desktop`，29.6.1 |
| ripgrep | `D:\mandarin-mission\Dev\tools\ripgrep` |

PowerShell 会话可使用：

```powershell
$env:ANDROID_HOME = 'D:\AndroidSDK'
$env:ANDROID_SDK_ROOT = $env:ANDROID_HOME
$env:JAVA_HOME = 'D:\mandarin-mission\Dev\sdk\jdk-17'
$env:PUB_CACHE = 'D:\mandarin-mission\Dev\pub-cache'

& 'D:\mandarin-mission\Dev\sdk\flutter\bin\flutter.bat' doctor -v
```

启动模拟器：

```powershell
Start-Process -FilePath 'D:\AndroidSDK\emulator\emulator.exe' `
  -ArgumentList @('-avd', 'flutter_emulator', '-gpu', 'auto')
```

Windows 桌面开发所需的 Visual Studio 未安装，这是已知且不影响 Android/iOS 目标的 `flutter doctor` 提示。

## 5. 常用验证命令

Flutter：

```powershell
Set-Location apps/mobile
flutter pub get
dart run build_runner build
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build apk --debug
```

学习核心与内容校验：

```powershell
Set-Location packages/learning_core
dart pub get
dart format --output=none --set-exit-if-changed .
dart analyze --fatal-infos
dart test
dart run bin/validate_content.dart ../../content/fixtures
```

Go API：

```powershell
Set-Location services/api
go vet ./...
go test ./...
docker build -t mandarin-mission-api .
```

生成文件门禁：

- 修改 Drift 表后提升 `schemaVersion`；
- 运行 `dart run build_runner build` 和 `dart run drift_dev make-migrations`；
- `app_database.g.dart`、schema snapshot 和 `test/drift/generated/` 必须一起提交；
- 不手工编辑生成文件；
- 提交前运行 `git diff --check`。

## 6. 架构地图

```text
apps/mobile/
  lib/app/                         App 启动与 go_router
  lib/core/theme/                  颜色、字体、spacing、尺寸
  lib/data/                        Drift、内容、进度、复习 Repository
  lib/features/<feature>/          功能内 application/presentation
  lib/shared/presentation/         真正跨功能的 UI 组合组件
  test/                            Widget、Repository、迁移与端到端测试

packages/learning_core/            纯 Dart 学习规则和内容校验
content/                           课程 Schema、Fixture 和未来正式资产
services/api/                      Go 单体 API
docs/                              流程、设计系统、ADR、项目状态和交接
```

分层不变量：

- View 只渲染状态和转发意图；
- Controller/ViewModel 处理提交、判分、失败和重试；
- Repository 统一本地/远端数据访问；
- 纯规则进入 `learning_core` 或纯 Dart domain，并写单元测试；
- 用户操作先写本地事务和 Outbox，UI 不等待云端成功；
- 外部供应商经 Adapter/Provider 接入，业务代码不散落 SDK 调用；
- Flutter App 不直接连接 PostgreSQL。

## 7. 已完成，不要重做

### 学习核心与内容

- `packages/learning_core/lib/src/review_scheduler.dart`：0—5 分箱调度；
- 忘记 −2、模糊不变、记得 +1、提示后不升级、同日补救最多两次；
- `content_validator.dart`：稳定 ID、引用、拼音、对话可达性和资产状态校验；
- `content/schema/course-package.schema.json`：课程数据契约；
- `content/fixtures/cafe-course.json`：当前“点咖啡”Draft Fixture。

### 移动端数据层

- Drift v1 六张本地表和 migration snapshot；
- 安装包课程 Repository；
- `LessonProgressRepository`：课程、练习、口语、掌握度和 Outbox 事务写入；
- `ReviewQueueRepository`：本地到期查询、优先级排序和调度提交；
- Riverpod Provider 已接入数据库、内容、进度和复习队列。

### 课程播放器

- Journey 到七步“点咖啡”流程可以完整跑通；
- scene、teach、listen、repeat、dialogue、summary 已拆成独立步骤组件；
- `LessonPlayerController` 管理提交中、保存失败、重试和完成；
- 听力提示 `usedListeningHint` 已正确写入持久化；
- 语音服务不可用时已有本地自评降级路径。

### UI 基线

- 运行依赖固定为 `shadcn_ui: 0.55.0`；
- `app_theme.dart`：语义颜色、字体、圆角和反馈状态；
- `app_layout.dart`：`4/8/12/16/20/24/32` spacing、640 最大内容宽度、卡片 padding、图标槽和控件高度；
- `AppLeadingRow` / `AppIconTile`：固定图标区域和稳定文本列；
- 全宽卡片不使用会导致漂移的 `ShadCard.leading/trailing`；
- 汉字拼音组按父容器居中；
- Widget 测试覆盖 `768/1024/1280/1440` 逻辑像素宽度；
- Android 模拟器已复核 Journey、听力反馈、口语重复、语音降级、对话和总结页。

### 后端与 CI

- Go API 有 `/healthz`、`/readyz`、`/v1/meta`；
- Dockerfile 可构建；
- GitHub Actions 三个 job 覆盖 mobile、learning-core/content 和 api。

## 8. UI 选材与实现规则

UI 单一执行基线：

1. `docs/design-system.md`；
2. `apps/mobile/lib/core/theme/app_theme.dart`；
3. `apps/mobile/lib/core/theme/app_layout.dart`；
4. `apps/mobile/lib/shared/presentation/`。

外部来源：

- [shadcn/ui](https://ui.shadcn.com/docs)：基础组件、命名和状态语义；
- [awesome-shadcn-ui](https://github.com/birobirobiro/awesome-shadcn-ui)：扩展组件、Registry、主题、动画和跨框架方案的发现目录；
- Flutter 实现继续使用当前 `shadcn_ui`、Lucide 和项目组合组件。

重要边界：

- `awesome-shadcn-ui` 是导航目录，不是可以整体加入 Flutter 的素材包；
- 目录仓库的 MIT 许可证不覆盖其链接项目；
- 采用候选前回到原始来源核验许可证、维护状态、移动端适用性和无障碍；
- 不复制 React、Tailwind、Radix 或 Framer Motion 代码进 Flutter；
- 不混入 Forui 等第二套完整 Flutter UI 框架；
- 正式图标、插画、音频和其他资产必须记录原始来源、许可证和署名；
- 标准按钮、卡片、徽章、进度和反馈直接用代码组合，不先画 Figma；
- 只有品牌素材、复杂交互、高风险方向比较或用户明确要求时才使用 Figma/静态稿。

每个外部 UI 候选至少记录：

- 原始 URL；
- 视觉/交互/代码/资产用途；
- 原项目许可证和核验日期；
- 对应的 Flutter 原语或项目共享组件；
- Web 到移动端的差异；
- 截图和验证结果。

## 9. 当前里程碑

M0 工程基线：已完成。
M0.5 代码优先 UI 基线：已完成。
M1 “点咖啡”端到端垂直切片：未完成。

M1 剩余放行条件：

1. 到期复习 UI 与 Journey 入口；
2. 真人课程音频；
3. 本地录音、回放与明确权限流程；
4. 音频/语音服务不可用时不阻断课程；
5. 缺失步骤类型和正式资产；
6. 真实 Android 设备完成课程 → 杀进程 → 进度保留 → 正确时间出现复习；
7. 飞行模式完成已下载课程。

不要因为代码容易写而提前扩展地图、社交、付费或 AI 对话。

## 10. 当前最高优先级：到期复习 UI

这是一个 M 级、纯本地功能，不需要后端。

必须交付：

- 建立 `docs/requirements/review-ui.md`；
- Journey 显示真实到期复习入口；
- 新增 `/review` 路由和 presentation；
- 覆盖 `meaning/listening/tone/hanzi` 四维题型；
- 用户可以选择忘记/模糊/记得；
- 覆盖加载、无到期项、保存中、保存失败、重试和音频不可用；
- 复习中断或失败不丢已保存结果；
- 补 ViewModel/Controller、Widget 和端到端测试；
- 保存关键状态截图并在 Android 验证。

已经就绪：

- 算法：`packages/learning_core/lib/src/review_scheduler.dart`；
- 队列：`apps/mobile/lib/data/review/review_queue_repository.dart`；
- Provider：`apps/mobile/lib/features/review/application/review_providers.dart`；
- Drift：`MasteryStates` / `ReviewAttempts`；
- UI：主题、布局令牌、共享 leading row 和课程播放器状态模式。

产品约束：

- 单次复习控制在 3—5 分钟；
- 到期过多拆成“今日必做 + 额外巩固”；
- 忘记项在本次尾部补救，同日同项最多两次；
- meaning/listening 使用客观选择 + 记忆自评；
- tone/hanzi 一期可翻卡自评；
- 首次课程不能授予记忆星，至少跨学习日成功回忆一次。

## 11. 可并行的 Agent 工作与冲突边界

只有明确分配文件所有权后才并行。

| 工作流 | 可拥有范围 | 冲突提醒 |
|---|---|---|
| 复习 UI | `features/review/`、`app/router.dart`、对应测试 | Journey 入口会修改 `journey_page.dart`，其他 agent 不要同时改 |
| 学习纯规则 | `packages/learning_core/` | 不直接修改 Flutter UI；变更算法必须说明迁移 |
| 音频基础能力 | 新的 audio service/provider、平台权限配置 | 在接口稳定前不要与复习 agent 同时改 repeat/listen 页面 |
| 内容校验 | `content/`、`learning_core/content_validator*` | 不改稳定 ID；正式资产需要 license/credit/sha256 |
| Go API | `services/api/` | M1 本地复习不依赖后端，不要让 UI 等 API |
| 文档/QA | `docs/`、测试证据和截图清单 | 以最新代码和测试为准，不把计划写成完成 |

所有 agents 都必须：

- 知道自己不是唯一修改者；
- 不还原或覆盖其他人的工作；
- 遇到同一文件冲突时停止并协调；
- 提交前显式列出暂存文件，禁止 `git add -A`。

## 12. 已知技术债

按优先级：

### P0

- 到期复习没有 presentation 和路由；
- 音频/录音仍是占位或降级路径，未实现真实媒体能力。

### P1

- `_confidenceFor`、复习队列排序和部分 score 规则仍散落在 Repository/presentation，应迁移到纯 Dart 并补测试；
- Journey 动态进度、连胜和解锁尚未接真实状态；
- schema 定义 9 种步骤，播放器只实现其中 6 种。

### P2

- validator 与 schema 的 ready 资产 `sha256` 规则需要统一；
- `LessonPlayerController` 状态机缺独立单元测试；
- 通用文案尚未进入 i18n；
- Go API 只有骨架，`/readyz` 尚未连接真实依赖；
- `shadcn_ui` 为 `0.x`，升级必须单独 PR 并做截图回归。

完整证据见 `docs/project-status.md`。

## 13. Git、文件和安全规则

- 禁止批量删除文件或目录；
- 不使用 `del /s`、`rd /s`、`rmdir /s`、`Remove-Item -Recurse`、`rm -rf`；
- 需要删除时一次只删除一个明确文件；批量删除请用户手动处理；
- 不使用 `git reset --hard`、破坏性 checkout 或强制推送；
- 不提交 `.env`、密钥、Token、邮箱、原始录音或完整转写；
- 手工编辑使用补丁方式；
- 默认使用独立功能分支、Conventional Commit 和草稿 PR；
- UI PR 包含采用来源、组件映射、关键状态截图、测试和已知视觉差异。

## 14. 完成标准

一个任务只有同时满足以下条件才可交付：

1. 用户结果可以从真实入口重复完成；
2. 正常和相关失败/空/不可用状态已覆盖；
3. 相关 format、analyze、test、内容或容器检查通过；
4. 文档、Schema、migration 和生成文件已同步；
5. UI 遵守 design system，并有关键状态截图或 Golden/真实设备证据；
6. `git diff --check` 通过；
7. 工作区没有本任务遗漏；
8. 已独立提交并推送，CI 给出最终结果；
9. 交付说明写明变更、验证、提交和已知限制。

## 15. 新 Agent 的前 20 分钟

```powershell
Set-Location 'D:\mandarin-mission\mandarin-mission'
git status -sb
git log -5 --oneline
rg --files
```

然后：

1. 读 `AGENTS.md`、本文件和 `docs/project-status.md`；
2. 根据任务读取对应 requirements、ADR、设计系统或内容文档；
3. 运行最接近任务的现有测试，先建立绿色基线；
4. 明确文件所有权和不做范围；
5. 从最小失败测试或状态契约开始；
6. 完成一个可独立验收模块后立即提交和推送。

如果本文件与最新代码不一致，请在同一任务中修正本文件，不要把过期交接继续传给下一个 agent。
