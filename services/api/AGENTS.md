# API Service Rules

本文件适用于 `services/api/`。先遵守根目录 `AGENTS.md`。

- 一期保持单个 Go 单体服务；没有真实负载证据时不拆微服务、不引入 Kubernetes。
- Flutter 客户端只访问 API，不直连 PostgreSQL；每个用户数据请求由服务端会话确定 `user_id`。
- 外部云与供应商能力放在可替换 Adapter/Provider 后；业务代码不得散落 SDK 调用。
- 商店通知和同步入口必须幂等；不要在日志中记录 Secret、Token、邮箱、原始录音、完整转写或购买票据。
- Cloud Run 默认 `min-instances=0`，并保留最大实例数预算护栏。
- 当前只有健康、就绪和版本端点；不要把计划中的认证、数据库或 Outbox 消费写成已实现。

验证：

```powershell
.\tools\scripts\verify.ps1 -Scope api
```
