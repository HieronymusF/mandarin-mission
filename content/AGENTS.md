# Course Content Rules

本文件适用于 `content/`。先遵守根目录 `AGENTS.md`。

- 课程是版本化数据；不要为单节课建立专用页面或专用业务逻辑。
- `CourseManifest`、`Location`、`Lesson`、`KnowledgeItem`、`Exercise`、`Dialogue` 和 `Asset` 使用稳定 ID；显示文案、排序或路径变化不能随意换 ID。
- 修改 Schema 时同步 Fixture、validator、测试和制作文档；修改 Fixture 时验证引用、前置知识、分支可达性与资源完整性。
- 音频和图片必须记录 path、SHA-256、来源、许可或内部制作标记。
- 真人音频优先；TTS 只有在模型、声线、工具许可、来源、哈希清晰且通过人工发音审核后才能成为正式资产，不得冒充真人音频。
- `ready` 表示资源技术可用，不等于听感或发布审批完成；整个内容包状态要独立判断。
- 不允许 AI 自由生成未经英语母语编辑和国际中文教师审核的正式主课程。

验证：

```powershell
.\tools\scripts\verify.ps1 -Scope content
```
