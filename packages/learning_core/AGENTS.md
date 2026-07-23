# Learning Core Rules

本文件适用于 `packages/learning_core/`。先遵守根目录 `AGENTS.md`。

- 保持纯 Dart；学习规则和内容校验不能依赖 Flutter Widget、平台插件或云 SDK。
- 复习调度、课程判分、连胜、提示与同步冲突规则必须确定、可解释并有单元测试。
- 修改复习算法先写或更新失败测试，再说明对现有进度数据的迁移影响。
- 公共 API 从 `lib/learning_core.dart` 导出；不要让 App 依赖内部 `src/` 路径。
- 内容校验器要覆盖 JSON Schema 难以表达的稳定 ID、跨引用、前置知识、对话可达性与资源状态规则。

验证：

```powershell
.\tools\scripts\verify.ps1 -Scope core
```
