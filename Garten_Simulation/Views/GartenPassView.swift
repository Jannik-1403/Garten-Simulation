import SwiftUI

struct GartenPassView: View {
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var settings: SettingsStore
    @Environment(\.dismiss) var dismiss
    
    @State private var zeigeWheelSheet = false
    @State private var zeigeRewardOverlay = false
    @State private var aktuelleBelohnung: GartenPassBelohnung? = nil
    
    private var aktuellerLevel: Int {
        GartenLevel.level(fuerXP: gardenStore.gesamtXP)
    }
    
    // Gruppiert nach Tier-Wechseln für Section-Header
    private var gruppiertNachTier: [(tier: GartenTier, belohnungen: [GartenPassBelohnung])] {
        let tiers: [GartenTier] = [.bronze, .silber, .gold, .diamant]
        return tiers.map { tier in
            let filtered = GartenPassBelohnung.alle.filter { $0.tier == tier }
            return (tier: tier, belohnungen: filtered)
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 0) {
                        // XP-Header
                        PassHeaderView(
                            aktuellerLevel: aktuellerLevel,
                            gesamtXP: gardenStore.gesamtXP
                        )
                        
                        // Tier-Sektionen
                        ForEach(gruppiertNachTier, id: \.tier.bezeichnung) { gruppe in
                            TierSektionView(
                                tier: gruppe.tier,
                                belohnungen: gruppe.belohnungen,
                                aktuellerLevel: aktuellerLevel,
                                abgeholte: gardenStore.abgeholtePassLevel,
                                onAbholen: { belohnung in
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        gardenStore.belohnungAbholen(belohnung: belohnung)
                                    }
                                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                    
                                    // DIREKT-FLOW: Bei Drehungen direkt zum Rad, sonst Overlay
                                    if case .gluecksradDrehung = belohnung.typ {
                                        withAnimation {
                                            zeigeWheelSheet = true
                                        }
                                    } else {
                                        aktuelleBelohnung = belohnung
                                        withAnimation(.spring(response: 0.45, dampingFraction: 0.72)) {
                                            zeigeRewardOverlay = true
                                        }
                                    }
                                }
                            )
                        }
                        
                        Spacer(minLength: 40)
                    }
                }
                .onAppear {
                    // Zum aktuellen Level scrollen
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation {
                            proxy.scrollTo("level_\(aktuellerLevel)", anchor: .center)
                        }
                    }
                }
            }
            .navigationTitle(NSLocalizedString("pass_titel", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                            .font(.title2)
                    }
                }
            }
            .fullScreenCover(isPresented: $zeigeWheelSheet) {
                GartenPassWheelView()
                    .environmentObject(gardenStore)
                    .environmentObject(settings)
            }
            .fullScreenCover(isPresented: $zeigeRewardOverlay) {
                if let belohnung = aktuelleBelohnung {
                    GartenPassRewardOverlay(
                        belohnung: belohnung,
                        onSpinNow: {
                            withAnimation {
                                zeigeRewardOverlay = false
                                // Ein kleiner Delay bevor das Rad öffnet
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    zeigeWheelSheet = true
                                }
                            }
                        },
                        onContinue: {
                            withAnimation {
                                zeigeRewardOverlay = false
                                // Belohnung verarbeiten (nur einmalig)
                                let typ = belohnung.typ
                                aktuelleBelohnung = nil
                                
                                // Wenn es kein Spin war -> zum Garten wechseln und Pass schließen
                                if case .gluecksradDrehung = typ {
                                    // Bei Spin später -> nur Pass schließen (wird durch Dismiss geregelt)
                                    dismiss()
                                } else {
                                    gardenStore.selectedTab = 0
                                    dismiss()
                                }
                            }
                        }
                    )
                }
            }
        }
    }
}

// MARK: - Header

struct PassHeaderView: View {
    let aktuellerLevel: Int
    let gesamtXP: Int
    
    private var tierAktuell: GartenTier {
        GartenPassBelohnung.alle.first { $0.id == aktuellerLevel }?.tier ?? .bronze
    }
    
    private var xpImLevel: Int { GartenLevel.xpImLevel(gesamtXP: gesamtXP) }
    private var xpZiel: Int { GartenLevel.xpFuerNaechstenLevel(gesamtXP: gesamtXP) }
    private var fortschritt: Double {
        xpZiel > 0 ? min(Double(xpImLevel) / Double(xpZiel), 1.0) : 1.0
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                // Tier-Badge
                HStack(spacing: 6) {
                    Circle()
                        .fill(tierAktuell.farbe)
                        .frame(width: 10, height: 10)
                    Text(tierAktuell.bezeichnung)
                        .font(.caption.weight(.semibold))
                        .foregroundColor(tierAktuell.dunkelFarbe)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(tierAktuell.hellFarbe)
                .clipShape(Capsule())
                
                Text(String(format: NSLocalizedString("pass_level_label", comment: ""), aktuellerLevel))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(xpImLevel) / \(xpZiel) XP")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // XP-Balken
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(.systemGray5))
                        .frame(height: 10)
                    Capsule()
                        .fill(tierAktuell.farbe)
                        .frame(width: geo.size.width * fortschritt, height: 10)
                }
            }
            .frame(height: 10)
            
            if aktuellerLevel < 50 {
                Text(String(format: NSLocalizedString("pass_naechstes_tier_hint", comment: ""),
                            naechstesTierName()))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
    }
    
    private func naechstesTierName() -> String {
        switch aktuellerLevel {
        case ..<10: return "\(GartenTier.silber.bezeichnung) (Level 11)"
        case ..<25: return "\(GartenTier.gold.bezeichnung) (Level 26)"
        case ..<40: return "\(GartenTier.diamant.bezeichnung) (Level 41)"
        default:    return ""
        }
    }
}

// MARK: - Tier Sektion

struct TierSektionView: View {
    let tier: GartenTier
    let belohnungen: [GartenPassBelohnung]
    let aktuellerLevel: Int
    let abgeholte: Set<Int>
    let onAbholen: (GartenPassBelohnung) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Sektion-Header (Tier-Trenner)
            TierTrennerView(tier: tier)
            
            // Belohnungs-Reihen
            ForEach(belohnungen) { belohnung in
                PassZeileView(
                    belohnung: belohnung,
                    aktuellerLevel: aktuellerLevel,
                    istAbgeholt: abgeholte.contains(belohnung.id),
                    onAbholen: { onAbholen(belohnung) }
                )
                .id("level_\(belohnung.id)")
            }
        }
    }
}

// MARK: - Tier-Trenner (farbiger Section-Header)

struct TierTrennerView: View {
    let tier: GartenTier
    
    /// Mittlere Stufe (II) als Referenzfarbe für den Trenner
    private var referenzStufe: GartenTierStufe {
        switch tier {
        case .bronze:  return .bronzeII
        case .silber:  return .silberII
        case .gold:    return .goldII
        case .diamant: return .diamantII
        }
    }
    
    var body: some View {
        HStack(spacing: 8) {
            Rectangle()
                .fill(referenzStufe.farbe.opacity(0.3))
                .frame(height: 1)
            
            HStack(spacing: 6) {
                Circle()
                    .fill(referenzStufe.farbe)
                    .frame(width: 8, height: 8)
                Text("\(tier.bezeichnung) · \(tier.levelRange)")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(referenzStufe.dunkelFarbe)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
            .background(referenzStufe.hellFarbe)
            .clipShape(Capsule())
            
            Rectangle()
                .fill(referenzStufe.farbe.opacity(0.3))
                .frame(height: 1)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}

// MARK: - Einzelne Pass-Zeile

struct PassZeileView: View {
    let belohnung: GartenPassBelohnung
    let aktuellerLevel: Int
    let istAbgeholt: Bool
    let onAbholen: () -> Void
    
    private var kannAbholen: Bool {
        belohnung.id <= aktuellerLevel && !istAbgeholt
    }
    private var istGesperrt: Bool {
        belohnung.id > aktuellerLevel
    }
    private var istAktuell: Bool {
        belohnung.id == aktuellerLevel && !istAbgeholt
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // Belohnungen alternieren links/rechts für Rhythmus
            let zeigeLinks = belohnung.id % 2 == 1
            
            if zeigeLinks {
                GartenPassReward3DButton(
                    belohnung: belohnung,
                    istAbgeholt: istAbgeholt,
                    istGesperrt: istGesperrt,
                    kannAbholen: kannAbholen,
                    onAbholen: onAbholen
                )
                .frame(maxWidth: .infinity)
                .padding(.leading, 16)
                .padding(.trailing, 8)
            } else {
                Spacer()
                    .frame(maxWidth: .infinity)
            }
            
            // Mittel: Spine mit Node (Line is handled globally or per section for layering)
            SpineView(
                level: belohnung.id,
                tier: belohnung.tier,
                istAktuell: istAktuell,
                istAbgeholt: istAbgeholt,
                istGesperrt: istGesperrt,
                istMeilenstein: belohnung.istMeilenstein
            )
            
            if !zeigeLinks {
                GartenPassReward3DButton(
                    belohnung: belohnung,
                    istAbgeholt: istAbgeholt,
                    istGesperrt: istGesperrt,
                    kannAbholen: kannAbholen,
                    onAbholen: onAbholen
                )
                .frame(maxWidth: .infinity)
                .padding(.leading, 8)
                .padding(.trailing, 16)
            } else {
                Spacer()
                    .frame(maxWidth: .infinity)
            }
        }
        .frame(minHeight: belohnung.istMeilenstein ? 110 : 96)
        .background(belohnung.id % 2 == 0 ? belohnung.tier.kontrastFarbe : Color(.systemBackground))
    }
}

// MARK: - Spine (vertikale Linie + Raute)

struct SpineView: View {
    let level: Int
    let tier: GartenTier
    let istAktuell: Bool
    let istAbgeholt: Bool
    let istGesperrt: Bool
    let istMeilenstein: Bool
    
    private var nodeGroesse: CGFloat { istMeilenstein ? 44 : 38 }
    
    var body: some View {
        ZStack {
            // Vertikale Linie — HINTER den Knoten
            Rectangle()
                .fill(tier.farbe.opacity(0.4))
                .frame(width: 4)
            
            // 3D-Node (Rund statt Raute)
            GartenPassNodeView(
                level: level,
                tier: tier,
                istAktuell: istAktuell,
                istAbgeholt: istAbgeholt,
                istGesperrt: istGesperrt,
                groesse: nodeGroesse
            )
        }
        .frame(width: 52)
    }
}

struct GartenPassNodeView: View {
    let level: Int
    let tier: GartenTier
    let istAktuell: Bool
    let istAbgeholt: Bool
    let istGesperrt: Bool
    let groesse: CGFloat
    
    private var schattenTiefe: CGFloat { groesse * 0.08 }
    
    var body: some View {
        ZStack {
            // 3D-Schatten (Unten)
            Circle()
                .fill(schattenFarbe)
                .frame(width: groesse, height: groesse)
                .offset(y: schattenTiefe * 0.5)
            
            // Oberfläche (Oben)
            Circle()
                .fill(oberflaechenFarbe)
                .frame(width: groesse, height: groesse)
                .offset(y: istAktuell ? -schattenTiefe : 0)
                .overlay(
                    Circle()
                        .stroke(randFarbe, lineWidth: istAktuell ? 2.5 : 1)
                        .scaleEffect(istAktuell ? 1.0 : 1.0)
                        .offset(y: istAktuell ? -schattenTiefe : 0)
                )
            
            // Inhalt
            Group {
                if istAbgeholt {
                    Image(systemName: "checkmark")
                        .font(.system(size: groesse * 0.4, weight: .bold))
                        .foregroundColor(.white)
                } else {
                    Text("\(level)")
                        .font(.system(size: groesse * 0.35, weight: .black, design: .rounded))
                        .foregroundColor(textFarbe)
                }
            }
            .offset(y: istAktuell ? -schattenTiefe : 0)
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: istAktuell)
    }
    
    private var schattenFarbe: Color {
        if istGesperrt { return tier.farbe.opacity(0.15) }
        return tier.dunkelFarbe
    }
    
    private var oberflaechenFarbe: Color {
        if istAbgeholt { return tier.farbe }
        if istGesperrt { return Color(.systemGray6) }
        if istAktuell  { return tier.farbe }
        return tier.hellFarbe
    }
    
    private var randFarbe: Color {
        if istGesperrt { return tier.farbe.opacity(0.2) }
        return tier.farbe
    }
    
    private var textFarbe: Color {
        if istAbgeholt { return .white }
        if istGesperrt { return .secondary.opacity(0.5) }
        if istAktuell  { return .white }
        return tier.dunkelFarbe
    }
}

// MARK: - Belohnungs-Karte

struct GartenPassReward3DButton: View {
    let belohnung: GartenPassBelohnung
    let istAbgeholt: Bool
    let istGesperrt: Bool
    let kannAbholen: Bool
    let onAbholen: () -> Void
    
    private var groesse: CGFloat { belohnung.istMeilenstein ? 84 : 74 }
    private var shadowDepth: CGFloat { groesse * 0.08 }
    
    /// Die Grundfarbe basierend auf Kategorie
    private var buttonFarbe: Color {
        if istGesperrt { return Color(.systemGray4) } // Inaktives Grau
        return belohnung.kategorieFarbe
    }
    
    var body: some View {
        VStack(spacing: 12) {
            Button {
                // Die Aktion wird mit einem Delay ausgeführt, damit die Animation sichtbar ist
                // Genau wie im Shop bei den 3D-Buttons.
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
                    onAbholen()
                }
            } label: {
                let info = belohnung.getDisplayInfo()
                Group {
                    if info.isAsset {
                        Image(info.icon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: groesse * 0.6, height: groesse * 0.6)
                            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                    } else {
                        Image(systemName: info.icon)
                            .font(.system(size: groesse * 0.45, weight: .black))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                    }
                }
            }
            .buttonStyle(GartenPassButtonStyle(
                farbe: buttonFarbe,
                sekundaerFarbe: buttonFarbe.darker(),
                groesse: groesse,
                istAbgeholt: istAbgeholt,
                istGesperrt: istGesperrt,
                kannAbholen: kannAbholen
            ))
            .disabled(istAbgeholt || istGesperrt)
            
            // Label
            Text(belohnung.beschriftung)
                .font(.system(size: 11, weight: .black, design: .rounded))
                .foregroundColor(istGesperrt ? .secondary.opacity(0.5) : .primary)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(kannAbholen ? Color.green.opacity(0.15) : Color.clear)
                .clipShape(Capsule())
        }
    }
}

// MARK: - Pass Button Style

struct GartenPassButtonStyle: ButtonStyle {
    let farbe: Color
    let sekundaerFarbe: Color
    let groesse: CGFloat
    let istAbgeholt: Bool
    let istGesperrt: Bool
    let kannAbholen: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        GartenPassButtonVisualView(
            configuration: configuration,
            farbe: farbe,
            sekundaerFarbe: sekundaerFarbe,
            groesse: groesse,
            istAbgeholt: istAbgeholt,
            istGesperrt: istGesperrt,
            kannAbholen: kannAbholen
        )
    }
}

private struct GartenPassButtonVisualView: View {
    let configuration: ButtonStyle.Configuration
    let farbe: Color
    let sekundaerFarbe: Color
    let groesse: CGFloat
    let istAbgeholt: Bool
    let istGesperrt: Bool
    let kannAbholen: Bool
    
    @State private var isVisualPressed = false
    
    var body: some View {
        let shadowDepth: CGFloat = groesse * 0.08
        
        ZStack {
            // Shadow / Base
            Circle()
                .fill(sekundaerFarbe)
                .offset(y: shadowDepth)
            
            // Top Layer
            Circle()
                .fill(farbe)
                .overlay {
                    configuration.label
                }
                .offset(y: isVisualPressed ? shadowDepth : 0)
        }
        .frame(width: groesse, height: groesse)
        .opacity(istGesperrt ? 0.7 : 1.0)
        .saturation(istGesperrt ? 0.2 : 1.0)
        .overlay(alignment: .bottomTrailing) {
            if istAbgeholt {
                ZStack {
                    Circle()
                        .fill(.white)
                        .frame(width: 28, height: 28)
                        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                    
                    Circle()
                        .fill(Color.green)
                        .frame(width: 24, height: 24)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .black))
                        .foregroundColor(.white)
                }
                .offset(x: 5, y: 5)
            }
        }
        .overlay(alignment: .topTrailing) {
            if istGesperrt {
                Image(systemName: "lock.fill")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .padding(6)
                    .background(Circle().fill(.black.opacity(0.4)))
                    .offset(x: 4, y: -4)
            }
        }
        .animation(.spring(response: 0.22, dampingFraction: 0.5), value: isVisualPressed)
        .onChange(of: configuration.isPressed) { oldValue, newValue in
            if newValue && kannAbholen {
                isVisualPressed = true
            } else {
                // Slight delay for release animation
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isVisualPressed = false
                }
            }
        }
        .sensoryFeedback(.impact(flexibility: .soft, intensity: 0.8), trigger: configuration.isPressed)
    }
}
