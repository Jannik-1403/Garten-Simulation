import SwiftUI
import FamilyControls

struct ContentView: View {
    @State var selection = FamilyActivitySelection()
    var body: some View {
        Button("Test") {}
            .familyActivityPicker(headerText: "Wähle Apps", isPresented: .constant(true), selection: $selection)
    }
}
