import SwiftUI
import WebKit

struct WebViewContainer: UIViewRepresentable {
    let configuration: WebsiteConfiguration

    func makeCoordinator() -> Coordinator { Coordinator(configuration: configuration) }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        if !configuration.allowCookies {
            config.websiteDataStore = .nonPersistent()
        }
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = configuration.allowBackForwardGestures
        applyCustomizations(to: webView)
        if let url = URL(string: configuration.url) {
            webView.load(URLRequest(url: url))
        }
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    private func applyCustomizations(to webView: WKWebView) {
        var js = ""
        if configuration.disableTextSelection {
            js += "document.documentElement.style.webkitUserSelect='none';"
        }
        for style in configuration.customStylesheets {
            if let css = try? String(contentsOf: style).replacingOccurrences(of: "\n", with: " ") {
                js += "var style=document.createElement('style');style.innerHTML=`\(css)`;document.head.appendChild(style);"
            }
        }
        for script in configuration.userScripts {
            if let content = try? String(contentsOf: script) {
                js += content
            }
        }
        if !js.isEmpty {
            let userScript = WKUserScript(source: js, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
            webView.configuration.userContentController.addUserScript(userScript)
        }
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        let configuration: WebsiteConfiguration
        private var blockRules: [String] = []
        init(configuration: WebsiteConfiguration) {
            self.configuration = configuration
            super.init()
            loadBlockRules()
        }

        private func loadBlockRules() {
            for list in configuration.adblockLists {
                if let content = try? String(contentsOf: list) {
                    let lines = content.components(separatedBy: .newlines)
                    for line in lines {
                        let trimmed = line.trimmingCharacters(in: .whitespaces)
                        if trimmed.isEmpty || trimmed.hasPrefix("!") { continue }
                        blockRules.append(trimmed)
                    }
                }
            }
        }

        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if let url = navigationAction.request.url?.absoluteString {
                if !configuration.requestWhitelist.isEmpty && configuration.requestWhitelist.first(where: { url.contains($0) }) == nil {
                    decisionHandler(.cancel)
                    return
                }
                for rule in blockRules where url.contains(rule) {
                    decisionHandler(.cancel)
                    return
                }
            }
            decisionHandler(.allow)
        }
    }
}
