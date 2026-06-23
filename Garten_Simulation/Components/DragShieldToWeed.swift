import SwiftUI

private struct WeedDotAnchor: Equatable {
    let index: Int
    let center: CGPoint
}

private struct WeedDotPreferenceKey: PreferenceKey {
    static var defaultValue: [WeedDotAnchor] = []
    static func reduce(value: inout [WeedDotAnchor], nextValue: () -> [WeedDotAnchor]) {
        value.append(contentsOf: nextValue())
    }
}

private struct PopParticle: Identifiable {
    let id = UUID()
    let angle: Double
    var distance: CGFloat
    var scale: CGFloat
    var opacity: Double
    var color: Color
}

/// Ziehe das Schutzschild auf die nummerierten Felder – Slam von oben, Karte drückt sich runter.
struct DragShieldToWeed: View {
    let shieldedIndices: Set<Int>
    let onShieldApplied: (Int) -> Void
    var coordinateSpaceName: String = "weedShieldSpace"
    var isDisabled: Bool = false

    @State private var dragOffset = CGSize.zero
    @State private var isDragging = false
    @State private var hoveredIndex: Int?
    @State private var letzterHover: Int?
    @State private var schildSkalierung: CGFloat = 1.0
    @State private var dragShieldVisible = true
    @State private var dotAnchors: [WeedDotAnchor] = []
    @State private var slamShieldPosition: CGPoint?
    @State private var impactPressedIndices: Set<Int> = []
    @State private var popParticles: [PopParticle] = []
    @State private var impactCenter: CGPoint?
    @State private var ringScale: CGFloat = 0.5
    @State private var ringOpacity: Double = 0.0
    @State private var slamInProgress = false
    @State private var phase: CGFloat = 0

    private let schildIconSize: CGFloat = 64
    private let trefferRadius: CGFloat = 32
    private let buttonDepth: CGFloat = 6
    private let dotSize: CGFloat = 80

    var body: some View {
        ZStack {
            VStack(spacing: 10) {
                Color.clear
                    .frame(maxWidth: .infinity, minHeight: 140, maxHeight: 140)
                shieldTargetsRow
            }
            .zIndex(0)

            shieldDragLayer
                .zIndex(1)

            slamAndSmokeOverlay
                .zIndex(2)
        }
        .coordinateSpace(.named(coordinateSpaceName))
        .onPreferenceChange(WeedDotPreferenceKey.self) { anchors in
            dotAnchors = anchors
        }
        .onAppear {
            withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                phase -= 20
            }
        }
    }

    // MARK: - Schild-Layer

    private var shieldDragLayer: some View {
        GeometryReader { geo in
            let bounds = geo.frame(in: .named(coordinateSpaceName))
            let shieldHome = CGPoint(x: bounds.midX, y: bounds.minY + 50)

            ZStack {
                if dragShieldVisible, slamShieldPosition == nil {
                    draggableShield(at: shieldHome)
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .allowsHitTesting(!isDisabled && !slamInProgress && shieldedIndices.count < GameConstants.habitsRequiredPerWeed)
    }

    private func draggableShield(at home: CGPoint) -> some View {
        let dragGesture = DragGesture(coordinateSpace: .named(coordinateSpaceName))
            .onChanged { value in
                guard !isDisabled, !slamInProgress,
                      shieldedIndices.count < GameConstants.habitsRequiredPerWeed else { return }

                if !isDragging { isDragging = true }

                var t = Transaction()
                t.animation = nil
                withTransaction(t) {
                    dragOffset = value.translation
                }

                let hit = nearestOpenTarget(to: value.location)
                let changed = hit != letzterHover
                hoveredIndex = hit

                if changed {
                    letzterHover = hit
                    withAnimation(.spring(response: 0.26, dampingFraction: 0.68)) {
                        schildSkalierung = hit != nil ? 1.15 : 1.0
                    }
                    if hit != nil { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
                }
            }
            .onEnded { value in
                guard !isDisabled, !slamInProgress else { return }

                if let index = nearestOpenTarget(to: value.location) {
                    performSlam(to: index, from: value.location)
                } else {
                    resetDragShield(animated: true)
                }
            }

        return shieldIconView(size: 88)
            .padding(18)
            .contentShape(Rectangle())
            .simultaneousGesture(dragGesture)
            .brightness(hoveredIndex != nil ? 0.1 : 0)
            .scaleEffect(schildSkalierung)
            .shadow(color: Color.black.opacity(isDragging ? 0.22 : 0.12), radius: isDragging ? 10 : 5, y: 3)
            .offset(dragOffset)
            .position(home)
            .animation(.spring(response: 0.26, dampingFraction: 0.68), value: hoveredIndex)
    }

    // MARK: - Ziel-Felder 1 · 2 · 3

    private var shieldTargetsRow: some View {
        HStack(spacing: 28) {
            ForEach(0..<GameConstants.habitsRequiredPerWeed, id: \.self) { index in
                shieldTargetDot(index: index)
            }
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private func shieldTargetDot(index: Int) -> some View {
        let shielded = shieldedIndices.contains(index)
        let highlighted = hoveredIndex == index && isDragging && !shielded
        let pressed = shielded || impactPressedIndices.contains(index)
        let faceY = pressed ? buttonDepth : (highlighted ? 2 : 0)

        ZStack {
            if highlighted {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(
                        Color.goldPrimary,
                        style: StrokeStyle(
                            lineWidth: 3,
                            lineCap: .round,
                            lineJoin: .round,
                            dash: [8, 6],
                            dashPhase: phase
                        )
                    )
                    .frame(width: dotSize + 16, height: dotSize + 16)
                    .offset(y: -buttonDepth + faceY)
                    .shadow(color: Color.goldPrimary.opacity(0.4), radius: 8)
            }

            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(shadowFill(shielded: shielded, highlighted: highlighted))
                .frame(width: dotSize, height: dotSize)

            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(faceFill(shielded: shielded, highlighted: highlighted))
                .frame(width: dotSize, height: dotSize)
                .offset(y: -buttonDepth + faceY)

            if shielded {
                Image(PowerUpWeedSupport.unkrautSchildAssetName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 64, height: 64)
                    .shadow(color: .black.opacity(0.15), radius: 1, y: 1)
                    .offset(y: -buttonDepth + faceY)
                    .transition(.scale(scale: 0.4).combined(with: .opacity))
            } else {
                Text("\(index + 1)")
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundStyle(.white.opacity(highlighted ? 1 : 0.65))
                    .offset(y: -buttonDepth + faceY)
            }
        }
        .scaleEffect(shielded ? 1.15 : 1.0)
        .frame(width: dotSize, height: dotSize + buttonDepth, alignment: .top)
        .allowsHitTesting(false)
        .background(
            GeometryReader { geo in
                let frame = geo.frame(in: .named(coordinateSpaceName))
                Color.clear.preference(
                    key: WeedDotPreferenceKey.self,
                    value: [WeedDotAnchor(
                        index: index,
                        center: CGPoint(x: frame.midX, y: frame.midY - buttonDepth / 2)
                    )]
                )
            }
        )
        .animation(.spring(response: 0.14, dampingFraction: 0.72), value: pressed)
        .animation(.spring(response: 0.22, dampingFraction: 0.65), value: highlighted)
    }

    // MARK: - Slam + Rauch

    private var slamAndSmokeOverlay: some View {
        GeometryReader { geo in
            ZStack {
                if let center = impactCenter {
                    // Clean, flat expanding ring
                    Circle()
                        .strokeBorder(Color.white, lineWidth: 6)
                        .frame(width: dotSize * ringScale, height: dotSize * ringScale)
                        .position(center)
                        .opacity(ringOpacity)

                    // Solid confetti particles
                    ForEach(popParticles) { p in
                        let rad = p.angle * .pi / 180
                        Circle()
                            .fill(p.color)
                            .frame(width: p.scale * 10, height: p.scale * 10)
                            .position(
                                x: center.x + cos(rad) * p.distance,
                                y: center.y + sin(rad) * p.distance
                            )
                            .opacity(p.opacity)
                    }
                }

                if let pos = slamShieldPosition {
                    shieldIconView(size: schildIconSize * 1.05)
                        .shadow(color: Color.black.opacity(0.2), radius: 8, y: 3)
                        .position(pos)
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .allowsHitTesting(false)
    }

    private func shieldIconView(size: CGFloat) -> some View {
        Image(PowerUpWeedSupport.unkrautSchildAssetName)
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
    }

    // MARK: - Slam

    private func performSlam(to index: Int, from dropLocation: CGPoint) {
        guard let anchor = dotAnchors.first(where: { $0.index == index }) else {
            resetDragShield(animated: true)
            return
        }

        let target = anchor.center
        let start = dropLocation

        slamInProgress = true
        isDragging = false
        hoveredIndex = nil
        letzterHover = nil
        dragOffset = .zero
        dragShieldVisible = false
        slamShieldPosition = start
        schildSkalierung = 1.0

        withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
            slamShieldPosition = target
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            spawnPop(at: target)

            _ = withAnimation(.spring(response: 0.12, dampingFraction: 0.78)) {
                impactPressedIndices.insert(index)
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onShieldApplied(index)
            slamShieldPosition = nil
            slamInProgress = false
            let doneAfterHit = shieldedIndices.count + 1 >= GameConstants.habitsRequiredPerWeed
            dragShieldVisible = !doneAfterHit
        }
    }

    private func spawnPop(at center: CGPoint) {
        impactCenter = center
        ringScale = 0.5
        ringOpacity = 1.0

        let colors: [Color] = [.white, Color(red: 0.35, green: 0.70, blue: 0.95), Color(red: 0.15, green: 0.55, blue: 0.85)]

        popParticles = (0..<24).map { i in
            PopParticle(
                angle: Double.random(in: 0...360),
                distance: CGFloat.random(in: 15...35),
                scale: CGFloat.random(in: 0.3...0.7),
                opacity: 1.0,
                color: colors.randomElement()!
            )
        }

        // Ring expanding and fading
        withAnimation(.easeOut(duration: 0.4)) {
            ringScale = 2.0
            ringOpacity = 0.0
        }

        // Particles flying out
        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
            popParticles = popParticles.map { p in
                var newP = p
                newP.distance *= 2.5
                return newP
            }
        }

        // Particles fading out slightly later
        withAnimation(.easeIn(duration: 0.2).delay(0.2)) {
            popParticles = popParticles.map { p in
                var newP = p
                newP.scale = 0.1
                newP.opacity = 0
                return newP
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
            popParticles = []
            impactCenter = nil
        }
    }

    // MARK: - Helpers

    private func nearestOpenTarget(to point: CGPoint) -> Int? {
        var best: (index: Int, dist: CGFloat)?
        for anchor in dotAnchors where !shieldedIndices.contains(anchor.index) {
            let d = hypot(point.x - anchor.center.x, point.y - anchor.center.y)
            guard d < trefferRadius else { continue }
            if best == nil || d < best!.dist {
                best = (anchor.index, d)
            }
        }
        return best?.index
    }

    private func resetDragShield(animated: Bool) {
        let reset = {
            dragOffset = .zero
            isDragging = false
            hoveredIndex = nil
            letzterHover = nil
            schildSkalierung = 1.0
            dragShieldVisible = true
        }
        if animated {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.72)) { reset() }
        } else {
            reset()
        }
    }

    private func shadowFill(shielded: Bool, highlighted: Bool) -> Color {
        if shielded { return Color(red: 0.15, green: 0.45, blue: 0.75) }
        if highlighted { return Color(red: 0.15, green: 0.55, blue: 0.85) }
        return Color(red: 0.58, green: 0.58, blue: 0.58)
    }

    private func faceFill(shielded: Bool, highlighted: Bool) -> Color {
        if shielded { return Color(red: 0.35, green: 0.70, blue: 0.95) }
        if highlighted { return Color(red: 0.45, green: 0.85, blue: 1.0) }
        return Color(red: 0.80, green: 0.80, blue: 0.80)
    }
}
