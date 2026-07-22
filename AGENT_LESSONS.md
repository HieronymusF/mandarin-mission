# Mandarin Mission Agent Lessons

仅保留可复用、项目特定且未被其他规则完整覆盖的经验。新增前先搜索并合并重复项。

涉及稳定仓库行为或行为代码变更时，按根 `AGENTS.md` 的 Repo docs sync gate 核对并最小更新 `repo-docs/`。

## Lesson: 联邦 Flutter 插件必须验证整套平台依赖

- Last confirmed: 2026-07-18
- Pattern: 顶层 `record 5.2.1` 可通过 `flutter analyze`，但解析出的 `record_linux 0.7.2` 与 `record_platform_interface 1.6.0` 不兼容，连 Android APK 的 Dart kernel 编译也会失败。
- Prevention rule: 新增或升级联邦插件时，选择与当前 Flutter/Dart 明确兼容的顶层版本，检查 lockfile 中平台实现与 platform interface 的代际，并运行目标平台完整构建。
- Verification: `pubspec.lock` 中相关包版本互相兼容；`flutter analyze`、`flutter test` 和 `flutter build apk --debug` 全部通过。
- Evidence: 音频模块将 `record` 固定为 `7.1.1` 后，解析到 `record_linux 2.1.1` 与 `record_platform_interface 2.1.0`，debug APK 构建通过。
- Status: active
- Promoted to: none

## Lesson: 课程媒体路径只能来自内容元数据

- Last confirmed: 2026-07-18
- Pattern: 根据 knowledge item ID 在 Widget 中拼接音频文件名，会绕过 `audioAssetId`、资产状态、许可和哈希，正式资产加入后仍可能播放失败。
- Prevention rule: 统一通过 `knowledgeItems[].audioAssetId → assets[].path` 解析媒体；只有 `ready` 资产可播放，planned/缺失资源必须走显式降级。
- Verification: 内容模型测试覆盖 ready 路径解析与 planned 返回空路径；UI 中不存在根据 item ID 猜测音频文件名的代码。
- Evidence: `CoursePackage.audioAssetPathForItem` 与 `course_content_repository_test.dart`。
- Status: active
- Promoted to: none

## Lesson: 交接准备不等于 Git 发布授权

- Last confirmed: 2026-07-18
- Pattern: 用户要求为新对话或其他 agent 准备交接材料，只授权本地整理，不自动授权建分支、提交、推送或创建 PR。
- Prevention rule: 默认把交接三件套保留为本地未提交改动；只有用户明确要求提交、推送、建 PR 或合并时，才执行对应 Git/GitHub 动作。
- Verification: 发布前能指出当前对话中的明确授权；没有授权时，`git status -sb` 只显示本地交接文件改动。
- Evidence: PR #13 在用户纠正后关闭且未合并，远端临时分支已删除，本地提交已移除。
- Status: active
- Promoted to: `AGENTS.md` 第 15 节

## Lesson: PR 改基线后显式触发 CI

- Last confirmed: 2026-07-18
- Pattern: 堆叠 PR 改为以 `main` 为基线后，GitHub 的 `pull_request` 工作流不会仅因 base branch 被编辑而自动运行。
- Prevention rule: PR 改基线后检查工作流触发类型；若没有新运行，关闭并重新打开 PR，或推送新提交触发 `reopened`/`synchronize`，再等待全部 job 完成。
- Verification: 在 GitHub 检查该 PR 对应的 `mobile`、`learning-core`、`api` 三项 job 都属于最新 head SHA 且最终通过。
- Evidence: PR #11、#12 改基线后的 CI 触发与合并验证。
- Status: active
- Promoted to: none

## Lesson: 滚动容器中的书写画布必须主动接管手势

- Last confirmed: 2026-07-18
- Pattern: 汉字书写画布位于可滚动课程页中时，竖向笔画可能被父级滚动手势竞争，导致笔迹中断或页面移动。
- Prevention rule: 自定义书写画布应尽早接管指针序列，并保留清除、重写、跳过与对照自评路径。
- Verification: 在 Android 设备或模拟器上分别验证横、竖、斜笔画连续，页面不随书写滚动；再运行对应 Widget 测试。
- Evidence: `apps/mobile/lib/features/lesson/presentation/steps/hanzi_writing_step.dart` 与汉字书写 Android 交互验收。
- Status: active
- Promoted to: none

## Lesson: PowerShell 明确使用 UTF-8 读取中文项目文档

- Last confirmed: 2026-07-18
- Pattern: Windows PowerShell 默认编码可能把 UTF-8 中文 Markdown 输出为乱码，进而污染判断或后续编辑。
- Prevention rule: 读取中文项目文档时使用 `Get-Content -Raw -Encoding utf8`；写入后检查 diff 中的中文和换行。
- Verification: 读取结果中文可辨认，`git diff --check` 通过，diff 中没有大面积无关字符变化。
- Evidence: 新对话交接三件套准备过程中的编码核验。
- Status: active
- Promoted to: `AGENTS.md` 与 `docs/handoff/ai-agent-handoff.md` 的启动命令示例

## Lesson: UI 工程验证不能替代视觉失败证据

- Last confirmed: 2026-07-22
- Pattern: 面对 UI 对齐问题时，先增加通用 token、布局组件和几何断言，并以 analyze、Widget tests、APK 构建通过作为结果；这些检查可能全部为绿，但没有复现用户看到的具体页面状态，也没有修复前后截图，无法证明视觉问题真正解决。仅被测试和文档引用的新布局组件也可能成为未验证抽象。
- Prevention rule: UI Bug 先记录入口、状态、viewport、文字缩放并保存修复前截图；写出根因假设和视觉成功标准；优先修改现有父容器或共享根因；修复后在同条件截图对比。只有两个真实生产调用点才允许新增共享组件。
- Verification: 同一场景有修复前/后视觉证据；相关尺寸与 200% 字号无溢出；每个改动行可追溯到根因；analyze/test/build 作为回归门禁单独通过。
- Evidence: 2026-07-22 Widget 库任务中自动测试与 APK 构建通过，但无连接设备、无新增页面截图，交付只能证明工程回归，不能证明具体视觉缺陷已修复。
- Status: active
- Promoted to: `AGENTS.md`“AI 开发行为约束”与根目录 `WIDGET_LIBRARY.md`

## Lesson: Riverpod 生命周期清理不能在卸载后读取 ref

- Last confirmed: 2026-07-22
- Pattern: `ConsumerState.dispose()` 中再通过 `ref.read(...)` 获取媒体 Controller 会触发 unmounted ref 错误；异步清理完成时直接写 Notifier state，也可能遇到 Provider 已释放。连续生命周期事件还可能重复取消同一次录音。
- Prevention rule: 在 `initState()` 保存需要的 Controller 回调；生命周期事件与页面离开复用一个幂等清理 Future；异步间隙后写 state 前检查 `ref.mounted`。
- Verification: Widget 测试覆盖 App 切后台和离开课程页；Controller 测试覆盖停止播放、停止回放、清理录音和异步状态竞态。
- Evidence: `lesson_overview_page.dart`、`audio_controller.dart`、`lesson_media_lifecycle_test.dart` 与 `audio_controller_test.dart`。
- Status: active
- Promoted to: none
