import SwiftUI
import DotLottie

// MARK: - Segment type for wheel layout
enum SegmentKind: Equatable {
    case weed, safe, gold
}

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
    @State private var powerUpActivated: Bool = false
    
    // UI Layout Config
    private let wheelSize: CGFloat = 310
    private let totalSegments = 12
    
    var probWeed: Double {
        return DailySpinLogic.currentWeedProbability(ownedItemsCount: gardenStore.totalItemsCount)
    }
    
    /// Generate an evenly-distributed segment layout with 1 gold, N weed, rest safe.
    /// Segments of the same kind are spaced as far apart as possible.
    func generateLayout() -> [SegmentKind] {
        let weedCount = min(totalSegments - 1, max(0, Int(round(probWeed * Double(totalSegments - 1)))))
        _ = totalSegments - 1 - weedCount
        
        // Start with all safe slots
        var slots: [SegmentKind] = Array(repeating: .safe, count: totalSegments)
        
        // Place gold at a random position first
        let goldIndex = Int.random(in: 0..<totalSegments)
        slots[goldIndex] = .gold
        
        // Collect non-gold indices
        let freeIndices = (0..<totalSegments).filter { $0 != goldIndex }
        
        // Distribute weed segments evenly among the free slots
        if weedCount > 0 && !freeIndices.isEmpty {
            let step = Double(freeIndices.count) / Double(weedCount)
            let offset = Int.random(in: 0..<max(1, Int(step)))
            for w in 0..<weedCount {
                let freeIdx = min(freeIndices.count - 1, Int(Double(w) * step) + offset)
                slots[freeIndices[freeIdx]] = .weed
            }
        }
        
        return slots
    }
    
    var body: some View {
        ZStack {
            // Background
            Color(UIColor.systemBackground).ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 30) {
                    // Header
                    VStack(spacing: 6) {
                        Button {
                            FeedbackManager.shared.playTap()
                        } label: {
                            Text(settings.localizedString(for: "dailyspin.title"))
                        }
                        .buttonStyle(Pressed3DTextButtonStyle())
                        
                        Text(settings.localizedString(for: "dailyspin.subtitle"))
                            .font(.system(size: 15, weight: .regular))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.bottom, 4)
                    
                    // Wheel Assembly — 3D Two-Layer Effect (like Item3DButton)
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
                            .disabled(isSpinning || (!gardenStore.isDailySpinAvailable && gardenStore.gluecksradDrehungen <= 0))
                        }
                        .frame(width: wheelSize + 38, height: wheelSize + 38 + 6)
                    }
                    .padding(.vertical, 10)
                    
                    // Unkraut-Gefahr / Probability Info
                    if !showResult {
                        VStack(spacing: 8) {
                            if powerUpActivated {
                                HStack(spacing: 6) {
                                    Image(systemName: "shield.checkered")
                                        .foregroundStyle(.green)
                                    Text(String(format: settings.localizedString(for: "dailyspin.weed.danger"), 0))
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundStyle(.green)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.green.opacity(0.12), in: Capsule())
                            } else {
                                HStack(spacing: 6) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundStyle(Color.orange)
                                    Text(String(format: settings.localizedString(for: "dailyspin.weed.danger"), Int(probWeed * 100)))
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundStyle(Color.orange)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.orange.opacity(0.12), in: Capsule())
                            }
                        }
                        .opacity(isSpinning ? 0 : 1)
                    }
                    
                    // Power-Up Button (3D Item Button)
                    if !isSpinning, !powerUpActivated,
                       gardenStore.gekaufteItems.contains(where: { $0.id == "powerup.zauberstab" }) {
                        
                        Item3DButton(
                            icon: "backpack.fill",
                            farbe: .gruenPrimary,
                            sekundaerFarbe: .gruenSecondary,
                            groesse: 56
                        ) {
                            FeedbackManager.shared.playSuccess()
                            powerUpActivated = true
                            if let item = gardenStore.gekaufteItems.first(where: { $0.id == "powerup.zauberstab" }) {
                                if let p = GameDatabase.allPowerUps.first(where: { $0.id == item.id }) {
                                    gardenStore.applyPowerUp(p)
                                    gardenStore.itemVerbrauchen(shopItem: item)
                                }
                            }
                        }
                        .padding(.top, 4)
                    }
                    
                    // MARK: Actions
                    
                    // Unkraut-Bot re-spin button
                    if showResult, spinResult == .weed, gardenStore.hasActivePowerUp(powerUpId: "powerup.zauberstab") {
                        Button(action: {
                            FeedbackManager.shared.playSuccess()
                            showResult = false
                            spinResult = nil
                            spinWheel()
                        }) {
                            HStack {
                                Image(systemName: "cpu")
                                Text("Bot nutzen: Nochmal drehen!")
                            }
                        }
                        .buttonStyle(DuolingoButtonStyle(
                            size: .large,
                            backgroundColor: .orange,
                            shadowColor: .orange.darker()
                        ))
                        .padding(.horizontal, 30)
                        .padding(.bottom, 12)
                    }
                    
                    // Main Action Button
                    Button(action: handleSpinAction) {
                        if gardenStore.isDailySpinAvailable {
                            Text(settings.localizedString(for: "spin_button_gratis"))
                        } else if gardenStore.gluecksradDrehungen > 0 {
                            Text(String(format: settings.localizedString(for: "spin_button_mit_anzahl"), gardenStore.gluecksradDrehungen))
                        } else {
                            Text(settings.localizedString(for: "spin_button_keine"))
                        }
                    }
                    .buttonStyle(DuolingoButtonStyle(
                        size: .large,
                        backgroundColor: (gardenStore.isDailySpinAvailable || gardenStore.gluecksradDrehungen > 0) ? .blauPrimary : .secondary,
                        shadowColor: (gardenStore.isDailySpinAvailable || gardenStore.gluecksradDrehungen > 0) ? .blauSecondary : .secondary.darker()
                    ))
                    .disabled(isSpinning || (!gardenStore.isDailySpinAvailable && gardenStore.gluecksradDrehungen <= 0))
                    .padding(.horizontal, 30)
                    
                    if !gardenStore.isDailySpinAvailable && gardenStore.gluecksradDrehungen <= 0 {
                        Text(settings.localizedString(for: "dailyspin.no_spins_hint"))
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.secondary)
                            .padding(.top, -10)
                    }
                    
                    Spacer().frame(height: 40)
                }
                .padding(.top, 40)
                .frame(minHeight: 800) // Avoid deprecated UIScreen.main.bounds.height for minHeight
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
                .transition(.opacity.combined(with: .scale(scale: 0.9)))
            }
        }
        .sheet(isPresented: $showPowerUpPicker) {
            WheelPowerUpPickerView(onPowerUpUsed: {
                if showResult && spinResult == .weed {
                    showResult = false
                    spinResult = nil
                    spinWheel()
                }
            })
            .presentationDetents([.medium, .large])
        }
        .onAppear {
            if segmentLayout.isEmpty {
                segmentLayout = generateLayout()
            }
        }
    }

    private func handleSpinAction() {
        guard !isSpinning else { return }
        
        if gardenStore.isDailySpinAvailable {
            // Kostenlose tägliche Drehung
            FeedbackManager.shared.playTap()
            spinWheel()
        } else if gardenStore.gluecksradDrehungen > 0 {
            // Bezahlte/Gearned Drehung
            FeedbackManager.shared.playTap()
            _ = gardenStore.gluecksradDrehungVerbrauchen()
            spinWheel()
        } else {
            FeedbackManager.shared.playError()
        }
    }
    
    private func spinWheel() {
        isSpinning = true

        let result: SpinResult
        if powerUpActivated {
            result = .safe
        } else {
            result = DailySpinLogic.spin(ownedItemsCount: gardenStore.totalItemsCount)
        }
        spinResult = result

        // Find matching segment indices in the shuffled layout
        let targetKind: SegmentKind
        switch result {
        case .weed:   targetKind = .weed
        case .safe:   targetKind = .safe
        case .coins:  targetKind = .gold
        }
        let matchingIndices = segmentLayout.enumerated().compactMap { $0.element == targetKind ? $0.offset : nil }
        let segDeg = 360.0 / Double(totalSegments)
        
        // Pick a random matching segment and target its center
        let targetIndex = matchingIndices.randomElement() ?? 0
        let rf = Double.random(in: 0.15...0.85)
        let sliceAngle = Double(targetIndex) * segDeg + rf * segDeg

        let fullSpins = 5.0 * 360.0
        let targetRotation = rotation + fullSpins + (360.0 - sliceAngle)
        
        // Tick haptics during spin
        let tickCount = Int(fullSpins / segDeg) + totalSegments
        let spinDuration: Double = 3.5
        for tick in 0..<tickCount {
            let progress = Double(tick) / Double(tickCount)
            // Ease-out timing: ticks slow down toward the end
            let easedTime = progress * spinDuration * (2.0 - progress)
            let delay = min(easedTime, spinDuration - 0.1)
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                if isSpinning {
                    FeedbackManager.shared.playTick()
                }
            }
        }

        // Improved spin physics: fast start, smooth deceleration
        withAnimation(
            .timingCurve(0.15, 0.85, 0.35, 1.0, duration: spinDuration)
        ) {
            rotation = targetRotation
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + spinDuration + 0.3) {
            withAnimation(.spring(response: 0.4)) {
                showResult = true
            }
            // Show the result overlay after a brief delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                let res = result
                if res == .weed {
                    FeedbackManager.shared.playError()
                } else {
                    FeedbackManager.shared.playSuccess()
                }
                
                withAnimation(.spring(response: 0.42, dampingFraction: 0.65)) {
                    showResultOverlay = true
                }
            }
        }
    }

    private func finishSpin() {
        switch spinResult {
        case .weed:
            gardenStore.isWeedActive = true
        case .safe:
            gardenStore.isWeedActive = false
        case .coins(let amount):
            gardenStore.isWeedActive = false
            gardenStore.coinsGutschreiben(amount: amount, beschreibung: "🎰 Daily Spin Jackpot")
        case nil:
            break
        }
        gardenStore.dailyQuestsCompletedSinceWeed = 0
        gardenStore.lastSpinTimestamp = Date()
        gardenStore.showDailySpinOverlay = false
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

// MARK: - Generic 3D Wrapper Button Style
struct Press3DWrapperButtonStyle: ButtonStyle {
    var depth: CGFloat = 6
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .offset(y: configuration.isPressed ? depth : 0)
            .animation(.spring(response: 0.15, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - SpinResultIconView
private struct SpinResultIconView: View {
    let result: SpinResult

    var body: some View {
        ZStack {
            switch result {
            case .safe:
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 72, weight: .bold))
                    .foregroundStyle(Color.gruenPrimary)
                    .shadow(color: .green.opacity(0.25), radius: 8, x: 0, y: 4)

            case .coins(_):
                Image(systemName: "dollarsign.circle.fill")
                    .font(.system(size: 72, weight: .bold))
                    .foregroundStyle(Color.coinBlue)
                    .shadow(color: Color.coinBlue.opacity(0.25), radius: 8, x: 0, y: 4)

            case .weed:
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 72, weight: .bold))
                    .foregroundStyle(Color.red)
                    .shadow(color: .red.opacity(0.25), radius: 8, x: 0, y: 4)
            }
        }
        .frame(height: 140)
    }
}

// MARK: - SpinResultOverlay
// MARK: - SpinResultOverlay
struct SpinResultOverlay: View {
    let result: SpinResult
    let onDismiss: () -> Void
    @EnvironmentObject var settings: SettingsStore

    @State private var contentOpacity: Double = 0
    @State private var iconScale: CGFloat = 0.5

    private var overlayTitel: String {
        switch result {
        case .safe:     return NSLocalizedString("spin.result.nichts.titel", comment: "")
        case .coins(_): return NSLocalizedString("spin.result.muenzen.titel", comment: "")
        case .weed:     return NSLocalizedString("spin.result.unkraut.titel", comment: "")
        }
    }

    private var overlayUntertitel: String {
        switch result {
        case .safe:
            return NSLocalizedString("spin.result.nichts.untertitel", comment: "")
        case .coins(let anzahl):
            return String(format: NSLocalizedString("spin.result.muenzen.untertitel", comment: ""), anzahl)
        case .weed:
            return NSLocalizedString("spin.result.unkraut.untertitel", comment: "")
        }
    }

    var body: some View {
        ZStack {
            // Konfetti ganz unten, hinter allem
            if result == .safe {
                DotLottieAnimation(
                    webURL: "https://lottie.host/e9ce3227-f1fc-4135-9b98-b1f578638775/77KBz7dIev.lottie",
                    config: AnimationConfig(autoplay: true, loop: false)
                ).view()
                .ignoresSafeArea()
                .allowsHitTesting(false)
            }

            Color.black.opacity(0.45)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                // Icon (kein Lottie hier)
                SpinResultIconView(result: result)
                    .scaleEffect(iconScale)

                VStack(spacing: 8) {
                    Text(overlayTitel)
                        .font(.title2.bold())
                        .multilineTextAlignment(.center)

                    Text(overlayUntertitel)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                // Button bei allen drei Zuständen
                Button(action: onDismiss) {
                    Text(settings.localizedString(for: "dailyspin.button.continue"))
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                }
                .buttonStyle(DuolingoButtonStyle(
                    size: .large,
                    fillWidth: true,
                    backgroundColor: result == .weed ? .red : .gruenPrimary,
                    shadowColor: (result == .weed ? Color.red : Color.gruenPrimary).darker(),
                    foregroundColor: .white
                ))
            }
            .padding(28)
            .background(
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(Color(UIColor.systemBackground))
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

// MARK: - WheelSlices (Solid Color Segments)
struct WheelSlices: View {
    let layout: [SegmentKind]

    var body: some View {
        GeometryReader { geo in
            let rect = geo.frame(in: .local)
            let center = CGPoint(x: rect.midX, y: rect.midY)
            let radius = min(rect.width, rect.height) / 2
            let count = max(layout.count, 1)
            let segDeg = 360.0 / Double(count)

            ZStack {
                ForEach(0..<count, id: \.self) { i in
                    let kind = i < layout.count ? layout[i] : .safe
                    let startDeg = -90.0 + Double(i) * segDeg
                    let endDeg   = startDeg + segDeg
                    let midDeg   = startDeg + segDeg / 2
                    let midRad   = midDeg * .pi / 180
                    let iconR = radius * 0.62
                    
                    let color = colorFor(kind)

                    // Segment fill with solid color
                    Path { path in
                        path.move(to: center)
                        path.addArc(center: center, radius: radius,
                                    startAngle: .degrees(startDeg),
                                    endAngle: .degrees(endDeg),
                                    clockwise: false)
                        path.closeSubpath()
                    }
                    .fill(color)

                    // Segment divider
                    Path { path in
                        path.move(to: center)
                        path.addArc(center: center, radius: radius,
                                    startAngle: .degrees(startDeg),
                                    endAngle: .degrees(endDeg),
                                    clockwise: false)
                        path.closeSubpath()
                    }
                    .stroke(Color.black.opacity(0.4), lineWidth: 2)

                    // Per-segment icon — radially rotated
                    WheelSegmentIcon(kind: kind)
                        .rotationEffect(.degrees(midDeg + 90))
                        .position(
                            x: center.x + CGFloat(cos(midRad)) * iconR,
                            y: center.y + CGFloat(sin(midRad)) * iconR
                        )
                }
            }
        }
    }
    
    func colorFor(_ kind: SegmentKind) -> Color {
        switch kind {
        case .safe: return Color.gruenPrimary
        case .weed: return Color.rotPrimary
        case .gold: return Color.coinBlue
        }
    }
}

// MARK: - WheelRimDot (Rounded Rectangles)
struct WheelRimDot: View {
    let index: Int
    let totalDots: Int
    let rimRadius: CGFloat

    var body: some View {
        let angle = Double(index) * (360.0 / Double(totalDots)) * .pi / 180.0 - .pi / 2.0
        let dx = CGFloat(cos(angle)) * rimRadius
        let dy = CGFloat(sin(angle)) * rimRadius
        RoundedRectangle(cornerRadius: 3)
            .fill(Color.white.opacity(0.85))
            .frame(width: 8, height: 8)
            .offset(x: dx, y: dy)
    }
}

// MARK: - WheelSegmentIcon
struct WheelSegmentIcon: View {
    let kind: SegmentKind

    var body: some View {
        switch kind {
        case .gold:
            Image(systemName: "dollarsign.circle.fill")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.white)
        case .weed:
            Image(systemName: "ant.fill")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.white)
        case .safe:
            Image(systemName: "leaf.fill")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.white)
        }
    }
}

// MARK: - WheelTrianglePointer
struct WheelTrianglePointer: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))  // tip pointing down
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

// MARK: - WheelPowerUpPickerView
struct WheelPowerUpPickerView: View {
    @EnvironmentObject var gardenStore: GardenStore
    @Environment(\.dismiss) var dismiss
    var onPowerUpUsed: () -> Void
    
    var usableItems: [ShopDetailPayload] {
        gardenStore.gekaufteItems.filter { $0.id == "powerup.zauberstab" }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appHintergrund.ignoresSafeArea()
                
                if usableItems.isEmpty {
                    VStack {
                        Image(systemName: "archivebox")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("Du hast noch keine Items.")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .padding(.top)
                        Text("Gehe in den Shop und kaufe dir welche!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(usableItems) { item in
                                Button {
                                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                    if let p = GameDatabase.allPowerUps.first(where: { $0.id == item.id }) {
                                        gardenStore.applyPowerUp(p)
                                        gardenStore.itemVerbrauchen(shopItem: item)
                                    }
                                    dismiss()
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        onPowerUpUsed()
                                    }
                                } label: {
                                    HStack(spacing: 16) {
                                        ZStack {
                                            Circle()
                                                .fill(item.color.opacity(0.2))
                                                .frame(width: 50, height: 50)
                                            if UIImage(named: item.icon) != nil {
                                                Image(item.icon)
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 30, height: 30)
                                            } else {
                                                Image(systemName: item.icon)
                                                    .font(.system(size: 24))
                                                    .foregroundColor(item.color)
                                            }
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(NSLocalizedString(item.title, comment: ""))
                                                .font(.headline)
                                                .foregroundColor(.primary)
                                            Text(NSLocalizedString(item.description, comment: ""))
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                                .lineLimit(2)
                                                .multilineTextAlignment(.leading)
                                        }
                                        Spacer()
                                        
                                        Text("Nutzen")
                                            .font(.subheadline.bold())
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(item.color)
                                            .clipShape(Capsule())
                                    }
                                    .padding()
                                    .background(Color(UIColor.secondarySystemGroupedBackground))
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Power-Ups verwenden")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fertig") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    WheelOfFortuneView()
        .environmentObject(GardenStore())
        .environmentObject(SettingsStore())
}
