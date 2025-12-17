import SwiftUI

struct ToastView: View {
    let url: String
    let onTap: () -> Void

    private var displayHost: String {
        URL(string: url)?.host ?? url
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 10) {
                Image(systemName: "link")
                VStack(alignment: .leading, spacing: 2) {
                    Text("External link blocked")
                        .font(.subheadline)
                        .bold()
                    Text(displayHost)
                        .font(.footnote)
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .opacity(0.9)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(.black.opacity(0.85))
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .padding(.horizontal)
        .accessibilityLabel("Blocked link notification")
    }
}
