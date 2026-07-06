import SwiftUI

// SegmentKind now resides in DailyWheelComponents.swift

struct WheelOfFortuneView: View {
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var settings: SettingsStore
    @Environment(\.dismiss) var dismiss
    
    @State private var rotation: Double = 0
    @State private var isSpinning = false
    @State private var spinResult: SpinResult? = nil
    @State private var showResult = false
    @State private var showPowerUpPicker = false
    @State private var segmentLayout: [SegmentKind] = []
    @State private var showResultOverlay = false
    
    // UI Layout Config
    private let wheelSize: CGFloat = 310
    private let totalSegments = 10
    
    /// Generate a randomized layout with exactly two of each reward type, ensuring no duplicates are adjacent.
    func generateLayout() -> [SegmentKind] {
        let base: [SegmentKind] = [.klein, .mittel, .gross, .xpBoost, .jackpot].shuffled()
        // Shuffling the base and repeating it ensures an alternating pattern A,B,C,D,E,A,B,C,D,E
        // This guarantees no identical segments are adjacent, even when looping.
        return base + base
    }
    
    var body: some View {
        ZStack {
            // Background
            Color(UIColor.systemBackground).ignoresSafeArea()
            
            // Close Button
            VStack {
                HStack {
                    Spacer()
                    LiquidGlassDismissButton {
                        FeedbackManager.shared.playTap()
                        dismiss()
                    }
                    .padding(.trailing, 16)
                    .padding(.top, 16)
                }
                Spacer()
            }
            .opacity(isSpinning ? 0 : 1)
            .animation(.easeInOut, value: isSpinning)
            .zIndex(10)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 30) {
                    // Header
                    VStack(spacing: 6) {
                        Button {
                            FeedbackManager.shared.playTap()
                        } label: {
                            Text(String(localized: "dailyspin.title"))
                        }
                        .buttonStyle(Pressed3DTextButtonStyle())
                        
                        Text(String(localized: "dailyspin.subtitle"))
                            .font(.system(size: 15, weight: .regular))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.bottom, 4)
                    
                    // Wheel Assembly — 3D Two-Layer Effect
                    VStack(spacing: 0) {
                        ZStack {
                            // === 3D BASE LAYER (darker, sits behind) ===
                            Circle()
                                .fill(Color(hex: "#0F1A30"))
                                .frame(width: wheelSize + 38, height: wheelSize + 38)
                            
                            // === 3D TOP LAYER & POINTER (clickable and moves) ===
                            Button {
                                handleSpinAction()
                            } label: {
                                ZStack {
                                    // Main Wheel Top Layer
                                    ZStack {
                                        // Dark blue outer ring
                                        Circle()
                                            .fill(Color(hex: "#1A2744"))
                                            .frame(width: wheelSize + 38, height: wheelSize + 38)
                                            .overlay(Circle().stroke(Color.black, lineWidth: 3))
                                        
                                        // Spinning Wheel
                                        WheelSlices(layout: segmentLayout)
                                            .frame(width: wheelSize, height: wheelSize)
                                            .clipShape(Circle())
                                            .overlay(Circle().stroke(Color.black, lineWidth: 2.5))
                                            .rotationEffect(.degrees(rotation))
                                        
                                        // Rim dots
                                        ForEach(0..<16, id: \.self) { i in
                                            WheelRimDot(index: i, totalDots: 16, rimRadius: (wheelSize + 38) / 2.0 - 9.0)
                                        }
                                        
                                        // Center hub
                                        ZStack {
                                            Circle()
                                                .fill(Color(hex: "#0F1A30"))
                                                .frame(width: 36, height: 36)
                                            Circle()
                                                .fill(Color(hex: "#1A2744"))
                                                .frame(width: 36, height: 36)
                                                .overlay(Circle().stroke(Color.white.opacity(0.85), lineWidth: 3))
                                                .offset(y: -3)
                                        }
                                    }
                                    
                                    // Pointer at top
                                    ZStack {
                                        WheelTrianglePointer()
                                            .fill(Color(hex: "#C8960C"))
                                            .frame(width: 28, height: 34)
                                        WheelTrianglePointer()
                                            .fill(Color(hex: "#FFD700"))
                                            .frame(width: 28, height: 34)
                                            .overlay(WheelTrianglePointer().stroke(Color.black, lineWidth: 2))
                                            .offset(y: -3)
                                    }
                                    .offset(y: -((wheelSize + 38) / 2) + 2) // Match placement
                                }
                                .offset(y: -6) // 3D depth offset pushes the whole interactive layer up
                            }
                            .buttonStyle(Press3DWrapperButtonStyle(depth: 6))
                            .disabled(isSpinning || (!gardenStore.pendingDailySpin && gardenStore.gluecksradDrehungen <= 0) || !gardenStore.heuteGegossen)
                        }
                        .frame(width: wheelSize + 38, height: wheelSize + 38 + 6)
                    }
                    .padding(.vertical, 10)
                    
                    // Main Action Button
                    VStack(spacing: 12) {
                        Button(action: handleSpinAction) {
                            if gardenStore.pendingDailySpin {
                                Text(String(localized: "spin_button_gratis"))
                            } else if gardenStore.gluecksradDrehungen > 0 {
                                Text(String(localized: "dailyspin.button.spin", defaultValue: "Glücksrad drehen"))
                            } else {
                                Text(String(localized: "spin_button_keine"))
                            }
                        }
                        .buttonStyle(DuolingoButtonStyle(
                            size: .large,
                            backgroundColor: (gardenStore.pendingDailySpin || gardenStore.gluecksradDrehungen > 0) && gardenStore.heuteGegossen ? .blauPrimary : .secondary,
                            shadowColor: (gardenStore.pendingDailySpin || gardenStore.gluecksradDrehungen > 0) && gardenStore.heuteGegossen ? .blauSecondary : .secondary.darker()
                        ))
                        .disabled(isSpinning || (!gardenStore.pendingDailySpin && gardenStore.gluecksradDrehungen <= 0) || !gardenStore.heuteGegossen)
                        .padding(.horizontal, 30)
                        
                        if !gardenStore.heuteGegossen {
                            Text(String(localized: "lucky_wheel_locked_hint"))
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        } else if !gardenStore.pendingDailySpin && gardenStore.gluecksradDrehungen <= 0 {
                            Text(String(localized: "dailyspin.no_spins_hint"))
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Spacer().frame(height: 40)
                }
                .padding(.top, 40)
                .frame(minHeight: 800)
            }
            
            // Result Overlay
            if showResultOverlay, let result = spinResult {
                SpinResultOverlay(result: result, onDismiss: {
                    withAnimation(.easeOut(duration: 0.25)) {
                        showResultOverlay = false
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        finishSpin()
                    }
                })
                .transition(.opacity.combined(with: .scale(0.9)))
            }
        }
        .onAppear {
            if segmentLayout.isEmpty {
                segmentLayout = generateLayout()
            }
        }
    }

    private func handleSpinAction() {
        guard !isSpinning && gardenStore.heuteGegossen else { return }
        
        if gardenStore.pendingDailySpin {
            gardenStore.pendingDailySpin = false
            FeedbackManager.shared.playTap()
            spinWheel()
        } else if gardenStore.gluecksradDrehungen > 0 {
            FeedbackManager.shared.playTap()
            _ = gardenStore.gluecksradDrehungVerbrauchen()
            spinWheel()
        } else {
            FeedbackManager.shared.playError()
        }
    }
    
    private func spinWheel() {
        isSpinning = true

        let result = DailySpinLogic.spin(ownedItemsCount: gardenStore.totalItemsCount)
        spinResult = result

        // Find matching segment indices in the shuffled layout
        let targetKind: SegmentKind
        switch result {
        case .klein:   targetKind = .klein
        case .mittel:  targetKind = .mittel
        case .gross:   targetKind = .gross
        case .xpBoost: targetKind = .xpBoost
        case .jackpot: targetKind = .jackpot
        }
        
        let matchingIndices = segmentLayout.enumerated().compactMap { $0.element == targetKind ? $0.offset : nil }
        let segDeg = 360.0 / Double(totalSegments)
        
        // Pick a random matching segment and target its center
        let targetIndex = matchingIndices.randomElement() ?? 0
        let rf = Double.random(in: 0.15...0.85)
        let sliceAngle = Double(targetIndex) * segDeg + rf * segDeg

        let fullSpins = 5.0 * 360.0
        let targetRotation = rotation + fullSpins + (360.0 - sliceAngle)
        
        let tickCount = Int(fullSpins / segDeg) + totalSegments
        let spinDuration: Double = 3.5
        for tick in 0..<tickCount {
            let progress = Double(tick) / Double(tickCount)
            let easedTime = progress * spinDuration * (2.0 - progress)
            let delay = min(easedTime, spinDuration - 0.1)
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                if isSpinning {
                    FeedbackManager.shared.playTick()
                }
            }
        }

        withAnimation(
            .timingCurve(0.15, 0.85, 0.35, 1.0, duration: spinDuration)
        ) {
            rotation = targetRotation
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + spinDuration + 0.3) {
            withAnimation(.spring(response: 0.4)) {
                showResult = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                FeedbackManager.shared.playSuccess()
                withAnimation(.spring(response: 0.42, dampingFraction: 0.65)) {
                    showResultOverlay = true
                }
            }
        }
    }

    private func finishSpin() {
        guard let result = spinResult else { return }
        
        switch result {
        case .klein:
            gardenStore.coins += 20
        case .mittel:
            gardenStore.coins += 50
        case .gross:
            gardenStore.coins += 100
        case .xpBoost:
            if let lowest = gardenStore.pflanzen.sorted(by: { $0.currentXP < $1.currentXP }).first {
                lowest.currentXP += 100
            }
            gardenStore.xpHinzufuegen(amount: 50)
        case .jackpot:
            gardenStore.coins += 300
        }
        
        gardenStore.saveStats()
        gardenStore.lastSpinTimestamp = Date()
        gardenStore.showDailySpinOverlay = false
        
        // Regenerate layout for next time
        segmentLayout = generateLayout()
    }
}

// MARK: - 3D Text Button Style
struct Pressed3DTextButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed
        ZStack {
            // Lower layer (shadow)
            configuration.label
                .font(.system(size: 42, weight: .black, design: .rounded))
                .foregroundStyle(Color.blauPrimary.opacity(0.35))
                .offset(y: 6)

            // Upper layer (visible text)
            configuration.label
                .font(.system(size: 42, weight: .black, design: .rounded))
                .foregroundStyle(Color.blauPrimary)
                .offset(y: isPressed ? 6 : 0)
        }
        .animation(.spring(response: 0.15, dampingFraction: 0.6), value: isPressed)
    }
}

// MARK: - SpinResultIconView
private struct SpinResultIconView: View {
    let result: SpinResult

    var body: some View {
        ZStack {
            switch result {
            case .klein, .mittel, .gross, .jackpot:
                Image("coin")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 72, height: 72)
                    .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
            case .xpBoost:
                Image("XP")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 72, height: 72)
                    .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
            }
        }
        .frame(height: 140)
    }
}

// MARK: - SpinResultOverlay
struct SpinResultOverlay: View {
    let result: SpinResult
    let onDismiss: () -> Void
    @EnvironmentObject var settings: SettingsStore

    @State private var contentOpacity: Double = 0
    @State private var iconScale: CGFloat = 0.5

    private var overlayTitel: String {
        switch result {
        case .klein:   return String(format: String(localized: "dailyspin.result.wheel.coins"), 20)
        case .mittel:  return String(format: String(localized: "dailyspin.result.wheel.coins"), 50)
        case .gross:   return String(format: String(localized: "dailyspin.result.wheel.coins"), 100)
        case .xpBoost: return String(format: String(localized: "dailyspin.result.wheel.xp"), 100)
        case .jackpot: return String(format: String(localized: "dailyspin.result.wheel.coins"), 300)
        }
    }

    private var overlayUntertitel: String {
        switch result {
        case .xpBoost: return String(localized: "dailyspin.result.xp.subtitle")
        default:       return String(localized: "dailyspin.result.coins.subtitle")
        }
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.45)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                SpinResultIconView(result: result)
                    .scaleEffect(iconScale)

                VStack(spacing: 8) {
                    Text(overlayTitel)
                        .font(.system(size: 32, weight: .black, design: .rounded))
                        .multilineTextAlignment(.center)

                    Text(overlayUntertitel)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                Button(action: onDismiss) {
                    Text(String(localized: "dailyspin.button.continue"))
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                }
                .buttonStyle(DuolingoButtonStyle(
                    size: .large,
                    fillWidth: true,
                    backgroundColor: .gruenPrimary,
                    shadowColor: Color.gruenPrimary.darker(),
                    foregroundColor: .white
                ))
            }
            .padding(28)
            .background(
                ZStack(alignment: .bottom) {
                    // 3D Shadow Layer (Base)
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .fill(Color(hex: "#E0E0E0"))
                        .offset(y: 8)
                    
                    // Main White Surface
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .fill(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 32, style: .continuous)
                                .stroke(Color.black.opacity(0.1), lineWidth: 1.5)
                        )
                }
                .shadow(color: .black.opacity(0.15), radius: 32, x: 0, y: 16)
            )
            .padding(.horizontal, 32)
            .opacity(contentOpacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.7)) {
                contentOpacity = 1.0
                iconScale = 1.0
            }
        }
    }
}
