import SwiftUI

// MARK: - Anklickbarer XP-Header (ersetzt alte XP-Bar + Garden Level-Karte)

struct ProfilXPHeaderView: View {
    @EnvironmentObject var settings: SettingsStore
    let gesamtXP: Int
    let onTippen: () -> Void   // öffnet GartenPassView

    private var level: Int {
        GartenLevel.level(fuerXP: gesamtXP)
    }

    private var xpImLevel: Int {
        GartenLevel.xpImLevel(gesamtXP: gesamtXP)
    }

    private var xpFuerNaechstenLevel: Int {
        GartenLevel.xpFuerNaechstenLevel(gesamtXP: gesamtXP)
    }

    private var fortschritt: Double {
        let maxXP = xpFuerNaechstenLevel
        guard maxXP > 0 else { return 1.0 }
        return Double(xpImLevel) / Double(maxXP)
    }

    private var farbe: Color {
        GartenLevel.farbe(fuerLevel: level)
    }

    var body: some View {
        Button(action: {
            FeedbackManager.shared.playTap()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
                onTippen()
            }
        }) {
            ZStack(alignment: .top) {
                // Background Layer (Depth/Shadow) - THE COLOR LAYER
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(farbe)
                    .offset(y: 8)
                
                // Content Layer - THE WHITE SURFACE
                VStack(spacing: 12) {
                    HStack {
                        HStack(spacing: 6) {
                            Image(systemName: GartenLevel.symbol(fuerLevel: level))
                                .font(.system(size: 14, weight: .black))
                                .foregroundColor(farbe)
                            
                            Text("\(GartenTierStufe.fuer(level: level).lokalisiertTitel(settings: settings)) · \(settings.localizedString(for: "level_up_label")) \(level)")
                                .font(.system(size: 16, weight: .black, design: .rounded))
                                .foregroundColor(GartenLevel.dunkelFarbe(fuerLevel: level))
                        }

                        Spacer()

                        Text("\(xpImLevel) / \(xpFuerNaechstenLevel) \(settings.localizedString(for: "common.xp"))")
                            .font(.system(size: 14, weight: .black, design: .rounded))
                            .foregroundColor(.secondary)

                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.black))
                            .foregroundColor(.secondary.opacity(0.5))
                    }

                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color(.systemGray6).opacity(0.5))
                            .frame(height: 8)
                        
                        Capsule()
                            .fill(farbe)
                            .frame(width: max(8, CGFloat(fortschritt) * (UIScreen.main.bounds.width - 76)), height: 8)
                    }
                    .mask(Capsule())
                    .animation(.spring(response: 0.6, dampingFraction: 0.82), value: fortschritt)

                    HStack {
                        if level < 50 {
                            Text(String(format: settings.localizedString(for: "xp_bis_naechste"),
                                        xpFuerNaechstenLevel - xpImLevel, "\(settings.localizedString(for: "level_up_label")) \(level + 1)"))
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.secondary)
                        } else {
                            Text(settings.localizedString(for: "tier_maximum_erreicht"))
                                .font(.system(size: 11, weight: .black))
                                .foregroundColor(farbe)
                        }
                        Spacer()
                        
                        Text("\(Int(fortschritt * 100))%")
                            .font(.system(size: 11, weight: .black))
                            .foregroundColor(farbe)
                    }
                }
                .padding(20)
                .background(Color(UIColor.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.black.opacity(0.08), lineWidth: 1)
                )
                .offset(y: isPressed ? 8 : 0)
            }
        }
        .buttonStyle(Duo3DCardButtonStyle(isPressed: $isPressed))
    }
    
    @State private var isPressed: Bool = false
}

// Custom ButtonStyle to track state and apply animation/haptics
struct Duo3DCardButtonStyle: ButtonStyle {
    @Binding var isPressed: Bool
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { old, newValue in
                isPressed = newValue
                if newValue {
                    FeedbackManager.shared.playTap()
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                }
            }
            .animation(.spring(response: 0.22, dampingFraction: 0.52), value: configuration.isPressed)
    }
}

// MARK: - Level-Badge (über dem Namen)

struct ProfilTierBadgeView: View {
    @EnvironmentObject var settings: SettingsStore
    let level: Int
    
    private var farbe: Color { GartenLevel.farbe(fuerLevel: level) }
    private var dunkelFarbe: Color { GartenLevel.dunkelFarbe(fuerLevel: level) }

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: GartenLevel.symbol(fuerLevel: level))
                .font(.system(size: 14, weight: .black))
                .foregroundColor(farbe)

            Text("\(GartenTierStufe.fuer(level: level).lokalisiertTitel(settings: settings)) · \(level)")
                .font(.system(size: 14, weight: .black, design: .rounded))
                .foregroundColor(dunkelFarbe)
        }
        .padding(.vertical, 4)
    }
}
