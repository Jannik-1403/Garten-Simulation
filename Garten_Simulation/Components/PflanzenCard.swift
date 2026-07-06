import SwiftUI

struct PflanzenCard: View {
    @ObservedObject var pflanze: HabitModel
    let wetterEvent: WetterEvent
    /// Wird vom globalen Wasser-Tropfen in GartenView gesetzt
    var isHighlightedForWatering: Bool = false
    let onTap: () -> Void
    /// Wird aufgerufen, wenn der globale Wasser-Tropfen auf diese Karte gezogen wird
    let onGiessen: () -> Void

    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var powerUpStore: PowerUpStore
    @AppStorage("isHapticEnabled") private var isHapticEnabled: Bool = true
    @State private var isVisualPressed = false
    @State private var plantWobble: CGFloat = 1.0
    @State private var greenGlowOpacity: Double = 0
    @State private var showReviveSheet = false
    @State private var zeigeBonusText: Bool = false
    @State private var bonusText: String = ""
    @State private var showWaterSplash: Bool = false

    var body: some View {
        ZStack {
            // MARK: - Layer 0: Visual Card Background (3D Button)
            Button {
                isVisualPressed = true
                FeedbackManager.shared.playTap()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                    isVisualPressed = false
                    if pflanze.isDead {
                        showReviveSheet = true
                    } else {
                        onTap()
                    }
                }
            } label: {
                Rectangle().fill(Color.clear)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 300)
            }
            .buttonStyle(PflanzenCardButtonStyle(
                isVisualPressed: isVisualPressed,
                isDead: pflanze.isDead
            ))
            .background(
                GeometryReader { proxy in
                    Color.clear
                        .preference(key: CardPositionPreferenceKey.self, value: [
                            CardPositionData(id: pflanze.id, center: proxy.frame(in: .global).center)
                        ])
                }
            )

            // MARK: - Layer 1: Interactive Card Content
            VStack(spacing: 12) {
                // MARK: Timer Countdown & Warning
                if !pflanze.istBewässert && !pflanze.isDead {
                    ZStack {
                        if pflanze.showWarning {
                            Image("Warndreieck")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 44, height: 44)
                                .offset(x: -42)
                        }
                        HStack(spacing: 4) {
                            Image(pflanze.timerIconName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 14, height: 14)
                            Text("\(pflanze.remainingHoursInCycle)\(String(localized: "common.hour_short"))")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundStyle(pflanze.showWarning ? .orange : .secondary)
                        }
                    }
                } else {
                    Color.clear.frame(height: 14)
                }

                // MARK: Habit Name + Seltenheit + Streak
                VStack(spacing: 6) {
                    Text(settings.showHabitInsteadOfName
                         ? NSLocalizedString(pflanze.displayedHabitName, comment: "")
                         : NSLocalizedString(pflanze.name, comment: ""))
                        .font(.system(size: 17, weight: .black, design: .rounded))
                        .foregroundStyle(Color.primary)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.6)
                        .padding(.horizontal, 4)

                    Text(pflanze.seltenheit.lokalisiertTitel)
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(pflanze.seltenheit.farbe)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(pflanze.seltenheit.farbe.opacity(0.12)))

                    // Streak & Tracker
                    HStack(spacing: 10) {
                        if pflanze.streak > 0 {
                            HStack(spacing: 3) {
                                Image(systemName: "flame.fill")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundStyle(.orange)
                                Text("\(pflanze.streak)")
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                    .foregroundStyle(.orange)
                            }
                        }
                        if let target = pflanze.customTrackerTarget, target > 0 {
                            HStack(spacing: 3) {
                                Image(systemName: "chart.bar.fill")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(.secondary)
                                Text("\(Int(pflanze.customTrackerProgress))/\(Int(target))")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(.top, 2)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 4)

                // MARK: Pflanzenbild (3D Button)
                GeometryReader { geo in
                    let scale = min(geo.size.width / 160, 1.2)
                    let baseDim: CGFloat = 130 * scale

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

                        // Glow wenn gegossen oder anvisiert
                        Circle()
                            .stroke(Color.gruenPrimary.opacity(
                                isHighlightedForWatering ? 0.7 : greenGlowOpacity * 0.6
                            ), lineWidth: 6 * scale)
                            .frame(width: baseDim * 1.15, height: baseDim * 1.15)
                            .blur(radius: isHighlightedForWatering ? 4 : 1.5 * scale)
                            .allowsHitTesting(false)
                            .animation(.easeInOut(duration: 0.2), value: isHighlightedForWatering)

                        PflanzenButton(
                            plant: GameDatabase.shared.plant(for: pflanze.plantID),
                            seltenheit: pflanze.seltenheit,
                            farbe: pflanze.color,
                            sekundaerFarbe: pflanze.color.darker(),
                            groesse: 105 * scale,
                            fallbackIcon: pflanze.symbolName,
                            externerPress: isHighlightedForWatering,
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

                        if showWaterSplash {
                            WaterSplashParticleView(isVisible: $showWaterSplash)
                                .frame(width: 200, height: 200)
                                .zIndex(250)
                                .allowsHitTesting(false)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(height: 145)
                .padding(.vertical, 6)
                .scaleEffect(plantWobble)
                .animation(.spring(response: 0.3, dampingFraction: 0.4), value: plantWobble)

                // MARK: Status-Bereich (kein Slider mehr - Wasser kommt global)
                Group {
                    if pflanze.isDead {
                        VStack(spacing: 2) {
                            Text(String(localized: "pflanze.tot.titel"))
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundStyle(.orange)
                            Text(String(format: String(localized: "pflanze.tot.seit"), pflanze.missedCycles))
                                .font(.system(size: 12, weight: .regular, design: .rounded))
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                    } else if !pflanze.istBewässert {
                        // Hinweis: Wasser per globalem Tropfen ziehen
                        HStack(spacing: 6) {
                            Image("Drop water")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 16, height: 20)
                                .opacity(isHighlightedForWatering ? 1.0 : 0.45)
                                .scaleEffect(isHighlightedForWatering ? 1.2 : 1.0)
                                .animation(.spring(response: 0.25), value: isHighlightedForWatering)
                            Text(isHighlightedForWatering
                                 ? String(localized: "plant.watering.release", defaultValue: "Loslassen zum Gießen!")
                                 : String(localized: "plant.watering.hint", defaultValue: "Wasser ziehen & ablegen"))
                                .font(.system(size: 11, weight: .semibold, design: .rounded))
                                .foregroundStyle(isHighlightedForWatering ? Color.gruenPrimary : .secondary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                                .animation(.easeInOut(duration: 0.2), value: isHighlightedForWatering)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .padding(.horizontal, 8)
                    } else {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundStyle(Color.gruenPrimary)
                            Text(String(localized: "garden.plant.done"))
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.gruenPrimary)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.top, 20)
            .padding(.bottom, 14)
            .frame(maxWidth: .infinity, alignment: .center)
            .allowsHitTesting(true)
            .sheet(isPresented: $showReviveSheet) {
                RevivePlantSheet(pflanze: pflanze)
                    .presentationDetents([.medium])
            }

            // MARK: Highlight Glow Overlay (wenn Wasser-Tropfen darüber schwebt)
            if isHighlightedForWatering {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color.gruenPrimary, lineWidth: 3)
                    .shadow(color: Color.gruenPrimary.opacity(0.8), radius: 14)
                    .allowsHitTesting(false)
                    .transition(.opacity.combined(with: .scale(scale: 1.02)))
            }

            if zeigeBonusText {
                BonusFloatingTextView(text: bonusText, isVisible: $zeigeBonusText, isProMode: gardenStore.isProUser)
                    .zIndex(300)
            }
        }
        .onChange(of: gardenStore.giessTriggerID) { _, _ in
            if gardenStore.letzteGiessPflanzeID == pflanze.id {
                if gardenStore.isProUser {
                    bonusText = "PRO"
                    zeigeBonusText = true
                } else if gardenStore.letzterBonus != nil {
                    bonusText = String(localized: "bonus_text")
                    zeigeBonusText = true
                }
            }
        }
    }

    // MARK: - Wird von GartenView aufgerufen (globaler Wasser-Tropfen)
    func triggerWateringAnimation() {
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) {
            FeedbackManager.shared.playWatering()
            showWaterSplash = true
            onGiessen()
        }
    }
}

// MARK: - Button Style für die gesamte Karte
struct PflanzenCardButtonStyle: ButtonStyle {
    @AppStorage("isHapticEnabled") var isHapticEnabled: Bool = true
    let isVisualPressed: Bool
    let isDead: Bool
    private let depth: CGFloat = 5
    private let cornerRadius: CGFloat = 20

    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed || isVisualPressed
        let baseColor = Color(white: 0.7)

        ZStack(alignment: .bottom) {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(baseColor)
                .padding(.horizontal, 1)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 300)

            configuration.label
                .frame(maxWidth: .infinity)
                .frame(minHeight: 300)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(Color.black.opacity(0.15), lineWidth: 1.2)
                )
                .offset(y: isPressed ? 0 : -depth)
        }
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.22, dampingFraction: 0.5), value: isPressed)
        .sensoryFeedback(trigger: isPressed) { _, newValue in
            (isHapticEnabled && newValue) ? .impact(flexibility: .soft, intensity: 0.75) : nil
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
            VStack(spacing: 12) {
                Image("Heillung")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 140, height: 140)

                Text(String(localized: "pflanze.wiederbeleben.titel"))
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 20)

            Text(String(format: String(localized: "pflanze.wiederbeleben.beschreibung"), pflanze.missedCycles))
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 24)

            let hasWunderWasser = gardenStore.gekaufteItems.contains(where: { $0.id == "powerup.wunder_wasser" })
            if !hasWunderWasser {
                GemsIcon(wert: GameConstants.wiederbelebungsKosten)
            }

            Spacer()

            VStack(spacing: 12) {
                if hasWunderWasser {
                    Button {
                        gardenStore.reviveWithWonderWater(pflanze: pflanze)
                        dismiss()
                    } label: {
                        Text("\(String(localized: "item.wunder_wasser.name")) (Gratis)")
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
                        Text(String(localized: "pflanze.wiederbeleben.button"))
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
                    Text(String(localized: "button.delete"))
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
            pflanze: HabitModel(id: "1", name: "Gym", symbolName: "figure.run", symbolColor: "orange", habitCategory: .fitness),
            wetterEvent: .normal,
            isHighlightedForWatering: true,
            onTap: {},
            onGiessen: {}
        )
        PflanzenCard(
            pflanze: {
                let p = HabitModel(id: "2", name: "Lesen", symbolName: "book.fill", symbolColor: "blue", habitCategory: .growth)
                p.currentXP = 200
                p.istBewässert = true
                return p
            }(),
            wetterEvent: .normal,
            onTap: {},
            onGiessen: {}
        )
    }
    .padding()
    .background(Color.appHintergrund)
}
