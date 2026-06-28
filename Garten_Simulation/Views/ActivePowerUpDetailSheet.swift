import SwiftUI

struct ActivePowerUpDetailSheet: View {
    let aktiv: ActivePowerUp
    @EnvironmentObject var settings: SettingsStore
    @Environment(\.dismiss) private var dismiss
    
    // Wir holen uns die Detail-Beschreibung aus der Datenbank
    private var powerUpBase: PowerUpItem? {
        GameDatabase.allPowerUps.first(where: { $0.id == aktiv.powerUpId })
    }

    var body: some View {
        ZStack {
            Color.appHintergrund.ignoresSafeArea()
            
            VStack(spacing: 32) {
                
                // MARK: - Icon
                if let base = powerUpBase {
                    Group {
                        if UIImage(named: base.symbolName) != nil {
                            Image(base.symbolName)
                                .resizable()
                                .scaledToFit()
                        } else {
                            Image(systemName: base.symbolName)
                                .font(.system(size: 60))
                                .foregroundStyle(base.color)
                        }
                    }
                    .frame(width: 100, height: 100)
                    .shadow(color: base.color.opacity(0.3), radius: 20, x: 0, y: 10)
                    .padding(.top, 60)
                }
                
                // MARK: - Texts
                VStack(spacing: 12) {
                    if let base = powerUpBase {
                        Text(NSLocalizedString(base.name, comment: ""))
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .multilineTextAlignment(.center)
                        
                        Text(NSLocalizedString(base.description, comment: ""))
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        if !base.howToUse.isEmpty {
                            VStack(spacing: 4) {
                                Text(String(localized: "shop.item.usage"))
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundStyle(.tertiary)
                                Text(NSLocalizedString(base.howToUse, comment: ""))
                                    .font(.system(size: 14))
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 40)
                            }
                            .padding(.top, 8)
                        }
                    }
                }
                
                // MARK: - Timer
                VStack(spacing: 4) {
                    Text(String(localized: "powerup.active_until")) // Could be localized
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.tertiary)
                        .textCase(.uppercase)
                    
                    if let exp = aktiv.expiresAt {
                        Text(exp, style: .time)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(powerUpBase?.color ?? .green)
                        
                        Text(String(format: String(localized: "powerup.remaining"), aktiv.timeRemainingFormatted))
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .padding(.top, 4)
                    } else {
                        Text(String(localized: "powerup.permanent"))
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(powerUpBase?.color ?? .green)
                            
                        Text(aktiv.timeRemainingFormatted)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .padding(.top, 4)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(UIColor.secondarySystemBackground).opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .padding(.horizontal, 24)
                
                Spacer()
                
                // MARK: Button
                Button {
                    dismiss()
                } label: {
                    Text(String(localized: "button.ok"))
                }
                .buttonStyle(DuolingoButtonStyle(
                    backgroundColor: powerUpBase?.color ?? .green,
                    shadowColor: (powerUpBase?.color ?? .green).darker()
                ))
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
            .padding(.horizontal)
        }
        .glassDismissOverlay()
    }
}
