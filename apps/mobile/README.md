# Mandarin Mission Mobile

Flutter Android/iOS 客户端。当前模块提供 Riverpod 依赖容器、go_router 路由、统一主题、Journey 到“点咖啡”课程概览的最小导航，以及 Drift v1 本地数据库。

## 开发

```bash
flutter pub get
dart run build_runner build
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build apk --debug
flutter run
```

- Flutter：3.44.6 stable；Dart：3.12.2。
- Android/iOS 标识：`com.hieronymusf.mandarinmission`。
- 学习规则通过 `../../packages/learning_core` 路径依赖接入。
- Android 构建需要 JDK 17、Android API 36、Build Tools 36.0.0 和 NDK 28.2.13676358。

## 本地数据库

- `lib/data/local/tables.dart`：内容安装索引、课程进度、四维掌握状态、复习记录、口语记录和同步 Outbox；
- `lib/data/local/app_database.dart`：schema version、迁移入口和设备数据库连接；
- `drift_schemas/app_database/`：必须提交的版本化 schema snapshot；
- `test/drift/`：由 snapshot 生成的迁移验证辅助代码和测试。

修改表结构后先提升 `schemaVersion`，再运行：

```bash
dart run build_runner build
dart run drift_dev make-migrations
flutter test test/drift test/data/local
```

`app_database.g.dart`、`test/drift/generated/` 和 schema snapshot 是生成文件，不手工编辑。当前 Drift 与 `drift_dev` 固定为 2.34.0，以兼容 Flutter 3.44.6 的 analyzer/test 版本组合。

## 目录边界

- `lib/app`：App 启动与路由；
- `lib/core`：主题等通用基础能力；
- `lib/data`：Drift 数据库、远端服务和 Repository 实现；
- `lib/features/<feature>`：按功能组织的页面和应用逻辑；
- `test`：Widget 与依赖边界测试。

当前课程卡片是 Journey 外壳的静态占位；下一阶段从版本化课程数据渲染，不在页面里继续硬编码课程步骤。
