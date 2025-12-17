import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let baseURL: String
    let shouldLoad: Bool
    @Binding var blockedURL: String?

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> WKWebView {
        let view = WKWebView()
        view.navigationDelegate = context.coordinator
        return view
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        guard shouldLoad, let url = URL(string: baseURL) else { return }
        webView.load(URLRequest(url: url))
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: WebView
        init(_ parent: WebView) { self.parent = parent }

        func webView(_ webView: WKWebView,
                     decidePolicyFor navigationAction: WKNavigationAction,
                     decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if let req = navigationAction.request.url?.absoluteString,
               !req.hasPrefix(parent.baseURL) {
                parent.blockedURL = req
                decisionHandler(.cancel)
            } else {
                decisionHandler(.allow)
            }
        }
    }
}
