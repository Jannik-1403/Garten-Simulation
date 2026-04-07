import SwiftUI

struct PflanzenCard: View {
    @ObservedObject var pflanze: HabitModel
    let wetterEvent: WetterEvent
    let onGiessen: () -> Void
    let onTap: () -> Void

    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var powerUpStore: PowerUpStore
    @AppStorage("isHapticEnabled") private var isHapticEnabled: Bool = true
    @State private var pflanzenPosition: CGPoint = .zero
    @State private var giessAnimation = false
    @State private var plantWobble: CGFloat = 1.0
    @State private var greenGlowOpacity: Double = 0
    @State private var wasserPressAktiv = false
    @State private var showReviveSheet = false
    @State private var ausgewaehlterEffekt: PflanzenEffekt? = nil
    
    private var activeStateID: String {
        "\(pflanze.id)-\(pflanze.wiederbelebtAm?.description ?? "none")"
    }

    private var aktiveEffekte: [PflanzenEffekt] {
        var effekte: [PflanzenEffekt] = []

        // 1. Status-Effekte (Wichtigste Prio: z.B. Erholung nach Wiederbelebung)
        if pflanze.isPenaltyActive {
            let expiration = pflanze.wiederbelebtAm?.addingTimeInterval(Double(pflanze.strafTage) * 24 * 3600)
            effekte.append(PflanzenEffekt(
                id: UUID(uuidString: "77777777-7777-7777-7777-000000000001")!, // Stabile ID für den Status-Botton
                typ: .status,
                ikonQuelle: .system("tortoise.fill"),
                titel: NSLocalizedString("effekt.erholung.titel", comment: ""),
                beschreibung: NSLocalizedString("effekt.erholung.beschreibung", comment: ""),
                expiresAt: expiration
            ))
        }

        // 2. Wetter (aus dem Property, wird von GartenView durchgereicht)
        let endOfDay = Calendar.current.startOfDay(for: Date().addingTimeInterval(86400))
        effekte.append(PflanzenEffekt(
            id: UUID(),
            typ: .wetter,
            ikonQuelle: .system(wetterEvent.systemIcon),
            titel: wetterEvent.titel,
            beschreibung: wetterEvent.untertitel,
            expiresAt: endOfDay
        ))

        // 3. Power-Ups (aus gardenStore, da hier die Quelle der Wahrheit liegt)
        for aktiv in gardenStore.activePowerUps where aktiv.isActive {
            // Global oder gezielt auf diese Pflanze
            if aktiv.targetPlantId == nil || aktiv.targetPlantId == pflanze.id {
                if let base = GameDatabase.allPowerUps.first(where: { $0.id == aktiv.powerUpId }) {
                    effekte.append(PflanzenEffekt(
                        id: UUID(),
                        typ: .powerUp,
                        ikonQuelle: .asset(base.symbolName),
                        titel: NSLocalizedString(base.name, comment: ""),
                        beschreibung: NSLocalizedString(base.description, comment: ""),
                        expiresAt: aktiv.expiresAt
                    ))
                }
            }
        }

        return Array(effekte)
    }

    var body: some View {
        ZStack {
            // MARK: - Layer 0: Visual Card Background (3D Button)
            Button {
                if pflanze.isDead {
                    showReviveSheet = true
                } else {
                    onTap()
                }
            } label: {
                // Invisible rectangle to define the button's shape/size
                Rectangle().fill(Color.clear)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 280)
            }
            .buttonStyle(PflanzenCardButtonStyle(
                seltenheitFarbe: pflanze.isDead ? .red : pflanze.seltenheit.farbe,
                isDead: pflanze.isDead,
                isPhase2: false
            ))
            
            // MARK: - Layer 1: Interactive Card Content
            VStack(spacing: 14) {
                // MARK: Name + Seltenheit
                VStack(spacing: 6) {
                    Text(settings.showHabitInsteadOfName 
                     ? settings.localizedString(for: pflanze.habitName)
                     : settings.localizedString(for: pflanze.name))
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .foregroundStyle(Color.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                    Text(pflanze.seltenheit.lokalisiertTitel)
                        .font(.appBadge)
                        .foregroundStyle(pflanze.isDead ? .red : pflanze.seltenheit.farbe)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill((pflanze.isDead ? Color.red : pflanze.seltenheit.farbe).opacity(0.15))
                        )
                    
                    // MARK: Timer (24h-Countdown)
                    HStack(spacing: 4) {
                        Image(pflanze.timerIconName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 14, height: 14)
                        
                        Text("\(pflanze.remainingHoursInCycle)h")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 2)
                }
                .frame(maxWidth: .infinity)
                .overlay(alignment: .topLeading) {
                    if !aktiveEffekte.isEmpty {
                        VStack(spacing: 3) {
                            ForEach(aktiveEffekte) { effekt in
                                EffektIkonButton(effekt: effekt) {
                                    ausgewaehlterEffekt = effekt
                                }
                            }
                        }
                        .offset(x: -8, y: 16) // Angepasst für Header-Level
                        .id(activeStateID)
                    }
                }

                // MARK: 3D Pflanzen-Button + Progress-Ring
                ZStack {
                    // Hintergrund-Ring (grau)
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 5)
                        .frame(width: 100, height: 100)

                    // Fortschritts-Ring (Seltenheits-Farbe)
                    Circle()
                        .trim(from: 0, to: pflanze.ringFortschritt)
                        .stroke(
                            pflanze.seltenheit.farbe,
                            style: StrokeStyle(lineWidth: 5, lineCap: .round)
                        )
                        .frame(width: 100, height: 100)
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(response: 0.6), value: pflanze.ringFortschritt)

                    // Hintergrund-Kreise
                    Circle()
                        .fill(pflanze.isDead ? Color.red.opacity(0.1) : Color.gruenPrimary.opacity(0.12))
                        .frame(width: 104, height: 104)
    
                    Circle()
                        .fill(pflanze.isDead ? Color.red.opacity(0.1) : Color.gruenPrimary.opacity(0.08))
                        .frame(width: 118, height: 118)
    
                    // Wasser-Wellen (falls gegossen wird)
                    Circle()
                        .fill(Color.blue.opacity(0.3))
                        .frame(width: giessAnimation ? 120 : 0, height: giessAnimation ? 120 : 0)
                        .opacity(giessAnimation ? 0.7 : 0)
                        .animation(.easeOut(duration: 0.65), value: giessAnimation)
                        .allowsHitTesting(false)
    
                    // Grüner Glow wenn frisch gegossen
                    Circle()
                        .stroke(Color.gruenPrimary.opacity(greenGlowOpacity * 0.6), lineWidth: 6)
                        .frame(width: 110, height: 110)
                        .blur(radius: 1.5)
                        .allowsHitTesting(false)
    
                    // Der 3D-Button (Jetzt Interaktiv!)
                    if let basePlant = GameDatabase.shared.plant(for: pflanze.plantID) {
                        PflanzenButton(
                            plant: basePlant,
                            seltenheit: pflanze.seltenheit,
                            farbe: pflanze.color,
                            sekundaerFarbe: pflanze.isDead ? .red : pflanze.color.darker(),
                            groesse: 88,
                            externerPress: wasserPressAktiv,
                            aktion: {
                                if pflanze.isDead {
                                    showReviveSheet = true
                                    FeedbackManager.shared.playTap()
                                } else {
                                    FeedbackManager.shared.playTap()
                                    onTap()
                                }
                            }
                        )
                        .grayscale(pflanze.isDead ? 1.0 : 0.0)
                        .opacity(pflanze.isDead ? 0.8 : 1.0)
                    }
                }
                .padding(.vertical, 8)
                .scaleEffect(plantWobble)
                .animation(.spring(response: 0.3, dampingFraction: 0.4), value: plantWobble)
                .background(
                    GeometryReader { geo in
                        Color.clear
                            .allowsHitTesting(false)
                            .onAppear { updatePflanzenPosition(from: geo) }
                            .onGeometryChange(for: CGRect.self) { proxy in
                                proxy.frame(in: .global)
                            } action: { _, newFrame in
                                pflanzenPosition = CGPoint(x: newFrame.midX, y: newFrame.midY)
                            }
                    }
                )

                // MARK: Gieß-Slider, Erledigt-Badge oder Löschen-Button
                Group {
                    if pflanze.isDead {
                        VStack(spacing: 2) {
                            Text(settings.localizedString(for: "pflanze.tot.titel"))
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundStyle(.red)
                            Text(String(format: settings.localizedString(for: "pflanze.tot.seit"), pflanze.missedCycles))
                                .font(.system(size: 12, weight: .regular, design: .rounded))
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 72)
                    } else if !pflanze.istBewässert {
                        DragToWater(
                            onGiessen: { handleWatering() },
                            pflanzenPosition: pflanzenPosition,
                            istErledigt: pflanze.istBewässert
                        )
                        .allowsHitTesting(true)
                        .frame(height: 72)
                    } else {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundStyle(Color.gruenPrimary)
                            
                            Text(settings.localizedString(for: "garden.plant.done"))
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.gruenPrimary)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 72)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity, alignment: .center)
            .allowsHitTesting(true) // Crucial: enable touches for subviews
            .overlay(alignment: .topLeading) {
                VStack(alignment: .leading, spacing: 8) {
                    // Aktive Power-Ups Badge
                    let plantPowerUps = gardenStore.plantSpecificActivePowerUps(plantId: pflanze.id)
                    if !plantPowerUps.isEmpty {
                        PowerUpBadge(count: plantPowerUps.count)
                    }
                }
                .padding(12)
            }
            .overlay {
                if pflanze.isDead {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(.red, lineWidth: 2)
                        .allowsHitTesting(false)
                }
            }
            .sheet(isPresented: $showReviveSheet) {
                RevivePlantSheet(pflanze: pflanze)
                    .presentationDetents([.medium])
            }
            .sheet(item: $ausgewaehlterEffekt) { effekt in
                EffektDetailSheet(effekt: effekt)
                    .presentationDetents([.fraction(0.38)])
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadius(28)
            }
        }
    }

    // MARK: - Gieß Animation
    private func handleWatering() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.4)) {
            plantWobble = 1.15
            greenGlowOpacity = 1.0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.4)) {
                plantWobble = 1.0
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.48) {
            withAnimation(.easeOut(duration: 0.35)) {
                greenGlowOpacity = 0
            }
        }
        withAnimation {
            giessAnimation = true
            wasserPressAktiv = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
            withAnimation(.spring(.snappy(duration: 0.02))) {
                wasserPressAktiv = false
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) {
            giessAnimation = false
            FeedbackManager.shared.playWatering()
            onGiessen()
        }
    }

    private func updatePflanzenPosition(from geo: GeometryProxy) {
        let frame = geo.frame(in: .global)
        pflanzenPosition = CGPoint(x: frame.midX, y: frame.midY)
    }
}

// MARK: - Button Style für die gesamte Karte
struct PflanzenCardButtonStyle: ButtonStyle {
    @AppStorage("isHapticEnabled") var isHapticEnabled: Bool = true
    let seltenheitFarbe: Color
    let isDead: Bool
    let isPhase2: Bool
    private let depth: CGFloat = 8
    private let cornerRadius: CGFloat = 24

    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed
        let baseColor = isDead ? Color.red : (isPhase2 ? Color.orange : seltenheitFarbe)

        ZStack(alignment: .top) {
            configuration.label
                .hidden()
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(baseColor)
                )
                .offset(y: depth)

            configuration.label
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(Color.black.opacity(0.12), lineWidth: 1)
                )
                .offset(y: isPressed ? depth : 0)
        }
        .animation(isPressed ? nil : .spring(response: 0.15, dampingFraction: 0.6), value: isPressed)
        .onChange(of: isPressed) {
            if isPressed {
                FeedbackManager.shared.playTap()
            }
        }
    }
}

// MARK: - PowerUpBadge
struct PowerUpBadge: View {
    let count: Int
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.yellow)
                .frame(width: 26, height: 26)
                .shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 1)
            
            Image("Powerup")
                .resizable()
                .scaledToFit()
                .frame(width: 14, height: 14)
        }
    }
}

// MARK: - RevivePlantSheet
struct RevivePlantSheet: View {
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var settings: SettingsStore
    @Environment(\.dismiss) var dismiss
    let pflanze: HabitModel
    
    var body: some View {
        VStack(spacing: 24) {
            // Icon
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.gruenPrimary.opacity(0.1))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "cross.circle.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(Color.gruenPrimary)
                }
                
                Text(settings.localizedString(for: "pflanze.wiederbeleben.titel"))
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 20)
            
            // Description
            Text(String(format: settings.localizedString(for: "pflanze.wiederbeleben.beschreibung"), pflanze.missedCycles))
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
            
            // Price
            GemsIcon(wert: GameConstants.wiederbelebungsKosten)
            
            Spacer()
            
            // Buttons
            VStack(spacing: 12) {
                Button {
                    gardenStore.revive(pflanze: pflanze)
                    dismiss()
                } label: {
                    Text(settings.localizedString(for: "pflanze.wiederbeleben.button"))
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                }
                .buttonStyle(DuolingoButtonStyle(
                    backgroundColor: .gruenPrimary,
                    shadowColor: Color.gruenPrimary.darker(),
                    foregroundColor: .white
                ))
                .disabled(gardenStore.coins < GameConstants.wiederbelebungsKosten)
                

                Button(role: .destructive) {
                    gardenStore.loeschePflanze(pflanze: pflanze)
                    dismiss()
                } label: {
                    Text(settings.localizedString(for: "button.delete"))
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.red)
                        .padding(.vertical, 8)
                }
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 32)
        }
        .padding()
        .background(Color.appHintergrund)
    }
}

#Preview {
    HStack(spacing: 16) {
        PflanzenCard(
            pflanze: HabitModel(id: "1", name: "Gym", symbolName: "figure.run", symbolColor: "orange", habitCategories: [.fitness]),
            wetterEvent: .normal,
            onGiessen: {},
            onTap: {}
        )
        PflanzenCard(
            pflanze: {
                let p = HabitModel(id: "2", name: "Lesen", symbolName: "book.fill", symbolColor: "blue", habitCategories: [.growth])
                p.currentXP = 200
                p.istBewässert = true
                return p
            }(),
            wetterEvent: .normal,
            onGiessen: {},
            onTap: {}
        )
    }
    .padding()
    .background(Color.appHintergrund)
}
