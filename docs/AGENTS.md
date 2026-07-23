# Documentation Rules

本文件适用于 `docs/`。先遵守根目录 `AGENTS.md`。

- 稳定产品与技术边界归 `architecture.md`；不可轻易逆转的决定归 `decisions/`；可执行操作归 `runbooks/`。
- `开发方案.md` 保存详细方案和阶段计划；`development-workflow.md` 保存功能交付流程；`content-authoring.md` 保存内容制作规则。
- 根 `HANDOFF.md` 是唯一实时状态。`docs/handoff/ai-agent-handoff.md` 只保存详细且相对稳定的环境、架构、验证和风险基线，不创建第二份实时交接。
- 修改架构决定时说明背景、选择、替代方案、后果和回滚条件；不要只记录结论。
- 使用绝对日期；明确区分已完成、部分完成、未验证和阻塞。
- 文档不能把计划写成实现，也不能把模拟器、自动测试或旧 CI 冒充真机或当前 CI。
- 读者行为指南在 `repo-docs/`，遵守根 `AGENTS.md` 的 foreground sync gate 与最小 owning page 原则。
