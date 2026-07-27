# App 首次使用引导需求

> 状态：首切片实现完成；自动门禁与 Android 模拟器视觉通过，Sony 真机待补
> 任务等级：M
> 首次定义：2026-07-27
> 上位门禁：[`public-mvp-completion.md`](public-mvp-completion.md) 的 G1/G2

## 用户问题与本轮目标

当前 App 首次启动直接进入 Journey。新用户看不到产品如何学习、离线边界、是否需要账号，以及本地学习数据由谁控制。

本轮交付一个可独立验收的首次使用引导：

- 第一次启动在主导航之前显示一页简短说明；
- 说明每天约 10 分钟的场景学习、已下载内容离线可用、无需账号即可开始，以及学习数据保存在本机并可从 Settings 清除；
- 用户完成引导后进入 Journey，后续启动不再自动打扰；
- Settings 提供重新查看入口，但重看不会重置或重复写入完成状态；
- 完成状态保存失败时留在引导页，明确提示并允许重试，核心学习数据不受影响。

## 最小方案与边界

- 使用一个单页引导，不做轮播、动画、个性化问卷或账号创建。
- 使用 Flutter 官方维护的 `shared_preferences` 新异步 API 保存版本化布尔标记 `onboarding.completed.v1`；不为一个偏好修改 Drift Schema。
- App 启动时读取失败则优先进入 Journey，避免偏好插件故障阻断本地核心课程；完成写入失败则不虚报成功。
- 本轮不实现登录、同步、通知、分析/崩溃选择、订阅、支持工单或正式法律同意。
- 首发文案继续使用英语；不引入 i18n 框架或新视觉资产。

## 状态与数据契约

| 状态 | 页面行为 | 数据行为 |
|---|---|---|
| 首次启动 | 显示引导，不显示主导航 | 标记缺失或为 `false` |
| 保存中 | 主按钮禁用并显示进度 | 只写完成标记 |
| 保存失败 | 留在引导并显示重试提示 | 不改变完成状态 |
| 完成 | 进入 Journey | 标记写为 `true` |
| Settings 重看 | 显示同一内容与返回动作 | 不重写、不清除标记 |

“清除本机学习数据”不清除引导完成标记；卸载或清除整个 App 数据后按平台行为重新成为首次启动。

## 验收标准

1. 完成标记为 `false` 时，首次启动只显示引导页面，不显示 Journey/Review/Settings 主导航。
2. 点击主动作先进入保存中；保存成功后显示 Journey，重新创建 App 后不再显示引导。
3. 保存抛错时仍停留在引导页，显示明确错误并可再次提交。
4. Settings 可打开重看页面并返回 Settings；重看不调用完成写入。
5. 启动读取偏好失败时进入 Journey，不阻断本地课程。
6. 360 逻辑像素宽、200% 字号无溢出或遮挡；主动作触控高度至少 44。
7. format、analyze、Flutter 全量测试、Debug APK 与 `git diff --check` 通过；自动布局证据与真机视觉验收分开报告。

## 2026-07-27 实现证据

- `features/onboarding/` 已接入生产启动门禁、版本化本地完成标记和 Settings 重看路由；偏好读取失败时按契约放行 Journey，写入失败时留在页面重试。
- Widget 测试覆盖首次拦截、成功完成、写入失败、读取失败、重看不写入，以及 360 逻辑像素宽 / 200% 字号；Flutter analyze 0 issues、全量 83 tests、Debug APK 构建通过。
- Debug APK 为 249,083,116 bytes，SHA-256 `f1cf172218683a7fcb76a71d3f9430db4c3aa916d5a2ee329823ec8a292157be`。
- Android 模拟器 `emulator-5554` 已验证首次页无主导航、完成后进入 Journey、冷启动不再重复、Settings 可重看并返回；前台日志无 `RenderFlex overflowed`、`FlutterError` 或 fatal exception。截图为 `app-first-use-onboarding.png` 与 `app-first-use-replay.png`。
- 本轮未在 Sony 上安装或清除数据；模拟器证据不能替代真机视觉验收，也不能推导 G1/G2 已全部通过。

## 隐私、回滚与后续

- 只保存一个本地布尔偏好，不记录账号、邮箱、设备标识、录音、转写、分析事件或购买信息。
- 回滚可移除 onboarding Feature、Settings 入口和 `shared_preferences` 依赖；Drift Schema 与学习数据无需迁移。
- 生产客服、隐私政策、服务条款和账号生命周期仍是后续 G2/G3 工作，不能由本切片推导为完成。
