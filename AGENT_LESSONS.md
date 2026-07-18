# Mandarin Mission Agent Lessons

仅保留可复用、项目特定且未被其他规则完整覆盖的经验。新增前先搜索并合并重复项。

## Lesson: PR 改基线后显式触发 CI

- Last confirmed: 2026-07-18
- Pattern: 堆叠 PR 改为以 `main` 为基线后，GitHub 的 `pull_request` 工作流不会仅因 base branch 被编辑而自动运行。
- Prevention rule: PR 改基线后检查工作流触发类型；若没有新运行，关闭并重新打开 PR，或推送新提交触发 `reopened`/`synchronize`，再等待全部 job 完成。
- Verification: 在 GitHub 检查该 PR 对应的 `mobile`、`learning-core`、`api` 三项 job 都属于最新 head SHA 且最终通过。
- Evidence: PR #11、#12 改基线后的 CI 触发与合并验证。
- Status: active
- Promoted to: none

## Lesson: 滚动容器中的书写画布必须主动接管手势

- Last confirmed: 2026-07-18
- Pattern: 汉字书写画布位于可滚动课程页中时，竖向笔画可能被父级滚动手势竞争，导致笔迹中断或页面移动。
- Prevention rule: 自定义书写画布应尽早接管指针序列，并保留清除、重写、跳过与对照自评路径。
- Verification: 在 Android 设备或模拟器上分别验证横、竖、斜笔画连续，页面不随书写滚动；再运行对应 Widget 测试。
- Evidence: `apps/mobile/lib/features/lesson/presentation/steps/hanzi_writing_step.dart` 与汉字书写 Android 交互验收。
- Status: active
- Promoted to: none

## Lesson: PowerShell 明确使用 UTF-8 读取中文项目文档

- Last confirmed: 2026-07-18
- Pattern: Windows PowerShell 默认编码可能把 UTF-8 中文 Markdown 输出为乱码，进而污染判断或后续编辑。
- Prevention rule: 读取中文项目文档时使用 `Get-Content -Raw -Encoding utf8`；写入后检查 diff 中的中文和换行。
- Verification: 读取结果中文可辨认，`git diff --check` 通过，diff 中没有大面积无关字符变化。
- Evidence: 新对话交接三件套准备过程中的编码核验。
- Status: active
- Promoted to: `AGENTS.md` 与 `docs/handoff/ai-agent-handoff.md` 的启动命令示例
