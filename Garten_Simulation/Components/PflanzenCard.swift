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
    @State private var plantWobble: CGFloat = 1.0
    @State private var greenGlowOpacity: Double = 0
    @State private var wasserPressAktiv = false
    @State private var showReviveSheet = false

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
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.7)
                    .frame(height: 38, alignment: .center)

                    Text(pflanze.seltenheit.lokalisiertTitel)
                        .font(.appBadge)
                        .foregroundStyle(pflanze.isDead ? .red : pflanze.seltenheit.farbe)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill((pflanze.isDead ? Color.red : pflanze.seltenheit.farbe).opacity(0.15))
                        )
                    
                    // MARK: Timer (24h-Countdown) & Warning (!)
                    if !pflanze.istBewässert && !pflanze.isDead {
                        HStack(spacing: 6) {
                            if pflanze.showWarning {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 14, height: 14)
                                    .foregroundStyle(.orange)
                                    .symbolEffect(.bounce, options: .repeating)
                            }

                            HStack(spacing: 4) {
                                Image(pflanze.timerIconName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 14, height: 14)
                                
                                Text("\(pflanze.remainingHoursInCycle)h")
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                    .foregroundStyle(pflanze.showWarning ? .orange : .secondary)
                            }
                        }
                        .padding(.top, 2)
                    }
                }
                .frame(maxWidth: .infinity)

                GeometryReader { geo in
                    let scale = min(geo.size.width / 160, 1.2) // Scale base 160, max 1.2
                    let baseDim: CGFloat = 100 * scale

                    ZStack {
                        // Hintergrund-Ring (grau)
                        Circle()
                            .stroke(Color.gray.opacity(0.2), lineWidth: 5 * scale)
                            .frame(width: baseDim, height: baseDim)

                        // Fortschritts-Ring (Seltenheits-Farbe)
                        Circle()
                            .trim(from: 0, to: pflanze.ringFortschritt)
                            .stroke(
                                pflanze.seltenheit.farbe,
                                style: StrokeStyle(lineWidth: 5 * scale, lineCap: .round)
                            )
                            .frame(width: baseDim, height: baseDim)
                            .rotationEffect(.degrees(-90))
                            .animation(.spring(response: 0.6), value: pflanze.ringFortschritt)

        
                        // Grüner Glow wenn frisch gegossen
                        Circle()
                            .stroke(Color.gruenPrimary.opacity(greenGlowOpacity * 0.6), lineWidth: 6 * scale)
                            .frame(width: baseDim * 1.1, height: baseDim * 1.1)
                            .blur(radius: 1.5 * scale)
                            .allowsHitTesting(false)
        
                        // Der 3D-Button (Jetzt Interaktiv!)
                        if let basePlant = GameDatabase.shared.plant(for: pflanze.plantID) {
                            PflanzenButton(
                                plant: basePlant,
                                seltenheit: pflanze.seltenheit,
                                farbe: pflanze.color,
                                sekundaerFarbe: pflanze.isDead ? .red : pflanze.color.darker(),
                                groesse: 88 * scale,
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
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(
                        Color.clear
                            .allowsHitTesting(false)
                            .onAppear { updatePflanzenPosition(from: geo) }
                            .onGeometryChange(for: CGRect.self) { proxy in
                                proxy.frame(in: .global)
                            } action: { _, newFrame in
                                pflanzenPosition = CGPoint(x: newFrame.midX, y: newFrame.midY)
                            }
                    )
                }
                .frame(height: 120)
                .padding(.vertical, 8)
                .scaleEffect(plantWobble)
                .animation(.spring(response: 0.3, dampingFraction: 0.4), value: plantWobble)

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
            wasserPressAktiv = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
            withAnimation(.spring(.snappy(duration: 0.02))) {
                wasserPressAktiv = false
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) {
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
            
            // Price or Wonder Water
            let hasWunderWasser = gardenStore.gekaufteItems.contains(where: { $0.id == "powerup.wunder_wasser" })
            if !hasWunderWasser {
                GemsIcon(wert: GameConstants.wiederbelebungsKosten)
            }
            
            Spacer()
            
            // Buttons
            VStack(spacing: 12) {
                if hasWunderWasser {
                    Button {
                        gardenStore.reviveWithWonderWater(pflanze: pflanze)
                        dismiss()
                    } label: {
                        Text("\(settings.localizedString(for: "item.wunder_wasser.name")) (Gratis)")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                    }
                    .buttonStyle(DuolingoButtonStyle(
                        backgroundColor: .blauPrimary,
                        shadowColor: Color.blauPrimary.darker(),
                        foregroundColor: .white
                    ))
                } else {
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
                }

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
