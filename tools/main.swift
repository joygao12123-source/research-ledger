import SwiftUI
import AppKit
MainActor.assumeIsolated {
    let store = Store()
    let out = CommandLine.arguments[1]
    @MainActor func render<V: View>(_ v: V, _ name: String) {
        let r = ImageRenderer(content: v.frame(width: 480).padding(18).background(Color(nsColor: .windowBackgroundColor)))
        r.scale = 2
        let png = NSBitmapImageRep(data: r.nsImage!.tiffRepresentation!)!.representation(using: .png, properties: [:])!
        try! png.write(to: URL(fileURLWithPath: "\(out)/\(name).png"))
    }
    render(TodayView(store: store), "today")
    render(WeekView(store: store), "week")
    render(MonthView(store: store), "month")
    render(ProjectsView(store: store), "projects")
    render(InsightsView(store: store), "insights")
}
