# 研究账本 · Research Ledger

一个记账式的研究日志，macOS 原生。没有 to do，只有一个动作：**记一笔**。

*A done-list style research journal for macOS. No to-dos. One action: log an entry (output / insight / decision / stuck), optionally attached to a project with a percent-progress bump. Views: today, this week, month heatmap, projects, and a separate "insights" ledger. Single-file SwiftUI, no dependencies, data is one JSON file. Build with `./build.sh` (needs Xcode Command Line Tools, macOS 14+).*

## 安装

不想编译的话，去 [Releases](../../releases) 下载 `研究账本.app.zip`，解压后拖到桌面或应用程序文件夹。第一次打开如果系统提示"无法验证开发者"，右键点 app 选"打开"即可（这个 app 没有付费签名）。


## 为什么是账本而不是 to do list

to do list 衡量"还剩多少"，账本衡量"走了多远"。这个设计综合了几个来源：

- Amabile & Kramer《进步原理》：内在动力最强的来源是感知到自己在有意义的工作上推进了；挫折的影响是进步的两倍，所以也要记。
- Andreessen 的 anti-todo list / iDoneThis：边做边记做了什么，而不是预先列要做什么。
- 学术研究日志惯例：带日期，记决定和理由，记成功也记失败，每周回顾。
- Julia Evans 的 brag document：记结果不记动作，按项目分区，单独留"学到了什么"。
- Simon Willison 的 TIL：一句"刚才懂了什么"，每天一条就能坚持。
- Interstitial journaling：任务间隙写一行带时间戳的短记录，对付拖延。
- Daily Dots / Year in Pixels：一个月一张点阵图。
- 论文进度追踪器：按阶段的进度条和里程碑。

## 四种记录

| 类型 | 记什么 |
|---|---|
| 产出 | 结果，不是动作。「3.2 节重写完，两段」而不是「写论文」 |
| 懂了 | 刚才理解了什么，一句话 |
| 决定 | 做了什么决定、为什么 |
| 卡住 | 卡在哪里 |

每一笔可以挂一个项目。产出挂上项目后默认给项目 +5% 进度（可选 +10/+15/+20 或不加）。项目页可以直接把进度跳到某个百分比，会自动记一笔「决定」留痕。删掉一笔会把它加的进度退回去。

## 五个视图

- **今天**：记一笔，看今天记了什么。
- **本周**：四类计数、几天有记录、每个项目这周从百分之几走到百分之几，然后按天列出。可以翻上周。
- **本月**：热力图，颜色越深记得越多，右上角有箭头的是项目进度动过的日子。点一天看那天的记录。
- **项目**：每个项目一个百分比和进度条，可以直接跳到某个数。
- **懂了**：所有"懂了"单独抽出来按月排，是知识账本。

## 使用

双击 `研究账本.app`。右上角图钉置顶。

数据在 `~/Library/Application Support/ResearchLedger/ledger.json`，纯 JSON。

## 改代码

源码在 `Sources/App.swift`，一个文件。改完：

```bash
./build.sh && cp -R "build/研究账本.app" ~/Desktop/
```

`tools/main.swift` 是离屏渲染预览工具：`./build/render build` 会把五个视图各画一张 PNG。
