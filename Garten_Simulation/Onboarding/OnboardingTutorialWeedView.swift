import SwiftUI

struct OnboardingTutorialWeedView: View {
    @EnvironmentObject var data: OnboardingData
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var gardenStore: GardenStore
    
    @State private var innerPose: IgelPose = .erklaert
    @State private var step: WeedTutorialStep = .intro
    @State private var rotation: Double = 0
    @State private var isSpinning = false
    @State private var showNext = false
    
    // UI Layout Config (Matching WheelOfFortuneView exactly)
    private let wheelSize: CGFloat = 310
    
    // Tutorial Layout: many weeds to show the "danger"
    private let tutorialLayout: [OnboardingSegmentKind] = [
        .safe, .weed, .safe, .weed, .gold, .weed,
        .safe, .weed, .safe, .weed, .safe, .weed
    ]
    
    enum WeedTutorialStep {
        case intro, buying, warning, wheel
    }
    
    var body: some View {
        VStack(spacing: 0) {
            OnboardingIgelView(
                pose: innerPose,
                sprechblasenText: bubbleText
            )
            .padding(.top, 20)
            
            Spacer()
            
            ZStack {
                switch step {
                case .intro, .buying:
                    VStack(spacing: 24) {
                        DecorationCard(decoration: GameDatabase.allTrashItems[0])
                            .scaleEffect(1.2)
                            .shadow(color: .black.opacity(0.1), radius: 20, y: 10)
                        
                        if step == .buying {
                            Button {
                                buyDecoration()
                            } label: {
                                Text(settings.localizedString(for: "onboarding_tutorial_weed_decoration_hint"))
                            }
                            .buttonStyle(DuolingoButtonStyle(
                                size: .medium,
                                backgroundColor: .gruenPrimary,
                                shadowColor: .gruenSecondary
                            ))
                            .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    
                case .warning, .wheel:
                    // === THE "REAL" WHEEL ASSEMBLY (Standalone Implementation) ===
                    VStack(spacing: 0) {
                        ZStack {
                            // === 3D BASE LAYER ===
                            Circle()
                                .fill(Color(hex: "#0F1A30"))
                                .frame(width: wheelSize + 38, height: wheelSize + 38)
                            
                            // === 3D TOP LAYER & POINTER ===
                            ZStack {
                                // Main Wheel Top Layer
                                ZStack {
                                    // Dark blue outer ring
                                    Circle()
                                        .fill(Color(hex: "#1A2744"))
                                        .frame(width: wheelSize + 38, height: wheelSize + 38)
                                        .overlay(Circle().stroke(Color.black, lineWidth: 3))
                                    
                                    // Spinning Wheel
                                    OnboardingWheelSlices(layout: tutorialLayout)
                                        .frame(width: wheelSize, height: wheelSize)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.black, lineWidth: 2.5))
                                        .rotationEffect(.degrees(rotation))
                                    
                                    // Rim dots
                                    ForEach(0..<16, id: \.self) { i in
                                        OnboardingWheelRimDot(index: i, totalDots: 16, rimRadius: (wheelSize + 38) / 2.0 - 9.0)
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
                                    OnboardingWheelTrianglePointer()
                                        .fill(Color(hex: "#C8960C"))
                                        .frame(width: 28, height: 34)
                                    OnboardingWheelTrianglePointer()
                                        .fill(Color(hex: "#FFD700"))
                                        .frame(width: 28, height: 34)
                                        .overlay(OnboardingWheelTrianglePointer().stroke(Color.black, lineWidth: 2))
                                        .offset(y: -3)
                                }
                                .offset(y: -((wheelSize + 38) / 2) + 2)
                            }
                            .offset(y: -6)
                        }
                        .frame(width: wheelSize + 38, height: wheelSize + 38 + 6)
                        .scaleEffect(step == .wheel ? 1.0 : 0.85)
                        .opacity(step == .wheel ? 1.0 : 0.6)
                        .animation(.spring(), value: step)
                        
                        if step == .warning {
                            Button {
                                showWheelDemo()
                            } label: {
                                Text(settings.localizedString(for: "onboarding_weiter"))
                            }
                            .buttonStyle(DuolingoButtonStyle(size: .medium))
                            .padding(.top, 40)
                        }
                    }
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                }
            }
            .frame(maxHeight: .infinity)
            
            Spacer()
            
            if showNext {
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    withAnimation(.easeInOut(duration: 0.35)) {
                        data.currentStep += 1
                    }
                } label: {
                    Text(settings.localizedString(for: "onboarding_weiter"))
                }
                .buttonStyle(DuolingoButtonStyle(
                    size: .large,
                    backgroundColor: Color.blauPrimary,
                    shadowColor: Color.blauPrimary.darker(),
                    foregroundColor: .white
                ))
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            } else {
                Spacer().frame(height: 100)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                withAnimation { step = .buying }
            }
        }
    }
    
    private var bubbleText: String {
        switch step {
        case .intro: return settings.localizedString(for: "onboarding_tutorial_4_text")
        case .buying: return settings.localizedString(for: "onboarding_tutorial_weed_decoration_hint")
        case .warning: return settings.localizedString(for: "onboarding_tutorial_interactive_weed_bubble")
        case .wheel: return settings.localizedString(for: "onboarding_tutorial_interactive_weed_warning")
        }
    }
    
    private func buyDecoration() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        withAnimation(.spring()) {
            step = .warning
            innerPose = .erklaert
        }
    }
    
    private func showWheelDemo() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        withAnimation(.spring()) {
            step = .wheel
            innerPose = .fragt
        }
        
        let fullSpins = 3.0 * 360.0
        let targetRotation = rotation + fullSpins + 180 
        
        withAnimation(.timingCurve(0.15, 0.85, 0.35, 1.0, duration: 3.5)) {
            rotation = targetRotation
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            withAnimation {
                showNext = true
                innerPose = .erklaert
            }
        }
    }
}

// MARK: - Local Onboarding Wheel Components (Copied from WheelOfFortuneView)

enum OnboardingSegmentKind: Equatable {
    case weed, safe, gold
}

struct OnboardingWheelSlices: View {
    let layout: [OnboardingSegmentKind]

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

                    Path { path in
                        path.move(to: center)
                        path.addArc(center: center, radius: radius,
                                    startAngle: .degrees(startDeg),
                                    endAngle: .degrees(endDeg),
                                    clockwise: false)
                        path.closeSubpath()
                    }
                    .fill(color)

                    Path { path in
                        path.move(to: center)
                        path.addArc(center: center, radius: radius,
                                    startAngle: .degrees(startDeg),
                                    endAngle: .degrees(endDeg),
                                    clockwise: false)
                        path.closeSubpath()
                    }
                    .stroke(Color.black.opacity(0.4), lineWidth: 2)

                    OnboardingWheelSegmentIcon(kind: kind)
                        .rotationEffect(.degrees(midDeg + 90))
                        .position(
                            x: center.x + CGFloat(cos(midRad)) * iconR,
                            y: center.y + CGFloat(sin(midRad)) * iconR
                        )
                }
            }
        }
    }
    
    func colorFor(_ kind: OnboardingSegmentKind) -> Color {
        switch kind {
        case .safe: return Color.gruenPrimary
        case .weed: return Color.rotPrimary
        case .gold: return Color.coinBlue
        }
    }
}

struct OnboardingWheelSegmentIcon: View {
    let kind: OnboardingSegmentKind

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

struct OnboardingWheelRimDot: View {
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

struct OnboardingWheelTrianglePointer: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}
