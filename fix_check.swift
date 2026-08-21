import SwiftUI

struct TestView: View {
    @State private var text = ""
    @State private var showAlert = false
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Hello")
            }
            .alert("Title", isPresented: $showAlert) {
                TextField("Placeholder", text: $text)
                Button("OK") {}
            } message: {
                Text("Message")
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Toolbar")
                }
            }
        }
    }
}
