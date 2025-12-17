import SwiftUI

struct ContentView: View {
    @AppStorage("savedURL") private var savedURL: String = ""

    @StateObject private var webViewStore = WebViewStore()
    @Environment(\.openURL) private var openURL

    @State private var hasLoadedThisSession = false

    // URL that was blocked because it does not start with baseURL
    @State private var blockedURL: String?

    // Confirmation prompt to open blockedURL externally
    @State private var showOpenPrompt = false

    var body: some View {
        ZStack(alignment: .bottom) {
            if savedURL.isEmpty {
                URLPromptView()
            } else {
                WebView(
                    baseURL: savedURL,
                    shouldLoad: !hasLoadedThisSession,
                    store: webViewStore,
                    blockedURL: $blockedURL
                )
                .ignoresSafeArea()
                .onAppear { hasLoadedThisSession = true }
            }

            // Bottom controls (centered)
            if !savedURL.isEmpty {
                HStack(spacing: 28) {
                    Button {
                        webViewStore.goBack()
                    } label: {
                        Image(systemName: "chevron.backward")
                            .font(.title2)
                    }
                    .disabled(!webViewStore.canGoBack)

                    Button {
                        webViewStore.goForward()
                    } label: {
                        Image(systemName: "chevron.forward")
                            .font(.title2)
                    }
                    .disabled(!webViewStore.canGoForward)

                    Button {
                        webViewStore.reload()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .font(.title2)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .padding(.bottom, 16)
            }

            // Toast-style notification for blocked URL
            if let blockedURL {
                ToastView(url: blockedURL) {
                    showOpenPrompt = true
                }
                .padding(.bottom, 70) // keep it above the nav buttons
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .onAppear {
                    // Auto-hide toast after a short time (but still keep blockedURL for alert if tapped)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        if !showOpenPrompt {
                            withAnimation { self.blockedURL = nil }
                        }
                    }
                }
            }
        }
        .alert("Open external link?", isPresented: $showOpenPrompt) {
            Button("Cancel", role: .cancel) {
                blockedURL = nil
            }
            Button("Open") {
                if let s = blockedURL, let url = URL(string: s) {
                    openURL(url)
                }
                blockedURL = nil
            }
        } message: {
            Text(blockedURL ?? "")
        }
    }
}
