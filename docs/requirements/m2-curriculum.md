# M2 课程蓝图：3 个地点、12 节课

> 版本：v0.9  
> 日期：2026-07-26  
> 状态：产品默认范围与正式发布均于 2026-07-26 确认。M2 `0.2.7` 保留英文编辑 Agent 与中文教学 Agent 已双审并 language lock 的课程文本；49 条新增普通话音频、三个地点终局、线性解锁、本地完成状态、跨进程恢复和新增范围 14/14 单元人工逐页 UX 均已通过既定门禁。`content/fixtures/m2-course.json` 现为 `release`，并由默认 Provider 直接加载；旧 `MM_USE_M2_DRAFT` 验收开关已移除。

## 1. 目标与边界

M2 面向英语界面的零基础学习者，用 3 个连续的城市生活地点验证“短课 → 复习 → 地点挑战”的可玩循环。课程必须满足：

- 每个地点 4 节课，共 12 节；每课只解决一个可观察的真实任务，目标时长 8—12 分钟。
- 每课引入 3—6 个新知识点，复用已学表达完成听辨、意义、声调、汉字和场景应用。
- 只使用当前内容 Schema 已支持的步骤类型，不因单节课新增页面、后端或专用业务逻辑。
- `cafe-01` 及其 3 个知识点 ID 保持不变；所有新 location、lesson、dialogue 和 knowledge item 使用稳定 kebab-case ID。
- 学习目标暂时是内容制作和审核要求，不增加运行时 `learningObjective` 字段。App 继续通过 `title`、`prerequisites`、`itemIds` 和 `steps` 执行课程。
- 已按本蓝图建立 `content/fixtures/m2-course.json`，现为 App 默认正式输入。`content/fixtures/cafe-course.json` 仍保持 `release` 和 1 地点、1 节课，作为 M1 回归基线保留。

## 2. 地点与稳定入口

| 顺序 | Location ID | 显示名 | Lesson IDs | M2 地点挑战 ID |
| ---: | --- | --- | --- | --- |
| 1 | `cafe` | Café | `cafe-01`—`cafe-04` | `cafe-final-challenge` |
| 2 | `market` | Market | `market-01`—`market-04` | `market-final-challenge` |
| 3 | `metro` | Metro | `metro-01`—`metro-04` | `metro-final-challenge` |

现有 `cafe-challenge` 继续作为 `cafe-01` 的课内对话，不重命名、不删除。M2 为地点终局另建 `cafe-final-challenge`，避免后续扩充终局内容时让第一课突然引用尚未学习的表达。

## 3. 课程目录

### 3.1 Café

| Lesson | 先修课程 | 可观察学习目标 | 本课新增知识点 | 复用 |
| --- | --- | --- | --- | --- |
| `cafe-01`<br>Order one coffee | `[]` | 在完整提示逐步撤除后，说出并提交“一杯咖啡”的订单。 | `phrase-wo-yao` — 我要 · wǒ yào · I want<br>`noun-kafei` — 咖啡 · kāfēi · coffee<br>`sentence-wo-yao-yi-bei-kafei` — 我要一杯咖啡。· wǒ yào yì bēi kāfēi · I would like a cup of coffee. | 无；沿用当前已审核内容 |
| `cafe-02`<br>Choose hot or iced | `[cafe-01]` | 听到“热的还是冰的？”后，识别两个选项并说出自己的选择。 | `phrase-re-de` — 热的 · rè de · hot<br>`phrase-bing-de` — 冰的 · bīng de · iced<br>`question-re-de-haishi-bing-de` — 热的还是冰的？· rè de háishì bīng de · Hot or iced?<br>`sentence-wo-yao-bing-de` — 我要冰的。· wǒ yào bīng de · I'll have it iced. | `phrase-wo-yao` |
| `cafe-03`<br>Pick a cup size | `[cafe-02]` | 听到杯型二选一问题后，选择并说出大杯或小杯。 | `phrase-da-bei` — 大杯 · dà bēi · large cup<br>`phrase-xiao-bei` — 小杯 · xiǎo bēi · small cup<br>`question-da-bei-haishi-xiao-bei` — 大杯还是小杯？· dà bēi háishì xiǎo bēi · Large or small?<br>`sentence-wo-yao-da-bei` — 我要大杯。· wǒ yào dà bēi · I'll have a large. | `phrase-wo-yao`、`question-re-de-haishi-bing-de` 中的二选一结构 |
| `cafe-04`<br>Ask for the total | `[cafe-03]` | 主动询问总价，听懂一个脚本价格，并礼貌结束交易。 | `question-yi-gong-duoshao-qian` — 一共多少钱？· yígòng duōshao qián · How much is it altogether?<br>`amount-er-shi-wu-kuai` — 二十五块。· èrshíwǔ kuài · Twenty-five yuan.<br>`phrase-hao-de` — 好的。· hǎo de · Okay.<br>`phrase-xiexie` — 谢谢。· xièxie · Thank you. | 前三课的订单、温度和杯型表达 |

`cafe-final-challenge`：在没有全文常驻提示的情况下，完成“点一杯咖啡 → 选择冷热 → 选择杯型 → 询问总价 → 致谢”。终局不引入新词句。

### 3.2 Market

| Lesson | 先修课程 | 可观察学习目标 | 本课新增知识点 | 复用 |
| --- | --- | --- | --- | --- |
| `market-01`<br>Ask about this item | `[cafe-04]` | 指向一种水果，区分“这个/那个”，并询问所指商品的价格。 | `demonstrative-zhe-ge` — 这个 · zhège · this one<br>`demonstrative-na-ge` — 那个 · nàge · that one<br>`noun-pingguo` — 苹果 · píngguǒ · apple<br>`noun-xiangjiao` — 香蕉 · xiāngjiāo · banana<br>`question-zhe-ge-duoshao-qian` — 这个多少钱？· zhège duōshao qián · How much is this? | `question-yi-gong-duoshao-qian` 中的价格问法 |
| `market-02`<br>Buy two apples | `[market-01]` | 听懂“要几个？”，并用数量加商品完成购买请求。 | `question-yao-ji-ge` — 要几个？· yào jǐ ge · How many do you want?<br>`quantity-liang-ge` — 两个 · liǎng ge · two<br>`quantity-san-ge` — 三个 · sān ge · three<br>`sentence-wo-yao-liang-ge-pingguo` — 我要两个苹果。· wǒ yào liǎng ge píngguǒ · I'll have two apples. | `phrase-wo-yao`、`noun-pingguo` |
| `market-03`<br>Choose a different one | `[market-02]` | 拒绝当前商品，并用“这个/那个 + 大的/小的”选择另一个。 | `phrase-da-de` — 大的 · dà de · the big one<br>`phrase-xiao-de` — 小的 · xiǎo de · the small one<br>`sentence-bu-yao-zhe-ge` — 不要这个。· bú yào zhège · I don't want this one.<br>`sentence-wo-yao-na-ge-da-de` — 我要那个大的。· wǒ yào nàge dà de · I'll have that big one.<br>`question-zhe-ge-ke-yi-ma` — 这个可以吗？· zhège kěyǐ ma · Is this one okay? | `demonstrative-zhe-ge`、`demonstrative-na-ge`、`phrase-wo-yao` |
| `market-04`<br>Finish at checkout | `[market-03]` | 回答是否需要袋子，听懂脚本总价，并礼貌结束结账。 | `question-yao-dai-zi-ma` — 要袋子吗？· yào dàizi ma · Do you need a bag?<br>`phrase-yao-dai-zi` — 要袋子。· yào dàizi · I need a bag.<br>`phrase-bu-yao-dai-zi` — 不要袋子。· bú yào dàizi · I do not need a bag.<br>`amount-yi-gong-shi-er-kuai` — 一共十二块。· yígòng shí'èr kuài · Twelve yuan altogether. | `phrase-hao-de`、`phrase-xiexie`、价格问法 |

`market-final-challenge`：完成“指出商品 → 询价 → 选择数量 → 更换商品 → 回答袋子问题 → 听懂总价”。终局不引入新词句。

### 3.3 Metro

| Lesson | 先修课程 | 可观察学习目标 | 本课新增知识点 | 复用 |
| --- | --- | --- | --- | --- |
| `metro-01`<br>Find the metro station | `[market-04]` | 礼貌询问地铁站位置，并听懂“一直走”的单步指令。 | `phrase-qing-wen` — 请问 · qǐngwèn · Excuse me, may I ask...<br>`noun-ditie-zhan` — 地铁站 · dìtiě zhàn · metro station<br>`question-ditie-zhan-zai-nar` — 请问，地铁站在哪里？· qǐngwèn, dìtiě zhàn zài nǎlǐ · Excuse me, where is the metro station?<br>`direction-yi-zhi-zou` — 一直走 · yìzhí zǒu · go straight | `phrase-xiexie` |
| `metro-02`<br>Say where you are going | `[metro-01]` | 说出目的地，并请求一张前往该目的地的票。 | `verb-qu` — 去 · qù · to go<br>`noun-huoche-zhan` — 火车站 · huǒchē zhàn · railway station<br>`quantity-yi-zhang-piao` — 一张票 · yì zhāng piào · one ticket<br>`sentence-wo-yao-qu-huoche-zhan` — 我要去火车站。· wǒ yào qù huǒchē zhàn · I want to go to the railway station.<br>`sentence-wo-yao-yi-zhang-piao` — 我要一张票。· wǒ yào yì zhāng piào · I'll have one ticket. | `phrase-wo-yao` |
| `metro-03`<br>Ask which metro line to take | `[metro-02]` | 询问线路，并从脚本指令中识别线路、左右方向和换乘动作。 | `question-ji-hao-xian` — 去火车站坐几号线？· qù huǒchē zhàn zuò jǐ hào xiàn · Which metro line should I take to the railway station?<br>`noun-yi-hao-xian` — 一号线 · yí hào xiàn · Line 1<br>`direction-zuo-bian` — 左边 · zuǒbian · on the left<br>`direction-you-bian` — 右边 · yòubian · on the right<br>`verb-huan-cheng` — 换乘 · huànchéng · transfer<br>`sentence-zai-you-bian-huan-cheng-er-hao-xian` — 在右边换乘二号线。· zài yòubian huànchéng èr hào xiàn · Transfer to Line 2 on your right. | `direction-yi-zhi-zou`、数字概念 |
| `metro-04`<br>Ask someone to repeat | `[metro-03]` | 听不懂指路时请求重复或放慢，确认听懂后继续任务。 | `phrase-qing-zai-shuo-yi-bian` — 请再说一遍。· qǐng zài shuō yí biàn · Please say it again.<br>`phrase-qing-man-yi-dian` — 请慢一点。· qǐng màn yìdiǎn · Please speak more slowly.<br>`sentence-wo-ting-bu-dong` — 我听不懂。· wǒ tīng bu dǒng · I don't understand.<br>`phrase-ming-bai-le` — 明白了。· míngbai le · I understand now. | `phrase-qing-wen`、`phrase-xiexie`、前三课的路线表达 |

`metro-final-challenge`：完成“询问地铁站 → 说明目的地 → 识别线路与方向 → 至少使用一次澄清表达”。终局不引入新词句。

## 4. 先修与解锁规则

M2 草案先采用单线解锁，减少首轮内部测试的分支变量：

```text
cafe-01 → cafe-02 → cafe-03 → cafe-04
        → cafe-final-challenge
        → market-01 → market-02 → market-03 → market-04
        → market-final-challenge
        → metro-01 → metro-02 → metro-03 → metro-04
        → metro-final-challenge
```

- 每个 location 的 `lessonIds` 必须按上表顺序保存；`prerequisites` 必须精确引用前一课。
- 地点终局只引用该地点第 1—4 课已经出现的知识点，并在第 4 课后解锁。
- 若内部体验数据显示单线解锁导致明显中断，再单独评审跨地点解锁；本轮不预建复杂 `unlockRule`。

## 5. 内容制作与审核门槛

蓝图确认后的制作顺序固定如下；第 1—6 步、技术验收和整包人工逐页 UX 均已完成：

1. 新建独立的 M2 Draft，复制当前已审核的 `cafe-01`、3 个知识点和现有 ready 资产作为起点。
2. 按 Café 其余 3 课、Market 4 课、Metro 4 课分批加入 lesson、knowledge item、dialogue 和 `planned` 资产；每批运行内容校验。
3. 每课使用现有步骤类型组织场景引入、教学、意义/听音、跟读、对话和总结；不为目录项预先发明新交互。
4. 主 Agent 分别编排独立英文编辑 Agent 与国际中文教学 Agent；两者逐单元给出“通过/需修改”，主 Agent 只集成有证据的结论，不把专业审核转交用户。
5. 实际音频生成后逐条审核普通话发音；图片和音频补齐 path、SHA-256、许可和署名。文本 Agent 双审不能替代音频试听。
6. 12 节课、3 个终局和全部资产通过审核后，由用户批准把整个 M2 包改为 `release` 并切换 App 默认加载入口；该步骤已于 2026-07-26 完成。

### 5.1 分批审核记录

| 批次 | AI 预审 | 英文编辑 Agent | 中文教学 Agent | 普通话音频 |
| --- | --- | --- | --- | --- |
| Café 02—04 | 2026-07-26 完成；Draft 升至 `0.2.1` | 2026-07-26 通过 `0.2.4` 复核 | 2026-07-26 通过 `0.2.4` 复核 | 12/12 已选定、写回并打包核对 |
| Market 01—04 | 2026-07-26 完成；Draft 升至 `0.2.2` | 2026-07-26 通过 `0.2.4` 复核 | 2026-07-26 通过 `0.2.4` 复核 | 18/18 已选定、写回并打包核对 |
| Metro 01—04 | 2026-07-26 完成；Draft 升至 `0.2.3` | 2026-07-26 通过 `0.2.4` 复核 | 2026-07-26 通过 `0.2.4` 复核 | 19/19 已选定、写回并打包核对 |

Café 首批预审只处理可从当前产品和运行时契约直接确认的问题：学习者完成页不再显示内部审核流程文案；两条英文订单译法改为更自然的 `I'll have ...`；Café 04 先由店员说“好的”，再由学习者主动问总价；交易在学习者说“谢谢”后结束，不再让店员用“好的”回应感谢。Café 地点终局也改为从已出现的问候语开始，并在“谢谢”处结束。

当前 `dialogue_turn` 页面会沿 `nextNodeId` 推进完整对话图，并在每个 learner 节点重新要求可观察动作；连续系统节点按原顺序同轮显示。Café 02—04、Market 01—04、Metro 01—04 与三个地点终局都使用同一播放器。运行时把未内嵌的 location `challengeId` 合成为两步终局课程；四课完成后开放终局，完成终局后开放下一地点。第一轮 AI 预审只负责暴露问题；独立英文编辑 Agent、中文教学 Agent 与主 Agent 的最终集成结论记录在第 5.2 节。

Draft `0.2.6` 只修改共享学习 UI 的 learner-facing 英文：移除教学卡基于课程前两项推断的 `Build the order`，把听辨、排序和总结反馈改为不虚构答题结果或 Café 01 场景的通用文案，并让无音频对话使用 `Read`。英文编辑 Agent 与中文教学 Agent 对 12 课及 3 个合成终局复核均为 15/15 通过；汉字、拼音、英文释义、对话顺序与音频资产未改。

Draft `0.2.7` 修复共享 `scene_intro`：页面只从 location 读取地点 Badge，并显示本步 authored `step.text`，不再写死 `CAFÉ`、`你好！` 或“完整订单”，也不从地点名推导场景句。首轮专业复核共同拦截 `At the metro` 的英文自然度与 Metro 01 场景矛盾；删除推导句并补 Market/Metro Widget 回归后，两名原 Agent 最终复核均为 15/15 通过。汉字、拼音、英文释义、对话顺序与音频资产未改。

| 课程 | 首次预审结论 | 专业复核检查点（已通过） |
| --- | --- | --- |
| `cafe-02` | “热的还是冰的？”与语境回复“我要冰的”组成可理解的二选一；英文回复改为 `I'll have it iced.` | 中文教学 Agent 检查“冰的”作为零基础咖啡点单表达的地区通用性，以及两个“的”的轻声处理 |
| `cafe-03` | “大杯还是小杯？”与“我要大杯”保持前课的二选一结构；英文回复改为 `I'll have a large.` | 中文教学 Agent 检查简化成大/小两档是否符合目标城市语境；英文编辑 Agent 检查标题、提示和 size 文案 |
| `cafe-04` | “一共多少钱？”、脚本价格“二十五块”和“谢谢”形成付款闭环；删除了“好的”回应“谢谢”的不自然结尾 | 中文教学 Agent 检查 `yígòng` 变调、`duōshao` 轻声和固定价格难度；英文编辑 Agent 检查 learner-facing 支付文案 |

Market 批次移除了四节完成页中的内部审核流程文案；两条购买回复的英文改为更自然的 `I'll have ...`。`market-01-exchange` 与地点终局从卖方“您好”开始，Market 01、Market 04 和地点终局都在学习者说“谢谢”后结束，不再让卖方用“好的”回应感谢。Market 02、03 的“好的”仍是对购买选择的确认，保留不变。

| 课程 | 首次预审结论 | 专业复核检查点（已通过） |
| --- | --- | --- |
| `market-01` | 指向商品后说“这个多少钱？”可完成询价；新增卖方“您好”作为对话入口提示，并在学习者致谢处结束 | 中文教学 Agent 检查 `zhège/nàge` 的轻声标注与指示范围，英文编辑 Agent 检查标题、场景提示和价格问法 |
| `market-02` | “要几个？”在苹果语境中可省略名词；购买回复英文改为 `I'll have two apples.` | 中文教学 Agent 检查语境省略、`liǎng` 的量词用法与 `ge` 轻声；英文编辑 Agent 检查数量提示和订单译法 |
| `market-03` | “不要这个”后接“我要那个大的”形成更换商品路径；场景提示改为“按大小选择另一个”，购买回复英文改为 `I'll have that big one.` | 中文教学 Agent 检查“不要这个”的礼貌程度、`大的/小的` 的省略用法，以及 `de/ge` 轻声；英文编辑 Agent 检查 `Turn down` 与 `big one` 文案 |
| `market-04` | “要袋子吗？”、否定回复、脚本总价和致谢形成结账路径；在“谢谢”处结束 | 中文教学 Agent 检查目标城市的袋子询问习惯、直接回答的礼貌程度、`bú yào`/`yígòng` 变调和 `dàizi` 轻声；英文编辑 Agent 检查 bag/total 文案 |

Metro 批次移除了四节完成页中的内部审核流程文案，并把英文释义收敛到自然的乘车语境。`metro-01-exchange`、`metro-03-exchange` 与地点终局新增系统“您好”作为对话入口提示；Metro 01 在“谢谢”处结束，Metro 03 在学习者说“好的”处结束。Metro 04 的首个学习者回复改为本课主目标“请再说一遍”，请求放慢后由系统分段重复同一条换乘指令，并在“明白了”处结束。地点终局也以系统问候开场、以学习者确认听懂结束；自动测试已证明通用播放器能遍历其完整多轮图，并由同一课程路由承载终局。

| 课程 | 首次预审结论 | 专业复核检查点（已通过） |
| --- | --- | --- |
| `metro-01` | 新增路人“您好”作为入口提示，学习者询问地铁站并在收到“一直走”后致谢结束 | 中文教学 Agent 检查礼貌前缀、地点问法与“一直”的变调；英文编辑 Agent 检查礼貌前缀与方向译法 |
| `metro-02` | “去哪里？”与“几张票？”构成目的地和票数的连续语境；购票回复改为 `I'll have one ticket.` | 中文教学 Agent 检查“一张”的变调及目的地/票数问法的场景语域；英文编辑 Agent 检查目的地与购票文案 |
| `metro-03` | 新增“您好”入口并在学习者“好的”处结束；线路、左右和换乘英文释义按方向语境收敛 | 中文教学 Agent 检查问线路表达、“一号线”的变调和“边”的轻声；英文编辑 Agent 检查线路与方向译法 |
| `metro-04` | 首个学习者回复使用“请再说一遍”；请求放慢后分段重复同一条换乘指令，并在“明白了”处结束 | 中文教学 Agent 检查“听不懂”中“不”的轻声、“一遍/一点”的变调、分段方式与任务难度；英文编辑 Agent 检查重复和放慢提示 |

### 5.2 专业 Agent 双审记录

语言审核覆盖 14 个单元：11 节新增课程与 3 个地点终局。`cafe-01` 沿用 M1 已放行内容，不重复审核；若其汉字、拼音、英文、步骤或对话被修改，必须重新加入本表。审核原文现以 `content/fixtures/m2-course.json` 为准，本节只记录结论，不复制第二份课程文本。

- 英文编辑 Agent `/root/m2_english_editor`：检查标题、场景提示、步骤说明、英文释义、语义对齐和零基础可读性；
- 中文教学 Agent `/root/m2_chinese_teacher`：检查真实语用、教学顺序、汉字、带调拼音、轻声、变调、儿化和任务难度；
- 主 Agent：合并两份独立报告、处理冲突、修改 Draft、运行门禁，再把受影响单元交回原审核 Agent 复核。

两名专业 Agent 均明确以 AI 身份审核，不冒充真人、母语者或持证教师。用户不参与逐条语言审校；只在出现产品取舍、目标场景选择或主观体验决策时介入。

首次审核分别得到英文 8/14 通过、中文 9/14 通过。主 Agent 将阻塞项集成到 Draft `0.2.4`：修正英文自然度，把 Metro 01 改为“请问，地铁站在哪里？”，把 Metro 03 改为“去火车站坐几号线？”，重排 Market 终局的选品与数量顺序，并补齐 Metro 终局的询路、购票、问线路和换乘角色。两名原审核 Agent 复核后均为 14/14 通过。

| 审核单元 | 英文编辑 Agent | 中文教学 Agent |
| --- | --- | --- |
| `cafe-02` | 通过（`m2_english_editor`，2026-07-26） | 通过（`m2_chinese_teacher`，2026-07-26） |
| `cafe-03` | 通过（`m2_english_editor`，2026-07-26） | 通过（`m2_chinese_teacher`，2026-07-26） |
| `cafe-04` | 通过（`m2_english_editor`，2026-07-26） | 通过（`m2_chinese_teacher`，2026-07-26） |
| `market-01` | 通过（`m2_english_editor`，2026-07-26） | 通过（`m2_chinese_teacher`，2026-07-26） |
| `market-02` | 通过（`m2_english_editor`，2026-07-26） | 通过（`m2_chinese_teacher`，2026-07-26） |
| `market-03` | 通过（`m2_english_editor`，2026-07-26） | 通过（`m2_chinese_teacher`，2026-07-26） |
| `market-04` | 通过（`m2_english_editor`，2026-07-26） | 通过（`m2_chinese_teacher`，2026-07-26） |
| `metro-01` | 通过（`m2_english_editor`，2026-07-26） | 通过（`m2_chinese_teacher`，2026-07-26） |
| `metro-02` | 通过（`m2_english_editor`，2026-07-26） | 通过（`m2_chinese_teacher`，2026-07-26） |
| `metro-03` | 通过（`m2_english_editor`，2026-07-26） | 通过（`m2_chinese_teacher`，2026-07-26） |
| `metro-04` | 通过（`m2_english_editor`，2026-07-26） | 通过（`m2_chinese_teacher`，2026-07-26） |
| `cafe-final-challenge` | 通过（`m2_english_editor`，2026-07-26） | 通过（`m2_chinese_teacher`，2026-07-26） |
| `market-final-challenge` | 通过（`m2_english_editor`，2026-07-26） | 通过（`m2_chinese_teacher`，2026-07-26） |
| `metro-final-challenge` | 通过（`m2_english_editor`，2026-07-26） | 通过（`m2_chinese_teacher`，2026-07-26） |

Draft `0.2.4` 的课程文本已于 2026-07-26 language lock。任何汉字、拼音、英文、步骤文案或对话顺序变化都会使受影响单元的对应 Agent 结论失效，并要求提升 Draft patch 版本、重跑门禁和复核。

### 5.3 后续录音审校要点

- `哪里`、`可以`的书面拼音保留本调，录音分别落实三声变调；
- `一共`、`一号线`、`一遍`读 `yí`，`一杯`、`一张`、`一点`、`一直`读 `yì`，`不要`读 `bú yào`；
- `听不懂`中的“不”轻读 `bu`；`的`、`个`、`子`、`吗`、`呢`、`了`及“谢谢”的第二个“谢”、“明白”的“白”自然轻声；
- “请慢一点”后的重复要降低整体语速并按意群停顿，不能逐字机械断开或把轻声恢复成重读；
- Metro 终局录制时用停顿或不同角色声线区分“路人”和“售票/服务人员”两个场景。

49 条新增音频（Café 12、Market 18、Metro 19）已全部取得用户可接受版本，并在当前 Release `0.2.7` 的资产数组中保留唯一最终选择表；文件已复制到 App asset，写回 path/SHA-256/credit 并提升为 `ready`。任何合成文本、声线、参数、文件内容或后处理变化都会使对应音频结论失效，并要求重新试听、计算哈希和验证 APK。

## 6. 验收标准

- 范围评审确认 3 个地点、12 个 lesson ID、3 个地点终局和全部先修关系。
- 每课有且只有一个可观察学习目标；新增知识点数量在 3—6 个之间，且稳定 ID 全局唯一。
- `m2-course.json` 通过 JSON Schema、跨引用、拼音对齐、前置课程、对话可达性和资源状态校验。
- `cafe-course.json` 保留作 M1 基线；App 默认加载路径指向 M2 Release。
- 自动校验或单一 Agent 通过不等于内容发布通过；文本需要英文与中文两个独立专业 Agent 复核，实际音频仍需逐条试听。这些门禁、Sony 真机技术链路、真实进程冷启动和新增范围 14/14 单元人工逐页 UX 均已完成；用户随后批准正式发布。M2 当前状态为 `release`，默认 Provider 直接加载该包。

## 7. 已确认的产品默认

- 首轮场景顺序采用 Café → Market → Metro。
- 首轮采用单线解锁，不预建地点内自由选课或复杂 `unlockRule`。
- Metro 的脚本目的地固定为“火车站”；对应稳定 ID 已进入 M2 Release Fixture，后续只在专业 Agent 复核发现明确问题时按内容变更流程处理。
