import SwiftUI

struct ScrollToTopButton: View {
    let action: () -> Void
    @State private var lastTriggerTime: Date = .distantPast

    var body: some View {
        Button(action: {
            action()
        }) {
            Image(systemName: "arrow.up")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.white)
        }
        .buttonStyle(ScrollToTopButtonStyle())
        // Ein DragGesture(minimumDistance: 0) fängt den Tap sofort ab.
        // WICHTIG: Wir nutzen .onChanged (Touch Down), weil .onEnded während
        // einer Scroll-Bewegung von der ScrollView abgebrochen (cancelled) wird!
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    let now = Date()
                    guard now.timeIntervalSince(lastTriggerTime) > 0.5 else { return }
                    lastTriggerTime = now
                    
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
