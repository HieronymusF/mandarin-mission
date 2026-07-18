# Mandarin Mission 项目交接

> 最后更新：2026-07-18 19:35（Asia/Hong_Kong）
> 项目：`D:\mandarin-mission\mandarin-mission`
> 分支/工作树：`docs/new-conversation-handoff`，跟踪 `origin/docs/new-conversation-handoff`

本文件是本项目唯一的实时交接入口。每次新对话或新任务必须先按根目录 `AGENTS.md` 的顺序读取全局协议、本文件、`AGENT_LESSONS.md` 和 `docs/handoff/ai-agent-handoff.md`，再核验仓库与 GitHub 当前状态。`AGENT_LESSONS.md` 保存去重后的项目特定复用经验；详细且相对稳定的项目基线在 `docs/handoff/ai-agent-handoff.md`。

## 当前正在做什么

- 新对话交接三件套已经准备完成：本文件已刷新，反思已归因，根目录 `AGENT_LESSONS.md` 已创建并接入启动协议。
- 本次只修改连续性文档与启动协议，不修改产品代码；完成后下一模块仍是 M1 的真人音频播放、本地录音、回放、权限和媒体不可用降级。

## 已经完成了什么

- 工程基线、代码优先 UI 基线、八步“点咖啡”课程、四维本地复习和汉字临摹/默写/对照自评已经实现。
- 汉字书写实现提交为 `8789860`，文档同步提交为 `8bb8090`。
- 汉字书写本地验证已通过：Flutter format/analyze/31 tests/debug APK；learning_core format/analyze/19 tests/content validate；Android 模拟器完整交互与 200% 字号验收。
- 已新增本文件作为唯一实时交接入口，并在 `AGENTS.md` 与 `docs/handoff/ai-agent-handoff.md` 固化每次对话的强制启动和收尾流程。
- 交接协议实现提交为 `d66cc9a docs: enforce project handoff protocol`。
- PR [#10](https://github.com/HieronymusF/mandarin-mission/pull/10) 已合并，merge commit 为 `a7db316`。
- PR [#11](https://github.com/HieronymusF/mandarin-mission/pull/11) 已在 `mobile`、`learning-core`、`api` 全部通过后合并，merge commit 为 `a5cdc29`。
- PR [#12](https://github.com/HieronymusF/mandarin-mission/pull/12) 已在三项 CI 全部通过后合并，merge commit 为 `5b20cd5`。
- `main` 最后一次交接刷新提交为 `8ebcb77`，当时本地与 `origin/main` 同步，main push CI 三项 job 全部通过。
- 已按 `maintain-project-continuity` 建立根目录 `AGENT_LESSONS.md`，并把它接入 `AGENTS.md` 与详细交接基线的强制启动顺序。
- 交接三件套首个提交为 `7e91ace docs: prepare cross-session handoff`；草稿 PR [#13](https://github.com/HieronymusF/mandarin-mission/pull/13) 以 `main` 为基线。

## 卡在了哪里

- 无功能阻塞。
- PR #13 尚待 CI 和用户确认后合并。
- M1 仍未达成：真人音频、录音/回放、权限流程、正式资产和真实设备持久化/飞行模式验收尚未完成。

## 下一步要做什么

1. 新对话先按强制启动顺序核验 PR #13、CI、分支与工作树。
2. 经用户确认后合并 PR #13，并从最新 `main` 建立音频功能分支。
3. 按 `docs/development-workflow.md` 定义音频与录音模块的需求、状态和平台契约，再实现真人课程音频播放、本地录音、回放、权限和媒体不可用降级。
4. 在真实 Android 设备验证媒体权限、来电/切后台中断和恢复。
5. 完成课程 → 杀进程 → 进度保留 → 到期复习及飞行模式验收。

## 哪些坑不要再踩

- 每次新对话都必须完整执行：全局 `C:\Users\Jerome\.codex\HANDOFF.md` → 项目 `AGENTS.md` → 本文件 → `AGENT_LESSONS.md` → `docs/handoff/ai-agent-handoff.md` → Git/外部状态核验；不能因为“已经熟悉”跳过。
- 不把聊天记录或旧交接中的分支、PR、测试结果直接当作当前事实；先用仓库和 GitHub 核验。
- 实时状态只更新本文件；复用经验去重后更新 `AGENT_LESSONS.md`；详细架构和长期基线更新 `docs/handoff/ai-agent-handoff.md`，不要创建第二份实时交接或流水账式反思文件。
- 堆叠 PR 改 base 后不能假定 CI 自动运行；必须核验最新 head SHA 的 job，必要时关闭并重新打开 PR 触发。
- PowerShell 读取中文 Markdown 时显式使用 `-Encoding utf8`。
- 不覆盖用户改动，不批量删除，不使用破坏性 Git 命令，不强制推送。
