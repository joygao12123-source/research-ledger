# Research Ledger · 研究账本

> For PhD researchers who have lost their drive lately.

**English** · [中文](README.zh.md)

<p align="center"><img src="docs/screenshot-today.png" width="520" alt="研究账本：今天视图"></p>

---

## What this is

A small macOS app (interface in Chinese). No to-do list. One action: **log an entry.** What you produced, what you just understood, what you decided, where you're stuck. Then it shows it back to you by day, by week, by month, by project.

It is not a productivity tool. It is a source of confirmation I built for myself. Here is why.

## My situation

I'm doing a PhD. I chose the direction, I got the scholarship, I like the work. And for a while I was scrolling short videos every day. In the gaps between tasks, on weekend mornings, every moment the phone was in my hand. Then one day a phrase from a short video came out of my own mouth, and I realised my brain had been colonised.

I thought it was a willpower problem. It wasn't.

What I was avoiding was a very specific kind of task: tedious, complex, hard, and with no guarantee of positive feedback even when done. Research is exactly that. Three days of running data and you don't know if it's right. A section written and you don't know if it counts as progress. Short videos do the opposite: feedback every three seconds. My brain was choosing between two feedback rhythms, and it picked the fast one.

One layer deeper: the moment I picked up the phone was not "I know what to do but don't want to." It was **I have no idea what the next step is.** And what I wanted was not praise from my supervisor. It was **an internal confirmation: I moved forward today.** These are the same problem. Confirmation requires that you defined, in advance, what "one step forward" means. If you don't know the next step, you can't feel "I completed the next step." I wasn't failing to get feedback. I was failing to leave myself anything that could produce feedback. That's what the emptiness was.

## Things that were said to me that actually helped

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

## How the app uses these ideas

It does one thing: **turn "I moved forward" into a fact you can check, instead of a feeling.**

- Every entry is one of four kinds: **output** (write results, not activities), **insight** (what you just understood), **decision** (what you decided and why), **stuck** (where you're blocked). Log the stuck ones too; the research says setbacks affect motivation twice as much as progress.
- An entry can be attached to a project. An output bumps the project by 5% by default. That's the ruler for "how much did the project move."
- **This week** shows counts by kind, how many days had entries, and each project's percent at the start and end of the week. **Month** is a heatmap. **Insights** are pulled out separately by month; a month later that list is the shape of what you learned.
- There is no to-do list, so it can never turn into a list of what you haven't done.

Design sources: Amabile and Kramer's progress principle (the strongest driver of inner work life is perceiving progress in meaningful work), Andreessen's anti-todo list, academic research-log conventions, Julia Evans's brag document, Simon Willison's TILs, interstitial journaling, and dot-grid apps like Daily Dots.

## Install

Download `研究账本.app.zip` from [Releases](../../releases), unzip, drag to Desktop or Applications. If macOS says it can't verify the developer, right-click the app and choose Open. macOS 14+, Apple Silicon.

Data lives in `~/Library/Application Support/ResearchLedger/ledger.json`, plain JSON.

## Build from source

Everything is in `Sources/App.swift`, one SwiftUI file, no dependencies. Needs Xcode Command Line Tools.

```bash
./build.sh && cp -R "build/研究账本.app" ~/Desktop/
```

`tools/main.swift` is an off-screen preview renderer: `./build/render build` writes one PNG per view.

---

---

## Sources

- Amabile & Kramer, *The Progress Principle* — [HBS Working Knowledge](https://hbswk.hbs.edu/item/6685.html)
- Marc Andreessen's anti-todo list — [Business Insider](https://www.businessinsider.nl/done-list-can-make-you-more-successful-at-work-2016-12)
- Cambridge HPS PhD progress log — [hps.cam.ac.uk](https://www.hps.cam.ac.uk/students/phd-guide/log)
- Julia Evans, brag documents — [summary](https://www.antoinebuteau.com/lessons-from-julia-evans.md)
- Simon Willison, one year of TILs — [simonwillison.net](https://simonwillison.net/2021/May/2/one-year-of-tils)
- Interstitial journaling — [Ness Labs](https://nesslabs.com/interstitial-journaling)
- Daily Dots — [App Store](https://apps.apple.com/app/id6761059676)
