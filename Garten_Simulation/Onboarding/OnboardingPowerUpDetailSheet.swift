import SwiftUI

struct OnboardingPowerUpDetailSheet: View {
    @EnvironmentObject var settings: SettingsStore
    @Environment(\.dismiss) private var dismiss
    
    var onUse: () -> Void
    
    // Golden Key details
    private let powerUpID = "powerup.goldener_schluessel"
    
    private var powerUp: PowerUpItem? {
        GameDatabase.allPowerUps.first { $0.id == powerUpID }
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.appHintergrund.ignoresSafeArea()
            
            VStack(spacing: 32) {
                if let item = powerUp {
                    // Hero Icon
                    VStack(spacing: 16) {
                        Image(item.symbolName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 140, height: 140)
                            .shadow(color: item.color.opacity(0.3), radius: 20, x: 0, y: 10)
                            .padding(.top, 60)
                        
                        Text(settings.localizedString(for: item.name))
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .multilineTextAlignment(.center)
                    }
                    
                    // Description
                    Text(settings.localizedString(for: item.description))
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    // Usage Hint
                    if !item.howToUse.isEmpty {
                        VStack(spacing: 8) {
                            Text(settings.localizedString(for: "shop.item.usage").uppercased())
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(.tertiary)
                                .tracking(1.5)
                            
                            Text(settings.localizedString(for: item.howToUse))
                                .font(.system(size: 15))
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                        .padding(.top, 8)
                    }
                    
                    Spacer()
                    
                    // USE Button
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        onUse()
                        dismiss()
                    } label: {
                        Text(settings.localizedString(for: "button.use"))
                    }
                    .buttonStyle(DuolingoButtonStyle(
                        size: .large,
                        fillWidth: true,
                        backgroundColor: item.color,
                        shadowColor: item.color.darker(),
                        foregroundColor: .white
                    ))
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
            
            // X Button
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.secondary)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(.ultraThinMaterial))
            }
            .padding(24)
        }
    }
}

#Preview {
    OnboardingPowerUpDetailSheet(onUse: {})
        .environmentObject(SettingsStore())
}
