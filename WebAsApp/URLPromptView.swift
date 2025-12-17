import SwiftUI

struct URLPromptView: View {
    @AppStorage("savedURL") private var savedURL: String = ""
    @State private var inputURL = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Enter Base URL").font(.headline)
            TextField("https://example.com", text: $inputURL)
                .textInputAutocapitalization(.never)
                .keyboardType(.URL)
                .textFieldStyle(.roundedBorder)
            Button("Save") {
                if let url = URL(string: inputURL), url.scheme != nil {
                    savedURL = inputURL
                }
            }
        }.padding()
    }
}
