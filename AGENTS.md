# Mandarin Mission Agent Guide

本文件只保存每个代理都必须遵守的稳定规则。产品、架构、运行与验证细节分别放在 `docs/`、局部 `AGENTS.md`、项目 Skills 和自动化脚本中；实时进度只放根目录 `HANDOFF.md`。

## 项目定位

- 产品：面向英语使用者的零基础简体普通话学习 App，核心体验是每天约 10 分钟完成真实场景中的理解、听辨和开口任务。
- 团队：一人独立开发；优先控制开发量、内容量、服务成本和长期维护成本。
- 当前范围、阻塞和下一步以 `HANDOFF.md` 为准，不在本文件复制实时状态。
- 稳定产品与技术边界见 `docs/architecture.md`；完整方案见 `docs/开发方案.md`。

## 开始任务

每次新任务或上下文恢复按顺序完成：

1. 阅读全局 `C:\Users\Jerome\.codex\HANDOFF.md`。
2. 阅读本文件、根目录 `HANDOFF.md` 和 `AGENT_LESSONS.md`。
3. 阅读 `repo-docs/README.md`；需要理解主流程时继续读 `repo-docs/walkthroughs/one-real-run.md`。
4. 运行 `git status -sb` 与 `git log -5 --oneline --decorate`，保护现有改动并核验交接状态。
5. 只读取与任务有关的文档和最近的局部 `AGENTS.md`；使用 `rg --files` 验证真实目录。
6. 涉及 GitHub、第三方 SDK、商店规范、价格或云能力时，使用当前官方来源核验，不把旧记录当成事实。

文档与代码冲突时，以测试、提交历史和实际运行证据判断当前事实，再修正文档；不要静默猜测。

## 知识路由

| 需要知道什么 | 权威入口 |
| --- | --- |
| 当前正在做什么、卡点、下一步 | `HANDOFF.md` |
| 可复用的项目纠错经验 | `AGENT_LESSONS.md` |
| 产品边界、技术基线、架构不变量 | `docs/architecture.md` |
| 详细开发方案与阶段计划 | `docs/开发方案.md` |
| 功能从立项到交付的流程 | `docs/development-workflow.md` |
| 运行、验证、真机验收 | `docs/runbooks/` |
| 不可轻易逆转的架构决定 | `docs/decisions/` |
| 人类可读的真实行为与代码地图 | `repo-docs/` |
| UI 组件、布局和视觉验证 | `WIDGET_LIBRARY.md`、`docs/design-system.md` |
| 课程内容制作 | `docs/content-authoring.md` |
| 详细环境与已完成基线 | `docs/handoff/ai-agent-handoff.md`、`docs/project-status.md` |

## 局部规则

Codex 会把根规则与当前目录最近的局部规则合并。进入下列区域时必须读取对应文件：

- `apps/mobile/AGENTS.md`：Flutter、UI、数据持久化、媒体与移动端验证。
- `content/AGENTS.md`：课程 Schema、稳定 ID、资产许可与内容校验。
- `packages/learning_core/AGENTS.md`：纯 Dart 学习规则与算法测试。
- `services/api/AGENTS.md`：Go 单体 API、云边界与服务端验证。
- `docs/AGENTS.md`：文档归属、ADR、runbook 与实时状态边界。

## 工作方式

- 代码编写、Bug 修复、重构或代码审查前调用 `$karpathy-guidelines`。
- 非琐碎任务先说明假设、歧义、取舍和可观察成功标准。
- Bug 先建立可重复的失败证据；每一行修改都要能追溯到当前需求或失败证据。
- 优先复用现有代码、Flutter/Dart/Go 原生能力和已安装依赖；不为单次使用建立抽象，不预建空层或未来脚手架。
- 不用绿测试替代用户结果。UI Bug 必须保存相同页面、状态、viewport 和文字缩放下的修复前后证据。
- 新共享组件至少要有两个真实生产调用点；测试或文档引用不算生产复用。
- 功能任务按 `docs/development-workflow.md` 推进；验证优先调用项目 Skill `$verify-mandarin-mission` 或 `tools/scripts/verify.ps1`。

## 不可违反的边界

- App 本地优先；网络、语音和分析服务失败不能阻断核心课程。
- Flutter App 不直接连接 PostgreSQL；外部供应商必须通过 Service/Adapter/Provider 边界。
- 不在仓库、日志、分析事件或错误报告中记录密钥、Token、邮箱、原始录音、完整转写或购买票据。
- 真实 Secret 只进入本地环境、安全密钥库或 GitHub Secrets；仓库只允许提交 `.env.example`。
- 保留用户已有改动，不重置、不覆盖、不擅自清理工作区。
- 禁止批量删除文件或目录。不得使用 `del /s`、`rd /s`、`rmdir /s`、`Remove-Item -Recurse`、`rm -rf`；删除时一次只处理一个已确认的明确文件路径，需要批量删除时停止并请用户手动处理。
- 不使用 `git reset --hard`、破坏性 checkout、强制推送或静默 amend。
- 搜索优先使用 `rg`/`rg --files`；手工修改使用补丁方式。

项目级 `.codex` Hook 会拦截已知批量删除命令和一次删除多个文件的补丁。Hook 是补充护栏，不替代上述规则；首次使用或 Hook 变更后需要在 Codex `/hooks` 中复核并信任。

## Git 与交付

- 默认分支 `main` 必须保持可构建；功能使用独立分支和草稿 PR，除非用户明确要求，不直接提交到 `main`。
- 修改前后运行 `git status -sb`；工作区混杂时显式暂存本任务文件，禁止 `git add -A`。
- 可独立验收的小模块使用单独 Conventional Commit；不改写用户提交。
- 推送前运行与风险匹配的验证。创建 PR 后必须核验当前 head SHA 对应的 CI，不能把旧 CI 当作当前结果。
- “准备交接”默认只产生本地未提交改动；除非用户明确要求，不据此建分支、提交、推送、创建 PR 或合并。
- 交付时说明变更、验证、提交/推送状态和已知限制；不得虚报测试、真机、CI、提交或外部操作。

## Repo docs

The living project guide is in `repo-docs/`. Start with `repo-docs/README.md`; when `repo-docs/walkthroughs/one-real-run.md` exists, use it as the main behavior trace.

This repo's `repo-docs/` guide is reader-facing Chinese documentation. When updating reader-facing guide pages, use `repo-docs-zh` when available; keep Chinese reader handles in the prose and preserve exact source identifiers for lookup.

Repo-docs sync triggers before the final response: repo questions; architecture, onboarding, or "how does this work" answers; behavior-bearing code/config/data/script/test edits; user uncertainty or correction about stable project behavior; stable project knowledge discovered or clarified in conversation; and knowledge about to be written to memory.

When a trigger happens, run a foreground repo-docs sync gate before answering: use the `repo-docs` skill in Sync mode when available, or manually read the relevant guide pages, inspect current source, and decide `none`, `answer-only`, `foreground patch`, or `background sync`. Ordinary repo questions may be `answer-only` when the guide is current enough and the answer can cite inspected guide/source evidence. Patch the smallest owning guide page before the final response only when the current answer or edit would otherwise mislead, the guide says the opposite, or the missing stable knowledge is a small local patch.

If the needed guide work is broader and not required for the current answer to be correct, delegate it to a background `repo-docs` sync agent when the platform supports a real tracked handoff. The handoff must name the trigger, durable facts or changed source areas, candidate guide pages, verification to run, and the expected `repo-docs/change-log.md` update. If no background agent is available, answer from inspected source and mention the pending docs gap when it matters.

When behavior-bearing code, config, data, scripts, or tests change, compare the change with the guide before finishing unless the user asked not to touch docs. Record meaningful guide updates in `repo-docs/change-log.md` with verification and `Synced through <sha>` when git is available.

## 连续性维护

- 长对话结束、任务切换、暂停、阻塞或当前状态发生实质变化时，先读取并更新唯一的根 `HANDOFF.md`。
- 有复用价值的纠正先分类为 `information-gap`、`reasoning-error`、`execution-gap` 或 `stale-state`，再去重合并到 `AGENT_LESSONS.md`。
- 稳定产品/技术规则改变时更新 `docs/architecture.md` 与相应方案；不可逆架构决定写入 `docs/decisions/`。
- 当前阶段或运行方式改变时更新 README；不要在根 `AGENTS.md` 复制实时进度或详细机制。
