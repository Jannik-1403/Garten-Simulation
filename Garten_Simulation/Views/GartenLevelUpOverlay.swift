import SwiftUI

struct GartenLevelUpOverlay: View {
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var settings: SettingsStore
    
    let neuerLevel: Int
    let freischaltungen: [GartenLevelFreischaltung]
    let onDismiss: () -> Void
    let onGluecksradDrehen: (() -> Void)?   // Optionaler Callback, um direkt zum Glücksrad zu springen
    
    @State private var zeigeInhalt = false
    @State private var karteOffset: CGFloat = 60
    @AppStorage("isHapticEnabled") var isHapticEnabled: Bool = true
    
    private var hatSpinFreischaltung: Bool {
        freischaltungen.contains {
            if case .gluecksradDrehung = $0.typ { return true }
            return false
        }
    }
    
    private var spinAnzahl: Int {
        freischaltungen.compactMap {
            if case .gluecksradDrehung(let n) = $0.typ { return n }
            return nil
        }.reduce(0, +)
    }
    
    var body: some View {
        ZStack {
            // Hintergrund-Dimmer
            Color.black.opacity(0.8)
                .ignoresSafeArea()
                .onTapGesture { } // Kein versehentliches Schließen durch Tippen daneben
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    
                    // Level-Badge Animation
                    ZStack {
                        Circle()
                            .fill(Color.goldPrimary)
                            .frame(width: 100, height: 100)
                            .shadow(color: Color.goldPrimary.opacity(0.6), radius: 25)
                        
                        VStack(spacing: 0) {
                            Text(settings.localizedString(for: "level_up_label"))
                                .font(.system(size: 12, weight: .black, design: .rounded))
                                .foregroundColor(.white.opacity(0.9))
                            Text("\(neuerLevel)")
                                .font(.system(size: 42, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.top, 60)
                    .scaleEffect(zeigeInhalt ? 1.1 : 0.5)
                    .opacity(zeigeInhalt ? 1 : 0)
                    
                    Text(settings.localizedString(for: "level_up_garten_titel"))
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.top, 24)
                        .opacity(zeigeInhalt ? 1 : 0)
                        .multilineTextAlignment(.center)
                    
                    // Freischaltungs-Karten
                    if !freischaltungen.isEmpty {
                        VStack(spacing: 12) {
                            Text(settings.localizedString(for: "level_up_freigeschaltet").uppercased())
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundColor(.white.opacity(0.6))
                                .tracking(1.2)
                                .padding(.top, 32)
                            
                            ForEach(freischaltungen.filter {
                                // Glücksrad separat anzeigen via Banner
                                if case .gluecksradDrehung = $0.typ { return false }
                                return true
                            }) { freischaltung in
                                GartenFreischaltungKarte(freischaltung: freischaltung)
                                    .environmentObject(settings)
                            }
                        }
                        .padding(.horizontal, 24)
                        .offset(y: karteOffset)
                        .opacity(zeigeInhalt ? 1 : 0)
                    }
                    
                    // Glücksrad-Banner (wenn verdient)
                    if hatSpinFreischaltung {
                        GluecksradVerdientBanner(anzahl: spinAnzahl)
                            .environmentObject(settings)
                            .padding(.horizontal, 24)
                            .padding(.top, 16)
                            .offset(y: karteOffset)
                            .opacity(zeigeInhalt ? 1 : 0)
                    }
                    
                    // Buttons
                    VStack(spacing: 14) {
                        if hatSpinFreischaltung, let onDrehen = onGluecksradDrehen {
                            Button {
                                playTap()
                                onDismiss()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    onDrehen()
                                }
                            } label: {
                                Label(
                                    settings.localizedString(for: "level_up_jetzt_drehen"),
                                    systemImage: "arrow.2.circlepath"
                                )
                            }
                            .buttonStyle(DuolingoButtonStyle(size: .large, backgroundColor: Color.goldPrimary, shadowColor: Color.goldPrimary.darker()))
                            .padding(.horizontal, 24)
                        }
                        
                        Button {
                            playTap()
                            onDismiss()
                        } label: {
                            Text(settings.localizedString(for: "level_up_weiter"))
                        }
                        .buttonStyle(DuolingoButtonStyle(size: hatSpinFreischaltung ? .medium : .large, backgroundColor: Color.blauPrimary, shadowColor: Color.blauSecondary))
                        .padding(.horizontal, 24)
                    }
                    .padding(.top, 40)
                    .padding(.bottom, 60)
                    .opacity(zeigeInhalt ? 1 : 0)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .onAppear {
            if isHapticEnabled {
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            }
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                zeigeInhalt = true
                karteOffset = 0
            }
        }
    }
    
    private func playTap() {
        if isHapticEnabled {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
    }
}

// MARK: - Freischaltungs-Karte

struct GartenFreischaltungKarte: View {
    @EnvironmentObject var settings: SettingsStore
    let freischaltung: GartenLevelFreischaltung
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(iconFarbe.opacity(0.15))
                    .frame(width: 48, height: 48)
                Image(systemName: freischaltung.symbolName)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(iconFarbe)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(settings.localizedString(for: freischaltung.titel))
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text(settings.localizedString(for: freischaltung.beschreibung))
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.gruenPrimary)
                .font(.title3)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                )
        )
    }
    
    private var iconFarbe: Color {
        switch freischaltung.typ {
        case .gluecksradDrehung: return .orange
        case .coinBonus:         return Color.goldPrimary
        case .pflanze:           return .green
        case .powerUp:           return .blauPrimary
        case .dekoration:        return .purple
        case .neuePflanzenkategorie: return .teal
        case .titelMeisterGaertner, .gartenSkin: return Color.goldPrimary
        }
    }
}

// MARK: - Glücksrad-Banner

struct GluecksradVerdientBanner: View {
    @EnvironmentObject var settings: SettingsStore
    let anzahl: Int
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.2))
                    .frame(width: 52, height: 52)
                Image(systemName: "arrow.2.circlepath")
                    .font(.system(size: 24, weight: .black))
                    .foregroundColor(.orange)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(String(format: settings.localizedString(for: "level_up_spin_verdient_titel"), anzahl))
                    .font(.system(size: 17, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                Text(settings.localizedString(for: "level_up_spin_verdient_desc"))
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            Text("+\(anzahl)")
                .font(.system(size: 22, weight: .black, design: .rounded))
                .foregroundColor(.orange)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.orange.opacity(0.12))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.orange.opacity(0.4), lineWidth: 2)
                )
        )
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        GartenLevelUpOverlay(
            neuerLevel: 5,
            freischaltungen: GartenLevel.freischaltungenFuer(level: 5),
            onDismiss: {},
            onGluecksradDrehen: {}
        )
        .environmentObject(GardenStore())
        .environmentObject(SettingsStore())
    }
}
