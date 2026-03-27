import SwiftUI

struct ScrollToTopButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                action()
            }
        }) {
            Image(systemName: "arrow.up")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.white)
        }
        .buttonStyle(ScrollToTopButtonStyle())
    }
}

struct ScrollToTopButtonStyle: ButtonStyle {
    @AppStorage("isHapticEnabled") var isHapticEnabled: Bool = true
    private let size: CGFloat = 46
    private let depth: CGFloat = 4

    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed
        
        ZStack {
            // Unterer Layer
            Circle()
                .fill(Color.blauSecondary)
                .frame(width: size, height: size)
                .offset(y: depth)

            // Oberer Layer
            configuration.label
                .frame(width: size, height: size)
                .background(Circle().fill(Color.blauPrimary))
                .offset(y: isPressed ? depth : 0)
        }
        .frame(width: size, height: size + depth)
        .scaleEffect(isPressed ? 0.96 : 1.0)
        .animation(isPressed ? nil : .spring(response: 0.15, dampingFraction: 0.6), value: isPressed)
        .sensoryFeedback(trigger: isPressed) { _, newValue in
            (isHapticEnabled && newValue) ? .impact(flexibility: .soft, intensity: 0.75) : nil
        }
    }
}
