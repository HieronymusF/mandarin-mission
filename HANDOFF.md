# Mandarin Mission 项目交接

> 最后更新：2026-07-22 12:47（Asia/Hong_Kong）
> 项目：`D:\mandarin-mission\mandarin-mission`
> 分支/工作树：`feat/audio-playback-recording`，音频模块功能分支

本文件是本项目唯一的实时交接入口。每次新对话或新任务必须先按根目录 `AGENTS.md` 的顺序读取全局协议、本文件、`AGENT_LESSONS.md` 和 `docs/handoff/ai-agent-handoff.md`，再核验仓库与 GitHub 当前状态。`AGENT_LESSONS.md` 保存去重后的项目特定复用经验；详细且相对稳定的项目基线在 `docs/handoff/ai-agent-handoff.md`。

## 当前正在做什么

- 音频播放与录音模块已提交并推送到 `origin/feat/audio-playback-recording`；本地分支跟踪远端，当前未创建 PR。
- `record` 包兼容性阻塞已解除，核心媒体架构、权限状态、录音回放、本地降级和内容资产路径接线已通过自动验证。
- 媒体组件级 Widget 测试与课程媒体生命周期自动清理已补齐，当前重点转为真人音频资产和真实 Android 设备验证。
- 已新增中文 `repo-docs/` living guide；后续行为代码或稳定项目认知变化要按 `AGENTS.md` 的 repo-docs sync gate 核对最小 owning page。
- UI 基线已扩展为可供 AI 直接调用的项目 Widget 库；后续页面和对齐修复必须按根目录 `WIDGET_LIBRARY.md` 执行。
- 已完成本轮开发方法纠偏并准备交给新对话：所有非琐碎任务先暴露假设和成功标准，Bug 先复现，修改保持精准，验证必须对应用户可见结果。

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
- 共享 UI 基线提交为 `85f3141`，音频/录音功能提交为 `602f2d7`，项目准则与 repo-docs 提交为 `e581459`；三笔均已推送到远端功能分支。
- 推送后远端 SHA 已与本地核对一致；`.github/workflows/core-ci.yml` 只监听 `main` push 和面向 `main` 的 PR，因此本次功能分支 push 没有产生 GitHub Actions 运行，不能写成远端 CI 已通过。
- 曾误建的 PR #13 已关闭且未合并，远端临时分支和本地临时提交均已移除，不影响 `main` 历史。
- `record` 已固定为 `7.1.1`；解析结果为 `record_linux 2.1.1`、`record_platform_interface 2.1.0`，与当前 Flutter 3.44.6 / Dart 3.12.2 兼容。
- 已修复设置页递归、本地录音被当作 asset 回放、权限分支不可达、dBFS 音量未归一化、录音到达时长上限后无法停止，以及播放结束后回放状态不复位。
- 课程音频不再硬编码文件名；`CoursePackage` 会从 `knowledgeItems[].audioAssetId` 解析 ready `assets[].path`，planned/缺失资源走明确降级。
- 已新增 `AppTextStyles` 并接入 shadcn theme；`AppSpacing`、`AppRadius`、`AppLayout` 和字体语义现在都有单一代码来源。
- 已新增 `AppContentFrame`、`AppPageScrollView`、`AppSection`、`AppListRow` 与 `app_widgets.dart` 统一入口；现有 `AppLeadingRow`、`AppIconTile`、`HanziPinyinText` 一并纳入库。
- 根目录 `WIDGET_LIBRARY.md` 已固化系统性父级布局修复、统一对齐基准、有限 spacing scale、魔法数字限制和 `768/1024/1280/1440` 响应式 QA。
- `AudioPlayerBar` 现在为 loading 状态显示进度反馈；`RecordingControls` 会让服务不可用降级优先于普通无权限提示。
- 新增 `media_controls_test.dart` 4 项 Widget 测试，覆盖播放加载/播放/暂停/错误、无资产降级、权限请求/拒绝/永久拒绝/服务不可用、录音/音量/回放/确认。
- 课程页现在会在 App 进入后台/非活动状态或用户离开页面时结束媒体会话：停止播放，取消录音或回放，并清理当前临时文件；重录前也会先清理旧文件。
- 新增 Controller 与课程页生命周期测试，覆盖停止/清理竞态、切后台和页面离开。
- 最新本地验证通过：Flutter format、analyze（0 issues）、46 tests、debug APK、repo-docs validator（0 errors / 1 既有 warning）、`git diff --check`。
- 使用 `repo-docs-zh` 创建 `repo-docs/README.md`、主 walkthrough、代码地图、三个机制模块、术语表、源码证据、质量复核和变更记录；validator 为 0 errors / 1 expected warning（代码地图按规则重复“重要代码”表头触发 broad-value 检查）。
- 已研究 [multica-ai/andrej-karpathy-skills](https://github.com/multica-ai/andrej-karpathy-skills) 的 README、`CLAUDE.md`、Skill 和示例；核验的 main HEAD 为 `2c606141936f1eeef17fa3043a72095b4765b9c2`（2026-04-20）。适合本项目的四项原则已写入 `AGENTS.md` 和 `docs/development-workflow.md`：编码前思考、简洁优先、精准修改、目标驱动执行。
- 已将此前 UI 处理方式分类为 `reasoning-error`（用通用组件/几何断言替代具体视觉问题复现）并伴随 `execution-gap`（没有修复前后视觉证据）；复用规则已写入 `AGENT_LESSONS.md` 和 `WIDGET_LIBRARY.md`。
- 本轮在既有未提交音频/UI 工作上补齐课程媒体生命周期停止与临时文件清理，并重新运行 Flutter 全量验证。

## 卡在了哪里

- 无代码构建阻塞。
- 尚无可发布的真人普通话音频文件；内容包内三个音频资产仍为 `planned`，因此 UI 正确显示音频不可用。
- 尚未在真实 Android 设备验证麦克风权限、录音、回放、音量提示、来电/切后台中断和恢复；自动停止/清理已有测试，但真机状态仍不得标记完成。
- 本轮 Widget 库有自动布局测试和 APK 构建证据，但当前没有连接 Android 设备，未新增真实设备视觉截图。
- `AppContentFrame`、`AppPageScrollView`、`AppSection`、`AppListRow` 当前只被测试和文档引用，没有真实生产页面调用；它们是部分完成的候选组件，不得当作已验证的生产抽象继续扩展。

## 下一步要做什么

1. **新对话先核验 Git 状态**：确认 `feat/audio-playback-recording` 与远端同步且工作树干净；不要把本文记录的提交或验证结果直接当作当前事实。
2. **处理候选布局组件**：在真实 UI 任务出现两个生产调用点时再采用；若长期只有测试/文档引用，不继续增加抽象，并在独立授权下考虑删除。
3. **加入真人音频资产**：获得内部录音或许可明确的普通话录音后，放入 App asset 目录，在内容 JSON 中写 `path`、`sha256`、`license`、`credit` 并把状态改为 `ready`；不得用未审核 TTS 冒充真人音频。
4. **真实设备测试**：在 Android 设备上验证：
   - 麦克风权限请求流程
   - 音频播放功能（播放、暂停、进度条）
   - 录音和回放功能
   - 音量检查和提示
   - 服务不可用时的降级路径
5. **真机生命周期验收**：验证来电、切后台、恢复和页面离开时的播放器/录音器状态与临时文件清理；自动停止/清理代码已完成，按真机结果做最小修正。
6. **按用户要求决定 PR**：当前分支已推送但未创建 PR；只有用户明确要求后才创建、标记 ready 或合并。创建面向 `main` 的 PR 后再等待并核验三项 CI。
7. **完成 M1 里程碑**：在真实设备完成课程 → 重启 → 进度保留 → 到期复习闭环。

## 哪些坑不要再踩

- 每次新对话都必须完整执行：全局 `C:\Users\Jerome\.codex\HANDOFF.md` → 项目 `AGENTS.md` → 本文件 → `AGENT_LESSONS.md` → `docs/handoff/ai-agent-handoff.md` → Git/外部状态核验；不能因为“已经熟悉”跳过。
- 不把聊天记录或旧交接中的分支、PR、测试结果直接当作当前事实；先用仓库和 GitHub 核验。
- 实时状态只更新本文件；复用经验去重后更新 `AGENT_LESSONS.md`；详细架构和长期基线更新 `docs/handoff/ai-agent-handoff.md`，不要创建第二份实时交接或流水账式反思文件。
- “准备交接”不等于授权 Git 发布；没有用户明确要求时只保留本地未提交改动。
- 堆叠 PR 改 base 后不能假定 CI 自动运行；必须核验最新 head SHA 的 job，必要时关闭并重新打开 PR 触发。
- PowerShell 读取中文 Markdown 时显式使用 `-Encoding utf8`。
- Flutter 联邦插件升级不能只看顶层包；必须核验平台实现与 platform interface 属于同一兼容代际，并跑目标平台完整构建。
- 课程媒体路径必须来自内容包 `audioAssetId → assets[].path`，不能在 Widget 中根据 item ID 猜文件名。
- UI 任务必须先读根目录 `WIDGET_LIBRARY.md`；错位先修父容器、Flex/constraints 和统一 token，不用逐元素 margin、translate 或固定坐标修补截图。
- 不把新组件、更多代码或绿测试当成用户问题已解决。UI Bug 必须先有同状态修复前截图，后有同条件修复后截图；无视觉证据只能标记未验证。
- 每一行改动必须能追溯到当前需求或失败证据；不顺手改相邻代码，不为单次使用建立共享抽象。
- 不覆盖用户改动，不批量删除，不使用破坏性 Git 命令，不强制推送。
