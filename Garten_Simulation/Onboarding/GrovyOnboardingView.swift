import SwiftUI

// MARK: - Grovy Onboarding
struct GrovyOnboardingView: View {
    var onFinish: () -> Void = {}

    @State private var scene = 0

    /// Dauer jeder Szene in Sekunden (letzte Szene bleibt stehen)
    private let durations: [Double] = [3.8, 4.8, 4.0, 5.6, 0]
    private var lastIndex: Int { durations.count - 1 }

    var body: some View {
        ZStack {
            background
            GOParticles(color: GOPalette.particles[scene])
                .ignoresSafeArea()

            currentScene
                .id(scene)
                .transition(
                    .asymmetric(
                        insertion: AnyTransition.opacity.combined(with: .scale(scale: 1.08)),
                        removal: AnyTransition.opacity.combined(with: .scale(scale: 0.92))
                    )
                )

            topBar
        }
        .contentShape(Rectangle())
        .onTapGesture { next() }
        .task(id: scene) {
            let d = durations[scene]
            guard d > 0 else { return }
            try? await Task.sleep(nanoseconds: UInt64(d * 1_000_000_000))
            if !Task.isCancelled { next() }
        }
    }

    // MARK: Scene Switching

    @ViewBuilder
    private var currentScene: some View {
        switch scene {
        case 0: GOBurstScene()
        case 1: GOGraphScene()
        case 2: GOWiltScene()
        case 3: GOGardenScene()
        default: GOFinaleScene(onFinish: onFinish)
        }
    }

    private func next() {
        guard scene < lastIndex else { return }
        #if canImport(UIKit)
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        #endif
        withAnimation(.spring(response: 0.7, dampingFraction: 0.88)) {
            scene += 1
        }
    }

    // MARK: Background

    private var background: some View {
        ZStack {
            ForEach(0..<GOPalette.backgrounds.count, id: \.self) { i in
                LinearGradient(
                    colors: GOPalette.backgrounds[i],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .opacity(scene == i ? 1 : 0)
            }
        }
        .animation(.easeInOut(duration: 0.9), value: scene)
        .ignoresSafeArea()
    }

    // MARK: Top Bar (Progress + Skip)

    private func segmentState(_ i: Int) -> Int {
        if i < scene { return 2 }
        if i == scene { return 1 }
        return 0
    }

    private var topBar: some View {
        VStack(spacing: 14) {
            HStack(spacing: 6) {
                ForEach(0..<durations.count, id: \.self) { i in
                    GOProgressSegment(state: segmentState(i), duration: durations[i])
                        .id("\(i)-\(segmentState(i))")
                }
            }
            HStack {
                Spacer()
                if scene < lastIndex {
                    Button(action: onFinish) {
                        Text(String(localized: "grovy_story_skip", defaultValue: "Überspringen"))
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }
}

// MARK: - Palette

private enum GOPalette {
    static let backgrounds: [[Color]] = [
        [Color(red: 0.08, green: 0.04, blue: 0.20), Color(red: 0.36, green: 0.10, blue: 0.42)],
        [Color(red: 0.10, green: 0.03, blue: 0.16), Color(red: 0.50, green: 0.10, blue: 0.24)],
        [Color(red: 0.10, green: 0.10, blue: 0.13), Color(red: 0.25, green: 0.25, blue: 0.30)],
        [Color(red: 0.03, green: 0.22, blue: 0.17), Color(red: 0.10, green: 0.50, blue: 0.28)],
        [Color(red: 0.03, green: 0.22, blue: 0.17), Color(red: 0.18, green: 0.72, blue: 0.44)]
    ]
    static let particles: [Color] = [.pink, .orange, .gray, .green, .yellow]
}

// MARK: - Progress Segment

private struct GOProgressSegment: View {
    let state: Int       // 0 = kommt noch, 1 = aktiv, 2 = fertig
    let duration: Double
    @State private var fill: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.white.opacity(0.25))
                Capsule()
                    .fill(Color.white)
                    .frame(width: geo.size.width * (state == 2 ? 1 : fill))
            }
        }
        .frame(height: 4)
        .onAppear {
            guard state == 1 else { return }
            if duration <= 0 {
                fill = 1
            } else {
                withAnimation(.linear(duration: duration)) { fill = 1 }
            }
        }
    }
}

// MARK: - Floating Particles

private struct GOParticles: View {
    let color: Color
    @State private var go = false

    var body: some View {
        GeometryReader { geo in
            ForEach(0..<16, id: \.self) { i in
                let x = CGFloat((i * 53) % 100) / 100 * geo.size.width
                let size = CGFloat(4 + (i * 7) % 9)
                let dur = 5.0 + Double((i * 13) % 6)
                Circle()
                    .fill(color)
                    .frame(width: size, height: size)
                    .blur(radius: 1)
                    .position(x: x, y: go ? -20 : geo.size.height + 20)
                    .opacity(0.35)
                    .animation(
                        .linear(duration: dur).repeatForever(autoreverses: false).delay(Double(i) * 0.3),
                        value: go
                    )
            }
        }
        .onAppear { go = true }
        .allowsHitTesting(false)
    }
}

// MARK: - Shared Text

private struct GOStoryText: View {
    let title: String
    let subtitle: String
    let show: Bool

    var body: some View {
        VStack(spacing: 12) {
            Text(title)
                .font(.system(size: 32, weight: .heavy, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .opacity(show ? 1 : 0)
                .offset(y: show ? 0 : 24)
                .animation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.2), value: show)

            Text(subtitle)
                .font(.system(size: 17, weight: .medium, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundColor(.white.opacity(0.75))
                .opacity(show ? 1 : 0)
                .offset(y: show ? 0 : 24)
                .animation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.45), value: show)
        }
        .padding(.horizontal, 28)
    }
}

// MARK: - Szene 1: Dopamin-Burst

private struct GOBurstScene: View {
    @State private var appeared = false
    @State private var ripple = false
    @State private var wobble = false

    private let icons = [
        "bell.fill", "heart.fill", "play.rectangle.fill", "message.fill",
        "cart.fill", "gamecontroller.fill", "camera.fill", "envelope.fill"
    ]

    var body: some View {
        VStack(spacing: 36) {
            Spacer(minLength: 80)

            ZStack {
                // Dopamin-Wellen
                Circle()
                    .stroke(Color.pink.opacity(0.6), lineWidth: 3)
                    .frame(width: 110, height: 110)
                    .scaleEffect(ripple ? 2.8 : 1)
                    .opacity(ripple ? 0 : 0.8)
                    .animation(.easeOut(duration: 1.6).repeatForever(autoreverses: false), value: ripple)

                Circle()
                    .stroke(Color.orange.opacity(0.5), lineWidth: 3)
                    .frame(width: 110, height: 110)
                    .scaleEffect(ripple ? 2.8 : 1)
                    .opacity(ripple ? 0 : 0.8)
                    .animation(.easeOut(duration: 1.6).repeatForever(autoreverses: false).delay(0.8), value: ripple)

                Image(systemName: "brain.head.profile")
                    .font(.system(size: 90))
                    .foregroundColor(.white)
                    .scaleEffect(ripple ? 1.08 : 0.96)
                    .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: ripple)

                ForEach(0..<icons.count, id: \.self) { i in
                    let angle = Double(i) / Double(icons.count) * 2 * Double.pi
                    let r: CGFloat = appeared ? 125 : 0
                    ZStack {
                        Circle().fill(Color.white.opacity(0.15)).frame(width: 52, height: 52)
                        Image(systemName: icons[i])
                            .font(.system(size: 22))
                            .foregroundColor(.white)
                    }
                    .overlay(alignment: .topTrailing) {
                        Circle().fill(Color.red).frame(width: 14, height: 14)
                            .offset(x: 2, y: -2)
                    }
                    .rotationEffect(.degrees(wobble ? 10 : -10))
                    .animation(
                        .easeInOut(duration: 0.35).repeatForever(autoreverses: true).delay(Double(i) * 0.05),
                        value: wobble
                    )
                    .offset(x: CGFloat(cos(angle)) * r, y: CGFloat(sin(angle)) * r)
                    .scaleEffect(appeared ? 1 : 0.1)
                    .opacity(appeared ? 1 : 0)
                    .animation(
                        .spring(response: 0.6, dampingFraction: 0.5).delay(0.3 + Double(i) * 0.08),
                        value: appeared
                    )
                }
            }
            .frame(width: 320, height: 320)

            GOStoryText(
                title: String(localized: "grovy_story_scene1_title", defaultValue: "Dein Gehirn liebt\nschnelle Kicks."),
                subtitle: String(localized: "grovy_story_scene1_sub", defaultValue: "Jede Benachrichtigung, jeder Like und jedes Video schüttet Dopamin aus."),
                show: appeared
            )

            Spacer(minLength: 60)
        }
        .onAppear {
            appeared = true
            ripple = true
            wobble = true
        }
    }
}

// MARK: - Szene 2: Dopamin-Achterbahn (Graph)

private struct GODopamineLine: Shape {
    func path(in rect: CGRect) -> Path {
        let ys: [CGFloat] = [0.50, 0.05, 0.85, 0.12, 0.92, 0.22, 0.97]
        let step = rect.width / CGFloat(ys.count - 1)
        var p = Path()
        p.move(to: CGPoint(x: 0, y: rect.height * ys[0]))
        for i in 1..<ys.count {
            let x0 = step * CGFloat(i - 1)
            let x1 = step * CGFloat(i)
            let y0 = rect.height * ys[i - 1]
            let y1 = rect.height * ys[i]
            p.addCurve(
                to: CGPoint(x: x1, y: y1),
                control1: CGPoint(x: (x0 + x1) / 2, y: y0),
                control2: CGPoint(x: (x0 + x1) / 2, y: y1)
            )
        }
        return p
    }
}

private struct GOGraphScene: View {
    @State private var show = false
    @State private var chips = 0
    @State private var start = Date()

    private let chipData: [(icon: String, key: String, def: String)] = [
        ("bolt.fill", "grovy_story_graph_kick", "Kick"),
        ("arrow.down.right", "grovy_story_graph_crash", "Crash"),
        ("arrow.triangle.2.circlepath", "grovy_story_graph_more", "Mehr davon!")
    ]

    var body: some View {
        VStack(spacing: 28) {
            Spacer(minLength: 80)

            VStack(spacing: 18) {
                graph
                    .frame(height: 220)
                    .padding(18)
                    .background(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(Color.white.opacity(0.07))
                    )
                    .padding(.horizontal, 24)

                HStack(spacing: 10) {
                    ForEach(0..<chipData.count, id: \.self) { i in
                        HStack(spacing: 6) {
                            Image(systemName: chipData[i].icon)
                            Text(String(localized: LocalizedStringResource(stringLiteral: chipData[i].key), defaultValue: String.LocalizationValue(chipData[i].def)))
                        }
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(Color.white.opacity(0.16)))
                        .scaleEffect(chips > i ? 1 : 0.3)
                        .opacity(chips > i ? 1 : 0)
                        .animation(.spring(response: 0.5, dampingFraction: 0.6), value: chips)
                    }
                }
            }

            GOStoryText(
                title: String(localized: "grovy_story_scene2_title", defaultValue: "Kick. Crash.\nWiederholen."),
                subtitle: String(localized: "grovy_story_scene2_sub", defaultValue: "Jeder Kick senkt dein Normal-Level – du brauchst immer mehr, um dich gut zu fühlen."),
                show: show
            )

            Spacer(minLength: 60)
        }
        .onAppear {
            start = Date()
            show = true
            for i in 1...3 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.9 * Double(i)) {
                    chips = i
                }
            }
        }
    }

    private var graph: some View {
        TimelineView(.animation) { ctx in
            let t = min(1.0, max(0.0, ctx.date.timeIntervalSince(start) / 3.0))
            let eased = t < 0.5 ? 2 * t * t : 1 - pow(-2 * t + 2, 2) / 2
            let p = CGFloat(eased)

            GeometryReader { geo in
                let rect = CGRect(origin: .zero, size: geo.size)
                let full = GODopamineLine().path(in: rect)
                let trimmed = full.trimmedPath(from: 0, to: p)

                ZStack(alignment: .topLeading) {
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: rect.height * 0.35))
                        path.addLine(to: CGPoint(x: rect.width, y: rect.height * 0.78))
                    }
                    .stroke(Color.white.opacity(0.35), style: StrokeStyle(lineWidth: 2, dash: [6, 6]))

                    trimmed.stroke(
                        LinearGradient(
                            colors: [.yellow, .orange, .pink, .red],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round)
                    )
                    .shadow(color: .pink.opacity(0.7), radius: 8)

                    if let tip = trimmed.currentPoint {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 14, height: 14)
                            .shadow(color: .white, radius: 10)
                            .position(tip)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(String(localized: "grovy_story_graph_label_dopamine", defaultValue: "Dopamin"))
                            .foregroundColor(.white)
                        Text(String(localized: "grovy_story_graph_label_normal", defaultValue: "- - Normal-Level"))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                }
            }
        }
    }
}

// MARK: - Szene 3: Fokus welkt

private struct GOWiltScene: View {
    @State private var show = false
    @State private var wilted = false

    var body: some View {
        VStack(spacing: 36) {
            Spacer(minLength: 80)

            ZStack(alignment: .bottom) {
                ForEach(0..<6, id: \.self) { i in
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 20))
                        .foregroundColor(wilted ? Color.gray : Color.green)
                        .offset(
                            x: CGFloat(i - 3) * 22 + (wilted ? CGFloat(i % 2 == 0 ? -24 : 24) : 0),
                            y: wilted ? -10 : -150 + CGFloat(i % 3) * 20
                        )
                        .rotationEffect(.degrees(wilted ? Double(i) * 80 : 0))
                        .opacity(wilted ? 0 : 1)
                        .animation(.easeIn(duration: 1.8).delay(Double(i) * 0.12), value: wilted)
                }

                VStack(spacing: 0) {
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 90))
                        .foregroundColor(wilted ? Color.gray : Color.green)
                    Capsule()
                        .fill(wilted ? Color.gray.opacity(0.8) : Color(red: 0.2, green: 0.6, blue: 0.3))
                        .frame(width: 10, height: 110)
                }
                .rotationEffect(.degrees(wilted ? 42 : 0), anchor: .bottom)
                .scaleEffect(wilted ? 0.85 : 1, anchor: .bottom)
                .animation(.easeIn(duration: 1.8), value: wilted)

                Capsule()
                    .fill(Color(red: 0.45, green: 0.30, blue: 0.20))
                    .frame(width: 150, height: 26)
                    .offset(y: 13)
            }
            .frame(height: 260)
            .padding(.bottom, 12)

            GOStoryText(
                title: String(localized: "grovy_story_scene3_title", defaultValue: "Und dein Fokus\nwelkt."),
                subtitle: String(localized: "grovy_story_scene3_sub", defaultValue: "Ständige Reize machen es schwer, dranzubleiben – gute Gewohnheiten gehen unter."),
                show: show
            )

            Spacer(minLength: 60)
        }
        .onAppear {
            show = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                wilted = true
            }
        }
    }
}

// MARK: - Szene 4: Grovy-Lösung (Garten wächst)

private struct GOGardenScene: View {
    @State private var show = false
    @State private var done = 0
    @State private var soil = false

    private let habits: [(icon: String, key: String, def: String)] = [
        ("figure.run", "grovy_story_habit_move", "Bewegung"),
        ("book.fill", "grovy_story_habit_read", "Lesen"),
        ("drop.fill", "grovy_story_habit_water", "Wasser"),
        ("moon.zzz.fill", "grovy_story_habit_sleep", "Schlaf"),
        ("sun.max.fill", "grovy_story_habit_morning", "Morgen")
    ]
    private let plantSizes: [CGFloat] = [60, 84, 70, 96, 76]
    private let greens: [Color] = [
        Color(red: 0.45, green: 0.90, blue: 0.50),
        Color(red: 0.30, green: 0.80, blue: 0.45),
        Color(red: 0.55, green: 0.95, blue: 0.40),
        Color(red: 0.25, green: 0.75, blue: 0.50),
        Color(red: 0.60, green: 0.90, blue: 0.35)
    ]

    var body: some View {
        VStack(spacing: 30) {
            Spacer(minLength: 80)

            VStack(spacing: 14) {
                HStack(alignment: .bottom, spacing: 10) {
                    ForEach(0..<habits.count, id: \.self) { i in
                        VStack(spacing: 10) {
                            Image(systemName: "leaf.fill")
                                .font(.system(size: plantSizes[i]))
                                .foregroundColor(greens[i])
                                .shadow(color: greens[i].opacity(0.6), radius: 10)
                                .scaleEffect(done > i ? 1 : 0.01, anchor: .bottom)
                                .rotationEffect(.degrees(done > i ? 0 : -30), anchor: .bottom)
                                .opacity(done > i ? 1 : 0)
                                .frame(height: 110, alignment: .bottom)

                            ZStack {
                                Circle().fill(Color.white.opacity(0.15)).frame(width: 50, height: 50)
                                Image(systemName: habits[i].icon)
                                    .font(.system(size: 20))
                                    .foregroundColor(.white)
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(.green)
                                    .background(Circle().fill(Color.white))
                                    .offset(x: 18, y: -18)
                                    .scaleEffect(done > i ? 1 : 0)
                            }

                            Text(String(localized: LocalizedStringResource(stringLiteral: habits[i].key), defaultValue: String.LocalizationValue(habits[i].def)))
                                .font(.system(size: 11, weight: .semibold, design: .rounded))
                                .foregroundColor(.white.opacity(0.85))
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, 16)

                Capsule()
                    .fill(Color(red: 0.40, green: 0.27, blue: 0.18))
                    .frame(height: 12)
                    .padding(.horizontal, 24)
                    .scaleEffect(x: soil ? 1 : 0.05, anchor: .center)
                    .animation(.spring(response: 0.8, dampingFraction: 0.7), value: soil)

                let doneStr = String(format: String(localized: "grovy_story_habits_done", defaultValue: "%lld von %lld Gewohnheiten erledigt"), done, habits.count)
                Text(doneStr)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(Capsule().fill(Color.white.opacity(0.16)))
            }

            GOStoryText(
                title: String(localized: "grovy_story_scene4_title", defaultValue: "Grovy dreht\nden Spieß um."),
                subtitle: String(localized: "grovy_story_scene4_sub", defaultValue: "Jede erledigte Gewohnheit lässt deinen Garten wachsen – echter Fortschritt statt Scroll-Kick."),
                show: show
            )

            Spacer(minLength: 60)
        }
        .onAppear {
            show = true
            soil = true
            for i in 0..<habits.count {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8 + Double(i) * 0.65) {
                    #if canImport(UIKit)
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    #endif
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.55)) {
                        done = i + 1
                    }
                }
            }
        }
    }
}

// MARK: - Szene 5: Finale / CTA

private struct GOFinaleScene: View {
    let onFinish: () -> Void

    @State private var show = false
    @State private var pulse = false
    @State private var sway = false

    var body: some View {
        VStack(spacing: 36) {
            Spacer(minLength: 80)

            ZStack {
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .stroke(Color.white.opacity(0.25), lineWidth: 2)
                        .frame(width: 130, height: 130)
                        .scaleEffect(pulse ? 2.2 : 1)
                        .opacity(pulse ? 0 : 0.8)
                        .animation(
                            .easeOut(duration: 2.4).repeatForever(autoreverses: false).delay(Double(i) * 0.8),
                            value: pulse
                        )
                }

                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 0.55, green: 0.95, blue: 0.60), Color(red: 0.12, green: 0.65, blue: 0.35)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 130, height: 130)
                    .shadow(color: Color.green.opacity(0.6), radius: 30)

                Image(systemName: "leaf.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.white)
                    .rotationEffect(.degrees(sway ? 8 : -8), anchor: .bottom)
                    .animation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true), value: sway)
            }
            .scaleEffect(show ? 1 : 0.2)
            .opacity(show ? 1 : 0)
            .animation(.spring(response: 0.8, dampingFraction: 0.55), value: show)
            .frame(height: 260)

            GOStoryText(
                title: String(localized: "grovy_story_scene5_title", defaultValue: "Dein Garten\nwartet."),
                subtitle: String(localized: "grovy_story_scene5_sub", defaultValue: "Starte mit einer kleinen Gewohnheit. Der Rest wächst von selbst."),
                show: show
            )

            Button(action: onFinish) {
                Text(String(localized: "grovy_story_start", defaultValue: "Los geht's"))
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.04, green: 0.24, blue: 0.18))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color.white)
                    .clipShape(Capsule())
                    .shadow(color: Color.white.opacity(0.35), radius: 16)
            }
            .padding(.horizontal, 32)
            .scaleEffect(show ? 1 : 0.6)
            .opacity(show ? 1 : 0)
            .animation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.8), value: show)

            Spacer(minLength: 40)
        }
        .onAppear {
            show = true
            pulse = true
            sway = true
        }
    }
}

#Preview {
    GrovyOnboardingView()
}
