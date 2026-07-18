# Mandarin Mission 项目交接

> 最后更新：2026-07-18 18:45（Asia/Hong_Kong）
> 项目：`D:\mandarin-mission\mandarin-mission`
> 分支/工作树：`chore/handoff-protocol`（基于 `feat/hanzi-writing`）

本文件是本项目唯一的实时交接入口。每次新对话或新任务必须先按根目录 `AGENTS.md` 的顺序读取全局协议、本文件和 `docs/handoff/ai-agent-handoff.md`，再核验仓库与 GitHub 当前状态。`docs/handoff/ai-agent-handoff.md` 保存详细且相对稳定的项目基线，不与本文件竞争实时状态。

## 当前正在做什么

- M1“本地到期复习 UI”已经完成，草稿 PR [#10](https://github.com/HieronymusF/mandarin-mission/pull/10) 以 `feat/local-review-ui` 指向 `main`，三个 CI job 均通过。
- 汉字书写模块已经完成，草稿 PR [#11](https://github.com/HieronymusF/mandarin-mission/pull/11) 以 `feat/hanzi-writing` 指向 `feat/local-review-ui`。
- 跨对话交接协议已经补齐，正在作为独立堆叠改动提交和推送；完成后继续 M1 的音频与录音基础能力。

## 已经完成了什么

- 工程基线、代码优先 UI 基线、八步“点咖啡”课程、四维本地复习和汉字临摹/默写/对照自评已经实现。
- 汉字书写实现提交为 `8789860`，文档同步提交为 `8bb8090`。
- 汉字书写本地验证已通过：Flutter format/analyze/31 tests/debug APK；learning_core format/analyze/19 tests/content validate；Android 模拟器完整交互与 200% 字号验收。
- PR #10 的 `mobile`、`learning-core`、`api` GitHub Actions 均为成功。
- 已新增本文件作为唯一实时交接入口，并在 `AGENTS.md` 与 `docs/handoff/ai-agent-handoff.md` 固化每次对话的强制启动和收尾流程。

## 卡在了哪里

- 无功能阻塞。
- PR #11 是堆叠 PR；现有 workflow 只监听目标为 `main` 的 pull request，因此在指向 `feat/local-review-ui` 时不会自动运行 CI。PR #10 合并后将 #11 改为指向 `main`，再等待 CI。

## 下一步要做什么

1. 审查并合并本交接协议改动。
2. 审查并合并 PR #10；随后把 PR #11 的 base 改为 `main`，运行并确认全部 CI。
3. 按 `docs/development-workflow.md` 进入 M1 的真人音频播放、本地录音、回放、权限和不可用降级模块。
4. 在真实 Android 设备验证课程 → 杀进程 → 进度保留 → 到期复习，以及媒体中断恢复和飞行模式。

## 哪些坑不要再踩

- 每次新对话都必须完整执行：全局 `C:\Users\Jerome\.codex\HANDOFF.md` → 项目 `AGENTS.md` → 本文件 → `docs/handoff/ai-agent-handoff.md` → Git/外部状态核验；不能因为“已经熟悉”跳过。
- 不把聊天记录或旧交接中的分支、PR、测试结果直接当作当前事实；先用仓库和 GitHub 核验。
- 实时状态只更新本文件；详细架构和长期基线更新 `docs/handoff/ai-agent-handoff.md`，不要创建第二份实时交接。
- 不覆盖用户改动，不批量删除，不使用破坏性 Git 命令，不强制推送。
