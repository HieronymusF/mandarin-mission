# 隐私数据清单与可选服务边界

> 任务等级：M
> 当前清单：App `0.2.0+3` / inventory revision 1
> 最近核对：2026-07-27
> 适用范围：当前 Android Pre-release 源码；iOS、账号、同步、订阅和任何未来 SDK 接入必须另行复核

## 用户问题与本轮结果

用户需要在 App 内看懂当前版本到底保存、使用和发送什么数据，而不能从“以后可能接入通知/诊断”的开关误以为服务已经运行。本轮在 Privacy 页面增加版本化数据清单，并把未接入服务的边界固定下来。

当前假设：

- 没有真实通知或诊断服务商，也没有获准新增 SDK、网络传输或权限；
- 当前通知与诊断选择只是本机的未来服务许可，不等于系统权限、SDK 初始化或数据发送；
- 当前公开的 GitHub APK 是 Android 验收包，不把 iOS 或商店披露标成已完成。

最简单方案是在现有 Privacy 页面复用 `AppSection`、`ShadCard` 和 `AppLeadingRow`，由一个与 App 版本显式绑定的纯 Dart 清单提供文案。没有服务实现时只在本文冻结契约，不创建空 Service/Adapter 代码。

## 当前数据清单

| 数据类别 | 当前字段或内容 | 位置与期限 | 当前发送/共享 | 用户控制 | 源码证据 |
| --- | --- | --- | --- | --- | --- |
| 学习进度 | 课程 ID、状态、分数、开始/完成/更新时间、内容版本 | App 私有 Drift 数据库；保留到清除本机学习数据或平台移除 App 数据 | 不发送；无同步消费者 | Settings → Data management 清除 | `data/local/tables.dart`、`features/settings/data/local_data_repository.dart` |
| 掌握度与复习 | 知识点 ID、维度、箱位、置信度、到期时间、结果、提示、延迟和重试次数 | App 私有 Drift 数据库；同上 | 不发送 | 同上 | `data/local/tables.dart` |
| 开口自评 | 尝试 ID、目标 ID、本地/Provider 分数、时间；当前 Provider 分数未接远端来源 | App 私有 Drift 数据库；同上 | 不发送 | 同上 | `data/local/tables.dart`、`data/progress/lesson_progress_repository.dart` |
| 本地 Outbox | 学习事件 ID、实体类型、JSON payload、时间、尝试和确认状态 | App 私有 Drift 数据库；当前只本地排队，清除学习数据时删除 | 不发送；Go API 没有同步端点 | 同上 | `data/local/tables.dart`、`services/api/internal/httpapi/handler.go` |
| 首次使用状态 | `onboarding.completed.v1` 布尔值 | Shared Preferences；清除学习数据时保留 | 不发送 | 由系统 App 数据控制；App 内可重看但不重置 | `features/onboarding/data/onboarding_status_store.dart` |
| 可选服务选择 | `preferences.notifications.enabled.v1`、`preferences.diagnostics.enabled.v1` | Shared Preferences；清除学习数据时保留，可随时撤回 | 不发送；不触发系统权限或 SDK | App preferences 开/关 | `features/settings/data/app_preferences_store.dart` |
| 临时录音 | 当前练习的 AAC/M4A 文件与内存中的时长/音量状态 | App 临时目录；重录、取消、离开课程或结束会话时删除 | 不上传、不转写 | 录音前请求麦克风权限；可拒绝并走自评降级 | `data/audio/recording_service_impl.dart`、`data/audio/audio_controller.dart` |
| 课程内容与音频 | 随 APK 分发的课程 JSON、图片与音频 | 安装包/App 资产；清除学习数据时保留 | 不发送 | 随安装/卸载和平台备份策略管理 | `pubspec.yaml`、`content/fixtures/m2-course.json` |
| 构建信息与外部链接 | App 版本/构建号；仅在配置真实链接时交给系统浏览器或邮件 App 打开 | 读取平台包信息；App 不建立远端会话 | 当前无内置网络上传 | 未配置真实 URL/邮箱时不展示假动作 | `trust_center_data_source.dart` |

平台与 SDK 核对：

- Android 主 Manifest 只显式声明 `RECORD_AUDIO`；当前代码没有通知权限、推送 Token、账号、广告 ID、商店支付或定位权限；
- iOS `Info.plist` 当前未形成公开 MVP 的麦克风隐私描述与系统验收，不能从 Android 结果推导 iOS 已通过；
- 与数据处理相关的运行依赖限于本地音频/录音、SQLite/Drift、Shared Preferences、权限、包信息和外部链接能力；没有 Firebase、Sentry、远端分析、推送、身份或购买 SDK；
- 操作系统备份/恢复可能影响卸载后的本地数据生命周期；当前不承诺加密备份、跨平台删除或云端删除已经实现。

明确未收集或未发送：账号身份、邮箱、通知 Token、广告标识符、购买票据、原始录音上传、完整转写、分析事件和崩溃报告。未来代码或 SDK 一旦改变这条结论，必须先更新本清单、App 内摘要、政策草案和商店披露映射，再允许启用。

## 通知 Provider/Adapter 契约

第一阶段只允许本地学习提醒，不引入远端推送：

1. `notificationsEnabled` 默认关闭；关闭时不得请求通知权限、注册 Token、安排后台任务或保留待发送队列。
2. 用户主动打开后，Adapter 才能请求平台通知权限；系统拒绝、永久拒绝和服务不可用必须分别呈现，不能把本机选择显示成“系统已允许”。
3. 提醒输入只来自本机到期复习/每日学习状态和本地时区；通知正文不得包含分数、录音、自由文本、账号或其他敏感内容。
4. 撤回时取消所有已安排提醒并清除 Adapter 保存的提醒标识；本机选择成功写回后 UI 才显示 Off。
5. 任何远端推送、设备 Token 或营销消息属于新范围，必须另做数据清单、服务端删除和同意门禁。

实现前需要的最小接口语义是：读取平台可用性/权限状态、在用户动作后请求权限、按稳定提醒 ID 安排或取消本地提醒、取消全部提醒。服务商/Flutter 包未选定前不建立空接口。

## 诊断 Provider/Adapter 契约

1. `diagnosticsEnabled` 默认关闭；关闭时不得初始化会建立持久标识或联网的 SDK，不写远端队列，不发送历史事件。
2. 打开后也只允许经过 allowlist 的结构化字段：App 版本、构建号、平台、OS 主版本、匿名错误码、受控事件名和发生时间；禁止 Token、邮箱、账号标识、录音、转写、自由文本、购买票据和完整 Outbox payload。
3. Adapter 必须在发送前再次读取当前同意状态；撤回后停止采集与发送，并删除未发送的可选诊断队列和供应商侧可删除标识。
4. 学习和复习失败不能因诊断服务不可用而失败；错误上报始终是旁路能力。
5. 选择供应商前必须核对数据地区、保存期限、删除接口、崩溃时的默认字段、子处理者、商业条款和 SDK 初始化行为；未核对前保持当前 no-op 事实，但不提交伪造 no-op Adapter。

## 页面状态与验收标准

- 主路径：Settings → Privacy 能看到 `Data inventory for 0.2.0 (3)`，并依次理解本机存储、临时录音、当前不发送和清除边界；
- 构建版本变化时，测试必须先失败，要求同步修改 App 内清单与本文；
- 数据清单不依赖网络或法律 URL，外部隐私政策未配置时仍保留原来的未发布状态；
- 200% 字号、小屏滚动和语义树不能溢出或遮挡；
- 定向 Widget 测试、inventory 版本测试、移动端 format/analyze/全量测试与 Debug APK 通过；页面级视觉证据单独记录，自动测试不能冒充真机验收。

## 明确不做

- 不接真实通知、推送、分析或崩溃 SDK；
- 不请求通知权限，不生成通知 Token，不发送测试事件；
- 不发布隐私政策、服务条款或商店 Data safety/App Privacy 答案；
- 不实现账号、同步、删除账号、订阅或服务器数据保留；
- 不改变 Drift schema、Shared Preferences 键或现有清除学习数据语义。

## 变更门禁

任何版本发布前逐项比对：依赖与原生 SDK、Android/iOS 权限、Drift 表、Shared Preferences 键、临时文件、网络端点、服务端日志、App 内清单、隐私政策、Google Data safety 和 Apple App Privacy。结论按“已实现 / 未实现 / 未验证”记录，不能用本文替代正式法律审查或商店提交时的官方规则核验。
