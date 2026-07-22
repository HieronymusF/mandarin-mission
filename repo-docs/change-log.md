# Repo guide 变更记录

## 2026-07-22

- 11:55 +08:00：同步课程媒体生命周期行为；记录切后台、页面离开、重录和释放时停止媒体并清理当前临时录音，以及对应 Widget/Controller 测试。
- 首次建立中文 repo guide。
- 以“完成点咖啡课程并进入到期复习”为主 walkthrough。
- 增加整个一方源码范围的代码地图，以及内容契约、本地学习闭环、媒体降级三个模块。
- 记录两轮源码取证、读者模拟、反证检查和当前未确认边界。
- 同步媒体组件行为：loading 反馈、不可用降级优先级，以及 4 项组件 Widget 测试。
- 验证：移动端 format、analyze、46 tests 和 debug APK 通过；`validate_repo_docs.py` 为 0 errors。代码地图因每个目录按规则重复“重要代码”表头保留 1 条 broad-value warning。
- 同步至 8ebcb77；同时核对 2026-07-22 当前 `feat/audio-playback-recording` 未提交工作树。

后续只记录会改变读者模型、阅读路径或证据范围的更新；临时调试状态继续放在根目录 `HANDOFF.md`。
