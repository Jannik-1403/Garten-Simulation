import SwiftUI

struct PflanzenCard: View {
    @ObservedObject var pflanze: HabitModel

    let onGiessen: () -> Void
    let onTap: () -> Void

    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var gardenStore: GardenStore
    @ObservedObject var healthManager = HealthManager.shared
    @AppStorage("isHapticEnabled") private var isHapticEnabled: Bool = true
    @State private var isVisualPressed = false
    @State private var isLocked = false
    @State private var pflanzenPosition: CGPoint = .zero
    @State private var plantWobble: CGFloat = 1.0
    @State private var greenGlowOpacity: Double = 0
    @State private var showReviveSheet = false
    @State private var showWaterSplash: Bool = false
    @State private var zeigeBonusText: Bool = false
    @State private var bonusText: String = ""
    
    // Slider-to-Complete
    @State private var dragWidth: CGFloat = 0.0
    @State private var isDragging: Bool = false
    @State private var cardWidth: CGFloat = 300
    @State private var wasLongPressCompleted: Bool = false
    
    private var maxDragWidth: CGFloat {
        max(50, cardWidth - 110)
    }
    
    private var healthProgress: Double? {
        guard let metric = pflanze.linkedHealthMetric, let target = pflanze.healthTarget, target > 0 else {
            return nil
        }
        let current: Double
        switch metric {
        case .steps: current = healthManager.todaysSteps
        case .water: current = healthManager.todaysWater
        case .sleep: current = healthManager.todaysSleep
        case .mindfulness: current = healthManager.todaysMindfulness
        case .running: current = healthManager.todaysRunning
        case .strengthTraining: current = healthManager.todaysStrengthTraining
        }
        return min(1.0, max(0.0, current / target))
    }
    
    private var currentProgress: Double {
        if let hp = healthProgress {
            return hp
        }
        if isDragging {
            return min(1.0, max(0.0, dragWidth / maxDragWidth))
        } else {
            return pflanze.sliderProgress
        }
    }
    
    var body: some View {
        ZStack {
            // MARK: - Card Content & Button
            Button {
                guard !isLocked else { return }
                isLocked = true
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
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    isLocked = false
                }
            } label: {
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
            
                            // Der 3D-Button
                            PflanzenButton(
                                plant: GameDatabase.shared.plant(for: pflanze.plantID),
                                seltenheit: pflanze.seltenheit,
                                farbe: pflanze.color,
                                sekundaerFarbe: pflanze.color.darker(),
                                groesse: 85 * scale,
                                fallbackIcon: pflanze.symbolName,
                                externerPress: false,
                                aktion: {}
                            )
                            .allowsHitTesting(false)
                            
                            if showWaterSplash {
                                WaterSplashParticleView(isVisible: $showWaterSplash)
                                    .frame(width: 100, height: 100)
                                    .zIndex(250)
                                    .allowsHitTesting(false)
                            }
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
                .zIndex(10)
                
                // MARK: Middle Column - Habit Info (Centered)
                VStack(alignment: .center, spacing: 8) {
                    
                    // Warning & Name Header
                    HStack(alignment: .center, spacing: 6) {
                        if !pflanze.istBewässert && pflanze.showWarning {
                            ZStack {
                                Image("Warndreieck")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 36, height: 36)
                            }
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
                        
                        Text(verbatim: "\(String(localized: "streak.label", defaultValue: "Streak")): \(pflanze.streak)")
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
                    
                    if pflanze.isDead {
                        Text(String(format: String(localized: "pflanze.tot.seit"), pflanze.missedCycles))
                            .font(.system(size: 12, weight: .regular, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.trailing, 16)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 16)
            .background(
                GeometryReader { proxy in
                    Color.clear
                        .preference(key: CardPositionPreferenceKey.self, value: [
                            CardPositionData(id: pflanze.id, center: proxy.frame(in: .global).center, frame: proxy.frame(in: .global))
                        ])
                        .onAppear { cardWidth = proxy.size.width }
                        .onChange(of: proxy.size.width) { _, new in cardWidth = new }
                }
            )
        }
        .buttonStyle(PflanzenCardHorizontalButtonStyle(
            isVisualPressed: isVisualPressed,
            isDead: pflanze.isDead,
            longPressProgress: currentProgress,
            progressColor: Color.gruenPrimary.opacity(0.3),
            onIsPressedChange: nil
        ))
        .highPriorityGesture(
            DragGesture(minimumDistance: 25)
                .onChanged { value in
                    guard healthProgress == nil else { return }
                    guard !pflanze.istBewässert && !pflanze.isDead else { return }
                    if !isDragging { isDragging = true }
                    let startX = pflanze.sliderProgress * maxDragWidth
                    dragWidth = startX + value.translation.width
                }
                .onEnded { value in
                    guard isDragging else { return }
                    isDragging = false
                    let finalProgress = min(1.0, max(0.0, dragWidth / maxDragWidth))
                    pflanze.sliderProgress = finalProgress
                    pflanze.intradayProgressHistory.removeAll { !Calendar.current.isDateInToday($0.timestamp) }
                    pflanze.intradayProgressHistory.append(DailyProgressEntry(timestamp: Date(), progress: finalProgress))
                    
                    if finalProgress >= 1.0 {
                        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                        triggerWatering()
                        pflanze.sliderProgress = 0.0
                    } else {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }
                }
        )
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
                bonusText = String(localized: "bonus_text", defaultValue: "Bonus!")
                zeigeBonusText = true
            }
        }
    }
    .coordinateSpace(name: "PflanzenCardSpace")
}

    // MARK: - Helper Logik
    private func triggerWatering() {
        withAnimation(.easeOut(duration: 0.3)) {
            pflanze.sliderProgress = 0
        }
        if isHapticEnabled {
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        }
        gardenStore.letzteGiessPflanzeID = pflanze.id
        gardenStore.giessTriggerID = UUID()
        gardenStore.giessen(pflanze: pflanze)
        
        // Triggers the water splash effect
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
            bonusText = String(localized: "bonus_text", defaultValue: "Bonus!")
            zeigeBonusText = true
        }
        
        onGiessen()
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
    var longPressProgress: CGFloat = 0.0
    var progressColor: Color = .blauPrimary
    var onIsPressedChange: ((Bool) -> Void)? = nil
    
    private let depth: CGFloat = 5
    private let cornerRadius: CGFloat = 20

    func makeBody(configuration: Configuration) -> some View {
        let isPressed = (configuration.isPressed || isVisualPressed) && longPressProgress == 0
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
                .background(
                    GeometryReader { proxy in
                        ZStack(alignment: .leading) {
                            Color.white
                            if longPressProgress > 0 {
                                progressColor
                                    .frame(width: proxy.size.width * longPressProgress)
                            }
                        }
                    }
                )
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
            return (isHapticEnabled && newValue) ? .impact(flexibility: .soft, intensity: 0.75) : nil
        }
        .onChange(of: configuration.isPressed) { newValue in
            onIsPressedChange?(newValue)
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
            return (isHapticEnabled && newValue) ? .impact(flexibility: .soft, intensity: 0.75) : nil
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
    @EnvironmentObject var shopStore: ShopStore
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
                    shopStore.removeFromPurchased(id: pflanze.plantID)
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

            onGiessen: {},
            onTap: {}
        )
    }
    .padding()
    .background(Color.appHintergrund)
    .environmentObject(SettingsStore())
    .environmentObject(GardenStore())

}
