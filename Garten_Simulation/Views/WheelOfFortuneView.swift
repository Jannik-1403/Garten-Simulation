import SwiftUI

// MARK: - Segment type for wheel layout
enum SegmentKind: Equatable {
    case weed, safe, gold
}

struct WheelOfFortuneView: View {
    @EnvironmentObject var gardenStore: GardenStore
    @Environment(\.dismiss) var dismiss
    
    @State private var rotation: Double = 0
    @State private var isSpinning = false
    @State private var spinResult: SpinResult? = nil
    @State private var showResult = false
    @State private var showPowerUpPicker = false
    @State private var segmentLayout: [SegmentKind] = []
    
    // UI Layout Config
    private let wheelSize: CGFloat = 280
    private let totalSegments = 12
    
    var probWeed: Double {
        if gardenStore.hatSchaedlingsschutz {
            return 0.0
        }
        return DailySpinLogic.currentWeedProbability(ownedItemsCount: gardenStore.totalItemsCount)
    }
    
    /// Generate an evenly-distributed segment layout with 1 gold, N weed, rest safe.
    /// Segments of the same kind are spaced as far apart as possible.
    func generateLayout() -> [SegmentKind] {
        let weedCount = min(totalSegments - 1, max(0, Int(round(probWeed * Double(totalSegments - 1)))))
        let safeCount = totalSegments - 1 - weedCount
        
        // Start with all safe slots
        var slots: [SegmentKind] = Array(repeating: .safe, count: totalSegments)
        
        // Place gold at a random position first
        let goldIndex = Int.random(in: 0..<totalSegments)
        slots[goldIndex] = .gold
        
        // Collect non-gold indices
        var freeIndices = (0..<totalSegments).filter { $0 != goldIndex }
        
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
                VStack(spacing: 8) {
                    Text("Daily Spin")
                        .font(.system(size: 34, weight: .black, design: .rounded))
                        .foregroundStyle(.primary)
                    
                    Text("Drehe das Rad, um in den Tag zu starten!")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
                
                // Wheel Assembly (Comic Style)
                VStack(spacing: -6) {
                    ZStack {
                        // Dark blue outer ring
                        Circle()
                            .fill(Color(red: 0.13, green: 0.18, blue: 0.35))
                            .frame(width: wheelSize + 38, height: wheelSize + 38)
                            .overlay(Circle().stroke(Color.black, lineWidth: 4))
                            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 8)
                        
                        // Spinning Wheel
                        WheelSlices(layout: segmentLayout)
                            .frame(width: wheelSize, height: wheelSize)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.black, lineWidth: 3))
                            .rotationEffect(.degrees(rotation))
                        
                        // White rivet dots on the rim
                        ForEach(0..<8, id: \.self) { i in
                            WheelRimDot(index: i, rimRadius: (wheelSize + 38) / 2.0 - 9.0)
                        }
                        
                        // Dark blue center axle
                        Circle()
                            .fill(Color(red: 0.13, green: 0.18, blue: 0.35))
                            .overlay(Circle().stroke(Color.black, lineWidth: 3))
                            .frame(width: 28, height: 28)
                        
                        // Yellow triangle stopper at top
                        WheelTrianglePointer()
                            .fill(Color.yellow)
                            .overlay(WheelTrianglePointer().stroke(Color.black, lineWidth: 2.5))
                            .frame(width: 28, height: 32)
                            .offset(y: -((wheelSize + 38) / 2) + 2)
                    }
                    .frame(width: wheelSize + 38, height: wheelSize + 38)
                    
                    // Trapezoid stand
                    WheelTrapezoidStand()
                        .fill(Color(red: 0.13, green: 0.18, blue: 0.35))
                        .overlay(WheelTrapezoidStand().stroke(Color.black, lineWidth: 3))
                        .frame(width: 160, height: 48)
                }
                .padding(.vertical, 10)
                
                // Result / Info Text
                if let result = spinResult, showResult {
                    VStack(spacing: 12) {
                        switch result {
                        case .weed:
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 40)).foregroundColor(.red)
                            Text("Unkraut-Befall!")
                                .font(.title2.bold()).foregroundColor(.red)
                            Text("Deine Erträge sind temporär reduziert. Erledige heute 3 Gewohnheiten, um das Unkraut zu entfernen!")
                                .font(.subheadline).multilineTextAlignment(.center)
                                .foregroundColor(.secondary).padding(.horizontal, 30)
                        case .safe:
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 40)).foregroundColor(.green)
                            Text("Sicher!")
                                .font(.title2.bold()).foregroundColor(.green)
                            Text("Dein Garten ist sicher für heute!")
                                .font(.subheadline).multilineTextAlignment(.center)
                                .foregroundColor(.secondary).padding(.horizontal, 30)
                        case .coins(let amount):
                            Text("🪙")
                                .font(.system(size: 52))
                            Text("+\(amount) Münzen!")
                                .font(.system(size: 28, weight: .black, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(colors: [.yellow, .orange], startPoint: .leading, endPoint: .trailing)
                                )
                            Text("Du hast das goldene Feld getroffen!")
                                .font(.subheadline).multilineTextAlignment(.center)
                                .foregroundColor(.secondary).padding(.horizontal, 30)
                        }
                    }
                    .transition(.scale.combined(with: .opacity))
                } else {
                    // Probability Info
                    VStack(spacing: 8) {
                        if gardenStore.hatSchaedlingsschutz {
                            Text("🛡️ Schädlingsschutz aktiv! (0% Gefahr)")
                                .font(.headline)
                                .foregroundColor(.green)
                        } else {
                            Text("Unkraut-Gefahr: \(Int(probWeed * 100))%")
                                .font(.headline)
                                .foregroundColor(probWeed > 0.5 ? .red : .orange)
                            
                            Text("Basiert auf \(gardenStore.totalItemsCount) besessenen Gegenständen.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .opacity(isSpinning ? 0 : 1)
                }
                
                Spacer()
                
                // MARK: Actions
                
                // Power-Up Inventar Button
                if (!isSpinning || showResult) {
                    VStack(spacing: 8) {
                        Item3DButton(
                            icon: "backpack.fill",
                            farbe: .indigo,
                            sekundaerFarbe: .indigo.opacity(0.5),
                            groesse: 56,
                            aktion: {
                                showPowerUpPicker = true
                            }
                        )
                        Text("Power-Up")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.secondary)
                    }
                    .padding(.bottom, 8)
                }
                
                if showResult, spinResult == .weed, gardenStore.hasActivePowerUp(powerUpId: "powerup.unkraut_bot") {
                    Button(action: {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
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
                Button(action: {
                    if showResult {
                        finishSpin()
                    } else if !isSpinning {
                        spinWheel()
                    }
                }) {
                    Text(showResult ? "Auf in den Garten!" : "Rad drehen")
                }
                .buttonStyle(DuolingoButtonStyle(
                    size: .large,
                    backgroundColor: showResult ? .green : .blue,
                    shadowColor: showResult ? .green.darker() : .blue.darker()
                ))
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
            }
            .padding(.top, 40)
            .frame(minHeight: UIScreen.main.bounds.height) // Ensures it vertically centers if there's enough room
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
}
    
    private func spinWheel() {
        isSpinning = true

        let result: SpinResult
        if gardenStore.hatSchaedlingsschutz {
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

        withAnimation(.timingCurve(0.1, 0.9, 0.2, 1, duration: 4.0)) {
            rotation = targetRotation
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.2) {
            withAnimation(.spring(response: 0.4)) {
                showResult = true
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

// MARK: - WheelSlices (Shuffled Layout)
struct WheelSlices: View {
    let layout: [SegmentKind]

    let safeColor = Color(red: 0.15, green: 0.75, blue: 0.25)
    let weedColor = Color(red: 0.95, green: 0.18, blue: 0.15)
    let goldColor = Color(red: 1.0,  green: 0.78, blue: 0.0)

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
                    let midRad   = (startDeg + segDeg / 2) * .pi / 180
                    let color: Color = kind == .gold ? goldColor : (kind == .weed ? weedColor : safeColor)
                    let iconR = radius * 0.62

                    // Segment fill
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
                    .stroke(Color.black, lineWidth: kind == .gold ? 3 : 2)

                    // Per-segment icon
                    WheelSegmentIcon(isWeed: kind == .weed, isGold: kind == .gold)
                        .position(
                            x: center.x + CGFloat(cos(midRad)) * iconR,
                            y: center.y + CGFloat(sin(midRad)) * iconR
                        )
                }
            }
        }
    }
}

// MARK: - WheelRimDot
struct WheelRimDot: View {
    let index: Int
    let rimRadius: CGFloat

    var body: some View {
        let angle = Double(index) * 45.0 * .pi / 180.0 - .pi / 2.0
        let dx = CGFloat(cos(angle)) * rimRadius
        let dy = CGFloat(sin(angle)) * rimRadius
        Circle()
            .fill(Color.white)
            .overlay(Circle().stroke(Color.black, lineWidth: 2))
            .frame(width: 14, height: 14)
            .offset(x: dx, y: dy)
    }
}

// MARK: - WheelSegmentIcon
struct WheelSegmentIcon: View {
    let isWeed: Bool
    var isGold: Bool = false

    var body: some View {
        if isGold {
            // Gold coin icon
            Image(systemName: "dollarsign.circle.fill")
                .font(.system(size: 16, weight: .black))
                .foregroundStyle(.black.opacity(0.75))
                .shadow(color: .white.opacity(0.6), radius: 1, x: 0, y: -0.5)
        } else if isWeed {
            // Weed icon
            Image(systemName: "leaf.fill")
                .font(.system(size: 14, weight: .black))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.6), radius: 1, x: 0.5, y: 0.5)
        } else {
            // Safe star
            WheelStar()
                .fill(Color.white)
                .overlay(WheelStar().stroke(Color.black, lineWidth: 1))
                .frame(width: 18, height: 18)
        }
    }
}

// MARK: - WheelStar
struct WheelStar: Shape {
    func path(in rect: CGRect) -> Path {
        let c = CGPoint(x: rect.midX, y: rect.midY)
        let outerR = min(rect.width, rect.height) / 2
        let innerR = outerR * 0.42
        var path = Path()
        for i in 0..<10 {
            let angle = Double(i) * 36.0 * .pi / 180.0 - .pi / 2
            let r: CGFloat = i % 2 == 0 ? outerR : innerR
            let pt = CGPoint(x: c.x + CGFloat(cos(angle)) * r,
                             y: c.y + CGFloat(sin(angle)) * r)
            i == 0 ? path.move(to: pt) : path.addLine(to: pt)
        }
        path.closeSubpath()
        return path
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

// MARK: - WheelTrapezoidStand
struct WheelTrapezoidStand: Shape {
    func path(in rect: CGRect) -> Path {
        let inset: CGFloat = 18
        var path = Path()
        path.move(to: CGPoint(x: rect.minX + inset, y: rect.minY))  // top-left
        path.addLine(to: CGPoint(x: rect.maxX - inset, y: rect.minY)) // top-right
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))         // bottom-right
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))         // bottom-left
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
        gardenStore.gekaufteItems.filter { $0.id == "powerup.schaedlingsschutz" || $0.id == "powerup.unkraut_bot" }
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
}
