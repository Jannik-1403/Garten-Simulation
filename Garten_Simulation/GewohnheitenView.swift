import SwiftUI

struct GewohnheitenView: View {
    var body: some View {
        ZStack {
            Color.orange.opacity(0.3).ignoresSafeArea()
            Text("🔥 Gewohnheiten")
                .font(.largeTitle)
                .fontWeight(.bold)
        }
    }
}

#Preview { GewohnheitenView() }
