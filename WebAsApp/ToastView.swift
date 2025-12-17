import SwiftUI

struct ToastView: View {
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text("Blocked link")
                .padding(10)
                .background(.black.opacity(0.85))
                .foregroundColor(.white)
                .cornerRadius(8)
        }
        .padding()
    }
}
