# 验证 Runbook

## 三层验证

1. `.codex/hooks/pre_tool_use_policy.py` 在工具执行前拦截已知批量删除命令和多文件删除补丁。首次启用或脚本变化后，需要在 Codex `/hooks` 中复核并信任。
2. `$verify-mandarin-mission` 根据当前 diff 选择最小验证范围，并补充 UI、真机、媒体、内容资产或迁移证据。
3. `.github/workflows/core-ci.yml` 在 `main` push 和面向 `main` 的 PR 上运行远端 CI。只有当前 head SHA 对应 job 才能作为当前 CI 证据。

Hook 是护栏，不是完整安全边界；本地脚本是便利入口，不替代用户可见验收；CI 通过也不代表真机、视觉或听感已经通过。

## 统一命令

从仓库根运行：

```powershell
.\tools\scripts\verify.ps1 -Scope mobile
.\tools\scripts\verify.ps1 -Scope core
.\tools\scripts\verify.ps1 -Scope content
.\tools\scripts\verify.ps1 -Scope api
.\tools\scripts\verify.ps1 -Scope docs
.\tools\scripts\verify.ps1 -Scope all -BuildApk -BuildContainer
```

- `mobile`：Dart format、Flutter analyze、Flutter tests；`-BuildApk` 追加 debug APK。
- `core`：纯 Dart format、analyze、tests。
- `content`：运行课程内容 validator；打包资产或 App 行为变化时再加 `mobile`。
- `api`：gofmt、go vet、go test；`-BuildContainer` 追加 Docker build。
- `docs`：运行 repo-docs validator。
- `all`：运行全部范围；构建仍由显式开关控制。

## 结果记录

交付说明必须区分：通过、失败、跳过、环境不可用、仅模拟器、真实设备。不要从本地测试推断远端 CI、真机、提交、推送或部署状态。
