# Mandarin Mission 项目交接

> 最后更新：2026-07-23 16:37（Asia/Hong_Kong）
> 项目：`D:\mandarin-mission\mandarin-mission`
> 分支/工作树：`feat/audio-playback-recording`，音频模块功能分支

本文件是本项目唯一的实时交接入口。每次新对话或新任务必须先按根目录 `AGENTS.md` 的顺序读取全局协议、本文件、`AGENT_LESSONS.md` 和 `docs/handoff/ai-agent-handoff.md`，再核验仓库与 GitHub 当前状态。`AGENT_LESSONS.md` 保存去重后的项目特定复用经验；详细且相对稳定的项目基线在 `docs/handoff/ai-agent-handoff.md`。

## 当前正在做什么

- Sony `XQ-DQ72`（Android 15，序列号 `QV770PBLJ4`）真机验收已覆盖书写跟手、包内音频播放、首次授权、普通拒绝/重试、永久拒绝/打开设置/返回恢复、录音、音量提示、回放、重新录制、Home 和步骤返回清理。只剩真实来电中断/恢复；最终课程音色也未获用户认可。
- 第 7 步原先只有静态答案与可直接推进的 `Send reply`，无法验证用户完成对话。现已改为初始隐藏答案并禁用发送，选择 `I said it aloud` 或 `Use phrase ticket` 后才可进入第 8 步；两条路径已在 Sony 真机通过。
- 第 7 步 `Reply ready` 状态卡的短文案曾因内容列收缩而左对齐；现已将状态卡内容列横向撑满并居中。几何回归测试与 Sony 同状态前后截图通过，修复后截图为 `mandarin-step7-reply-centered.png`。
- 2026-07-23 新会话已重新核验实际 Git 根目录、分支和工作树：`feat/audio-playback-recording` 的本地 HEAD、upstream 与远端仍一致指向 `8072279`，进入会话前的全部未提交改动仍保留；Sony 真机权限、可自主触发生命周期、本地学习闭环与飞行模式课程已经完成。真实来电因该设备无 SIM 无法执行。
- 已按 2026-07-23 用户提供的小红书“Claude Code Project Structure”思路完成 Codex 等价结构调整：根 `AGENTS.md` 只保留稳定规则与路由，产品/架构、局部上下文、重复验证和机械护栏分别下沉到 docs、局部 `AGENTS.md`、项目 Skill、Hook 与脚本。全部改动仍在当前未提交工作树中。
- 音频播放与录音模块已提交并推送到 `origin/feat/audio-playback-recording`；本地分支跟踪远端，当前未创建 PR。
- `record` 包兼容性阻塞已解除，核心媒体架构、权限状态、录音回放、本地降级和内容资产路径接线已通过自动验证。
- 媒体组件级 Widget 测试、课程媒体生命周期自动清理和复习 listening 真实音频接线已补齐；三条 Apache-2.0 Kokoro TTS 音频只作为开发占位接入，用户评价为“能用但不满意”，后续允许换用许可清晰且听感更好的商用 TTS。当前真机重点只剩真实来电分支。
- 当前工作树新增播放/录音/录音回放错误原地重试、普通麦克风权限拒绝反馈及回归测试，尚未提交或推送；进入本轮前已有的 `AGENTS.md`、`HANDOFF.md` 修改已完整保留。
- 已新增中文 `repo-docs/` living guide；后续行为代码或稳定项目认知变化要按 `AGENTS.md` 的 repo-docs sync gate 核对最小 owning page。
- UI 基线已扩展为可供 AI 直接调用的项目 Widget 库；后续页面和对齐修复必须按根目录 `WIDGET_LIBRARY.md` 执行。
- 已完成本轮开发方法纠偏并准备交给新对话：所有非琐碎任务先暴露假设和成功标准，Bug 先复现，修改保持精准，验证必须对应用户可见结果。

## 已经完成了什么

- Agent 上下文结构已完成第一轮拆分：根 `AGENTS.md` 从约 21KB/315 行缩减为约 8KB/102 行；稳定产品与技术基线迁入 `docs/architecture.md`。
- 已在 `apps/mobile`、`content`、`packages/learning_core`、`services/api` 与 `docs` 增加局部 `AGENTS.md`，让 Codex 只在相应目录加载模块规则。
- 已新增仓库级 `.agents/skills/verify-mandarin-mission`、`.codex/config.toml`、`.codex/hooks/pre_tool_use_policy.py`、`tools/scripts/verify.ps1` 与 `docs/runbooks/`；Hook 会阻止已知递归强制删除命令及一次删除多个文件的补丁。
- 结构验证通过：Hook `--self-test` 与 deny 输出样例、`config.toml` 解析、Skill quick validator、PowerShell Parser、repo-docs validator（0 errors / 1 既有 broad-value warning）和 `git diff --check`。Skill validator 首次因系统 Python 缺少 PyYAML 失败，随后使用 `uv run --with pyyaml` 成功；不能把首次失败省略为全程一次通过。
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
- `media_controls_test.dart` 现有 6 项 Widget 测试，覆盖播放加载/播放/暂停/错误重试、无资产降级、权限请求/拒绝/永久拒绝/服务不可用、录音/音量/回放/确认，以及录音和录音回放错误重试。
- 播放错误可用当前 asset 路径原地重试；录音错误可在当前口语步骤重新开始录制，课程上下文不丢失。
- 录音回放错误会保留当前临时文件，显示专用错误说明，并通过 `Try playback again` 重试同一路径。
- 用户试听否决 `zf_xiaoyi`（speaker 48、0.82 语速）的机械听感；三条 WAV 已改用 Kokoro-82M v1.0 + `sherpa-onnx 1.13.4` 的中文女声 `zf_xiaoxiao`（speaker 47、0.95 语速）重新生成并覆盖 `apps/mobile/assets/audio/kokoro/`。Fixture 版本升至 `0.1.3`，ready path 保持不变，SHA-256 和 credit 已同步；整句合成输入仍用同音“义杯”实现 `yì bēi` 变调，输出经去直流、峰值归一化和 8 ms 首尾淡化。用户评价新声线“能用但不满意”，它只作为开发占位，不是最终课程音色。
- 复习 listening 条目现在通过 `CoursePackage.audioAssetPathForItem` 解析 ready 音频并显示共享 `AudioPlayerBar`；planned/缺失资源继续显示书面降级，只有该降级路径揭晓答案才记录 `usedHint: true`。
- 新 debug APK 已安装到 Android 模拟器；从 Journey 的 8 条到期复习进入第 2 条 listening 题后，UI 显示 `Play prompt` 且没有音频不可用提示。点击播放后日志确认当前 App 获取/释放音频焦点并解码 24 kHz、单声道 `audio/raw`。
- 普通拒绝麦克风权限后会显示独立拒绝状态、再次授权入口和无录音自评说明，不再静默退回首次授权卡。
- Android 模拟器已在课程第 6 步实际拒绝系统麦克风权限，确认拒绝说明、再次授权入口和 `Continue without recording` 同屏可见；截图位于 Codex visualizations 目录，这仍不是真机验收。
- Android 模拟器 `emulator-5554` 已完成 debug APK 安装、App 启动和 Journey → 课程第 1 步冒烟检查；这不是麦克风、真实播放或生命周期的真机验收。
- 课程页现在会在 App 进入后台/非活动状态或用户离开页面时结束媒体会话：停止播放，取消录音或回放，并清理当前临时文件；重录前也会先清理旧文件。
- 新增 Controller 与课程页生命周期测试，覆盖停止/清理竞态、切后台和页面离开。
- 设置返回会重新读取平台麦克风权限，清除旧的永久拒绝状态；课程头部返回会先等待同一个幂等媒体清理 Future，再切换到上一课程步骤。
- 本轮本地验证通过：三条 Kokoro 音频 SHA-256 与元数据一致、内容校验、Flutter format、analyze（0 issues）、49 tests、debug APK、Android 模拟器课程播放、repo-docs validator（0 errors / 1 既有 warning）和 `git diff --check`。
- 2026-07-23 15:11 续接复核通过：Hook `--self-test` 与递归删除 deny 样例、`.codex/config.toml` 解析、项目 Skill quick validator、`verify.ps1` PowerShell Parser、repo-docs validator（0 errors / 1 既有 warning）、内容校验、Flutter format（0 changed）、analyze（0 issues）、49 tests、debug APK 和 `git diff --check`。首次组合回归因工具 124 秒超时且输出被缓冲，随后拆分命令全部成功；不得省略这次超时写成一次通过。
- 书写画布问题已用两个失败测试复现：同一帧快速移动原实现只保留 1 个触点，跨双字中线仍是 1 条笔迹。修复后画布在本地保留连续触点并在字符格线处新开一笔；目标测试 5 项、移动端 analyze、全量 51 tests 和 debug APK 均通过，修复版已用 `adb install -r` 安装到 Sony 真机。
- 新 `zf_xiaoxiao` 候选的三条 SHA-256 与 Fixture `0.1.3` 一致；内容校验、课程内容 Repository 6 项测试、debug APK 构建和 APK 内三条资源条目检查通过。尚未把旧音色的模拟器播放证据冒充为新音色验证。
- 复习听力接线验证通过：先新增失败测试复现 `audioAvailable: false` 硬编码，再改为内容元数据路径；Flutter format、analyze（0 issues）、49 tests、内容校验、debug APK、模拟器真实复习入口与播放日志通过。
- 使用 `repo-docs-zh` 创建 `repo-docs/README.md`、主 walkthrough、代码地图、三个机制模块、术语表、源码证据、质量复核和变更记录；validator 为 0 errors / 1 expected warning（代码地图按规则重复“重要代码”表头触发 broad-value 检查）。
- 已研究 [multica-ai/andrej-karpathy-skills](https://github.com/multica-ai/andrej-karpathy-skills) 的 README、`CLAUDE.md`、Skill 和示例；核验的 main HEAD 为 `2c606141936f1eeef17fa3043a72095b4765b9c2`（2026-04-20）。适合本项目的四项原则已写入 `AGENTS.md` 和 `docs/development-workflow.md`：编码前思考、简洁优先、精准修改、目标驱动执行。
- `karpathy-guidelines` 已通过 Codex `skill-installer` 安装到 `C:\Users\Jerome\.codex\skills\karpathy-guidelines\SKILL.md`；`AGENTS.md` 已要求 Codex 在代码编写、Bug 修复、重构和审查前调用 `$karpathy-guidelines`。安装后的选择器从下一轮对话开始可用。
- 已将此前 UI 处理方式分类为 `reasoning-error`（用通用组件/几何断言替代具体视觉问题复现）并伴随 `execution-gap`（没有修复前后视觉证据）；复用规则已写入 `AGENT_LESSONS.md` 和 `WIDGET_LIBRARY.md`。
- 本轮在既有未提交音频/UI 工作上补齐课程媒体生命周期停止与临时文件清理，并重新运行 Flutter 全量验证。
- 2026-07-23 16:12 权限与步骤生命周期回归通过：先用失败测试复现设置授权返回仍显示永久拒绝、录音中从第 6 步返回第 5 步仍继续录制，再完成最小修复；移动端 format（0 changed）、analyze（0 issues）、全量 52 tests、debug APK 和 Sony 真机复测均通过。真机缓存最终无 M4A；仅按明确路径删除一个 5,602-byte 孤儿测试文件 `cache/recording_1784792630385.m4a`。
- Journey 咖啡课程卡原先硬编码 `Ready to start`、0% 和 `Start`，即使完成事务已经落库，返回或冷启动仍显示未开始。现已通过 `lessonProgressProvider` 读取真实 `lesson_progress_entries`，完成后显示 `Completed`、100% 和 `Practice again`，进行中明确显示 `Start again`；完成事务成功后会失效查询再返回 Journey。
- 2026-07-23 16:37 M1 设备闭环通过：Sony 完成八步课程后显示真实 completed 状态；覆盖安装与两次冷启动后进度保留；8 项必做到期复习显示 `Review saved`，返回后仅保留 2 项可选巩固；飞行模式下完整重走课程并返回 completed Journey，结束后飞行模式已关闭。目标测试先复现失败；常驻 StreamProvider 方案导致组合测试超时后收缩为一次性 FutureProvider + 显式失效。最终 format、analyze（0 issues）、全量 52 tests、debug APK 和真机均通过。

## 卡在了哪里

- 无代码构建阻塞。
- 项目级 Codex Hook 已写入仓库但尚未由用户在新会话的 `/hooks` 中复核并信任；在完成信任前不得声称 Hook 已自动生效。项目 Skill 需要新会话/刷新后才能从选择器验证实际发现状态。
- 三条 Kokoro `ready` 音频已有许可、来源、文件和模拟器播放证据，但当前 `zf_xiaoxiao` 只获得“能用但不满意”的反馈，仍是待替换的开发占位；最终音色可能改用商用 TTS，届时必须重新核验商业发布权、声线授权、数据条款、价格、哈希和普通话听感。图片资产仍为 `planned`，整个内容包保持 `draft`。
- Sony 真机已验证首次授权、普通拒绝/重试、永久拒绝/打开设置/返回恢复、录音、音量提示、回放、重新录制、Home 和步骤返回清理；设备没有 SIM，真实来电中断/恢复当前无法验证，不得把媒体真机验收写成全部完成。
- Sony `XQ-DQ72` 修复版书写真机验收通过：多转折触摸保留全部折点，跨“咖/啡”中线的连续触摸在两侧生成独立笔迹；用户亲手复测确认“跟手了”。修复后截图保存为 `mandarin-hanzi-fixed-real-device.png`。
- Sony 真机媒体主路径通过：第 5 步播放时获取音频焦点，以 24 kHz 单声道解码，完成后释放焦点；第 6 步从未授权状态进入 App 权限用途说明并获得系统授权，以 44.1 kHz 录制本地 M4A。用户提供的约 7 秒录音为 115,228 bytes（约 0.9 MB/分钟），同一文件回放完成、状态复位，重新录制删除当前文件；录音中按 Home 会停止录音、释放焦点并删除本次临时文件。测试产生的单个孤儿录音已按明确路径删除，未导出或读取音频内容。
- Sony 真机第 7 步交互修复通过：初始页显示 `I said it aloud`、`Use phrase ticket` 和禁用的 `Choose how to reply`；前者显示 `Reply ready`，后者显示整句 phrase ticket，两者都会启用 `Send reply`，点击后进入 `Step 8 of 8`。修复前后截图为 `mandarin-step7-blocked.png`、`mandarin-step7-fixed.png`，phrase ticket 状态为 `mandarin-step7-ticket.png`。
- 本轮已连接 Sony 真机并新增书写修复、录音停止态、录音中音量提示、普通拒绝、永久拒绝与设置返回恢复截图；普通权限分支不再只依赖模拟器证据。
- `AppContentFrame`、`AppPageScrollView`、`AppSection`、`AppListRow` 当前只被测试和文档引用，没有真实生产页面调用；它们是部分完成的候选组件，不得当作已验证的生产抽象继续扩展。

## 下一步要做什么

1. **完成项目 Skill 与 Hook 的 UI 侧启用确认**：本轮已确认 `feat/audio-playback-recording` 位于 `8072279`、工作树改动完整，且项目 Skill/Hook 文件及自测有效；但 `$verify-mandarin-mission` 仍未出现在本会话 Skills 列表，Hook 也尚未由用户在 `/hooks` 中复核并信任。
2. **延期 Sony 真机来电分支**：当前设备无 SIM，无法接收真实来电；未来具备可呼入设备时，再验证录音中的来电中断与返回 App 后恢复。不要用 Home 或 ADB 模拟冒充真实来电证据。
3. **最终音色后续替换**：当前 `zf_xiaoxiao` 继续服务开发流程，不阻塞工程推进；扩展正式课程前调研并选择更自然的真人或商用 TTS，按 `docs/development-workflow.md` 的音频门禁重新核验和试听。
4. **真实设备剩余测试**：服务不可用时的降级路径仍只有自动测试证据；首次授权、普通拒绝/重试、永久拒绝/设置恢复、播放、录音、音量、回放和重录已通过。
5. **真机生命周期剩余验收**：只剩真实来电中断/恢复；Home 切后台和录音中从第 6 步返回第 5 步已通过，按来电结果做最小修正。
6. **按用户要求决定 PR**：当前分支已推送但未创建 PR；只有用户明确要求后才创建、标记 ready 或合并。创建面向 `main` 的 PR 后再等待并核验三项 CI。
7. **继续关闭 M1 其他条件**：真机课程 → 重启 → 进度保留 → 到期复习和飞行模式课程已通过；剩余重点是最终课程音频、缺失步骤类型与正式资产。

## 哪些坑不要再踩

- 根 `AGENTS.md` 只保存稳定、高频、必须遵守的规则与知识路由；产品/架构细节放 `docs/architecture.md`，重复流程放 `.agents/skills/`，机械检查放 Hook/脚本，模块规则放最近的局部 `AGENTS.md`，实时状态只放本文件。
- 项目级 `.codex` 配置和 Hook 只有在可信仓库中加载，非托管 Hook 新增或变化后还必须通过 `/hooks` 复核并信任；Hook 是补充护栏，不是完整安全边界。
- 每次新对话都必须完整执行：全局 `C:\Users\Jerome\.codex\HANDOFF.md` → 项目 `AGENTS.md` → 本文件 → `AGENT_LESSONS.md` → `docs/handoff/ai-agent-handoff.md` → Git/外部状态核验；不能因为“已经熟悉”跳过。
- 不把聊天记录或旧交接中的分支、PR、测试结果直接当作当前事实；先用仓库和 GitHub 核验。
- 实时状态只更新本文件；复用经验去重后更新 `AGENT_LESSONS.md`；详细架构和长期基线更新 `docs/handoff/ai-agent-handoff.md`，不要创建第二份实时交接或流水账式反思文件。
- “准备交接”不等于授权 Git 发布；没有用户明确要求时只保留本地未提交改动。
- 堆叠 PR 改 base 后不能假定 CI 自动运行；必须核验最新 head SHA 的 job，必要时关闭并重新打开 PR 触发。
- PowerShell 读取中文 Markdown 时显式使用 `-Encoding utf8`。
- Flutter 联邦插件升级不能只看顶层包；必须核验平台实现与 platform interface 属于同一兼容代际，并跑目标平台完整构建。
- 课程媒体路径必须来自内容包 `audioAssetId → assets[].path`，不能在 Widget 中根据 item ID 猜文件名；`ready` 只表示技术资源可用，不表示音色已经获批。TTS 正式资产必须有清晰许可、来源、哈希和人工发音审核，且不得冒充真人音频。
- UI 任务必须先读根目录 `WIDGET_LIBRARY.md`；错位先修父容器、Flex/constraints 和统一 token，不用逐元素 margin、translate 或固定坐标修补截图。
- 不把新组件、更多代码或绿测试当成用户问题已解决。UI Bug 必须先有同状态修复前截图，后有同条件修复后截图；无视觉证据只能标记未验证。
- 每一行改动必须能追溯到当前需求或失败证据；不顺手改相邻代码，不为单次使用建立共享抽象。
- 不覆盖用户改动，不批量删除，不使用破坏性 Git 命令，不强制推送。
