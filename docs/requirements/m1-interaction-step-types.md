# M1 互动步骤类型

> 状态：2026-07-24 已实现，通过自动验证、Android 模拟器和 Sony Android 15 真机交互验收；完整 11 步完成、6 项到期复习与两次冷启动持久化已通过。咖啡场景图已从 `planned` 升为 `ready`，包内路径为 `assets/images/cafe-counter.png`，SHA-256 为 `a5fd40ea29477c59dd4aefae658044c251ae3867b50a574503f42ef921d5f011`；第二版“小杯子、大人物”构图和中文+拼音选项已获用户真机确认。

## 用户结果

英语零基础学习者在“点咖啡”课程中可以完成三种不同认知动作，而不是遇到 `Unsupported lesson step`：

- 看场景图选择对应意义；
- 听目标短语并辨认带调拼音；
- 把词块按中文语序组成完整订单。

## 内容契约

| 类型 | 必填字段 | 正确答案 | 降级 |
| --- | --- | --- | --- |
| `image_choice` | `itemId`、`dimension: meaning`、`assetId`、至少两个 `optionItemIds` | `itemId` | 图片不是 `ready` 时明确说明插画未就绪，保留文字选择；正式降级不得直接显示英文 `meaning` |
| `tone_contrast` | `itemId`、`dimension: tone`、至少两个 `optionTexts` | 目标知识点的 `pinyin` | 音频不可用时使用共享音频降级，不阻断题目 |
| `order_tokens` | `itemId`、`dimension: meaning`、至少两个 `tokens` | 按数组顺序拼回目标汉字，忽略句末标点 | 无外部服务依赖 |

Validator 必须确认选择题包含正确答案，并确认 `tokens` 能重建目标汉字。图片、音频和知识点继续使用稳定 ID；不为咖啡课程写专用页面逻辑。

## 状态与保存

- View 只渲染选中项、排序结果和反馈；Controller 负责判分、重试和 Repository 写入。
- 未完成选择或词块排序时，主按钮不可推进。
- 错误答案先保存 `forgotten` attempt，再清空当前答案供重试；正确答案保存 `remembered` attempt 后进入下一步。
- 保存失败保留当前答案并显示原地重试信息。

## 验收标准

- 咖啡 Fixture 从 8 步扩展为 11 步，三种类型均能从入口走到结果。
- 内容 Schema、运行时 Validator、Flutter 模型、Controller、Widget 和端到端测试同步更新。
- 320 × 640 逻辑尺寸、200% 文字缩放下三种步骤无横向溢出。
- planned 图片显示诚实降级，不使用临时几何图冒充正式插画。
- 不新增后端、云服务、数据库迁移或第二套 UI 组件库。
