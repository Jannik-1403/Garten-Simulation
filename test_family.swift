import SwiftUI
import FamilyControls

func test() -> some View {
    EmptyView()
        .familyActivityPicker(headerText: Text("Hallo"), isPresented: .constant(true), selection: .constant(FamilyActivitySelection()))
}
