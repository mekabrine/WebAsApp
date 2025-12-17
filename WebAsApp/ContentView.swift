import SwiftUI

struct ContentView: View {
    @AppStorage("savedURL") private var savedURL: String = ""
    @State private var hasLoadedThisSession = false
    @State private var blockedURL: String?
    @State private var showPopup = false

    var body: some View {
        ZStack(alignment: .topTrailing) {
            if savedURL.isEmpty {
                URLPromptView()
            } else {
                WebView(
                    baseURL: savedURL,
                    shouldLoad: !hasLoadedThisSession,
                    blockedURL: $blockedURL
                )
                .onAppear { hasLoadedThisSession = true }
            }

            if let blockedURL {
                ToastView {
                    showPopup = true
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.blockedURL = nil
                    }
                }
            }
        }
        .alert("Blocked URL", isPresented: $showPopup) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(blockedURL ?? "")
        }
    }
}
