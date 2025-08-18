import SwiftUI

struct WebBrowserView: View {
    let configuration: WebsiteConfiguration

    var body: some View {
        let fullscreen = configuration.allowFullscreen || configuration.forceOrientation == .landscape
        let hideNav = configuration.hideNavigation
        return WebViewContainer(configuration: configuration)
            .ignoresSafeArea(fullscreen ? .all : [])
            .navigationBarTitle(configuration.nickname, displayMode: .inline)
            .navigationBarHidden(hideNav)
            .navigationBarBackButtonHidden(hideNav)
            .statusBar(hidden: fullscreen || hideNav)
            .onAppear { applyOrientation() }
            .onDisappear { OrientationManager.shared.currentMask = .all }
            .disableSwipeBack()
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

private struct DisableSwipeBack: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> Controller { Controller() }
    func updateUIViewController(_ uiViewController: Controller, context: Context) {}

    class Controller: UIViewController {
        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        }

        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        }
    }
}

private extension View {
    func disableSwipeBack() -> some View {
        background(DisableSwipeBack())
    }
}
