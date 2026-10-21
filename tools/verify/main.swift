import SwiftUI
MainActor.assumeIsolated {
    let s = Store()
    print("loadFailed=\(s.loadFailed) projects=\(s.projects.map { "\($0.name):\($0.percent)%" }) entries=\(s.entries.count)")
}
