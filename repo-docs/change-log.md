# Repo guide 变更记录

## 2026-07-23

- 16:37 +08:00：修复 Journey 咖啡课程卡硬编码 `Not started` 的问题，改为读取持久化课程进度，完成后显示 100% 与 `Practice again`。Sony `XQ-DQ72` 已完成课程、覆盖安装/两次冷启动进度保留、8 项必做到期复习保存，以及飞行模式完整重走课程；结束后飞行模式已关闭。目标测试先失败再通过；移动端 format、analyze（0 issues）、全量 52 tests 和 debug APK 通过。真实来电因设备无 SIM 延期。Synced through 8072279；工作树仍未提交。
- 16:12 +08:00：同步 Sony `XQ-DQ72` 权限与步骤生命周期真机验收：普通拒绝后的说明/重试、永久拒绝后的 `Open Settings`、设置授权返回后的实时权限刷新，以及录音中从第 6 步返回第 5 步的停止和临时文件清理均通过。修复权限状态缓存未在 `resumed` 刷新、课程步骤返回未等待媒体清理两个问题。验证：移动端 format、analyze（0 issues）、全量 52 tests、debug APK、Sony 真机界面/日志/缓存；Synced through 8072279，工作树仍未提交。
- 15:52 +08:00：修正第 7 步预设对话的静态空壳行为。页面初始隐藏答案并禁用发送，用户需选择 `I said it aloud` 或 `Use phrase ticket`；phrase ticket 会显示整句，随后 `Send reply` 才能进入第 8 步。验证：移动端 format、analyze、全量 51 tests、debug APK，以及 Sony `XQ-DQ72` 两条交互路径和进入第 8 步的真机验收。Synced through 8072279；工作树仍未提交。
- 15:39 +08:00：同步 Sony `XQ-DQ72` 真机证据：课程包内音频播放、麦克风授权、44.1 kHz 录音、音量提示、同文件回放、重录删除当前文件和 Home 切后台停止/清理均通过；约 7 秒 M4A 为 115,228 bytes（约 0.9 MB/分钟）。普通权限拒绝、永久拒绝、真实来电恢复与最终课程音色仍未完成。验证：书写目标 5 tests、移动端 analyze、全量 51 tests、debug APK、Sony 真机日志与界面、repo-docs validator 和 `git diff --check`。Synced through 8072279；工作树仍未提交。
- 09:08 +08:00：将 21KB 根 `AGENTS.md` 拆为 8KB/102 行的项目入口、`docs/architecture.md`、五个局部 `AGENTS.md`、项目级 `$verify-mandarin-mission` Skill、Codex `PreToolUse` 文件安全 Hook、统一验证脚本和 `docs/runbooks/`；代码地图同步新的 Agent 工作流与本地护栏。验证：Hook 自测与阻断样例、TOML 解析、Skill 校验、PowerShell Parser、repo-docs validator（0 errors / 1 既有 broad-value warning）和 `git diff --check`。Synced through 8072279；工作树仍未提交。

## 2026-07-22

- 14:18 +08:00：明确当前 Kokoro `zf_xiaoxiao` 只是“能用但未获最终听感认可”的开发占位，开发流程允许未来替换为许可清晰的商用 TTS，并新增商业发布权、声线授权、数据条款、成本、哈希和重新试听门禁；复习 listening 题已从内容元数据解析 `ready` 音频，`planned`/缺失资源继续书面降级并正确记录 `usedHint`。验证：Flutter format、analyze、49 tests、内容校验、debug APK、模拟器真实到期复习入口与 24 kHz 单声道播放、repo-docs validator 和 `git diff --check`。Synced through 8072279；工作树仍未提交。
- 14:06 +08:00：用户试听否决 `zf_xiaoyi`（speaker 48、0.82 语速）的机械听感；三条课程 WAV 已改用 Kokoro `zf_xiaoxiao`（speaker 47、0.95 语速）重新生成，Fixture 升至 `0.1.3` 并更新 SHA-256/credit。验证：三条哈希匹配、内容校验、课程内容 Repository 6 tests、debug APK、APK 资源条目、repo-docs validator 和 `git diff --check`；新候选仍待用户试听确认。Synced through 8072279；工作树仍未提交。

- 13:55 +08:00：用 Apache-2.0 Kokoro-82M v1.0 / `sherpa-onnx 1.13.4` 的 `zf_xiaoyi` 声线替换三条不可发布预览，Fixture 升至 `0.1.2` 并更新 path/SHA-256/来源；新 APK 在模拟器课程第 2 步交付 17,604 帧，与新“我要”WAV 一致。验证：内容校验、Flutter format/analyze、49 tests、debug APK、模拟器播放、repo-docs validator（0 errors / 1 既有 warning）和 `git diff --check`；普通话人工试听仍待完成。Synced through 8072279；工作树仍未提交。
- 13:36 +08:00：接入三条 Windows `Microsoft Huihui Desktop (zh-CN)` WAV 开发预览，记录 path/SHA-256/不可发布限制；Android 模拟器从课程第 2 步完成真实播放。验证：文件哈希、内容校验、Flutter analyze、49 tests、debug APK、模拟器 AudioFlinger 日志和 repo-docs validator（0 errors / 1 既有 warning）。Synced through 8072279；工作树仍未提交。
- 13:20 +08:00：同步录音回放失败状态；保留当前临时录音，显示专用错误说明，并允许原地重试同一路径。验证：移动端 analyze、49 tests、debug APK 和 repo-docs validator（0 errors / 1 既有 warning）通过。Synced through 8072279；同时核对当前未提交工作树。
- 13:10 +08:00：同步媒体错误恢复和普通权限拒绝反馈；播放与录音失败有当前步骤内重试，拒绝麦克风后显示独立状态、再次授权入口和无录音自评说明。验证：移动端 analyze、47 tests 和 debug APK 通过。Synced through 8072279；同时核对当前未提交工作树。
- 11:55 +08:00：同步课程媒体生命周期行为；记录切后台、页面离开、重录和释放时停止媒体并清理当前临时录音，以及对应 Widget/Controller 测试。
- 首次建立中文 repo guide。
- 以“完成点咖啡课程并进入到期复习”为主 walkthrough。
- 增加整个一方源码范围的代码地图，以及内容契约、本地学习闭环、媒体降级三个模块。
- 记录两轮源码取证、读者模拟、反证检查和当前未确认边界。
- 同步媒体组件行为：loading 反馈、不可用降级优先级，以及 4 项组件 Widget 测试。
- 验证：移动端 format、analyze、46 tests 和 debug APK 通过；`validate_repo_docs.py` 为 0 errors。代码地图因每个目录按规则重复“重要代码”表头保留 1 条 broad-value warning。
- 当时基线为 8ebcb77；同时核对 2026-07-22 当前 `feat/audio-playback-recording` 未提交工作树。

后续只记录会改变读者模型、阅读路径或证据范围的更新；临时调试状态继续放在根目录 `HANDOFF.md`。
