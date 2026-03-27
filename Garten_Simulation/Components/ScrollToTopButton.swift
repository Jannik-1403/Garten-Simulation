import SwiftUI

struct ScrollToTopButton: View {
    let action: () -> Void

    @State private var isPressed = false
    private let size: CGFloat = 46
    private let depth: CGFloat = 4

    var body: some View {
        ZStack {
            // Unterer Layer — bewegt sich NICHT
            Circle()
                .fill(Color.blauSecondary)
                .frame(width: size, height: size)
                .offset(y: depth) // immer unten, nie animiert

            // Oberer Layer — bewegt sich beim Drücken
            Circle()
                .fill(Color.blauPrimary)
                .frame(width: size, height: size)
                .overlay(
                    Image(systemName: "arrow.up")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                )
                .offset(y: isPressed ? depth : 0)
        }
        .frame(width: size, height: size + depth)
        .scaleEffect(isPressed ? 0.96 : 1.0)
        .animation(.bouncy(duration: 0.2), value: isPressed)
        .sensoryFeedback(.impact(flexibility: .soft, intensity: 0.75), trigger: isPressed) { _, new in new }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isPressed {
                        isPressed = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.06) {
                            action()
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                            isPressed = false
                        }
                    }
                }
                .onEnded { _ in isPressed = false }
        )
    }
}
