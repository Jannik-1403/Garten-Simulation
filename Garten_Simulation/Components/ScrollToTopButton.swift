import SwiftUI

struct ScrollToTopButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: {
            action()
        }) {
            Image(systemName: "arrow.up")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.white)
        }
        .buttonStyle(ScrollToTopButtonStyle())
        // Ein DragGesture(minimumDistance: 0) fängt den Tap sofort ab, 
        // auch wenn die ScrollView darunter noch ausrollt (decelerating).
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onEnded { value in
                    // Nur als Tap werten, wenn der Finger nicht weit bewegt wurde
                    guard abs(value.translation.width) < 10 && abs(value.translation.height) < 10 else { return }
                    
                    action()
                    // Mehrfacher Aufruf bricht eine noch laufende Scroll-Animation ab
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        action()
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        action()
                    }
                }
        )
    }
}

struct ScrollToTopButtonStyle: ButtonStyle {
    @AppStorage("isHapticEnabled") var isHapticEnabled: Bool = true
    private let size: CGFloat = 46
    private let depth: CGFloat = 4

    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed
        
        ZStack(alignment: .bottom) {
            // Unterer Layer (Shadow)
            Circle()
                .fill(Color.blauSecondary)
                .frame(width: size, height: size)

            // Oberer Layer (Action Surface)
            configuration.label
                .frame(width: size, height: size)
                .background(Circle().fill(Color.blauPrimary))
                .offset(y: isPressed ? 0 : -depth)
        }
        .frame(width: size, height: size)
        .animation(.spring(response: 0.22, dampingFraction: 0.5), value: isPressed)
        .sensoryFeedback(trigger: isPressed) { _, newValue in
            (isHapticEnabled && newValue) ? .impact(flexibility: .soft, intensity: 0.75) : nil
        }
    }
}
