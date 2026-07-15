# Mandarin Mission Mobile

Flutter Android/iOS 客户端。当前模块提供 Riverpod 依赖容器、go_router 路由、统一主题，以及 Journey 到“点咖啡”课程概览的最小导航。

## 开发

```bash
flutter pub get
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

## 目录边界

- `lib/app`：App 启动与路由；
- `lib/core`：主题等通用基础能力；
- `lib/features/<feature>`：按功能组织的页面和应用逻辑；
- `test`：Widget 与依赖边界测试。

当前课程卡片是 Journey 外壳的静态占位；下一阶段从版本化课程数据渲染，不在页面里继续硬编码课程步骤。
