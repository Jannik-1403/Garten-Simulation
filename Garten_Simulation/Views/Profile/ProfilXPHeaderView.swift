import SwiftUI

// MARK: - Anklickbarer XP-Header (ersetzt alte XP-Bar + Garden Level-Karte)

struct ProfilXPHeaderView: View {
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
        Button(action: onTippen) {
            VStack(spacing: 12) {
                // Obere Zeile: Level links, XP rechts, Chevron
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: GartenLevel.symbol(fuerLevel: level))
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(farbe)
                        
                        Text("\(NSLocalizedString("level_up_label", comment: "")) \(level)")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(GartenLevel.dunkelFarbe(fuerLevel: level))
                    }

                    Spacer()

                    Text("\(xpImLevel) / \(xpFuerNaechstenLevel) XP")
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .foregroundColor(.secondary)

                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundColor(.secondary.opacity(0.5))
                }

                // XP-Balken
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(.systemGray6))
                        .frame(height: 12)
                    
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [farbe, farbe.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(12, CGFloat(fortschritt) * (UIScreen.main.bounds.width - 72)), height: 12) // Approximate width
                        .shadow(color: farbe.opacity(0.3), radius: 4, x: 0, y: 2)
                    
                    // Glossy shine effect
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [.white.opacity(0.3), .clear],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(height: 6)
                        .padding(.horizontal, 4)
                        .padding(.top, 1)
                }
                .mask(Capsule())
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: fortschritt)

                // Hint-Text
                HStack {
                    if level < 50 {
                        Text(String(format: NSLocalizedString("xp_bis_naechste", comment: ""),
                                    xpFuerNaechstenLevel - xpImLevel, "Level \(level + 1)"))
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.secondary)
                    } else {
                        Text(NSLocalizedString("tier_maximum_erreicht", comment: ""))
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(farbe)
                    }
                    Spacer()
                    
                    Text("\(Int(fortschritt * 100))%")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(farbe)
                }
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.04), radius: 15, x: 0, y: 8)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(farbe.opacity(0.15), lineWidth: 1.5)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Level-Badge (über dem Namen)

struct ProfilTierBadgeView: View {
    let level: Int

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: GartenLevel.symbol(fuerLevel: level))
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(GartenLevel.farbe(fuerLevel: level))

            Text("\(NSLocalizedString("level_up_label", comment: "")) \(level)")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(GartenLevel.dunkelFarbe(fuerLevel: level))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 6)
        .background(GartenLevel.hellFarbe(fuerLevel: level))
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(GartenLevel.farbe(fuerLevel: level).opacity(0.2), lineWidth: 1)
        )
    }
}
