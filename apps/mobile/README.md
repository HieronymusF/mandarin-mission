# Mandarin Mission Mobile

Flutter Android/iOS 客户端。当前模块提供 Riverpod 依赖容器、go_router 路由、统一主题、Journey、Drift v1 本地数据库、安装包内课程 Repository，以及数据驱动的七步“点咖啡”课程播放器。

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

## 课程内容加载

- `../../content/fixtures/cafe-course.json` 是当前唯一课程内容源，并通过本地 `mandarin_mission_content` package asset 打入 App；
- `lib/data/content/course_content_repository.dart` 从 `AssetBundle` 异步读取 JSON，运行 `learning_core` 内容校验，再提供按稳定 ID 查询；
- `lib/data/content/course_content_models.dart` 把当前页面需要的内容转为只读的类型化课程、步骤和知识点模型；
- `test/data/content/` 验证真实打包资产、稳定 ID 查询、非法版本和损坏 JSON。

Repository 当前只读取随 App 发布的 Draft Fixture。后续增量内容下载仍应复用相同模型与校验规则，但不在本模块预建远端接口。

## 目录边界

- `lib/app`：App 启动与路由；
- `lib/core`：主题等通用基础能力；
- `lib/data`：Drift 数据库、远端服务和 Repository 实现；
- `lib/features/<feature>`：按功能组织的页面和应用逻辑；
- `test`：Widget 与依赖边界测试。

“点咖啡”课程播放器按 Fixture 中的步骤顺序渲染场景、教学卡、听力选择、口语降级、对话和完成页。逐字拼音来自 `pinyinSyllables`，标点作为独立布局单元，不参与汉字—拼音中心线计算。下一阶段将练习结果和四维掌握状态写入 Drift。
