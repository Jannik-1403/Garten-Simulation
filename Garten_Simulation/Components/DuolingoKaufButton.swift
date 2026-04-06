import SwiftUI

struct DuolingoKaufButton: View {
    @EnvironmentObject var settings: SettingsStore
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                action()
            }
        }) {
            HStack(spacing: 8) {
                Image("coin")
                    .resizable().scaledToFit()
                    .frame(width: 20, height: 20)
                Text(settings.localizedString(for: "button.buy_now"))
                    .font(.system(.title3, design: .rounded, weight: .bold))
            }
            .foregroundStyle(.white)
        }
        .buttonStyle(DuolingoKaufButtonStyle(color: color))
    }
}

struct DuolingoKaufButtonStyle: ButtonStyle {
    @AppStorage("isHapticEnabled") var isHapticEnabled: Bool = true
    let color: Color
    private let shadowDepth: CGFloat = 4
    private let cornerRadius: CGFloat = 16

    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed
        
        ZStack {
            // Unterer Layer
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(color.darker())
                .offset(y: shadowDepth)

            // Oberer Layer
            configuration.label
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(color)
                )
                .offset(y: isPressed ? shadowDepth : 0)
        }
        .frame(maxWidth: .infinity)
        .animation(isPressed ? nil : .spring(response: 0.15, dampingFraction: 0.6), value: isPressed)
        .onChange(of: isPressed) {
            if isPressed {
                FeedbackManager.shared.playTap()
            }
        }
    }
}
