# Course Content Rules

本文件适用于 `content/`。先遵守根目录 `AGENTS.md`。

- 课程是版本化数据；不要为单节课建立专用页面或专用业务逻辑。
- `CourseManifest`、`Location`、`Lesson`、`KnowledgeItem`、`Exercise`、`Dialogue` 和 `Asset` 使用稳定 ID；显示文案、排序或路径变化不能随意换 ID。
- 修改 Schema 时同步 Fixture、validator、测试和制作文档；修改 Fixture 时验证引用、前置知识、分支可达性与资源完整性。
- 音频和图片必须记录 path、SHA-256、来源、许可或内部制作标记。
- 真人音频优先；TTS 只有在模型、声线、工具许可、来源、哈希清晰且通过人工发音审核后才能成为正式资产，不得冒充真人音频。
- `ready` 表示资源技术可用，不等于听感或发布审批完成；整个内容包状态要独立判断。
- 不允许单一 AI 自由生成后直接把主课程标为正式内容。文本进入 language lock 前，主 Agent 必须分别编排独立英文编辑 Agent 与国际中文教学 Agent，记录逐单元结论并完成主审集成；专业 Agent 审核必须明确标注为 AI 审核，不冒充真人或母语者身份。实际音频仍需在文件生成后逐条试听，文本双审不能替代发音审核。

验证：

```powershell
.\tools\scripts\verify.ps1 -Scope content
```
