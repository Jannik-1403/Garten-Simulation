import SwiftUI
import RiveRuntime

struct AufgabenView: View {
    var body: some View {
        ZStack {
            Color.mint.opacity(0.3).ignoresSafeArea()
            
            VStack {
                RiveViewModel(fileName: "note_book").view()
                    .frame(width: 200, height: 200)
                
                Text("Aufgaben")
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
        }
    }
}