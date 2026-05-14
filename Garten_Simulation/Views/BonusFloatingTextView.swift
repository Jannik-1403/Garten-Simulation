import SwiftUI

struct BonusFloatingTextView: View {
    let text: String
    @Binding var isVisible: Bool

    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 0.3
    @State private var offsetY: CGFloat = 0

    var body: some View {
        ZStack {
            // Unsichtbarer Hintergrund für Dismissal
            Color.black.opacity(0.001)
                .ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                }
            
            // 3D Text in Hellblau/Türkis
            ZStack {
                // 3D-Schatten (Dunkelblau für Tiefe)
                Text(text)
                    .font(.system(size: 40, weight: .black, design: .rounded))
                    .foregroundColor(Color(hex: "#1A2744"))
                    .offset(y: 4)
                
                // Haupt-Text (Hellblau/Türkis)
                Text(text)
                    .font(.system(size: 40, weight: .black, design: .rounded))
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
            .onTapGesture {
                dismiss()
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                opacity = 1
                scale = 1.0
                offsetY = -40
            }
        }
    }
    
    private func dismiss() {
        withAnimation(.easeIn(duration: 0.3)) {
            opacity = 0
            scale = 1.2
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isVisible = false
        }
    }
}
