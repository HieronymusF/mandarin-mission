# 给后续 AI 代理的交接提示

> 先读根目录 `AGENTS.md`，再读 `docs/development-workflow.md`、`docs/design-system.md` 和 `docs/project-status.md`。本文件只说明当前下一步与容易踩的坑，不复制完整规则。

## 当前最高优先级

实现本地到期复习 UI：

- Journey 增加到期复习入口；
- 新增 `/review` 路由与 presentation；
- 覆盖 meaning/listening/tone/hanzi 四维题型；
- 让用户选择忘记/模糊/记得；
- 覆盖加载、无到期项、保存失败和音频不可用降级；
- 增加 Widget 与端到端测试。

这是纯本地功能，不需要后端。直接按代码优先流程和 shadcn 设计系统实现，不要先去 Figma 画通用按钮、卡片或页面原型。

## 已经就绪，不要重做

- 分箱算法：`packages/learning_core/lib/src/review_scheduler.dart`；
- 队列数据层：`apps/mobile/lib/data/review/review_queue_repository.dart`；
- Drift 表：`MasteryStates` / `ReviewAttempts`；
- Riverpod：`reviewSchedulerProvider` / `reviewQueueRepositoryProvider`；
- 主题与组件基线：`app_theme.dart` + `docs/design-system.md`；
- 课程播放器的 shadcn 组件用法和 Controller 错误处理模式。

## 硬约束

1. 复习断网可用，不等待云端。
2. View 不直接调 Repository 或计算 rating；Controller/ViewModel 管理提交、失败与重试。
3. 不修改复习算法，除非先补测试并说明已有进度迁移。
4. 使用现有语义令牌和 shadcn 原语，不引入第二套 UI 库。
5. 不用 emoji、字符画或临时几何图冒充正式资产；图标用 Lucide，插画记录来源。
6. 独立功能分支、Conventional Commits、草稿 PR；不 `git add -A`。
7. 禁止批量删除；一次只删除一个明确文件。

## 从上一轮代码审视保留的经验

已在代码优先 UI 重构中修复：

- 1103 行课程页面已按步骤拆分；
- Repository 调用从按钮回调移入 `LessonPlayerController`；
- state 使用 `copyWith`；
- 保存中、保存失败和重试已有状态；
- `usedListeningHint` 已正确透传并有集成回归断言；
- 重复音频占位反馈已集中。

仍需继续处理：

- 新的纯规则进入 `learning_core` 并有单元测试；
- Journey 接入真实进度/解锁时再建立 ViewModel；
- 课程和复习通用文案需要未来 i18n 入口；
- 不吞 Future，不允许重复提交；
- `shadcn_ui` 升级必须单独 PR 并做截图回归。

## 复习 UI 的产品约束

- 复习不是课程练习，必须表达忘记/模糊/记得三态；
- 单次控制在 3—5 分钟，到期过多拆成“今日必做 + 额外巩固”；
- 忘记项在本次尾部补救，同日同项最多两次；
- meaning/listening 使用客观选择 + 记忆自评；
- tone/hanzi 一期可使用翻卡自评；
- 首次课程不授予记忆星，至少跨学习日成功回忆一次。

## 推荐执行顺序

1. 为 M 级任务建立 `docs/requirements/review-ui.md`；
2. 写 ViewModel 状态和失败测试；
3. 接 `ReviewQueueRepository`；
4. 用现有 shadcn 组件完成页面与 Journey 入口；
5. 跑 format/analyze/test、关键状态截图和真实 Android 验证；
6. 更新项目状态与 M1 里程碑，草稿 PR 说明已知限制。

如果代码和文档不一致，以测试和实际运行判断事实，再同步文档。
