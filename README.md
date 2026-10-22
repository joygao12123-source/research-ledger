# 研究账本 · Research Ledger

> 献给最近没动力的 PhD 研究者。
> For PhD researchers who have lost their drive lately.

[English below](#english)

<p align="center"><img src="docs/screenshot-today.png" width="520" alt="研究账本：今天视图"></p>

---

## 这是什么

一个 macOS 上的小程序。没有 to do list，只有一个动作：**记一笔**。记你做出来的东西、刚懂的东西、做的决定、卡住的地方。然后它把这些按天、按周、按月、按项目给你看回去。

它不是一个效率工具。它是我给自己造的一个确认感来源。下面解释为什么。

## 我的困境

我在读 PhD，做的是自己选的方向，拿到了奖学金，做的是喜欢的事。但有一段时间我每天都在刷短视频。工作间隙刷，休息日早上刷，手里拿着手机的每一刻都在刷。直到有一天，短视频里的话从我嘴里蹦出来，我才意识到我的大脑被洗了。

我以为是意志力问题。不是。

我逃避的是一类非常具体的任务：繁琐、复杂、难度高、做了也不一定有正反馈。研究就是这种任务。跑了三天数据不知道对不对，写了一节不知道算不算推进。短视频做的事恰好相反，三秒一个反馈。我的大脑在两种反馈节奏之间选了快的那个。

更深一层，我拿起手机的那一刻，不是"知道该做什么但不想做"，而是**根本不知道下一步是什么**。我想要的也不是导师的一句好，而是**自己心里的一个确认感：今天推进了**。这两件事是同一件事。确认感有一个前提：事先定义过什么叫"推进了一步"。下一步是什么都不知道，就不可能有"我完成了下一步"的感觉。我不是得不到反馈，我是没有给自己留下一个可以产生反馈的东西。那个"空"就是这个。

## 对我有用的几句话

这些是我在和 Claude 聊的时候被告诉的话。它们不是鸡汤，每一句都改变了我对某件事的理解。写在这里，也许对你也有用。

**关于短视频。**
"这不是意志力问题，是你的大脑在两种反馈节奏之间选了快的那个。从末端下手戒手机没有用，要从第一环下手。"

**关于"空"。**
"你缺的不是动机，不是意志力。你缺的是一个进度单位。读文献你从不逃避，因为它自带进度条。日记坚持不下来，因为每天打开本子时，没有一个'今天的单位'可以写。"

**关于自己给自己反馈。**
"反馈的本质是信息，不是情绪。它回答一个问题：我做的和我打算做的，对上了吗？确认感来自对账，不来自自我评价。羽毛球打完一场，你不需要任何人告诉你'今天练了'，因为'一场'是事先定义好的单位。研究缺的就是这个单位，不是缺一个夸你的人。你不是要给自己反馈，你是要给自己留下一个可以被反馈的标准。反馈会自己来。"

**关于尺子在谁手里。**
"你用来评价自己的那把尺子，一直在别人手里。它们在的时候你很能干，它们一不在，比如休息日早上，比如任务没拆开的时候，你就空了。先评价，再听评价：任何东西交给别人看之前，先自己写一句评价。把别人的话拆成观察和结论：观察照单全收，结论自己下。"

**关于导师。**
"导师通常不会对'我不知道往哪走'这种状态做出反应，不是不关心，是这种状态没有给他们一个可以抓的东西。你每周带去的如果是进展汇报，他们会点头；带去的如果是一个需要他们做的决定，他们会坐直。只带一页纸：一句话的研究问题，这周做了什么，一个需要他们现在选的 A 或 B。"

**关于"做的对不对"。**
"研究里不存在事先的'对'。能替代它的检验只有一个：你能不能用一句话说出你在问什么问题、用什么数据、比较什么和什么。能说出来，就是走在路上；说不出来，那句话本身就是当前的工作。"

**关于新领域里的累。**
"没有任何人、任何工具能带你走上'最准确的一条路'，因为在一个新领域里，那条路还不存在。它是你走过去之后回头看才会显出来的东西。你感到的累，有一部分正是在找一个不存在的东西。在新领域里感到迷路，就是'不确定性'阶段的感觉，不是哪里做错了。"

## 这个软件怎么用这些想法

它只做一件事：**让"我推进了一步"变成一个可以核对的事实，而不是一种感觉。**

- 每一笔是四种之一：**产出**（写结果不写动作）、**懂了**（刚才理解了什么）、**决定**（做了什么决定、为什么）、**卡住**（卡在哪）。卡住也要记，研究说挫折对动力的影响是进步的两倍。
- 每一笔可以挂一个项目，产出默认给项目 +5% 进度。这是"项目层面多了多少"的尺子。
- **本周**告诉你四类各几条、几天有记录、每个项目从百分之几走到百分之几。**本月**是热力图。**懂了**单独抽出来按月排，一个月后回头看，是你知识水平的变化。
- 没有待办，所以它永远不会变成一张"你还没做"的清单。

设计来源：Amabile 和 Kramer 的"进步原理"（内在动力最强的来源是感知到自己在有意义的工作上推进了）、Andreessen 的 anti-todo list、学术研究日志的惯例、Julia Evans 的 brag document、Simon Willison 的 TIL、interstitial journaling、Daily Dots 这类点阵 app。

## 安装

去 [Releases](../../releases) 下载 `研究账本.app.zip`，解压后拖到桌面或应用程序文件夹。第一次打开如果系统提示"无法验证开发者"，右键点 app 选"打开"。macOS 14 以上，Apple Silicon。

数据在 `~/Library/Application Support/ResearchLedger/ledger.json`，纯 JSON，可以自己备份。

## 改代码

源码在 `Sources/App.swift`，一个文件，SwiftUI，没有依赖。需要 Xcode Command Line Tools。

```bash
./build.sh && cp -R "build/研究账本.app" ~/Desktop/
```

`tools/main.swift` 是离屏渲染预览工具，`./build/render build` 会把五个视图各画一张 PNG。

## 如果它对你有用

点一个 star，让更多没动力的博士生搜得到它。

---

<a name="english"></a>

## English

### What this is

A small macOS app. No to-do list. One action: **log an entry.** What you produced, what you just understood, what you decided, where you're stuck. Then it shows it back to you by day, by week, by month, by project.

It is not a productivity tool. It is a source of confirmation I built for myself. Here is why.

### My situation

I'm doing a PhD. I chose the direction, I got the scholarship, I like the work. And for a while I was scrolling short videos every day. In the gaps between tasks, on weekend mornings, every moment the phone was in my hand. Then one day a phrase from a short video came out of my own mouth, and I realised my brain had been colonised.

I thought it was a willpower problem. It wasn't.

What I was avoiding was a very specific kind of task: tedious, complex, hard, and with no guarantee of positive feedback even when done. Research is exactly that. Three days of running data and you don't know if it's right. A section written and you don't know if it counts as progress. Short videos do the opposite: feedback every three seconds. My brain was choosing between two feedback rhythms, and it picked the fast one.

One layer deeper: the moment I picked up the phone was not "I know what to do but don't want to." It was **I have no idea what the next step is.** And what I wanted was not praise from my supervisor. It was **an internal confirmation: I moved forward today.** These are the same problem. Confirmation requires that you defined, in advance, what "one step forward" means. If you don't know the next step, you can't feel "I completed the next step." I wasn't failing to get feedback. I was failing to leave myself anything that could produce feedback. That's what the emptiness was.

### Things that were said to me that actually helped

These came from conversations with Claude. They are not motivational quotes; each one changed how I understood something. Maybe they help you too.

**On short videos.**
"This isn't a willpower problem. Your brain picked the faster of two feedback rhythms. Attacking it at the end of the chain, by quitting the phone, won't work. You have to go to the first link."

**On the emptiness.**
"You're not missing motivation or willpower. You're missing a unit of progress. You never avoid reading papers, because reading comes with its own progress bar. The journal never stuck, because each day you opened it there was no 'unit for today' to write down."

**On giving yourself feedback.**
"Feedback is information, not emotion. It answers one question: did what I did match what I set out to do? Confirmation comes from reconciling, not from self-evaluation. When you finish a badminton session, nobody has to tell you 'you trained today,' because 'a session' is a pre-defined unit. Research is missing that unit, not missing someone to praise you. You don't need to give yourself feedback. You need to leave yourself a standard that feedback can be measured against. The feedback comes on its own."

**On whose hand the ruler is in.**
"The ruler you measure yourself with has always been in someone else's hand. When those people are present, you're capable. When they're absent, weekend mornings, tasks that haven't been broken down, you go empty. Evaluate first, then listen: before you hand anything to anyone, write one line of your own assessment. Split what people say into observation and conclusion: take the observation in full, draw the conclusion yourself."

**On supervisors.**
"Supervisors usually don't react to 'I don't know where to go.' It's not that they don't care; that state gives them nothing to grab. Bring a progress report and they nod. Bring a decision they have to make and they sit up. Bring one page: the research question in one sentence, what you did this week, and one A-or-B they need to choose right now."

**On 'am I doing it right'.**
"In research there is no 'right' in advance. The only substitute is this test: can you say in one sentence what question you're asking, with what data, comparing what to what? If you can, you're on the road. If you can't, that sentence is the current job."

**On being tired in a new field.**
"No person and no tool can lead you to 'the most accurate path,' because in a new field that path doesn't exist yet. It's something you see only when you look back after walking it. Part of your tiredness is searching for something that isn't there. Feeling lost in a new field is what the 'uncertainty' stage feels like. It's not a sign you did something wrong."

### How the app uses these ideas

It does one thing: **turn "I moved forward" into a fact you can check, instead of a feeling.**

- Every entry is one of four kinds: **output** (write results, not activities), **insight** (what you just understood), **decision** (what you decided and why), **stuck** (where you're blocked). Log the stuck ones too; the research says setbacks affect motivation twice as much as progress.
- An entry can be attached to a project. An output bumps the project by 5% by default. That's the ruler for "how much did the project move."
- **This week** shows counts by kind, how many days had entries, and each project's percent at the start and end of the week. **Month** is a heatmap. **Insights** are pulled out separately by month; a month later that list is the shape of what you learned.
- There is no to-do list, so it can never turn into a list of what you haven't done.

Design sources: Amabile and Kramer's progress principle (the strongest driver of inner work life is perceiving progress in meaningful work), Andreessen's anti-todo list, academic research-log conventions, Julia Evans's brag document, Simon Willison's TILs, interstitial journaling, and dot-grid apps like Daily Dots.

### Install

Download `研究账本.app.zip` from [Releases](../../releases), unzip, drag to Desktop or Applications. If macOS says it can't verify the developer, right-click the app and choose Open. macOS 14+, Apple Silicon.

Data lives in `~/Library/Application Support/ResearchLedger/ledger.json`, plain JSON.

### Build from source

Everything is in `Sources/App.swift`, one SwiftUI file, no dependencies. Needs Xcode Command Line Tools.

```bash
./build.sh && cp -R "build/研究账本.app" ~/Desktop/
```

`tools/main.swift` is an off-screen preview renderer: `./build/render build` writes one PNG per view.

### If this helped

Star it, so other PhD students who've lost their drive can find it.

---

## 参考 · Sources

- Amabile & Kramer, *The Progress Principle* — [HBS Working Knowledge](https://hbswk.hbs.edu/item/6685.html)
- Marc Andreessen's anti-todo list — [Business Insider](https://www.businessinsider.nl/done-list-can-make-you-more-successful-at-work-2016-12)
- Cambridge HPS PhD progress log — [hps.cam.ac.uk](https://www.hps.cam.ac.uk/students/phd-guide/log)
- Julia Evans, brag documents — [summary](https://www.antoinebuteau.com/lessons-from-julia-evans.md)
- Simon Willison, one year of TILs — [simonwillison.net](https://simonwillison.net/2021/May/2/one-year-of-tils)
- Interstitial journaling — [Ness Labs](https://nesslabs.com/interstitial-journaling)
- Daily Dots — [App Store](https://apps.apple.com/app/id6761059676)
