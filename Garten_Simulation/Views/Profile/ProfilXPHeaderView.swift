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
        Item3DButton(
            farbe: farbe,
            sekundaerFarbe: farbe.darker(),
            groesse: 90,
            isRectangular: true,
            aktion: {
                FeedbackManager.shared.playTap()
                onTippen()
            }
        ) {
            HStack(spacing: 16) {
                // Linke Seite: Großes Level-Icon (ohne Hintergrundkreis)
                Image("Erfolg")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 64, height: 64)
                    .padding(.leading, 8)
                
                // Mitte: Titel und Fortschritt
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(GartenTierStufe.fuer(level: level).lokalisiertTitel(settings: settings)) · \(settings.localizedString(for: "level_up_label")) \(level)")
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    
                    // Progress Bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(.white.opacity(0.3))
                                .frame(height: 6)
                            
                            Capsule()
                                .fill(.white)
                                .frame(width: max(6, CGFloat(fortschritt) * geo.size.width), height: 6)
                        }
                    }
                    .frame(height: 6)
                    .padding(.top, 2)
                    
                    HStack {
                        Text("\(xpImLevel) / \(xpFuerNaechstenLevel) XP")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundColor(.white.opacity(0.9))
                        
                        Spacer()
                        
                        Text("\(Int(fortschritt * 100))%")
                            .font(.system(size: 10, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                    }
                }
                
                // Rechte Seite: Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .black))
                    .foregroundColor(.white.opacity(0.6))
            }
            .padding(.horizontal, 16)
        }
    }
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
