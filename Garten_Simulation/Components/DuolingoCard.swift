import SwiftUI

struct DuolingoCard<Content: View>: View {
    let action: () -> Void
    let badgeText: String?
    let badgeColor: Color
    let tier: ErfolgTier?
    @ViewBuilder let content: Content
    
    @State private var manualPress = false
    @State private var isLocked = false
    @AppStorage("isHapticEnabled") private var isHapticEnabled: Bool = true
    
    init(action: @escaping () -> Void, badgeText: String? = nil, badgeColor: Color = Color.blauPrimary, tier: ErfolgTier? = nil, @ViewBuilder content: () -> Content) {
        self.action = action
        self.badgeText = badgeText
        self.badgeColor = badgeColor
        self.tier = tier
        self.content = content()
    }
    
    var body: some View {
        Button(action: {
            guard !isLocked else { return }
            isLocked = true
            if isHapticEnabled {
                let impactLight = UIImpactFeedbackGenerator(style: .soft)
                impactLight.impactOccurred(intensity: 0.75)
            }
            
            // Garantierte Animation bei schnellem Tippen
            manualPress = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                manualPress = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    action()
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                isLocked = false
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
                            .fill(badgeColor)
                        )
                }
            }
        }
        .buttonStyle(DuolingoCardButtonStyle(tier: tier, forcePressed: manualPress))
    }
}

struct DuolingoCardButtonStyle: ButtonStyle {
    @AppStorage("isHapticEnabled") var isHapticEnabled: Bool = true
    private let shadowDepth: CGFloat = 4
    private let cornerRadius: CGFloat = 12
    var tier: ErfolgTier? = nil
    var forcePressed: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed || forcePressed
        
        configuration.label
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(Color(UIColor.systemBackground))
                }
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
            .sensoryFeedback(trigger: configuration.isPressed) { _, newValue in
                // Standard-Haptik nur auslösen, wenn nicht manuell gepresst wird (vermeidet doppelte Haptik)
                (isHapticEnabled && newValue && !forcePressed) ? .impact(flexibility: .soft, intensity: 0.75) : nil
            }
    }
}
