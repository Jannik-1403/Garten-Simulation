import SwiftUI

struct DuolingoKaufButton: View {
    let color: Color
    let action: () -> Void

    @State private var isPressed = false
    @State private var hatAusgeloest = false

    private let shadowDepth: CGFloat = 4
    private let cornerRadius: CGFloat = 16

    var body: some View {
        ZStack {
            // Unterer Layer — bleibt immer stehen
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(color.darker())
                .offset(y: shadowDepth)

            // Oberer Layer — bewegt sich beim Drücken
            HStack(spacing: 8) {
                Image("Coin")
                    .resizable().scaledToFit()
                    .frame(width: 20, height: 20)
                Text("JETZT KAUFEN")
                    .font(.system(.title3, design: .rounded, weight: .bold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(color)
            )
            .offset(y: isPressed ? shadowDepth : 0)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 56 + shadowDepth)
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .animation(.bouncy(duration: 0.2), value: isPressed)
        .sensoryFeedback(
            .impact(flexibility: .soft, intensity: 0.75),
            trigger: isPressed
        ) { _, newValue in newValue }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !hatAusgeloest {
                        isPressed = true
                        hatAusgeloest = true
                        // Aktion NACH Animation (0.2s = bouncy duration)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.20) {
                            action()
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) {
                            isPressed = false
                            hatAusgeloest = false
                        }
                    }
                }
                .onEnded { _ in
                    isPressed = false
                    hatAusgeloest = false
                }
        )
    }
}
