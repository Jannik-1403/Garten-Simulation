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
    @State private var showDeathAlert = false

    var body: some View {
        ZStack {
            // MARK: Die eigentliche Karte (Button)
            Button {
                // Delay to allow the 3D "pop-back" animation to complete
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                    onTap()
                }
            } label: {
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

                        // Gieß-Wasser-Animation
                        Circle()
                            .fill(Color.cyan.opacity(0.35))
                            .frame(width: 130, height: 130)
                            .scaleEffect(giessAnimation ? 1.5 : 1.0)
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
                        PflanzenButton(
                            symbolName: pflanze.symbolName,
                            farbe: pflanze.color,
                            sekundaerFarbe: pflanze.isDead ? .red : pflanze.color.darker(),
                            groesse: 88,
                            externerPress: wasserPressAktiv,
                            aktion: {
                                if pflanze.isDead {
                                    showDeathAlert = true
                                    FeedbackManager.shared.playError()
                                } else {
                                    FeedbackManager.shared.playTap()
                                    onTap()
                                }
                            }
                        )
                        .saturation(pflanze.isDead ? 0.3 : pflanze.drynessSaturation)
                        .colorMultiply(pflanze.isDead ? Color.red.opacity(0.8) : Color.white)
                        .opacity(pflanze.isDead ? 0.8 : 1.0)
                        
                        if pflanze.missedCycles > 0 {
                            Text(pflanze.missedCycles == 1 ? "!" : "!!")
                                .font(.system(size: 16, weight: .black, design: .rounded))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Capsule().fill(Color.red))
                                .shadow(radius: 2)
                                .offset(x: 35, y: -35)
                        }
                    }
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
                            HStack(spacing: 8) {
                                Image(systemName: "cross.fill")
                                    .font(.system(size: 20, weight: .bold))
                                Text(settings.localizedString(for: "garden.plant.status.dead"))
                                    .font(.system(size: 15, weight: .black, design: .rounded))
                            }
                            .padding(.horizontal, 20)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(
                                Capsule()
                                    .fill(Color.red.opacity(0.15))
                            )
                            .overlay(
                                Capsule()
                                    .strokeBorder(Color.red.opacity(0.3), lineWidth: 1.5)
                            )
                            .foregroundStyle(Color.red)
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
                .overlay(alignment: .topLeading) {
                    VStack(alignment: .leading, spacing: 8) {
                        // Aktive Power-Ups Badge
                        let plantPowerUps = gardenStore.plantSpecificActivePowerUps(plantId: pflanze.id)
                        if !plantPowerUps.isEmpty {
                            PowerUpBadge(count: plantPowerUps.count)
                        }
                        
                        // (Unkraut Badge entfernt, wird nun global im Glücksrad geregelt)
                    }
                    .padding(12)
                }
            }
            .buttonStyle(PflanzenCardButtonStyle(
                seltenheitFarbe: pflanze.isDead ? .red : pflanze.seltenheit.farbe,
                isPhase2: false
            ))
            .alert(settings.localizedString(for: "garden.plant.status.dead"), isPresented: $showDeathAlert) {
                Button(settings.localizedString(for: "button.delete"), role: .destructive) {
                    gardenStore.loeschePflanze(pflanze: pflanze)
                }
                Button(settings.localizedString(for: "button.cancel"), role: .cancel) { }
            } message: {
                Text(settings.localizedString(for: "garden.plant.dead.alert.message"))
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
    let isPhase2: Bool
    private let depth: CGFloat = 8
    private let cornerRadius: CGFloat = 24

    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed
        let baseColor = isPhase2 ? Color.orange : seltenheitFarbe

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



#Preview {
    HStack(spacing: 16) {
        PflanzenCard(
            pflanze: HabitModel(id: "1", name: "Gym", symbolName: "figure.run", symbolColor: "orange", habitCategory: .fitness),
            wetterEvent: .normal,
            onGiessen: {},
            onTap: {}
        )
        PflanzenCard(
            pflanze: {
                let p = HabitModel(id: "2", name: "Lesen", symbolName: "book.fill", symbolColor: "blue", habitCategory: .learning)
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
