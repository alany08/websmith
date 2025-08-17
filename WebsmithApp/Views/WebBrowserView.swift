import SwiftUI

struct WebBrowserView: View {
    @Environment(\.dismiss) private var dismiss
    let configuration: WebsiteConfiguration

    var body: some View {
        VStack(spacing: 0) {
            if configuration.showTopBar {
                HStack {
                    Button("Close") { dismiss() }
                    Spacer()
                    Text(configuration.nickname)
                    Spacer()
                }
                .padding()
                .background(Color(UIColor.systemGray6))
            }
            WebViewContainer(configuration: configuration)
                .edgesIgnoringSafeArea(configuration.allowFullscreen ? .all : [])
        }
        .onAppear { applyOrientation() }
        .onDisappear { OrientationManager.shared.currentMask = .all }
    }

    private func applyOrientation() {
        switch configuration.forceOrientation {
        case .portrait:
            OrientationManager.shared.currentMask = .portrait
        case .landscape:
            OrientationManager.shared.currentMask = .landscape
        case .system:
            OrientationManager.shared.currentMask = .all
        }
    }
}
