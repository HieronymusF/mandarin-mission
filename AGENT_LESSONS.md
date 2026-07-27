# Mandarin Mission Agent Lessons

仅保留可复用、项目特定且未被其他规则完整覆盖的经验。新增前先搜索并合并重复项。

涉及稳定仓库行为或行为代码变更时，按根 `AGENTS.md` 的 Repo docs sync gate 核对并最小更新 `repo-docs/`。

## Lesson: 商店发布必须晚于 App 产品完成门禁

- Last confirmed: 2026-07-27
- Pattern: M2 默认内容、GitHub Pre-release 和默认 Release 真机复验完成后，把 release keystore 和商店签名当成自然下一步；但生产路由只有 Journey/课程/复习，Go 服务只有健康/就绪/元数据端点，客服、隐私、账号、同步、删除、订阅和公开 MVP 内容均未实现。
- Prevention rule: 推荐任何商店签名、素材或审核动作前，先按 `docs/requirements/public-mvp-completion.md` 审计 G1—G6。M1/M2、绿 CI、真机内容验收和 GitHub Pre-release 只证明各自范围，不得升级为“App 已完成”或商店候选。功能开发需要的 Apple/Google 沙箱配置可以提前做，但正式上架工作必须最后开始。
- Verification: G1—G6 每项都有生产实现、自动/手工证据和真实支持/法律信息；任一未关闭时，`HANDOFF.md` 的下一步仍是 App 产品开发或质量修复。
- Evidence: `apps/mobile/lib/app/router.dart`、`apps/mobile/lib/features/`、`services/api/internal/httpapi/handler.go`，以及 2026-07-27 用户对上架优先级的纠正。
- Status: active
- Promoted to: `docs/requirements/public-mvp-completion.md`

## Lesson: 内容签核必须枚举全部发布单元并编排专业 Agent

- Last confirmed: 2026-07-26
- Pattern: M2 交接把下一步写成“取得 11 节新增课程的人工签核”，既漏掉同属 release 门禁的 3 个地点终局，又把可由专业 Agent 完成的逐条语言审核转交给用户协调。
- Prevention rule: 从 `locations[].lessonIds` 与 `locations[].challengeId` 推导完整审核范围；主 Agent 分别编排独立英文编辑 Agent 与国际中文教学 Agent，自己负责交叉核对和集成，只把产品取舍或主观验收交给用户。不得用 lesson 数量代替完整发布范围，也不得把代理可完成的专业审核转嫁给用户。
- Verification: 审核表覆盖 11 节新增课程和 3 个地点终局，并有两份独立 Agent 结论及主 Agent 集成记录；language lock 后的音频门禁覆盖 Café 12、Market 18、Metro 19，共 49 条 `planned` 音频。
- Evidence: `docs/requirements/m2-curriculum.md` 第 5.2 节、`content/fixtures/m2-course-draft.json` 的 3 个 `challengeId`，以及 2026-07-26 用户明确要求调用中英文专业 Agent 完成审核。
- Status: active
- Promoted to: `content/AGENTS.md`

## Lesson: Release 交付必须验证远端可下载资产

- Last confirmed: 2026-07-24
- Pattern: 本地完成 `flutter build apk --release` 并记录产物，不代表 GitHub 已发布 Release；若仓库侧栏仍显示 `No releases published`，用户无法从 GitHub 下载安装包。
- Prevention rule: 用户要求“打 release 包并上传到 Git”时，把交付门禁定义为：版本标签指向预期 `main` 提交、GitHub Release 已发布、APK 资产状态为 `uploaded`，且远端资产大小与 SHA-256 和本地产物一致。Debug 证书签名的 release 模式包必须标记为验收包或 Pre-release。
- Verification: `gh release view <tag> --json assets,targetCommitish,url` 与 GitHub Releases 页面都能看到 APK；GitHub API 返回的 `size` 和 `digest` 与本地 `Get-Item`、`Get-FileHash -Algorithm SHA256` 一致。
- Evidence: GitHub Pre-release `v0.1.0+1` 的 `app-release.apk` 为 62,720,887 bytes，远端和本地 SHA-256 均为 `235d7e2875d3d5c35040aab3f6078fa960ed8aeae36eed96fa017942e2819792`。
- Status: active
- Promoted to: none

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
- Promoted to: 根 `AGENTS.md` 的“连续性维护”与知识路由

## Lesson: PR 改基线后显式触发 CI

- Last confirmed: 2026-07-18
- Pattern: 堆叠 PR 改为以 `main` 为基线后，GitHub 的 `pull_request` 工作流不会仅因 base branch 被编辑而自动运行。
- Prevention rule: PR 改基线后检查工作流触发类型；若没有新运行，关闭并重新打开 PR，或推送新提交触发 `reopened`/`synchronize`，再等待全部 job 完成。
- Verification: 在 GitHub 检查该 PR 对应的 `mobile`、`learning-core`、`api` 三项 job 都属于最新 head SHA 且最终通过。
- Evidence: PR #11、#12 改基线后的 CI 触发与合并验证。
- Status: active
- Promoted to: none

## Lesson: 书写画布必须在本地完整接管高频指针序列

- Last confirmed: 2026-07-26
- Pattern: 汉字书写画布位于可滚动课程页中时，父级可能竞争竖向手势；如果每个 `PointerMoveEvent` 又从尚未重建的父组件 props 复制笔迹，同一帧内较早采样点会被覆盖，曲线被拉成稀疏直线。双字共用画布若不按字符格线断笔，还会把“咖”与“啡”跨格连接。
- Prevention rule: 自定义书写画布应尽早接管指针序列，并在本地保存当前手势的连续采样；向父级回传副本，不以父级重建作为下一事件的数据源。多字画布跨字符格线时新开一笔，同时保留清除、重写、跳过与对照自评路径。
- Verification: Widget 测试在不 `pump` 的情况下连续发送多个 move，确认全部采样保留；跨字符中线后确认产生两笔。再在 Android 真机分别验证横、竖、斜、曲线和跨字移动，页面不滚动、笔迹不被拉直或跨格连线。
- Evidence: `apps/mobile/lib/features/lesson/presentation/steps/hanzi_writing_step.dart`、`apps/mobile/test/features/lesson/presentation/hanzi_writing_step_test.dart` 与 2026-07-23 Sony XQ-DQ72 真机反馈。
- Status: active
- Promoted to: none

## Lesson: 学习挑战必须先有可观察动作再允许推进

- Last confirmed: 2026-07-23
- Pattern: `dialogue_turn` 只展示标准答案和静态麦克风图标，同时让底部主按钮直接进入下一步。页面虽然能导航，但用户没有可执行、可验证的挑战动作，终局对话退化为静态过场。
- Prevention rule: 每个练习或挑战步骤至少提供一个与目标一致的可观察动作；在动作完成前禁用主推进按钮。P0 不具备 AI 判音时，应明确使用脱稿自报或提示卡降级，不伪装成语音识别。多轮对话必须沿 `nextNodeId` 读取真实图，不假设节点数组顺序或严格 `system → learner` 交替；连续系统节点可以同轮展示，但每个 learner 节点都要重新完成动作门禁。
- Verification: Widget/端到端测试先点击禁用主按钮并确认仍停留当前步骤，再分别走无提示和提示路径；多轮测试覆盖连续系统节点、每轮动作重置、系统/学习者两类终止节点和离页清理，并用真实地点终局核对完整 learner 轮数。真机确认所有入口可见、状态反馈明确、完成后才能进入下一步。
- Evidence: `DialogueStep`、`CourseDialogue.turnFrom`、`LessonPlayerState.dialogueReplyMethod`、`dialogue_flow_test.dart`、`app_test.dart`，以及 2026-07-23 Sony XQ-DQ72 第 7 步真机验收。
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

## Lesson: 真机跨进程验收不能拆成两次 `flutter test integration_test`

- Last confirmed: 2026-07-26
- Pattern: 在 Sony 真机先后运行两次 `flutter test integration_test/... -d <device>`，预期第一次写入的 App 沙箱数据库供第二次读取；实际测试框架在每次结束后卸载测试 App，包与沙箱数据一并消失，也清除了设备此前安装版本的本地数据。
- Prevention rule: 真实磁盘冷启动使用只安装一次的专用验收入口：构建一个独立 target APK，以 `adb install -r` 安装，首次启动写入唯一命名的隔离数据库，`adb shell am force-stop <package>` 后重启同一 APK 只读复核。执行任何可能卸载 App 的测试命令前，先确认设备可丢弃或已备份；不得声称卸载后的既有用户数据仍被保留。
- Verification: 强制停止后 `pidof` 为空；重启后的 Android PID 与数据库 marker 中的 seed PID 不同；同一数据库恢复预期记录和 Journey 状态。结束后只删除明确的隔离数据库文件，并用 `install -r` 恢复默认构建。
- Evidence: `apps/mobile/integration_test/m2_process_persistence_app.dart`；2026-07-26 Sony `XQ-DQ72` seed PID `21038`、verify PID `21209`。
- Status: active
- Promoted to: none

## Lesson: 真机交还状态必须匹配下一项验收

- Last confirmed: 2026-07-26
- Pattern: M2 冷启动验收完成后，为了证明源码默认 Provider 未改变而把 Sony 恢复成 Café Release 构建；但交接中的下一项工作正是 M2 人工逐页 UX，用户接手设备时只能看到第一课，误以为第二课尚未实现。
- Prevention rule: 区分“源码默认入口”和“当前设备安装包”。验收默认兼容性后，如果下一步仍依赖 Draft/feature build，应把该验收构建重新装回设备并停留在用户需要检查的入口；不要为了证明默认值而把设备留在与下一步相反的状态。
- Verification: 交还前用 UI hierarchy 检查下一步需要的课程/按钮实际可见，并在 `HANDOFF.md` 明确记录 build flag、设备当前页面和源码默认值，两者不得混写。
- Evidence: 2026-07-26 Sony 重新安装 `MM_USE_M2_DRAFT=true` 后，层级中出现 `Choose hot or iced`、Market 与 Metro 终局，设备进入 Café 02 `Step 2 of 10`。
- Status: active
- Promoted to: none

## Lesson: UI 工程验证不能替代视觉失败证据

- Last confirmed: 2026-07-27
- Pattern: 面对 UI 对齐问题时，先增加通用 token、布局组件和几何断言，并以 analyze、Widget tests、APK 构建通过作为结果；这些检查可能全部为绿，但没有复现用户看到的具体页面状态，也没有修复前后截图，无法证明视觉问题真正解决。仅被测试和文档引用的新布局组件也可能成为未验证抽象。交互控件即使在 200% 字号测试中无溢出，内部可点击语义区域仍可能小于外层布局声明的 44dp。
- Prevention rule: UI Bug 先记录入口、状态、viewport、文字缩放并保存修复前截图；写出根因假设和视觉成功标准；优先修改现有父容器或共享根因；修复后在同条件截图对比。对按钮、开关等交互控件同时断言实际可点击语义区域至少 44×44dp，不能只检查外层 Row 或约束。只有两个真实生产调用点才允许新增共享组件。
- Verification: 同一场景有修复前/后视觉证据；相关尺寸与 200% 字号无溢出；交互控件的 Widget 几何与目标设备 UI hierarchy 均显示足够触控区域和正确语义；每个改动行可追溯到根因；analyze/test/build 作为回归门禁单独通过。
- Evidence: 2026-07-22 Widget 库任务中自动测试与 APK 构建通过，但无连接设备、无新增页面截图，交付只能证明工程回归，不能证明具体视觉缺陷已修复；2026-07-26 M2 自动链路全绿后，Sony 人工逐页检查仍在 Café 02 Step 4 发现长汉字/拼音行溢出 78 px，随后以同页前后截图和窄卡片失败测试闭环。2026-07-27 通知/诊断开关首轮 Widget 测试和截图都无溢出，但模拟器 UI hierarchy 显示可点击语义只包住约 38×21dp 的内部开关；改为 44×44dp 外层语义/手势后，自动断言与设备层级均通过。
- Status: active
- Promoted to: `AGENTS.md`“AI 开发行为约束”与根目录 `WIDGET_LIBRARY.md`

## Lesson: 共享课程组件不能从课程全局数据推断本步语义

- Last confirmed: 2026-07-26
- Pattern: 共享 `teach_card` 读取课程前两个知识点后，在每张教学卡生成同一个 `Build the order`；听辨、排序和总结组件又写死 Café 01 的“完整订单”“咖啡回复”和“明日复习”。`scene_intro` 同样写死 Café 地点与问候，首次改动又从 location 标题推导出不自然且与 Metro 01 矛盾的 `At the metro`。单课冒烟可看似合理，跨课后会教错组合、虚构答题结果、承诺错误时间或制造错误场景。
- Prevention rule: 共享步骤只呈现本步显式字段和题型稳定语义；不从 lesson 级列表推断组合，也不从 location 标题生成完整场景句；不在共享组件写场景名、固定答案含义或日历承诺。需要场景结果时由内容包提供 outcome/support text。
- Verification: 至少用两个语义不同的课程 fixture 覆盖共享组件；断言不会出现第一课专用文案、推断卡或地点派生句。learner-facing 文案变更按 language lock 提升版本，并让受影响范围重新进行中英文双审。
- Evidence: 2026-07-26 Sony Café 02—04 逐页 UX、`teach_card_step.dart`、`scene_intro_step.dart`、`listen_choice_step.dart`、`order_tokens_step.dart`、`dialogue_step.dart`、`summary_step.dart` 及对应 Widget tests。
- Status: active
- Promoted to: `docs/content-authoring.md`

## Lesson: 语序题的干扰项必须随机且在一次答题内稳定

- Last confirmed: 2026-07-27
- Pattern: `order_tokens` 用固定 `.reversed` 生成词块区，看似保证了初始答案错误，实际让所有题都能按从右向左的固定模式完成。这是 `reasoning-error`：实现只避免了正确顺序，没有检查交互是否仍能测量语序回忆。
- Prevention rule: 语序、拼接或排序练习进入步骤时只生成一次干扰顺序，本次答题内选择、撤回和父级重建都保持稳定；三个以上选项同时避开正确顺序与固定完全倒序。内容数据继续保存唯一正确顺序，不为随机展示改写内容包。
- Verification: 至少用一个四词题先证明旧实现为完全倒序，再断言新顺序既非正确顺序也非完全倒序；选择并撤回首个词块后，词块区恢复为同一初始顺序。最后在真实课程页面核对可见词块顺序和运行日志。
- Evidence: 2026-07-27 `order_tokens_step.dart`、`m1_step_types_test.dart`、Android 模拟器 Café 01 Step 8 截图 `build-the-phrase-shuffled.png`；完整移动端 analyze、86 tests 与 Debug APK 通过。
- Status: active
- Promoted to: `repo-docs/walkthroughs/one-real-run.md`

## Lesson: Riverpod 生命周期清理不能在卸载后读取 ref

- Last confirmed: 2026-07-23
- Pattern: `ConsumerState.dispose()` 中再通过 `ref.read(...)` 获取媒体 Controller 会触发 unmounted ref 错误；异步清理完成时直接写 Notifier state，也可能遇到 Provider 已释放。连续生命周期事件可能重复取消同一次录音；系统设置中改变权限后，Controller 的缓存状态可能过期；同一课程页内切换步骤不会触发 `dispose()`，录音可能跨步骤继续。
- Prevention rule: 在 `initState()` 保存需要的 Controller 回调；生命周期、页面离开与步骤返回复用一个幂等清理 Future，导航前等待清理完成；App 恢复到 `resumed` 时重新读取平台权限；异步间隙后写 state 前检查 `ref.mounted`。
- Verification: Widget 测试覆盖 App 切后台、设置返回权限刷新和从录音步骤返回上一课程步骤；Controller 测试覆盖停止播放、停止回放、清理录音、平台权限刷新和异步状态竞态。真机同时核对界面、AudioRecord/音频焦点日志与缓存文件。
- Evidence: `lesson_overview_page.dart`、`audio_controller.dart`、`lesson_media_lifecycle_test.dart` 与 `audio_controller_test.dart`。
- Status: active
- Promoted to: none

## Lesson: 持久化成功不等于返回页已经呈现真实状态

- Last confirmed: 2026-07-23
- Pattern: 课程完成事务正确写入 `lesson_progress_entries`，到期复习也能从同一数据库出现，但 Journey 课程卡仍可能因为硬编码文案、进度值和按钮而显示 `Not started`；只检查数据库或复习数量会漏掉这个用户可见断链。
- Prevention rule: 汇总页必须从 owning Repository 读取持久化事实；完成事务成功后显式刷新对应查询再导航。若没有持久化步骤索引，不得把 `in_progress` 文案写成可恢复原步骤的 `Continue`。
- Verification: 端到端测试在返回 Journey 后断言 completed 文案与操作；真机完成课程后覆盖安装并冷启动，核对完成状态、复习数量与操作按钮共同保留，再完成一轮到期复习并二次冷启动。
- Evidence: `lesson_progress_repository.dart`、`lesson_providers.dart`、`journey_page.dart`、`lesson_overview_page.dart`、`app_test.dart` 与 2026-07-23 Sony `XQ-DQ72` 真机闭环。
- Status: active
- Promoted to: none

## Lesson: 极短 TTS 资产必须先做首尾完整性与对话韵律试听

- Last confirmed: 2026-07-26
- Pattern: 对“我要”“咖啡”这类两三个音节直接单独合成时，模型可能吞掉开头主体、把结尾压短或让音节含混；较长句子也可能在句内压缩某个分句，让前后语速明显不均。对话回复即使字音正确，也可能把信息焦点重读错位，或使用像后面仍有话的未完句语气。同一命名声线在不同 seed、文本或推理结果中仍可能产生明显的说话人身份与音色漂移，不能把 Provider 的 speaker 标签当作听感一致性证据。格式、哈希、波形峰值和文本前端声调全部正确，不能证明听感或语用韵律可用。
- Prevention rule: 同一课程的一组极短 TTS 优先在一次推理中合成为一条母带，再按静音边界切成独立文件；若模型对独立短词仍压缩音节，先合成同词重复的上下文试听，选中清楚的一次后再精确裁切。每个音节的声母、韵母和声调必须分别检查：`ei`、`ao`、`ou` 等复合韵母要核对滑动是否完整，一声要确认高平调没有弱化成轻声；长句还要逐分句比较语速，不能只听整句总时长。用户指出过快或吞音后，新一轮候选必须围绕该缺陷做技术预筛；与被拒版本时长、边界或节奏仍接近的候选不再全部转交用户，但时长只能用于淘汰明显无改进版本，不能替代人工逐音节签核。若只有一个分句过快，优先尝试自然韵律边界；仍无法改善时可只放慢该分句再拼接，但必须连续试听拼接点、音色、重音和整句问答语气。任何 seed、文本边界或分段合成变化都使既有说话人听感批准失效；新候选先与至少一条用户已接受的同声线参考连续对比，可用基频和频谱特征只淘汰明显离群项，但不得据此断言性别或替代人工确认说话人身份与音色一致性。对话音频还必须放回前后轮次，按角色意图检查信息焦点、对比重音和句末完整性，例如回答“要袋子吗？”时，“要袋子。”的肯定焦点应落在“要”。必要时用合法同音字作为合成文本，但必须记录显示文本与合成文本的差异。分别调用模型或分别归一化可能造成声纹漂移。固定随机参数若引入声码器电音或金属感，应淘汰该模型/模式，不以“音色统一”为理由继续调参。写入 Fixture、标记最终候选或构建 APK 前，由人工连续对比全部片段，确认首音、末音、每个音节、声调、停顿、分句语速、重音、句末语气、音量、音色一致性和无声码器伪影。
- Verification: 连续播放整组最终裁剪文件，听清完整 `wǒ yào`、`kā fēi` 等目标音节，并确认片段间是同一音色；长句逐分句比较语速，拼接方案还要确认边界连续、音色一致且没有不自然停顿；对话回复再与前一轮问题连续播放，确认重音表达正确的信息焦点、句末语气符合该轮是否结束。自动校验只负责格式、哈希、响度和打包，不替代这些人工判断。
- Evidence: 2026-07-24 MeloTTS 首版 `wo-yao.wav` 吞掉“我”的主体、`kafei.wav` 两个音节含混；第二轮重复合成后截取中间 take 虽改善边界，但用户确认两条音色不一致；第三轮固定随机参数的一次母带解决一致性后，长句出现明显电音。MeloTTS 因连续三轮人工试听失败被淘汰。同日 CosyVoice 初版 `咖啡` 只有约 0.44 秒并被用户否决；降速 J 组虽获“都还可以”的初步反馈，放回整组后仍被听成 `kāfi`；同音“咖飞”K 组修正 `/ei/` 后，`kā` 又被用户指出偏轻声。2026-07-26 Market 验收又发现“不要这个。”句尾像仍有后文，而作为“要袋子吗？”肯定回答的“要袋子。”应重读“要”；Metro 原版“火车站”约 0.476 秒，被用户指出过快且三个音节均未念完整，重生成后只将明显延长至约 0.69 秒的两个版本送审；同组长句“去火车站坐几号线？”又出现前半句过快而后半句正常的句内语速不均。其替换 round 12 中，A 的句内节奏最好却被用户明确听成男声，自动测得中位基频仅约 87 Hz；B/C/D 虽未出现同样的低音高离群，但都因重音奇怪被否决。说明词音、speaker 标签和格式正确不能替代逐音节、逐分句、说话人身份与对话语用韵律检查，也不能把未针对反馈改善的候选继续转交用户。
- Status: active
- Promoted to: `docs/content-authoring.md` 的 TTS 课程音频门禁
