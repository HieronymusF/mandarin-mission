# Mandarin Mission API

一期自研业务后端的单体 Go 服务。它面向 Cloud Run 容器部署；PostgreSQL、R2 和外部供应商都通过服务端适配器接入，不允许 Flutter App 直接持有基础设施 Secret。

当前只建立可部署、可探活的最小骨架：

- `GET /healthz`：进程存活检查；
- `GET /readyz`：依赖就绪检查，接入数据库后必须扩展；
- `GET /v1/meta`：服务名称与部署版本。

## 本地运行

需要 Go 1.26：

```bash
go test ./...
go run ./cmd/api
```

服务默认监听 `:8080`。可配置：

| 环境变量 | 默认值 | 用途 |
|---|---|---|
| `PORT` | `8080` | HTTP 监听端口，Cloud Run 自动注入 |
| `APP_VERSION` | `dev` | `/v1/meta` 返回的部署版本 |

## 容器

```bash
docker build -t mandarin-mission-api .
docker run --rm -p 8080:8080 mandarin-mission-api
```

数据库、认证、同步、权益和 R2 适配器按实际一期接口逐步加入。不要提前拆微服务，也不要让 API 转发课程大文件；资源下载应直接使用 R2 自定义域名和 CDN。
