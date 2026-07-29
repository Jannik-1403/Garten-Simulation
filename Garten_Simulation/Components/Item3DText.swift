import SwiftUI

/// A reusable 3D Text component that matches the visual style of the wheel of fortune (Glücksrad).
struct Item3DText: View {
    let text: String
    var size: CGFloat = 24
    var color: Color = Color.blauPrimary
    
    var body: some View {
        ZStack {
            // Lower layer (shadow)
            Text(text)
                .font(.system(size: size, weight: .black, design: .rounded))
                .foregroundStyle(color.opacity(0.35))
                .offset(y: size * 0.15)

            // Upper layer (visible text)
            Text(text)
                .font(.system(size: size, weight: .black, design: .rounded))
                .foregroundStyle(color)
        }
    }
}

#Preview {
    Item3DText(text: "Ziel-Analysen", size: 32)
}
