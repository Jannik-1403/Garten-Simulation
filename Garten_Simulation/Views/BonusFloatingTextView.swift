import SwiftUI

struct BonusFloatingTextView: View {
    let text: String
    @Binding var isVisible: Bool

    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 0.3
    @State private var offsetY: CGFloat = 0

    var body: some View {
        ZStack {
            // 3D-Schatten (Dunkelblau für Tiefe)
            Text(text)
                .font(.system(size: 28, weight: .black, design: .rounded))
                .foregroundColor(Color(hex: "#1A2744"))
                .offset(y: 3)
            
            // Haupt-Text (Hellblau/Türkis)
            Text(text)
                .font(.system(size: 28, weight: .black, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(hex: "#40E0D0"), Color.blauPrimary],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: .black.opacity(0.2), radius: 2)
        }
        .scaleEffect(scale)
        .opacity(opacity)
        .offset(y: offsetY)
        .allowsHitTesting(false)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                opacity = 1
                scale = 1.0
                offsetY = -60
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                dismiss()
            }
        }
    }
    
    private func dismiss() {
        withAnimation(.easeIn(duration: 0.3)) {
            opacity = 0
            scale = 0.8
            offsetY = -80
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isVisible = false
        }
    }
}
