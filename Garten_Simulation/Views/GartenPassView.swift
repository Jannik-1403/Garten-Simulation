import SwiftUI

struct GartenPassView: View {
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var settings: SettingsStore
    @Environment(\.dismiss) var dismiss
    
    @State private var zeigeWheelSheet = false
    @State private var zeigePowerUpWheel = false
    @State private var claimedReward: GartenPassBelohnung? = nil
    @State private var pflanzeAuswahlBelohnung: GartenPassBelohnung? = nil
    @State private var pendingGluecksradBelohnung: GartenPassBelohnung? = nil
    
    @EnvironmentObject var gartenPfadStore: GartenPfadStore
    @EnvironmentObject var powerUpStore: PowerUpStore
    
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
    
    private var fortschrittInLevel: Double {
        let xpImLevel = GartenLevel.xpImLevel(gesamtXP: gardenStore.gesamtXP)
        let xpZiel = GartenLevel.xpFuerNaechstenLevel(gesamtXP: gardenStore.gesamtXP)
        return xpZiel > 0 ? min(Double(xpImLevel) / Double(xpZiel), 1.0) : 1.0
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
                        ForEach(gruppiertNachTier, id: \.tier.bezeichnungKey) { gruppe in
                            TierSektionView(
                                tier: gruppe.tier,
                                belohnungen: gruppe.belohnungen,
                                aktuellerLevel: aktuellerLevel,
                                fortschritt: fortschrittInLevel,
                                abgeholte: gardenStore.abgeholtePassLevel,
                                onAbholen: { belohnung in
                                    if case .pflanze = belohnung.typ {
                                        // Level wird ERST in onWahl als abgeholt markiert!
                                        pflanzeAuswahlBelohnung = belohnung
                                    } else if case .gluecksradDrehung = belohnung.typ {
                                        // Level wird ERST beim Spin als abgeholt markiert!
                                        pendingGluecksradBelohnung = belohnung
                                    } else {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            gardenStore.abgeholtePassLevel.insert(belohnung.id)
                                            gartenPfadStore.belohnungGutschreiben(belohnung, gardenStore: gardenStore, powerUpStore: powerUpStore)
                                        }
                                        claimedReward = belohnung
                                    }
                                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                }
                            )
                        }
                        
                        // Master Abschluss-Icon ganz unten
                        MasterEndCapView(aktuellerLevel: aktuellerLevel)
                        
                        Spacer(minLength: 40)
                    }
                }
                .background(Color(.systemBackground).ignoresSafeArea())
                .onAppear {
                    // Zum aktuellen Level scrollen
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation {
                            proxy.scrollTo("level_\(aktuellerLevel)", anchor: .center)
                        }
                    }
                }
            }
            .navigationTitle(settings.localizedString(for: "pass_titel"))
            .navigationBarTitleDisplayMode(.inline)
            .fullScreenCover(isPresented: $zeigeWheelSheet) {
                GartenPassWheelView()
                    .environmentObject(gartenPfadStore)
                    .environmentObject(gardenStore)
            }
            .fullScreenCover(isPresented: $zeigePowerUpWheel) {
                GartenPassPowerUpWheelView(onRewardClaimed: { puReward in
                    // No automatic popper here, as the wheel has its own result screen
                })
                .environmentObject(gartenPfadStore)
                .environmentObject(gardenStore)
                .environmentObject(powerUpStore)
            }
            .overlay {
                if let reward = claimedReward {
                    GartenPassRewardOverlay(
                        belohnung: reward,
                        onDismiss: {
                            claimedReward = nil
                            
                            // Feature 2: Wenn es eine Drehung war -> Wheel öffnen
                            if case .gluecksradDrehung = reward.typ {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                                    zeigeWheelSheet = true
                                }
                            }
                        }
                    )
                }
            }
            .fullScreenCover(item: $pendingGluecksradBelohnung) { belohnung in
                if case .gluecksradDrehung(let n) = belohnung.typ {
                    GartenPassWheelView(
                        pendingSpins: n,
                        onSpinStarted: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                _ = gardenStore.abgeholtePassLevel.insert(belohnung.id)
                            }
                        }
                    )
                    .environmentObject(gartenPfadStore)
                    .environmentObject(gardenStore)
                    .environmentObject(settings)
                }
            }
            .sheet(item: $pflanzeAuswahlBelohnung) { belohnung in
                PflanzeOderAlternativeView(
                    pflanzeBelohnung: belohnung,
                    onWahl: { gewaehlte in
                        // Erst HIER wird der Node als gesammelt markiert
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            _ = gardenStore.abgeholtePassLevel.insert(belohnung.id)
                        }
                        
                        if case .powerUp(let id) = gewaehlte.typ, id == "random" {
                            // SONDERFALL: Power-Up Wheel öffnen
                            pflanzeAuswahlBelohnung = nil
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                zeigePowerUpWheel = true
                            }
                        } else {
                            // NORMALFALL: Direkt einlösen und Popper zeigen
                            gartenPfadStore.belohnungGutschreiben(gewaehlte, gardenStore: gardenStore, powerUpStore: powerUpStore)
                            pflanzeAuswahlBelohnung = nil
                            
                            // Zeige den "Popo" (Overlay) nach der Auswahl
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                claimedReward = gewaehlte
                            }
                            
                            // Falls es eine Drehung war, wird nach dem Overlay das Wheel geöffnet (siehe Overlay onDismiss)
                        }
                    }
                )
                .environmentObject(gardenStore)
                .environmentObject(gartenPfadStore)
            }
        }
    }
}

// MARK: - Header

struct PassHeaderView: View {
    @EnvironmentObject var settings: SettingsStore
    let aktuellerLevel: Int
    let gesamtXP: Int
    
    private var tierAktuell: GartenTier {
        GartenPassBelohnung.alle.first { $0.id == aktuellerLevel }?.tier ?? .bronze
    }
    
    private var aktuellesLevel: Int { GartenLevel.level(fuerXP: gesamtXP) }
    private var xpZielKumuliert: Int { GameConstants.xpFuerLevel(aktuellesLevel + 1) }
    private var fortschritt: Double {
        xpZielKumuliert > 0 ? min(Double(gesamtXP) / Double(xpZielKumuliert), 1.0) : 1.0
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                // Tier-Badge
                HStack(spacing: 6) {
                    Image("Achievment_Gold")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 14, height: 14)
                        .applyErfolgFarbe(for: tierAktuell.asErfolgTier)
                    Text(settings.localizedString(for: tierAktuell.bezeichnungKey))
                        .font(.caption.weight(.bold))
                        .foregroundColor(tierAktuell.dunkelFarbe)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(tierAktuell.hellFarbe)
                .clipShape(Capsule())
                
                Text(String(format: settings.localizedString(for: "pass_level_label"), aktuellerLevel))
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(gesamtXP) / \(xpZielKumuliert) \(settings.localizedString(for: "pass.xp"))")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
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
                Text(String(format: settings.localizedString(for: "pass_naechstes_tier_hint"),
                            naechstesTierName()))
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
                .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 4)
        )
        .padding(.horizontal, 16)
        .padding(.top, 16)
    }
    
    private func naechstesTierName() -> String {
        switch aktuellerLevel {
        case ..<10: return String(format: settings.localizedString(for: "pass.next_tier_level"), settings.localizedString(for: GartenTier.silber.bezeichnungKey), 11)
        case ..<25: return String(format: settings.localizedString(for: "pass.next_tier_level"), settings.localizedString(for: GartenTier.gold.bezeichnungKey), 26)
        case ..<40: return String(format: settings.localizedString(for: "pass.next_tier_level"), settings.localizedString(for: GartenTier.diamant.bezeichnungKey), 41)
        default:    return ""
        }
    }
}

// MARK: - Tier Sektion

struct TierSektionView: View {
    @EnvironmentObject var settings: SettingsStore
    let tier: GartenTier
    let belohnungen: [GartenPassBelohnung]
    let aktuellerLevel: Int
    let fortschritt: Double
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
                    fortschritt: fortschritt,
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
    @EnvironmentObject var settings: SettingsStore
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
        HStack {
            Spacer()
            
            HStack(spacing: 8) {
                Image("Achievment_Gold")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                    .applyErfolgFarbe(for: tier.asErfolgTier)
                
                Text("\(settings.localizedString(for: tier.bezeichnungKey).uppercased()) · \(tier.levelRange(settings: settings))")
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .foregroundColor(referenzStufe.dunkelFarbe)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(Color(.systemBackground))
            )
            .overlay(
                Capsule()
                    .stroke(tier.farbe.opacity(0.35), lineWidth: 1.5)
            )
            .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
            
            Spacer()
        }
        .padding(.vertical, 20)
    }
}

// MARK: - Einzelne Pass-Zeile

struct PassZeileView: View {
    @EnvironmentObject var settings: SettingsStore
    let belohnung: GartenPassBelohnung
    let aktuellerLevel: Int
    let fortschritt: Double
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
                istMeilenstein: belohnung.istMeilenstein,
                aktuellerLevel: aktuellerLevel,
                fortschritt: fortschritt
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
        .background(Color.clear)
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
    let aktuellerLevel: Int
    let fortschritt: Double
    
    private var nodeGroesse: CGFloat { istMeilenstein ? 44 : 38 }
    
    var body: some View {
        GeometryReader { geo in
            let rowHeight = geo.size.height
            
            ZStack {
                // Einzelne durchgehende vertikale Linie über die gesamte Zeilenhöhe
                ZStack(alignment: .top) {
                    Rectangle()
                        .fill(Color(.systemGray4))
                        .frame(width: 4)
                    
                    Rectangle()
                        .fill(tier.farbe)
                        .frame(width: 4, height: rowHeight * aktivierterAnteil())
                }
                
                // 3D-Node (Rund statt Raute), exakt vertikal zentriert
                GartenPassNodeView(
                    level: level,
                    tier: tier,
                    istAktuell: istAktuell,
                    istAbgeholt: istAbgeholt,
                    istGesperrt: istGesperrt,
                    groesse: nodeGroesse
                )
                .position(x: geo.size.width / 2, y: geo.size.height / 2)
            }
        }
        .frame(width: 52)
    }
    
    /// Berechnet den aktiven Anteil der gesamten Linie in diesem Level-Abschnitt (von 0.0 bis 1.0)
    private func aktivierterAnteil() -> CGFloat {
        if level < aktuellerLevel {
            return 1.0
        } else if level == aktuellerLevel {
            return CGFloat(fortschritt)
        } else {
            return 0.0
        }
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
    
    @State private var auraScale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            // Pulsierender Ring für das aktive Level (Duolingo-Style)
            if istAktuell {
                Circle()
                    .stroke(tier.farbe.opacity(0.35), lineWidth: 3)
                    .frame(width: groesse + 8, height: groesse + 8)
                    .scaleEffect(auraScale)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                            auraScale = 1.15
                        }
                    }
            }
            
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
        if istGesperrt { return Color(.systemGray4) }
        return tier.dunkelFarbe
    }
    
    private var oberflaechenFarbe: Color {
        if istGesperrt { return Color(.systemGray5) }
        return tier.farbe
    }
    
    private var randFarbe: Color {
        if istGesperrt { return Color(.systemGray4) }
        return tier.dunkelFarbe.opacity(0.25)
    }
    
    private var textFarbe: Color {
        if istGesperrt { return .secondary.opacity(0.6) }
        return .white
    }
}

// MARK: - Belohnungs-Karte

struct GartenPassReward3DButton: View {
    @EnvironmentObject var settings: SettingsStore
    let belohnung: GartenPassBelohnung
    let istAbgeholt: Bool
    let istGesperrt: Bool
    let kannAbholen: Bool
    let onAbholen: () -> Void
    
    private var groesse: CGFloat { belohnung.istMeilenstein ? 84 : 74 }
    private var shadowDepth: CGFloat { groesse * 0.08 }
    
    @State private var pulseScale: CGFloat = 1.0
    
    /// Die Grundfarbe basierend auf Kategorie
    private var buttonFarbe: Color {
        if istGesperrt { return Color(hex: "#E5E5EA") } // Grauer Hintergrund
        return belohnung.kategorieFarbe
    }

    private var buttonSekundaerFarbe: Color {
        if istGesperrt { return Color(hex: "#C7C7CC") } // Grauer Schatten
        return belohnung.kategorieFarbe.darker()
    }
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                // Aura-Glow für abholbare Belohnungen
                if kannAbholen {
                    Circle()
                        .fill(belohnung.kategorieFarbe.opacity(0.25))
                        .frame(width: groesse + 14, height: groesse + 14)
                        .blur(radius: 6)
                        .scaleEffect(pulseScale)
                }
                
                Button {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
                        onAbholen()
                    }
                } label: {
                    let info = belohnung.getDisplayInfo(settings: settings)
                    Group {
                        if case .pflanze(let id) = belohnung.typ, 
                           let pl = GameDatabase.shared.plant(for: id) {
                            PlantIconView(plant: pl, seltenheit: .bronze, size: groesse * 0.6, alwaysShowFullGrown: true)
                                .grayscale(istGesperrt ? 1.0 : 0.0)
                                .opacity(istGesperrt ? 0.5 : 1.0)
                        } else if info.isAsset {
                            Image(info.icon)
                                .resizable()
                                .scaledToFit()
                                .frame(width: groesse * 0.6, height: groesse * 0.6)
                                .grayscale(istGesperrt ? 1.0 : 0.0)
                                .opacity(istGesperrt ? 0.5 : 1.0)
                                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                        } else {
                            Image(systemName: info.icon)
                                .font(.system(size: groesse * 0.45, weight: .black))
                                .foregroundColor(istGesperrt ? Color(hex: "#AEAEB2") : .white)
                                .shadow(color: .black.opacity(istGesperrt ? 0 : 0.1), radius: 2, x: 0, y: 1)
                        }
                    }
                }
                .buttonStyle(GartenPassButtonStyle(
                    farbe: buttonFarbe,
                    sekundaerFarbe: buttonSekundaerFarbe,
                    groesse: groesse,
                    istAbgeholt: istAbgeholt,
                    istGesperrt: istGesperrt,
                    kannAbholen: kannAbholen
                ))
                .disabled(istAbgeholt || istGesperrt)
                .scaleEffect(kannAbholen ? pulseScale : 1.0)
            }
            .onAppear {
                if kannAbholen {
                    withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                        pulseScale = 1.06
                    }
                }
            }
            
            // Label
            Text(belohnung.beschriftung(settings: settings))
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
        // Keine Opacity oder Saturation mehr, das wird direkt über die grauen Farben geregelt
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

extension GartenTier {
    var asErfolgTier: ErfolgTier {
        switch self {
        case .bronze: return .bronze
        case .silber: return .silber
        case .gold: return .gold
        case .diamant: return .diamant
        }
    }
}

// MARK: - Master End Cap
struct MasterEndCapView: View {
    @EnvironmentObject var settings: SettingsStore
    let aktuellerLevel: Int
    
    private var istPassFertig: Bool {
        aktuellerLevel >= 50
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Image("Achievment_Rot")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .applyErfolgFarbe(for: .master)
                .grayscale(istPassFertig ? 0.0 : 1.0)
                .opacity(istPassFertig ? 1.0 : 0.4)
                .shadow(color: istPassFertig ? Color(hex: "#FF3B30").opacity(0.4) : .clear, radius: 15, x: 0, y: 8)
            
            Text(settings.localizedString(for: "tier_stufe_master_1").uppercased())
                .font(.system(size: 20, weight: .black, design: .rounded))
                .foregroundColor(istPassFertig ? Color(hex: "#FF3B30") : .secondary.opacity(0.5))
        }
        .padding(.top, 10)
        .padding(.bottom, 40)
    }
}
