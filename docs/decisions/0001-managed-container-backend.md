# ADR 0001：自研后端运行在托管容器上

- 状态：已接受
- 日期：2026-07-15
- 决策人：项目所有者

## 背景

一期需要账号、跨设备同步、订阅权益、内容发布、语音代理和基础事件采集。Supabase 能快速覆盖这些能力，但组合套餐对低流量独立项目不够经济；自己维护虚拟机又会引入补丁、监控、备份、扩容和故障恢复工作。

目标是在不管理虚拟机和 Kubernetes 的前提下，自己掌握业务服务与数据模型，并让计算、数据库、对象存储和 CDN 都按实际用量扩展。

## 决策

采用以下一期基线：

| 层 | 选择 | 边界 |
|---|---|---|
| 业务 API | Go 单体服务 | 账号会话、批量同步、内容 Manifest、商店通知与权益、语音代理、事件批量写入都从一个服务起步 |
| 容器运行时 | Google Cloud Run | 不使用虚拟机；最小实例数为 0，最大实例数先限制为 3 |
| 关系数据库 | Neon PostgreSQL | 使用池化连接串；与 Cloud Run 选择尽量接近的地区；迁移文件由仓库管理 |
| 对象存储 | Cloudflare R2 | 通过 S3 兼容接口上传课程包、音频和插画；数据库只保存元数据 |
| 全球分发 | R2 自定义域名 + Cloudflare CDN | App 直接下载带版本和哈希的资源，不让大文件经过 Cloud Run |
| 付费资源门禁 | 短时令牌 + 小型 Cloudflare Worker | 免费资源可公开缓存；付费资源由边缘层校验短时令牌后读取私有 R2，MVP 前再实现 |
| 身份与订阅 | 自研业务逻辑 | App 可匿名学习；需要同步或购买时，以 Apple/Google 身份和商店服务端通知作为外部协议，不再依赖 Supabase Auth 或 RevenueCat |

不拆微服务。只有当某个模块出现独立扩缩容、权限隔离或发布节奏需求时，才从单体中拆出服务。

## 成本假设

以下是 2026-07-15 查阅官方价格后的低流量估算，不是账单保证，且不含域名、Apple/Google 开发者账号与语音供应商费用：

| 阶段 | 预估月成本 | 假设 |
|---|---:|---|
| 本地开发/封闭测试 | US$0—5 | Cloud Run 缩到 0；Neon 与 R2 保持在免费额度内；仅当付费资源门禁需要 Workers Paid 时产生约 US$5 起步费 |
| 早期公开 MVP | US$15—30 | Neon 进入用量计费，Cloud Run 仍是低流量，R2 大部分请求和存储处于低用量，Worker 约 US$5 起 |

定价锚点：

- Cloud Run 按使用量计费并提供免费额度，默认可在无流量时缩到 0：[Cloud Run pricing](https://cloud.google.com/run/pricing)、[Cloud Run autoscaling](https://docs.cloud.google.com/run/docs/about-instance-autoscaling)。
- Neon Free 为 US$0，当前每个项目含 100 CU-hours/月和 0.5 GB 存储；Launch 为用量计费，官方示例典型用量约 US$15/月：[Neon pricing](https://neon.com/pricing)。
- R2 Standard 当前为 US$0.015/GB-month，免费层含 10 GB-month、每月 100 万次 Class A 与 1000 万次 Class B 操作，公网出口免费：[R2 pricing](https://developers.cloudflare.com/r2/pricing/)。
- R2 自定义域名可启用 Cloudflare Cache；`r2.dev` 只用于开发且有速率限制：[R2 public buckets](https://developers.cloudflare.com/r2/buckets/public-buckets/)。
- Workers Free 当前为每天 10 万请求；Paid 最低 US$5/月：[Workers pricing](https://developers.cloudflare.com/workers/platform/pricing/)。

## 成本护栏

1. Cloud Run `min-instances=0`、`max-instances=3`，先使用请求计费和较小内存。
2. 客户端将学习事件批量同步，禁止每次点击产生一次远端写入。
3. 课程资源使用不可变哈希文件名和长缓存；更新发布新 Manifest，不覆盖旧文件。
4. 音频、图片和课程包直接走 CDN；Cloud Run 只返回元数据、令牌和小型 JSON。
5. Neon 使用池化连接，API 请求内避免聊天式多次往返；空闲计算自动休眠。
6. 临时语音文件设置生命周期规则，评测完成后不长期保留。
7. 在三个供应商分别设置预算告警，每月检查计算、数据库存储、对象存储请求和语音分钟数。

## 安全边界

- Flutter App 不直接连接 PostgreSQL，也不持有数据库、R2 或语音供应商 Secret。
- API 每个用户数据操作都要从服务端会话确定 `user_id`，并为跨用户访问编写拒绝测试。
- 刷新令牌只保存哈希；访问令牌短时有效并支持密钥轮换。
- GitHub Secrets 或云密钥管理服务保存生产 Secret，仓库只提交变量名和示例值。
- 付费资源不能只依赖隐藏 URL；使用短时、可验证、包含资源范围的令牌。

## 结果与取舍

优点是没有固定虚拟机成本，大文件出口不压在 API 上，业务逻辑和数据模型可控，未来也能替换任一基础设施供应商。代价是认证、权益、同步冲突、迁移与安全测试都由项目负责；因此一期必须保持单体、批量接口和最小功能面，不能把“自研”演变成基础设施平台工程。
