import SwiftUI

struct ProfilView: View {
    var body: some View {
        ZStack {
            Color.blue.opacity(0.3).ignoresSafeArea()
            Text("👤 Profil")
                .font(.largeTitle)
                .fontWeight(.bold)
        }
    }
}

#Preview { ProfilView() }
