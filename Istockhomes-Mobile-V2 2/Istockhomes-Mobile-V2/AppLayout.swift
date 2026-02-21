import SwiftUI

struct AppLayout<Content: View>: View {
    let franchiseManager: FranchiseManager
    let content: Content

    init(franchiseManager: FranchiseManager, @ViewBuilder content: () -> Content) {
        self.franchiseManager = franchiseManager
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 0) {
            if let config = franchiseManager.config {
                HeaderView(config: config)
            } else {
                ProgressView("Loading header...")
            }

            content

            FooterView()
        }
    }
}

