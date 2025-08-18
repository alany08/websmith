import SwiftUI

struct WebBrowserView: View {
    let configuration: WebsiteConfiguration

    var body: some View {
        let fullscreen = configuration.allowFullscreen
        let hideNav = configuration.hideNavigation
        return WebViewContainer(configuration: configuration)
            .ignoresSafeArea(fullscreen ? .all : [])
            .navigationBarTitle(configuration.nickname, displayMode: .inline)
            .navigationBarHidden(hideNav)
            .navigationBarBackButtonHidden(hideNav)
            .statusBar(hidden: fullscreen || hideNav)
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
