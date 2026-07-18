# Mandarin Mission 项目交接

> 最后更新：2026-07-18 19:07（Asia/Hong_Kong）
> 项目：`D:\mandarin-mission\mandarin-mission`
> 分支/工作树：`main`，与 `origin/main` 同步

本文件是本项目唯一的实时交接入口。每次新对话或新任务必须先按根目录 `AGENTS.md` 的顺序读取全局协议、本文件和 `docs/handoff/ai-agent-handoff.md`，再核验仓库与 GitHub 当前状态。`docs/handoff/ai-agent-handoff.md` 保存详细且相对稳定的项目基线，不与本文件竞争实时状态。

## 当前正在做什么

- M1“本地到期复习 UI”、汉字书写模块和跨对话交接协议已经全部合并到 `main`。
- 当前下一模块是 M1 的真人音频播放、本地录音、回放、权限和媒体不可用降级。

## 已经完成了什么

- 工程基线、代码优先 UI 基线、八步“点咖啡”课程、四维本地复习和汉字临摹/默写/对照自评已经实现。
- 汉字书写实现提交为 `8789860`，文档同步提交为 `8bb8090`。
- 汉字书写本地验证已通过：Flutter format/analyze/31 tests/debug APK；learning_core format/analyze/19 tests/content validate；Android 模拟器完整交互与 200% 字号验收。
- 已新增本文件作为唯一实时交接入口，并在 `AGENTS.md` 与 `docs/handoff/ai-agent-handoff.md` 固化每次对话的强制启动和收尾流程。
- 交接协议实现提交为 `d66cc9a docs: enforce project handoff protocol`。
- PR [#10](https://github.com/HieronymusF/mandarin-mission/pull/10) 已合并，merge commit 为 `a7db316`。
- PR [#11](https://github.com/HieronymusF/mandarin-mission/pull/11) 已在 `mobile`、`learning-core`、`api` 全部通过后合并，merge commit 为 `a5cdc29`。
- PR [#12](https://github.com/HieronymusF/mandarin-mission/pull/12) 已在三项 CI 全部通过后合并，merge commit 为 `5b20cd5`。

## 卡在了哪里

- 无功能阻塞。
- M1 仍未达成：真人音频、录音/回放、权限流程、正式资产和真实设备持久化/飞行模式验收尚未完成。

## 下一步要做什么

1. 从最新 `main` 建立独立功能分支，按 `docs/development-workflow.md` 定义音频与录音模块的需求、状态和平台契约。
2. 实现真人课程音频播放、本地录音、回放、权限和媒体不可用降级。
3. 在真实 Android 设备验证媒体权限、来电/切后台中断和恢复。
4. 完成课程 → 杀进程 → 进度保留 → 到期复习及飞行模式验收。

## 哪些坑不要再踩

- 每次新对话都必须完整执行：全局 `C:\Users\Jerome\.codex\HANDOFF.md` → 项目 `AGENTS.md` → 本文件 → `docs/handoff/ai-agent-handoff.md` → Git/外部状态核验；不能因为“已经熟悉”跳过。
- 不把聊天记录或旧交接中的分支、PR、测试结果直接当作当前事实；先用仓库和 GitHub 核验。
- 实时状态只更新本文件；详细架构和长期基线更新 `docs/handoff/ai-agent-handoff.md`，不要创建第二份实时交接。
- 不覆盖用户改动，不批量删除，不使用破坏性 Git 命令，不强制推送。
