import SwiftUI
import WebKit

/// Shared WKWebView holder so SwiftUI can control navigation (back/forward/reload)
final class WebViewStore: ObservableObject {
    let webView: WKWebView

    @Published var canGoBack: Bool = false
    @Published var canGoForward: Bool = false

    private var observers: [NSKeyValueObservation] = []

    init() {
        self.webView = WKWebView(frame: .zero)

        // Keep button enabled/disabled state in sync with the webview
        observers.append(webView.observe(\.canGoBack, options: [.initial, .new]) { [weak self] webView, _ in
            DispatchQueue.main.async { self?.canGoBack = webView.canGoBack }
        })
        observers.append(webView.observe(\.canGoForward, options: [.initial, .new]) { [weak self] webView, _ in
            DispatchQueue.main.async { self?.canGoForward = webView.canGoForward }
        })
    }

    func goBack() {
        webView.goBack()
    }

    func goForward() {
        webView.goForward()
    }

    func reload() {
        webView.reload()
    }
}

struct WebView: UIViewRepresentable {
    let baseURL: String
    let shouldLoad: Bool
    @ObservedObject var store: WebViewStore

    /// URLs outside baseURL are blocked and reported here
    @Binding var blockedURL: String?

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> WKWebView {
        let view = store.webView
        view.navigationDelegate = context.coordinator
        return view
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        guard shouldLoad, let url = URL(string: baseURL) else { return }
        // Avoid reloading if already on the base page (or inside it)
        if webView.url?.absoluteString.hasPrefix(baseURL) == true { return }
        webView.load(URLRequest(url: url))
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: WebView
        init(_ parent: WebView) { self.parent = parent }

        func webView(_ webView: WKWebView,
                     decidePolicyFor navigationAction: WKNavigationAction,
                     decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

            guard let url = navigationAction.request.url else {
                decisionHandler(.cancel)
                return
            }

            let req = url.absoluteString

            // Allow anything that stays within the configured base URL (including redirects)
            if req.hasPrefix(parent.baseURL) {
                decisionHandler(.allow)
                return
            }

            // Block everything else and surface it to SwiftUI (toast + confirm prompt)
            DispatchQueue.main.async {
                parent.blockedURL = req
            }
            decisionHandler(.cancel)
        }
    }
}
