import SwiftUI
import AppKit

// MARK: - 数据模型

enum Kind: String, Codable, CaseIterable, Identifiable {
    case output = "产出", insight = "懂了", decision = "决定", stuck = "卡住"
    var id: String { rawValue }
    var color: Color {
        switch self {
        case .output: return .blue
        case .insight: return .purple
        case .decision: return .teal
        case .stuck: return .orange
        }
    }
    var icon: String {
        switch self {
        case .output: return "hammer.fill"
        case .insight: return "lightbulb.fill"
        case .decision: return "arrow.triangle.branch"
        case .stuck: return "exclamationmark.triangle.fill"
        }
    }
    var hint: String {
        switch self {
        case .output: return "记结果，不记动作。例如「3.2 节重写完，两段」"
        case .insight: return "刚才懂了什么？一句话。例如「DiD 的平行趋势要在 pre 期检验」"
        case .decision: return "做了什么决定、为什么。例如「放弃 2015 前样本，因为缺破产数据」"
        case .stuck: return "卡在哪里。例如「Table 2 系数符号反了，不知道为什么」"
        }
    }
}

struct Milestone: Codable, Equatable {   // 旧版本遗留，只用于读取老数据
    var title: String
    var doneAt: Date? = nil
}

struct Project: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var progress: Double = 0           // 0...1
    var createdAt = Date()
    var milestones: [Milestone]? = nil // 旧版本遗留

    var percent: Int { Int((progress * 100).rounded()) }

    // 容错解码：缺字段不报错（Swift 默认值不参与解码，必须手写）
    enum CodingKeys: String, CodingKey { case id, name, progress, createdAt, milestones }
    init(id: UUID = UUID(), name: String, progress: Double = 0, createdAt: Date = Date()) {
        self.id = id; self.name = name; self.progress = progress; self.createdAt = createdAt
    }
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        name = try c.decodeIfPresent(String.self, forKey: .name) ?? "未命名"
        progress = try c.decodeIfPresent(Double.self, forKey: .progress) ?? 0
        createdAt = try c.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()
        milestones = try c.decodeIfPresent([Milestone].self, forKey: .milestones)
    }
}

struct Entry: Identifiable, Codable, Equatable {
    var id = UUID()
    var date = Date()
    var kind: Kind
    var text: String
    var projectID: UUID? = nil
    var progressFrom: Double? = nil    // 这一笔让项目进度从哪到哪
    var progressTo: Double? = nil

    enum CodingKeys: String, CodingKey { case id, date, kind, text, projectID, progressFrom, progressTo }
    init(id: UUID = UUID(), date: Date = Date(), kind: Kind, text: String, projectID: UUID? = nil) {
        self.id = id; self.date = date; self.kind = kind; self.text = text; self.projectID = projectID
    }
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        date = try c.decodeIfPresent(Date.self, forKey: .date) ?? Date()
        kind = try c.decodeIfPresent(Kind.self, forKey: .kind) ?? .output
        text = try c.decodeIfPresent(String.self, forKey: .text) ?? ""
        projectID = try c.decodeIfPresent(UUID.self, forKey: .projectID)
        progressFrom = try c.decodeIfPresent(Double.self, forKey: .progressFrom)
        progressTo = try c.decodeIfPresent(Double.self, forKey: .progressTo)
    }
}

struct LedgerData: Codable {
    var projects: [Project] = []
    var entries: [Entry] = []
}

// MARK: - 存储

@MainActor @Observable
final class Store {
    var data = LedgerData() { didSet { save() } }
    private let url: URL
    let cal: Calendar = {
        var c = Calendar.current
        c.firstWeekday = 2 // 周一开始
        return c
    }()

    init() {
        let dir = FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("ResearchLedger", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        url = dir.appendingPathComponent("ledger.json")
        if let d = try? Data(contentsOf: url) {
            do {
                var decoded = try JSONDecoder().decode(LedgerData.self, from: d)
                migrate(&decoded)
                data = decoded
            } catch {
                // 读不懂就把原文件另存一份，绝不覆盖
                let keep = url.deletingLastPathComponent().appendingPathComponent("ledger.unreadable-\(Int(Date().timeIntervalSince1970)).json")
                try? d.write(to: keep)
                NSLog("ResearchLedger: 数据文件读取失败，已另存到 \(keep.path)：\(error)")
                loadFailed = true
            }
        }
    }
    var loadFailed = false

    private func migrate(_ decoded: inout LedgerData) {
        // 旧版本的里程碑折算成百分比
        for i in decoded.projects.indices {
            if let ms = decoded.projects[i].milestones {
                if !ms.isEmpty && decoded.projects[i].progress == 0 {
                    decoded.projects[i].progress = Double(ms.filter { $0.doneAt != nil }.count) / Double(ms.count)
                }
                decoded.projects[i].milestones = nil
            }
        }
    }

    private func save() {
        let enc = JSONEncoder(); enc.outputFormatting = [.prettyPrinted, .sortedKeys]
        if let d = try? enc.encode(data) { try? d.write(to: url, options: .atomic) }
    }

    // 查询
    var entries: [Entry] { data.entries.sorted { $0.date > $1.date } }
    var projects: [Project] { data.projects }
    func project(_ id: UUID?) -> Project? { id.flatMap { pid in data.projects.first { $0.id == pid } } }
    func entries(on day: Date) -> [Entry] { entries.filter { cal.isDate($0.date, inSameDayAs: day) } }
    func entries(from a: Date, to b: Date) -> [Entry] { entries.filter { $0.date >= a && $0.date < b } }
    /// 某段时间里让进度动过的记录，按项目分组，并给出首尾进度
    func progressMoves(from a: Date, to b: Date) -> [(project: Project, from: Double, to: Double)] {
        let evs = data.entries.filter { $0.progressTo != nil && $0.date >= a && $0.date < b }
        return data.projects.compactMap { p in
            let mine = evs.filter { $0.projectID == p.id }.sorted { $0.date < $1.date }
            guard let first = mine.first, let last = mine.last else { return nil }
            return (p, first.progressFrom ?? 0, last.progressTo ?? p.progress)
        }
    }
    func progressDays(from a: Date, to b: Date) -> Set<Date> {
        Set(data.entries.filter { $0.progressTo != nil && $0.date >= a && $0.date < b }
            .map { cal.startOfDay(for: $0.date) })
    }

    var streak: Int {
        let days = Set(data.entries.map { cal.startOfDay(for: $0.date) })
        var day = cal.startOfDay(for: Date())
        if !days.contains(day) { day = cal.date(byAdding: .day, value: -1, to: day)! }
        var n = 0
        while days.contains(day) { n += 1; day = cal.date(byAdding: .day, value: -1, to: day)! }
        return n
    }

    // 写入
    /// step：这一笔给项目加多少进度（0.05 = 5%），nil 或 0 表示不动
    func add(kind: Kind, text: String, projectID: UUID?, step: Double? = nil) {
        let t = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else { return }
        var e = Entry(kind: kind, text: t, projectID: projectID)
        if let pid = projectID, let st = step, st != 0,
           let pi = data.projects.firstIndex(where: { $0.id == pid }) {
            let from = data.projects[pi].progress
            let to = min(1, max(0, from + st))
            data.projects[pi].progress = to
            e.progressFrom = from; e.progressTo = to
        }
        data.entries.append(e)
    }
    /// 直接把进度调到某个值，同时记一笔「决定」留痕
    func setProgress(projectID: UUID, to pct: Int) {
        guard let pi = data.projects.firstIndex(where: { $0.id == projectID }) else { return }
        let from = data.projects[pi].progress
        let to = min(1, max(0, Double(pct) / 100))
        guard to != from else { return }
        data.projects[pi].progress = to
        var e = Entry(kind: .decision, text: "把进度调到 \(pct)%", projectID: projectID)
        e.progressFrom = from; e.progressTo = to
        data.entries.append(e)
    }
    func update(entry id: UUID, text: String) {
        let t = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty, let i = data.entries.firstIndex(where: { $0.id == id }) else { return }
        data.entries[i].text = t
    }
    /// 删掉一笔：如果它动过进度，把那段进度退回去
    func delete(entry id: UUID) {
        if let e = data.entries.first(where: { $0.id == id }), let pid = e.projectID,
           let from = e.progressFrom, let to = e.progressTo,
           let pi = data.projects.firstIndex(where: { $0.id == pid }) {
            data.projects[pi].progress = min(1, max(0, data.projects[pi].progress - (to - from)))
        }
        data.entries.removeAll { $0.id == id }
    }
    func addProject(name: String) {
        let n = name.trimmingCharacters(in: .whitespaces)
        guard !n.isEmpty else { return }
        data.projects.append(Project(name: n))
    }
    func deleteProject(_ id: UUID) {
        data.projects.removeAll { $0.id == id }
        for i in data.entries.indices where data.entries[i].projectID == id {
            data.entries[i].projectID = nil
            data.entries[i].progressFrom = nil; data.entries[i].progressTo = nil
        }
    }

    // 日期工具
    func weekStart(containing d: Date) -> Date {
        cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: d))!
    }
    func monthStart(containing d: Date) -> Date {
        cal.date(from: cal.dateComponents([.year, .month], from: d))!
    }
    func dayLabel(_ d: Date) -> String {
        if cal.isDateInToday(d) { return "今天" }
        if cal.isDateInYesterday(d) { return "昨天" }
        let f = DateFormatter(); f.locale = Locale(identifier: "zh_CN")
        f.dateFormat = cal.isDate(d, equalTo: Date(), toGranularity: .year) ? "M月d日 EEE" : "yyyy年M月d日"
        return f.string(from: d)
    }
    func shortDate(_ d: Date, _ fmt: String) -> String {
        let f = DateFormatter(); f.locale = Locale(identifier: "zh_CN"); f.dateFormat = fmt
        return f.string(from: d)
    }
}

// MARK: - 共用小组件

struct KindBadge: View {
    let kind: Kind
    var body: some View {
        Label(kind.rawValue, systemImage: kind.icon)
            .font(.caption2.weight(.semibold))
            .padding(.horizontal, 6).padding(.vertical, 2)
            .background(Capsule().fill(kind.color.opacity(0.15)))
            .foregroundStyle(kind.color)
    }
}

struct EntryRow: View {
    let entry: Entry
    let store: Store
    var showDate = false
    @State private var editing = false
    @State private var draft = ""
    @FocusState private var focused: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: entry.kind.icon).foregroundStyle(entry.kind.color).frame(width: 16).padding(.top, 3)
            VStack(alignment: .leading, spacing: 3) {
                if editing {
                    TextField("", text: $draft, axis: .vertical)
                        .lineLimit(1...5).textFieldStyle(.roundedBorder).focused($focused)
                        .onSubmit { commit() }
                        .onExitCommand { editing = false }
                    HStack(spacing: 8) {
                        Button("保存") { commit() }.controlSize(.small).buttonStyle(.borderedProminent)
                            .keyboardShortcut(.return, modifiers: .command)
                        Button("取消") { editing = false }.controlSize(.small)
                        Text("↩ 保存，esc 取消").font(.caption2).foregroundStyle(.tertiary)
                    }
                } else {
                    Text(entry.text).font(.body).fixedSize(horizontal: false, vertical: true)
                        .onTapGesture(count: 2) { beginEdit() }
                    HStack(spacing: 6) {
                        if let p = store.project(entry.projectID) {
                            Text(p.name).font(.caption).foregroundStyle(.secondary)
                        }
                        if let a = entry.progressFrom, let b = entry.progressTo {
                            Label("\(Int((a*100).rounded()))% → \(Int((b*100).rounded()))%", systemImage: "arrow.up.right")
                                .font(.caption.monospacedDigit()).foregroundStyle(b >= a ? .green : .orange)
                        }
                        Text(showDate ? store.shortDate(entry.date, "M月d日 HH:mm") : store.shortDate(entry.date, "HH:mm"))
                            .font(.caption).foregroundStyle(.tertiary)
                    }
                }
            }
            Spacer()
            if !editing {
                HStack(spacing: 2) {
                    Button { beginEdit() } label: { Image(systemName: "pencil") }
                        .help("改这一条（双击文字也可以）")
                    Button { withAnimation { store.delete(entry: entry.id) } } label: { Image(systemName: "trash") }
                        .help("删掉这一条")
                }
                .buttonStyle(.borderless).controlSize(.small).foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 5)
    }

    private func beginEdit() { draft = entry.text; editing = true; focused = true }
    private func commit() { store.update(entry: entry.id, text: draft); editing = false }
}

struct SectionTitle: View {
    let text: String
    var body: some View {
        Text(text).font(.caption.weight(.semibold)).foregroundStyle(.secondary)
    }
}

// MARK: - 今天：记一笔

struct TodayView: View {
    let store: Store
    @State private var kind: Kind = .output
    @State private var text = ""
    @State private var projectID: UUID? = nil
    @State private var step: Double = 0.05
    @FocusState private var focused: Bool
    private let steps: [(String, Double)] = [("不加", 0), ("+5%", 0.05), ("+10%", 0.10), ("+15%", 0.15), ("+20%", 0.20)]

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            captureCard
            let today = store.entries(on: Date())
            VStack(alignment: .leading, spacing: 4) {
                SectionTitle(text: "今天 · \(today.count) 笔")
                if today.isEmpty {
                    Text("还没记。做完一件事、懂了一个东西、做了一个决定、或者卡住了，都记一笔。")
                        .font(.callout).foregroundStyle(.tertiary).padding(.vertical, 8)
                }
                ForEach(today) { e in EntryRow(entry: e, store: store); Divider() }
            }
        }
    }

    private var captureCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Picker("", selection: $kind) {
                ForEach(Kind.allCases) { k in Text(k.rawValue).tag(k) }
            }
            .pickerStyle(.segmented).labelsHidden()

            TextField(kind.hint, text: $text, axis: .vertical)
                .lineLimit(2...5).textFieldStyle(.roundedBorder).focused($focused)
                .onSubmit { submit() }

            HStack(spacing: 8) {
                Picker("项目", selection: $projectID) {
                    Text("不挂项目").tag(UUID?.none)
                    ForEach(store.projects) { p in Text(p.name).tag(Optional(p.id)) }
                }
                .frame(maxWidth: 170)

                if kind == .output, let p = store.project(projectID) {
                    Picker("进度", selection: $step) {
                        ForEach(steps, id: \.1) { Text($0.0).tag($0.1) }
                    }
                    .frame(maxWidth: 120)
                    Text("\(p.percent)% → \(min(100, p.percent + Int((step*100).rounded())))%")
                        .font(.caption.monospacedDigit()).foregroundStyle(.secondary)
                }
                Spacer()
                Button("记一笔") { submit() }
                    .keyboardShortcut(.return, modifiers: .command)
                    .buttonStyle(.borderedProminent)
                    .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            Text(kind == .output ? "产出写结果不写过程。挂上项目，这一笔就给项目加进度。" : "⌘↩ 记入。")
                .font(.caption).foregroundStyle(.tertiary)
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 12).fill(kind.color.opacity(0.08)))
    }

    private func submit() {
        store.add(kind: kind, text: text, projectID: projectID,
                  step: (kind == .output && projectID != nil) ? step : nil)
        text = ""; focused = true
    }
}

// MARK: - 本周

struct WeekView: View {
    let store: Store
    @State private var offset = 0   // 0 = 本周，-1 = 上周

    private var start: Date {
        store.cal.date(byAdding: .weekOfYear, value: offset, to: store.weekStart(containing: Date()))!
    }
    private var end: Date { store.cal.date(byAdding: .day, value: 7, to: start)! }

    var body: some View {
        let es = store.entries(from: start, to: end)
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Button { offset -= 1 } label: { Image(systemName: "chevron.left") }.buttonStyle(.borderless)
                Text(offset == 0 ? "本周" : offset == -1 ? "上周" : store.shortDate(start, "M月d日") + " 那周")
                    .font(.headline)
                Text(store.shortDate(start, "M.d") + " – " + store.shortDate(store.cal.date(byAdding: .day, value: 6, to: start)!, "M.d"))
                    .font(.caption).foregroundStyle(.secondary)
                Button { offset += 1 } label: { Image(systemName: "chevron.right") }
                    .buttonStyle(.borderless).disabled(offset >= 0)
                Spacer()
            }
            summaryCard(es)
            ForEach(0..<7, id: \.self) { i in
                let day = store.cal.date(byAdding: .day, value: i, to: start)!
                let items = es.filter { store.cal.isDate($0.date, inSameDayAs: day) }
                if day <= Date() {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack {
                            SectionTitle(text: store.dayLabel(day))
                            if items.isEmpty { Text("—").font(.caption).foregroundStyle(.quaternary) }
                        }
                        ForEach(items) { e in EntryRow(entry: e, store: store) }
                    }
                }
            }
        }
    }

    private func summaryCard(_ es: [Entry]) -> some View {
        let moves = store.progressMoves(from: start, to: end)
        return VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 14) {
                ForEach(Kind.allCases) { k in
                    let n = es.filter { $0.kind == k }.count
                    HStack(spacing: 4) {
                        Image(systemName: k.icon).foregroundStyle(n > 0 ? k.color : Color.secondary.opacity(0.3))
                        Text("\(n)").font(.title3.weight(.semibold).monospacedDigit())
                        Text(k.rawValue).font(.caption).foregroundStyle(.secondary)
                    }
                }
            }
            if es.isEmpty {
                Text("这周还没有记录。").font(.caption).foregroundStyle(.tertiary)
            } else {
                let days = Set(es.map { store.cal.startOfDay(for: $0.date) }).count
                Text("\(days) 天有记录。").font(.caption).foregroundStyle(.secondary)
            }
            if !moves.isEmpty {
                Divider()
                ForEach(moves, id: \.project.id) { m in
                    let a = Int((m.from*100).rounded()), b = Int((m.to*100).rounded())
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.up.right").foregroundStyle(.green).font(.caption)
                        Text(m.project.name).font(.callout.weight(.medium))
                        Text("\(a)% → \(b)%").font(.callout.monospacedDigit()).foregroundStyle(.secondary)
                        Text(b >= a ? "+\(b - a)%" : "\(b - a)%").font(.caption).foregroundStyle(b >= a ? .green : .orange)
                    }
                }
            }
        }
        .padding(14).frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.primary.opacity(0.04)))
    }
}

// MARK: - 本月热力图

struct MonthView: View {
    let store: Store
    @State private var offset = 0
    @State private var selected: Date? = nil

    private var start: Date {
        store.cal.date(byAdding: .month, value: offset, to: store.monthStart(containing: Date()))!
    }
    private var end: Date { store.cal.date(byAdding: .month, value: 1, to: start)! }
    private var days: [Date] {
        let n = store.cal.range(of: .day, in: .month, for: start)!.count
        return (0..<n).map { store.cal.date(byAdding: .day, value: $0, to: start)! }
    }
    private var leadingBlanks: Int {
        let wd = store.cal.component(.weekday, from: start) // 1 = Sun
        return (wd - store.cal.firstWeekday + 7) % 7
    }

    var body: some View {
        let es = store.entries(from: start, to: end)
        let counts = Dictionary(grouping: es) { store.cal.startOfDay(for: $0.date) }.mapValues { $0.count }
        let milestoneDays = store.progressDays(from: start, to: end)
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Button { offset -= 1; selected = nil } label: { Image(systemName: "chevron.left") }.buttonStyle(.borderless)
                Text(store.shortDate(start, "yyyy年M月")).font(.headline)
                Button { offset += 1; selected = nil } label: { Image(systemName: "chevron.right") }
                    .buttonStyle(.borderless).disabled(offset >= 0)
                Spacer()
                Text("\(es.count) 笔 · \(counts.count) 天 · \(milestoneDays.count) 天进度动过")
                    .font(.caption).foregroundStyle(.secondary)
            }
            let cols = Array(repeating: GridItem(.flexible(), spacing: 6), count: 7)
            LazyVGrid(columns: cols, spacing: 6) {
                ForEach(["一", "二", "三", "四", "五", "六", "日"], id: \.self) { w in
                    Text(w).font(.caption2).foregroundStyle(.tertiary)
                }
                ForEach(0..<leadingBlanks, id: \.self) { _ in Color.clear.frame(height: 40) }
                ForEach(days, id: \.self) { d in
                    let n = counts[d] ?? 0
                    let future = d > Date()
                    Button { selected = (selected == d) ? nil : d } label: {
                        ZStack(alignment: .topTrailing) {
                            RoundedRectangle(cornerRadius: 7)
                                .fill(n == 0 ? Color.primary.opacity(future ? 0.02 : 0.06)
                                             : Color.blue.opacity(min(0.2 + Double(n) * 0.18, 0.95)))
                            RoundedRectangle(cornerRadius: 7)
                                .stroke(selected == d ? Color.accentColor : .clear, lineWidth: 2)
                            VStack(spacing: 1) {
                                Text("\(store.cal.component(.day, from: d))")
                                    .font(.caption.weight(store.cal.isDateInToday(d) ? .bold : .regular))
                                    .foregroundStyle(n >= 3 ? Color.white : (future ? Color.secondary.opacity(0.4) : Color.primary))
                                if n > 0 {
                                    Text("\(n)").font(.caption2.monospacedDigit())
                                        .foregroundStyle(n >= 3 ? .white.opacity(0.85) : .secondary)
                                }
                            }
                            if milestoneDays.contains(d) {
                                Image(systemName: "arrow.up.right").font(.system(size: 8, weight: .bold))
                                    .foregroundStyle(n >= 3 ? .white : .green).padding(4)
                            }
                        }
                        .frame(height: 40)
                    }
                    .buttonStyle(.plain)
                }
            }
            if let d = selected {
                let items = store.entries(on: d)
                VStack(alignment: .leading, spacing: 2) {
                    SectionTitle(text: "\(store.dayLabel(d)) · \(items.count) 笔")
                    if items.isEmpty { Text("这天没有记录。").font(.caption).foregroundStyle(.tertiary) }
                    ForEach(items) { e in EntryRow(entry: e, store: store) }
                }
            } else {
                Text("点一天看那天记了什么。颜色越深记得越多，右上角有箭头的是项目进度动过的日子。")
                    .font(.caption).foregroundStyle(.tertiary)
            }
        }
    }
}

// MARK: - 项目

struct ProjectsView: View {
    let store: Store
    @State private var newName = ""
    @State private var jump: [UUID: String] = [:]

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            ForEach(store.projects) { p in projectCard(p) }
            VStack(alignment: .leading, spacing: 8) {
                SectionTitle(text: "新项目")
                HStack {
                    TextField("项目名，例如「第一篇论文」", text: $newName)
                        .textFieldStyle(.roundedBorder)
                        .onSubmit { addProject() }
                    Button("建立") { addProject() }.disabled(newName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            if store.projects.isEmpty {
                Text("项目是「多了多少」的尺子。记产出的时候挂上项目，默认每笔 +5%，也可以在这里直接把进度调到某个数。")
                    .font(.callout).foregroundStyle(.tertiary)
            }
        }
    }

    private func addProject() { store.addProject(name: newName); newName = "" }

    private func projectCard(_ p: Project) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text(p.name).font(.headline)
                Spacer()
                Text("\(p.percent)%").font(.title2.weight(.semibold).monospacedDigit())
                    .foregroundStyle(p.progress >= 1 ? .green : .primary)
                Button { store.deleteProject(p.id) } label: { Image(systemName: "trash") }
                    .buttonStyle(.borderless).controlSize(.small).foregroundStyle(.secondary)
                    .help("删除项目（记录保留，只是不再挂在项目上）")
            }
            ProgressView(value: p.progress).tint(p.progress >= 1 ? .green : .blue)
            HStack(spacing: 8) {
                Text("跳到").font(.caption).foregroundStyle(.secondary)
                TextField("", text: Binding(get: { jump[p.id] ?? "" }, set: { jump[p.id] = $0 }))
                    .textFieldStyle(.roundedBorder).controlSize(.small).frame(width: 52)
                    .onSubmit { commitJump(p) }
                Text("%").font(.caption).foregroundStyle(.secondary)
                Button("调整") { commitJump(p) }.controlSize(.small)
                    .disabled(Int(jump[p.id] ?? "") == nil)
                Spacer()
                let n = store.entries.filter { $0.projectID == p.id }.count
                Text("\(n) 笔记录").font(.caption).foregroundStyle(.tertiary)
            }
            let recent = Array(store.entries.filter { $0.projectID == p.id }.prefix(3))
            if !recent.isEmpty {
                Divider()
                SectionTitle(text: "最近")
                ForEach(recent) { e in EntryRow(entry: e, store: store, showDate: true) }
            }
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.primary.opacity(0.04)))
    }

    private func commitJump(_ p: Project) {
        guard let v = Int(jump[p.id] ?? "") else { return }
        store.setProgress(projectID: p.id, to: v); jump[p.id] = ""
    }
}

// MARK: - 懂了：知识账本

struct InsightsView: View {
    let store: Store
    var body: some View {
        let items = store.entries.filter { $0.kind == .insight }
        let groups = Dictionary(grouping: items) { store.monthStart(containing: $0.date) }
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("知识账本").font(.headline)
                Spacer()
                Text("共 \(items.count) 条").font(.caption).foregroundStyle(.secondary)
            }
            Text("所有「懂了」单独放在这里。过一个月回头看，就是你知识水平的变化曲线。")
                .font(.caption).foregroundStyle(.tertiary)
            ForEach(groups.keys.sorted(by: >), id: \.self) { m in
                SectionTitle(text: store.shortDate(m, "yyyy年M月") + " · \(groups[m]!.count) 条")
                ForEach(groups[m]!) { e in EntryRow(entry: e, store: store, showDate: true) }
            }
        }
    }
}

// MARK: - 主窗口

enum Tab: String, CaseIterable, Identifiable {
    case today = "今天", week = "本周", month = "本月", projects = "项目", insights = "懂了"
    var id: String { rawValue }
    var icon: String {
        switch self {
        case .today: return "pencil.line"
        case .week: return "calendar"
        case .month: return "square.grid.3x3.fill"
        case .projects: return "flag.fill"
        case .insights: return "lightbulb.fill"
        }
    }
}

struct ContentView: View {
    @State private var store = Store()
    @State private var tab: Tab = .today
    @State private var pinned = false

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            ScrollView { content.padding(18) }
        }
        .frame(minWidth: 440, idealWidth: 480, minHeight: 560, idealHeight: 720)
        .background(Color(nsColor: .windowBackgroundColor))
        .onChange(of: pinned) { _, v in NSApp.windows.first?.level = v ? .floating : .normal }
    }

    @ViewBuilder var content: some View {
        switch tab {
        case .today: TodayView(store: store)
        case .week: WeekView(store: store)
        case .month: MonthView(store: store)
        case .projects: ProjectsView(store: store)
        case .insights: InsightsView(store: store)
        }
    }

    private var header: some View {
        VStack(spacing: 8) {
            if store.loadFailed {
                Text("数据文件读取失败，原文件已另存在 Application Support/ResearchLedger 里，没有被覆盖。请把这个提示告诉 Claude。")
                    .font(.caption).foregroundStyle(.red).fixedSize(horizontal: false, vertical: true)
            }
            HStack {
                Text("研究账本").font(.title3.bold())
                Spacer()
                if store.streak > 0 {
                    Label("连续 \(store.streak) 天", systemImage: "flame.fill")
                        .font(.caption).foregroundStyle(.orange)
                }
                Toggle(isOn: $pinned) { Image(systemName: pinned ? "pin.fill" : "pin") }
                    .toggleStyle(.button).help("窗口置顶")
            }
            Picker("", selection: $tab) {
                ForEach(Tab.allCases) { t in Label(t.rawValue, systemImage: t.icon).tag(t) }
            }
            .pickerStyle(.segmented).labelsHidden()
        }
        .padding(.horizontal, 18).padding(.top, 12).padding(.bottom, 10)
    }
}

#if !RENDER
@main
struct LedgerApp: App {
    var body: some Scene {
        WindowGroup("研究账本") { ContentView() }
            .defaultSize(width: 480, height: 720)
    }
}
#endif
