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
    @State private var isVisualPressed = false
    @State private var pflanzenPosition: CGPoint = .zero
    @State private var plantWobble: CGFloat = 1.0
    @State private var greenGlowOpacity: Double = 0
    @State private var showReviveSheet = false
    @State private var zeigeBonusText: Bool = false
    @State private var bonusText: String = ""
    @State private var showWaterSplash: Bool = false
    
    var body: some View {
        ZStack {
            // MARK: - Layer 0: Visual Card Background
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
                    .frame(minHeight: 120)
            }
            .buttonStyle(PflanzenCardHorizontalButtonStyle(
                isVisualPressed: isVisualPressed,
                isDead: pflanze.isDead
            ))
            .background(
                GeometryReader { proxy in
                    Color.clear
                        .preference(key: CardPositionPreferenceKey.self, value: [
                            CardPositionData(id: pflanze.id, center: proxy.frame(in: .global).center, frame: proxy.frame(in: .global))
                        ])
                }
            )
            
            // MARK: - Layer 1: Interactive Card Content
            HStack(spacing: 24) {
                
                // MARK: Left Column - 3D Plant Button & Rank
                VStack(spacing: 8) {
                    GeometryReader { geo in
                        let scale: CGFloat = 0.8
                        let baseDim: CGFloat = 110 * scale

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
                            PflanzenButton(
                                plant: GameDatabase.shared.plant(for: pflanze.plantID),
                                seltenheit: pflanze.seltenheit,
                                farbe: pflanze.color,
                                sekundaerFarbe: pflanze.color.darker(),
                                groesse: 85 * scale,
                                fallbackIcon: pflanze.symbolName,
                                externerPress: false,
                                aktion: {
                                    if pflanze.isDead {
                                        showReviveSheet = true
                                        FeedbackManager.shared.playTap()
                                    } else {
                                        FeedbackManager.shared.playTap()
                                        onTap()
                                    }
                                    
                                    if showWaterSplash {
                                        WaterSplashParticleView(isVisible: $showWaterSplash)
                                            .frame(width: 100, height: 100)
                                            .zIndex(250)
                                            .allowsHitTesting(false)
                                    }
                                }
                            )
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(
                            Color.clear
                                .allowsHitTesting(false)
                                .onAppear { updatePflanzenPosition(from: geo) }
                        )
                    }
                    .frame(width: 90, height: 90)
                    .scaleEffect(plantWobble)
                    .animation(.spring(response: 0.3, dampingFraction: 0.4), value: plantWobble)
                    
                    Text(pflanze.seltenheit.lokalisiertTitel)
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(pflanze.seltenheit.farbe)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(pflanze.seltenheit.farbe.opacity(0.12))
                        )
                }
                .frame(width: 100)
                
                // MARK: Middle Column - Habit Info (Centered)
                VStack(alignment: .center, spacing: 8) {
                    
                    // Warning & Name Header
                    HStack(alignment: .center, spacing: 6) {
                        if !pflanze.istBewässert && pflanze.showWarning {
                            Image("Warndreieck")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 18, height: 18)
                        }
                        Text(settings.showHabitInsteadOfName ? NSLocalizedString(pflanze.displayedHabitName, comment: "") : NSLocalizedString(pflanze.name, comment: ""))
                            .font(.system(size: 20, weight: .black, design: .rounded))
                            .foregroundStyle(Color.primary)
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                            .minimumScaleFactor(0.8)
                    }
                    
                    // Streak Display
                    HStack(spacing: 4) {
                        Image("streak")
                            .renderingMode(.original)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 14, height: 14)
                        
                        Text("\(String(localized: "streak.label", defaultValue: "Streak")): \(pflanze.streak)")
                            .font(.system(size: 14, weight: .black, design: .rounded))
                    }
                    .foregroundStyle(Color(hex: "#D95F00"))
                    
                    // Timer Info (Only if not watered)
                    if !pflanze.istBewässert && !pflanze.isDead {
                        HStack(spacing: 4) {
                            Image(pflanze.timerIconName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 12, height: 12)
                            
                            Text("\(pflanze.remainingHoursInCycle)\(String(localized: "common.hour_short"))")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundStyle(pflanze.showWarning ? .orange : .secondary)
                        }
                    }
                    
                    // Daily Target & Progress
                    if pflanze.isDead {
                        Text(String(format: String(localized: "pflanze.tot.seit"), pflanze.missedCycles))
                            .font(.system(size: 12, weight: .regular, design: .rounded))
                            .foregroundStyle(.secondary)
                    } else if pflanze.istBewässert {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                            Text(String(localized: "garden.plant.done"))
                        }
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.gruenPrimary)
                        .padding(.top, 4)
                    } else {
                        // Not completed yet
                        if let target = pflanze.customTrackerTarget, target > 0 {
                            buildTargetProgressView(current: pflanze.customTrackerProgress, target: target)
                        } else if let healthTarget = pflanze.healthTarget, healthTarget > 0 {
                            buildTargetProgressView(current: pflanze.customTrackerProgress, target: healthTarget)
                        } else {
                            // Kein Target vorhanden -> Zeige Plus Button anstelle von leerer Progressbar
                            buildEmptyProgressView()
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.trailing, 16)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 16)
            .allowsHitTesting(true)
            .sheet(isPresented: $showReviveSheet) {
                RevivePlantSheet(pflanze: pflanze)
                    .presentationDetents([.medium])
            }
            
            if zeigeBonusText {
                BonusFloatingTextView(text: bonusText, isVisible: $zeigeBonusText, isProMode: gardenStore.isProUser)
                    .zIndex(300)
            }
        }
        .onChange(of: gardenStore.giessTriggerID) { _, _ in
            if gardenStore.letzteGiessPflanzeID == pflanze.id {
                // Wenn gegossen wurde, Wasser-Splash auslösen
                showWaterSplash = true
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
                
                if gardenStore.isProUser {
                    bonusText = "PRO"
                    zeigeBonusText = true
                } else if gardenStore.letzterBonus != nil {
                    bonusText = String(localized: "bonus_text")
                    zeigeBonusText = true
                }
            }
        }
        .coordinateSpace(name: "PflanzenCardSpace")
    }
    
    @ViewBuilder
    private func buildTargetProgressView(current: Double, target: Double) -> some View {
        VStack(alignment: .center, spacing: 4) {
            ZStack(alignment: .leading) {
                ProgressView(value: min(current, target), total: target)
                    .progressViewStyle(LinearProgressViewStyle(tint: pflanze.seltenheit.farbe))
                    .frame(height: 6)
                
                if !gardenStore.isProUser {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.secondary)
                        .padding(.leading, 4)
                }
            }
            
            Text("\(Int(current)) / \(Int(target))")
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .padding(.top, 4)
    }

    @ViewBuilder
    private func buildEmptyProgressView() -> some View {
        HStack(spacing: 8) {
            ProgressView(value: 0, total: 1)
                .progressViewStyle(LinearProgressViewStyle(tint: .gray.opacity(0.5)))
                .frame(height: 6)
            
            Button {
                onTap() // Öffnet die Detail-Ansicht, um ein Ziel hinzuzufügen
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(.gray)
            }
        }
        .padding(.top, 4)
    }

    private func updatePflanzenPosition(from geo: GeometryProxy) {
        let frame = geo.frame(in: .named("PflanzenCardSpace"))
        pflanzenPosition = CGPoint(x: frame.midX, y: frame.midY)
    }
}

// MARK: - Button Style
struct PflanzenCardHorizontalButtonStyle: ButtonStyle {
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
                .frame(minHeight: 120)
            
            configuration.label
                .frame(maxWidth: .infinity)
                .frame(minHeight: 120)
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

// MARK: - Legacy Button Style (used by BadHabitCard and others)
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
                .frame(minHeight: 320)
            
            configuration.label
                .frame(maxWidth: .infinity)
                .frame(minHeight: 320)
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
    VStack(spacing: 16) {
        PflanzenCard(
            pflanze: HabitModel(id: "1", name: "Gym", symbolName: "figure.run", symbolColor: "orange", habitCategory: .fitness),
            wetterEvent: .normal,
            onGiessen: {},
            onTap: {}
        )
        PflanzenCard(
            pflanze: {
                let p = HabitModel(id: "2", name: "Lesen", symbolName: "book.fill", symbolColor: "blue", habitCategory: .growth)
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
