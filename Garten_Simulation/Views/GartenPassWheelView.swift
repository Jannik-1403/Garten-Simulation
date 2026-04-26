import SwiftUI
import DotLottie

struct GartenPassWheelView: View {
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var gartenPfadStore: GartenPfadStore
    @Environment(\.dismiss) var dismiss
    
    @State private var rotation: Double = 0
    @State private var isSpinning = false
    @State private var wonReward: GartenPassSpinBelohnung? = nil
    @State private var showResultOverlay = false
    
    // UI Layout Config (Exactly like original)
    private let wheelSize: CGFloat = 310
    private let totalSegments = 12
    
    var body: some View {
        ZStack {
            // Background (Exactly like original)
            Color(UIColor.systemBackground).ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 30) {
                    // Header
                    VStack(spacing: 6) {
                        Button {
                            FeedbackManager.shared.playTap()
                        } label: {
                            Text(NSLocalizedString("ice_wheel_title", comment: ""))
                        }
                        .buttonStyle(Pressed3DTextButtonStyle())
                        
                        Text(NSLocalizedString("ice_wheel_subtitle", comment: ""))
                            .font(.system(size: 15, weight: .regular))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.bottom, 4)
                    
                    // Wheel Assembly — 3D Two-Layer Effect (Exactly like original)
                    VStack(spacing: 0) {
                        ZStack {
                            // === 3D BASE LAYER (darker, sits behind) ===
                            Circle()
                                .fill(Color(hex: "#0F1A30"))
                                .frame(width: wheelSize + 38, height: wheelSize + 38)
                            
                            // === 3D TOP LAYER & POINTER (clickable and moves) ===
                            Button {
                                guard !isSpinning && gartenPfadStore.verfuegbareSpins > 0 else { return }
                                
                                // Delay for premium 3D feeling (pop-back animation)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
                                    spinWheel()
                                }
                            } label: {
                                ZStack {
                                    // Main Wheel Top Layer
                                    ZStack {
                                        // Dark blue outer ring
                                        Circle()
                                            .fill(Color(hex: "#1A2744"))
                                            .frame(width: wheelSize + 38, height: wheelSize + 38)
                                            .overlay(Circle().stroke(Color.black, lineWidth: 3))
                                        
                                        // Spinning Wheel (Using 12 segments)
                                        IceWheelSlices(segments: GartenPassWheelLogic.segmente(fuerDekorationen: gardenStore.placedDecorations.count))
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
                                    .offset(y: -((wheelSize + 38) / 2) + 2)
                                }
                                .offset(y: -6)
                            }
                            .buttonStyle(Press3DWrapperButtonStyle(depth: 6))
                        }
                        .frame(width: wheelSize + 38, height: wheelSize + 38 + 6)
                    }
                    .padding(.vertical, 10)
                    
                    // Available Spins Info
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.2.circlepath")
                            .font(.system(size: 16, weight: .bold))
                        Text(String(format: NSLocalizedString("wheel.spins_label", comment: ""), gartenPfadStore.verfuegbareSpins))
                            .font(.system(size: 16, weight: .bold))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blauPrimary.opacity(0.1), in: Capsule())
                    .opacity(isSpinning ? 0 : 1)
                    
                    // Main Action Button (Exactly like original style)
                    Button(action: {
                        guard !isSpinning && gartenPfadStore.verfuegbareSpins > 0 else { return }
                        
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        
                        // Delay for premium 3D feeling (pop-back animation)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
                            spinWheel()
                        }
                    }) {
                        if gartenPfadStore.verfuegbareSpins > 0 {
                            Text(String(format: NSLocalizedString("wheel_drehen_format", comment: ""), gartenPfadStore.verfuegbareSpins))
                        } else {
                            Text(NSLocalizedString("wheel_keine_spins", comment: ""))
                        }
                    }
                    .buttonStyle(DuolingoButtonStyle(
                        size: .large,
                        backgroundColor: gartenPfadStore.verfuegbareSpins > 0 ? Color.blauPrimary : Color.gray,
                        shadowColor: gartenPfadStore.verfuegbareSpins > 0 ? Color.blauSecondary : Color.gray.darker()
                    ))
                    .disabled(isSpinning || gartenPfadStore.verfuegbareSpins == 0)
                    .padding(.horizontal, 30)
                    
                    // Back to Pass Button (3D) - Only show when NO SPINS LEFT
                    if !isSpinning && gartenPfadStore.verfuegbareSpins == 0 {
                        Button(action: {
                            // Delay for premium 3D feeling (pop-back animation)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                                dismiss()
                            }
                        }) {
                            Text(NSLocalizedString("ice_wheel_back_button", comment: ""))
                                .font(.system(size: 16, weight: .bold))
                        }
                        .buttonStyle(DuolingoButtonStyle(
                            size: .medium,
                            fillWidth: false,
                            backgroundColor: .white,
                            shadowColor: Color.gray.opacity(0.3),
                            foregroundColor: .primary
                        ))
                        .padding(.top, 10)
                        .padding(.bottom, 40)
                    }
                }
                .padding(.top, 40)
            }
            
            // Result Overlay
            if showResultOverlay, let reward = wonReward {
                IceRewardOverlay(reward: reward) {
                    withAnimation {
                        showResultOverlay = false
                        wonReward = nil
                    }
                }
                .transition(.opacity.combined(with: .scale(scale: 0.9)))
                .zIndex(100)
            }
        }
    }
    
    private func spinWheel() {
        guard !isSpinning && gartenPfadStore.verfuegbareSpins > 0 else { return }
        isSpinning = true
        gartenPfadStore.spinVerbrauchen()
        gardenStore.gluecksradDrehungen = gartenPfadStore.verfuegbareSpins // Keep in sync optionally or stick to PfadStore
        
        let result = GartenPassWheelLogic.spin(decorationCount: gardenStore.placedDecorations.count)
        wonReward = result.belohnung
        
        let segDeg = 360.0 / Double(totalSegments)
        let targetIndex = result.index
        let rf = Double.random(in: 0.15...0.85)
        let sliceAngle = Double(targetIndex) * segDeg + rf * segDeg
        
        let fullSpins = 5.0 * 360.0
        let targetRotation = rotation + fullSpins + (360.0 - sliceAngle)
        
        // Tick haptics during spin
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
        
        withAnimation(.timingCurve(0.15, 0.85, 0.35, 1.0, duration: spinDuration)) {
            rotation = targetRotation
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + spinDuration + 0.3) {
            FeedbackManager.shared.playSuccess()
            gardenStore.einloesenGartenPassBelohnung(belohnung: result.belohnung)
            withAnimation(.spring(response: 0.42, dampingFraction: 0.65)) {
                showResultOverlay = true
            }
            isSpinning = false
        }
    }
}

// MARK: - Wheel Slices (Adapted Colors for original design)
struct IceWheelSlices: View {
    let segments: [GartenPassSpinBelohnung]
    
    var body: some View {
        GeometryReader { geo in
            let rect = geo.frame(in: .local)
            let center = CGPoint(x: rect.midX, y: rect.midY)
            let radius = min(rect.width, rect.height) / 2
            let count = max(segments.count, 1)
            let segDeg = 360.0 / Double(count)
            
            ZStack {
                ForEach(0..<count, id: \.self) { i in
                    let reward = segments[i]
                    let startDeg = -90.0 + Double(i) * segDeg
                    let endDeg   = startDeg + segDeg
                    let midDeg   = startDeg + segDeg / 2
                    let midRad   = midDeg * .pi / 180
                    let iconR = radius * 0.62
                    
                    let color = colorFor(i)
                    
                    Path { path in
                        path.move(to: center)
                        path.addArc(center: center, radius: radius, startAngle: .degrees(startDeg), endAngle: .degrees(endDeg), clockwise: false)
                        path.closeSubpath()
                    }
                    .fill(color)
                    
                    Path { path in
                        path.move(to: center)
                        path.addArc(center: center, radius: radius, startAngle: .degrees(startDeg), endAngle: .degrees(endDeg), clockwise: false)
                    }
                    .stroke(Color.black.opacity(0.4), lineWidth: 2)
                    
                    IceWheelIcon(reward: reward)
                        .rotationEffect(.degrees(midDeg + 90))
                        .position(
                            x: center.x + CGFloat(cos(midRad)) * iconR,
                            y: center.y + CGFloat(sin(midRad)) * iconR
                        )
                }
            }
        }
    }
    
    func colorFor(_ index: Int) -> Color {
        // Alternating colors like original gold/safe/weed but using blues/purples
        if index < segments.count && segments[index] == .weed {
            return Color.orangePrimary.opacity(0.8)
        }
        
        if index == 11 { return Color.coinBlue } // Jackpot Mega
        if index % 4 == 0 { return Color.blauSecondary }
        if index % 2 == 0 { return Color.gruenPrimary }
        return Color.blauPrimary
    }
}

struct IceWheelIcon: View {
    let reward: GartenPassSpinBelohnung
    
    var body: some View {
        Group {
            switch reward {
            case .coins(_):
                Image("coin")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
            case .powerUp(let id):
                if let pu = GameDatabase.allPowerUps.first(where: { $0.id == id }) {
                    Image(pu.symbolName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 26, height: 26)
                } else {
                    Image(systemName: "bolt.fill")
                        .foregroundColor(.white)
                }
            case .pflanze(_):
                Image(systemName: "leaf.fill")
                    .foregroundColor(.white)
            case .deko(_):
                Image(systemName: "sparkles")
                    .foregroundColor(.white)
            case .xp(_):
                Image(systemName: "star.fill")
                    .foregroundColor(.white)
            case .seeds(_):
                Image(systemName: "leaf.fill")
                    .foregroundColor(.white)
            case .weed:
                Image(systemName: "ant.fill")
                    .foregroundColor(.white)
            }
        }
        .font(.system(size: 24, weight: .bold))
    }
}

// MARK: - Reward Overlay (Matches original SpinResultOverlay style)
struct IceRewardOverlay: View {
    let reward: GartenPassSpinBelohnung
    let onDismiss: () -> Void
    
    @State private var contentOpacity: Double = 0
    @State private var iconScale: CGFloat = 0.5
    
    var body: some View {
        ZStack {
            // Dunkles Dimming
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            // schwebende Card
            VStack(spacing: 16) {
                // Icon in blauem Kreis
                ZStack {
                    Circle()
                        .fill(Color.blauPrimary.opacity(0.15))
                        .frame(width: 88, height: 88)
                    
                    IceWheelIcon(reward: reward)
                        .scaleEffect(1.5)
                        .foregroundColor(Color.blauPrimary)
                }
                .scaleEffect(iconScale)
                
                // Titel
                Text(NSLocalizedString("wheel_gewonnen", comment: ""))
                    .font(.title2.bold())
                    .foregroundColor(.primary)
                
                // Gewinn-Text
                Text(rewardName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                // 3D Button - Weiter
                Button {
                    // Delay for premium 3D feeling (pop-back animation)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
                        onDismiss()
                    }
                } label: {
                    Text(NSLocalizedString("wheel_weiter", comment: ""))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(DuolingoButtonStyle(size: .large))
                .padding(.top, 8)
            }
            .padding(28)
            .background(
                ZStack(alignment: .bottom) {
                    // 3D Shadow Layer (Base)
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color(hex: "#E0E0E0"))
                        .offset(y: 8)
                    
                    // Main White Surface
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color(UIColor.systemBackground))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .stroke(Color.black.opacity(0.1), lineWidth: 1.5)
                        )
                }
            )
            .padding(.horizontal, 28)
            .opacity(contentOpacity)
        }
        .overlay(
            SafeDotLottieView(
                url: "https://lottie.host/e9ce3227-f1fc-4135-9b98-b1f578638775/77KBz7dIev.lottie",
                animationConfig: AnimationConfig(autoplay: true, loop: false),
                fixedSize: CGSize(width: 800, height: 800)
            )
            .frame(width: 800, height: 800)
            .allowsHitTesting(false)
            .opacity(contentOpacity)
        )
        .onAppear {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.7)) {
                contentOpacity = 1.0
                iconScale = 1.0
            }
        }
    }
    
    private var rewardName: String {
        switch reward {
        case .coins(let n):
            return String(format: NSLocalizedString("reward.coins_format", comment: ""), n)
        case .powerUp(let id):
            return NSLocalizedString(id, comment: "")
        case .pflanze(let id):
            return NSLocalizedString(id + ".name", comment: "")
        case .deko(_):
            return NSLocalizedString("wheel.reward.deko", comment: "")
        case .xp(let n):
            return "\(n) \(NSLocalizedString("pass.xp", comment: ""))"
        case .seeds(let n):
            return String(format: NSLocalizedString("reward.seeds_format", comment: ""), n)
        case .weed:
            return NSLocalizedString("wheel.reward.weed", comment: "")
        }
    }
}
