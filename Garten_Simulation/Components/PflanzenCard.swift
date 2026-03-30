import SwiftUI

struct PflanzenCard: View {
    let pflanze: HabitModel
    let wetterEvent: WetterEvent
    let onGiessen: () -> Void
    let onTap: () -> Void

    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var powerUpStore: PowerUpStore
    @AppStorage("isHapticEnabled") private var isHapticEnabled: Bool = true
    @State private var pflanzenPosition: CGPoint = .zero
    @State private var giessAnimation = false
    @State private var plantWobble: CGFloat = 1.0
    @State private var greenGlowOpacity: Double = 0
    @State private var wasserPressAktiv = false

    var body: some View {
        Button(action: {
            // Delay to allow the 3D "pop-back" animation to complete
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                onTap()
            }
        }) {
            VStack(spacing: 14) {
                // MARK: Name + Seltenheit
                VStack(spacing: 6) {
                    Text(settings.localizedString(for: pflanze.name))
                        .font(.appSubheadline)
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.center)

                    Text(pflanze.seltenheit.lokalisiertTitel)
                        .font(.appBadge)
                        .foregroundStyle(pflanze.seltenheit.farbe)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(pflanze.seltenheit.farbe.opacity(0.15))
                        )
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
                        sekundaerFarbe: pflanze.color.darker(),
                        groesse: 88,
                        externerPress: wasserPressAktiv,
                        aktion: {
                            onTap()
                        }
                    )
                    .saturation(pflanze.istBewässert ? 1.0 : 0.85)
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

                // MARK: Gieß-Slider oder Erledigt-Badge
                if !pflanze.istBewässert {
                    DragToWater(
                        onGiessen: { handleWatering() },
                        pflanzenPosition: pflanzenPosition,
                        istErledigt: pflanze.istBewässert
                    )
                    .allowsHitTesting(true)
                } else {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(Color.gruenPrimary)
                        Text(settings.localizedString(for: "garden.plant.done"))
                            .font(.appButtonKlein)
                            .foregroundStyle(Color.gruenPrimary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity, alignment: .center)
            .overlay(alignment: .topLeading) {
                // Aktive Power-Ups Icons (Oben Links)
                HStack(spacing: 4) {
                    ForEach(powerUpStore.aktivePowerUps.filter { $0.isActive && $0.targetPlantId == pflanze.id }) { aktiv in
                        Image(systemName: aktiv.symbolName)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Color.white)
                            .padding(4)
                            .background(Circle().fill(Color.gruenPrimary))
                            .overlay(Circle().stroke(Color.white, lineWidth: 1))
                    }
                }
                .padding(12)
            }
        }
        .buttonStyle(PflanzenCardButtonStyle(
            seltenheitFarbe: pflanze.seltenheit.farbe,
            isPhase2: false
        ))
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
        .sensoryFeedback(trigger: isPressed) { _, newValue in
            (isHapticEnabled && newValue) ? .impact(flexibility: .soft, intensity: 0.75) : nil
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
