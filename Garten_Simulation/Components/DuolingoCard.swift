import SwiftUI

struct DuolingoCard<Content: View>: View {
    let action: () -> Void
    let badgeText: String?
    @ViewBuilder let content: Content
    
    init(action: @escaping () -> Void, badgeText: String? = nil, @ViewBuilder content: () -> Content) {
        self.action = action
        self.badgeText = badgeText
        self.content = content()
    }
    
    var body: some View {
        Button(action: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                action()
            }
        }) {
            ZStack(alignment: .topLeading) {
                content
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity, minHeight: 110, alignment: .leading)

                if let badge = badgeText {
                    Text(badge)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            UnevenRoundedRectangle(
                                topLeadingRadius: 12,
                                bottomLeadingRadius: 0,
                                bottomTrailingRadius: 8,
                                topTrailingRadius: 0
                            )
                            .fill(Color.blauPrimary)
                        )
                }
            }
        }
        .buttonStyle(DuolingoCardButtonStyle())
    }
}

struct DuolingoCardButtonStyle: ButtonStyle {
    @AppStorage("isHapticEnabled") var isHapticEnabled: Bool = true
    private let shadowDepth: CGFloat = 4
    private let cornerRadius: CGFloat = 12

    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed
        
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color(UIColor.systemBackground))
                    .shadow(
                        color: Color.gray.opacity(0.3),
                        radius: 0,
                        y: isPressed ? 0 : shadowDepth
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.gray.opacity(0.15), lineWidth: 1)
            )
            .offset(y: isPressed ? shadowDepth : 0)
            .animation(isPressed ? nil : .spring(response: 0.15, dampingFraction: 0.6), value: isPressed)
            .sensoryFeedback(trigger: isPressed) { _, newValue in
                (isHapticEnabled && newValue) ? .impact(flexibility: .soft, intensity: 0.75) : nil
            }
    }
}
