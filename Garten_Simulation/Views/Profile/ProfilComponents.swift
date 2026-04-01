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
                Text(NSLocalizedString(stufe.labelKey, comment: ""))
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
            .onChange(of: fortschritt) { newValue in
                withAnimation(.spring(response: 0.6, dampingFraction: 0.75)) {
                    animierterFortschritt = max(0, min(1, newValue))
                }
            }
            
            if let naechste = stufe.naechste {
                Text(String(format: NSLocalizedString("stufe.naechste.hinweis", comment: ""),
                    xpNaechsteStufe - aktuelleXP,
                    NSLocalizedString(naechste.labelKey, comment: "")))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            } else {
                Text("Max Level!")
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
                
                Text(NSLocalizedString(stufe.labelKey, comment: ""))
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

struct CoinsStatButton: View {
    let coins: Int
    @Binding var showDetail: Bool
    
    var body: some View {
        VStack(spacing: 6) {
            Item3DButton(
                icon: "dollarsign.circle.fill",
                farbe: Color(hex: "#FFD60A"),          // Gold
                sekundaerFarbe: Color(hex: "#B8960A"), // dunkles Gold
                groesse: 72,
                aktion: { showDetail = true }
            )
            Text("\(coins)")
                .font(.system(size: 22, weight: .black, design: .rounded))
            Text(LocalizedStringKey("profile.coins"))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

struct PflanzenStatButton: View {
    let count: Int
    @Binding var showDetail: Bool
    
    var body: some View {
        VStack(spacing: 6) {
            Item3DButton(
                icon: "leaf.fill",
                farbe: Color(hex: "#34C759"),          // Grün
                sekundaerFarbe: Color(hex: "#1E7A35"), // dunkles Grün
                groesse: 72,
                aktion: { showDetail = true }
            )
            Text("\(count)")
                .font(.system(size: 22, weight: .black, design: .rounded))
            Text(LocalizedStringKey("profile.plants"))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

struct StreakStatButton: View {
    let streak: Int
    var aktion: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 6) {
            Item3DButton(
                icon: "flame.fill",
                farbe: Color(hex: "#FF6B35"),          // Orange
                sekundaerFarbe: Color(hex: "#C43D00"), // dunkles Orange
                groesse: 72,
                aktion: aktion
            )
            Text("\(streak)")
                .font(.system(size: 22, weight: .black, design: .rounded))
            Text(streak == 1
                 ? LocalizedStringKey("streak.singular.label")
                 : LocalizedStringKey("streak.plural.label"))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

struct ErfolgeStatButton: View {
    let count: Int
    @Binding var showDetail: Bool
    
    var body: some View {
        VStack(spacing: 6) {
            Item3DButton(
                icon: "trophy.fill",
                farbe: Color(hex: "#AF52DE"),          // Lila
                sekundaerFarbe: Color(hex: "#6B1F99"), // dunkles Lila
                groesse: 72,
                aktion: { showDetail = true }
            )
            Text("\(count)")
                .font(.system(size: 22, weight: .black, design: .rounded))
            Text(LocalizedStringKey("profile.achievements"))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
