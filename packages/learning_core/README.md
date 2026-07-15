# learning_core

Mandarin Mission 的纯 Dart 学习核心。它不依赖 Flutter Widget、数据库或云服务，可在移动端、内容工具和测试中复用。

当前包含：

- 四个学习维度的 0—5 分箱复习调度；
- 同日补救次数限制；
- 课程内容稳定 ID、跨引用和对话可达性校验；
- Draft/Release 资源状态校验。

## 运行

```bash
dart pub get
dart analyze
dart test
dart run bin/validate_content.dart ../../content/fixtures
```

算法与内容规则以仓库根目录 `AGENTS.md` 和 `docs/开发方案.md` 为准。
