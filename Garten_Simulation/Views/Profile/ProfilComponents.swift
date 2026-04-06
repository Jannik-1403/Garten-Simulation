import SwiftUI

// MARK: - ProfilXPBarView
struct ProfilXPBarView: View {
    let stufe: PflanzenStufe
    let fortschritt: Double  // 0.0–1.0
    let aktuelleXP: Int
    let xpNaechsteStufe: Int  // absoluter XP-Wert der nächsten Stufe
    
    @EnvironmentObject var settings: SettingsStore
    @State private var animierterFortschritt: Double = 0.0
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(settings.localizedString(for: stufe.labelKey))
                    .font(.caption.weight(.bold))
                    .foregroundStyle(stufe.farbe)
                
                Spacer()
                
                Text("\(aktuelleXP) / \(xpNaechsteStufe) XP")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(UIColor.tertiarySystemFill))
                        .frame(height: 14)
                    
                    Capsule()
                        .fill(stufe.farbe)
                        .frame(width: max(0, geo.size.width * CGFloat(animierterFortschritt)), height: 14)
                        .shadow(color: stufe.farbe.opacity(0.6), radius: 6, y: 2)
                }
            }
            .frame(height: 14)
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.75)) {
                    animierterFortschritt = max(0, min(1, fortschritt))
                }
            }
            .onChange(of: fortschritt) { _, newValue in
                withAnimation(.spring(response: 0.6, dampingFraction: 0.75)) {
                    animierterFortschritt = max(0, min(1, newValue))
                }
            }
            
            if let naechste = stufe.naechste {
                Text(String(format: settings.localizedString(for: "stufe.naechste.hinweis"),
                    xpNaechsteStufe - aktuelleXP,
                    settings.localizedString(for: naechste.labelKey)))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            } else {
                Text(settings.localizedString(for: "profile.level.max"))
                    .font(.caption2)
                    .foregroundStyle(stufe.farbe)
            }
        }
    }
}

// MARK: - ProfilHeaderView
struct ProfilHeaderView: View {
    let name: String
    let stufe: PflanzenStufe
    @EnvironmentObject var settings: SettingsStore
    
    var body: some View {
        VStack(spacing: 6) {
            Text(name)
                .font(.system(size: 24, weight: .bold, design: .rounded))
            
            HStack(spacing: 6) {
                Image(systemName: stufe.sfSymbol)
                    .foregroundStyle(stufe.farbe)
                    .font(.caption)
                
                Text(settings.localizedString(for: stufe.labelKey))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(stufe.farbe)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(stufe.farbe.opacity(0.15), in: Capsule())
        }
    }
}

// MARK: - Stat Buttons (Item3DButton Wrappers)

struct XPStatButton: View {
    let xp: Int
    @Binding var showDetail: Bool
    @EnvironmentObject var settings: SettingsStore
    
    var body: some View {
        VStack(spacing: 6) {
            Item3DButton(
                icon: "XP",
                farbe: Color(hex: "#FFD000"),          // Blitzgelb
                sekundaerFarbe: Color(hex: "#D9A300"), // dunkles Gelb
                groesse: 80,
                aktion: { showDetail = true }
            )
            Text("\(xp)")
                .font(.system(size: 22, weight: .black, design: .rounded))
            Text(settings.localizedString(for: "profile.xp.total"))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

struct InventoryStatButton: View {
    let count: Int
    @Binding var showDetail: Bool
    @EnvironmentObject var settings: SettingsStore
    
    var body: some View {
        VStack(spacing: 6) {
            Item3DButton(
                icon: "Inventar",
                farbe: Color(hex: "#8B4513"),          // Holz-Braun
                sekundaerFarbe: Color(hex: "#5D2E0C"), // dunkles Braun
                groesse: 80,
                aktion: { showDetail = true }
            )
            Text("\(count)")
                .font(.system(size: 22, weight: .black, design: .rounded))
            Text(settings.localizedString(for: "profile.inventory"))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

struct StreakStatButton: View {
    let currentStreak: Int
    let bestStreak: Int
    var aktion: (() -> Void)? = nil
    @EnvironmentObject var settings: SettingsStore
    
    var body: some View {
        VStack(spacing: 6) {
            Item3DButton(
                icon: "streak",
                farbe: Color(hex: "#FF4B00"),          // Flammen-Rot/Orange
                sekundaerFarbe: Color(hex: "#C43D00"), // dunkles Rot
                groesse: 80,
                aktion: aktion
            )
            
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text("\(bestStreak)")
                    .font(.system(size: 22, weight: .black, design: .rounded))
            }
            
            Text(settings.localizedString(for: "profile.streak.best"))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

struct ErfolgeStatButton: View {
    let count: Int
    @Binding var showDetail: Bool
    @EnvironmentObject var settings: SettingsStore
    
    var body: some View {
        VStack(spacing: 6) {
            Item3DButton(
                icon: "Erfolg",
                farbe: Color(hex: "#FFB800"),          // Trophäen-Gold
                sekundaerFarbe: Color(hex: "#C5A000"), // dunkles Gold
                groesse: 80,
                aktion: { showDetail = true }
            )
            
            Text("\(count)")
                .font(.system(size: 22, weight: .black, design: .rounded))

            Text(settings.localizedString(for: "profile.achievements"))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

struct WasserStatButton: View {
    let liter: String
    @Binding var showDetail: Bool
    @EnvironmentObject var settings: SettingsStore
    
    var body: some View {
        VStack(spacing: 6) {
            Item3DButton(
                icon: "Drop water",
                farbe: .blauPrimary,
                sekundaerFarbe: .blauSecondary,
                groesse: 80,
                aktion: { showDetail = true }
            )
            
            VStack(spacing: 0) {
                Text(settings.localizedString(for: "wasser.karte.titel"))
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundStyle(.secondary)
                
                Text(liter)
                    .font(.system(size: 22, weight: .black, design: .rounded))
                
                Text(settings.localizedString(for: "wasser.gesamt"))
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
            }
        }
    }
}
