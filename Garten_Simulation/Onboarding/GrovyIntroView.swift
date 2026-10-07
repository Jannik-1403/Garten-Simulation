import SwiftUI
import AVFoundation
import Combine

// MARK: - GrovyIntroView  v4
//
// Ablauf (Finger halten → Animation läuft):
//   0.0 -  4.8  TikTok-Word-Build-Up (1 Wort → 2 → 3 gleichzeitig)
//   4.8 -  6.0  Herzschlag
//   5.8 -  9.8  Speed-Linien (Continuous Warp) + 3 Slam-Zahlen
//   9.8 - 11.0  Fade
//  11.0 - 12.8  "Dein Gehirn will mehr."
//  12.8 - 17.0  Habit-Statistiken (relevant zur App)
//  17.0 - 19.5  GROVY-Logo + Button

private let kIntroDuration: Double = 19.5

struct GrovyIntroView: View {
    let accent: Color
    let warning: Color
    let background: Color
    let soundEnabled: Bool
    let buttonTitle: String
    let onFinish: () -> Void

    @StateObject private var audio = GIAudio()
    @State private var alive = true
    @State private var startTick: Date? = nil
    @State private var ringProgress: Double = 0.0
    @State private var lastHapticProgress: Double = 0.0
    @State private var buttonPressed: Bool = false
    @State private var endWiggle: Double = 0.0

    init(
        accent: Color = .blauPrimary,
        warning: Color = .red,
        background: Color = .clear,
        soundEnabled: Bool = true,
        buttonTitle: String = "Los geht's",
        onFinish: @escaping () -> Void = {}
    ) {
        self.accent = accent; self.warning = warning; self.background = background
        self.soundEnabled = soundEnabled; self.buttonTitle = buttonTitle; self.onFinish = onFinish
    }

    private let slams: [(start: Double, big: String, small: String)] = [
        (6.2, "180", "MIN. AM TAG"),
        (7.5, "47",  "SEK. FOKUS"),
        (8.8, "46",  "TAGE IM JAHR")
    ]

    var body: some View {
        ZStack {
            background.ignoresSafeArea()

            GITimed(startDate: startTick) { t in
                ZStack {
                    if startTick != nil {
                        // Phase 0: TikTok Word Build-Up
                        if t < 5.2 {
                            GIWordBuildUp(t: t).ignoresSafeArea()
                        }

                        // Phase 1: Herzschlag
                        if t > 4.8 && t < 6.2 { heartbeat(t - 4.8) }

                        // Phase 2: Speed-Linien (Continuous) + Slams
                        if t > 5.8 && t < 9.8 { layerA(t) }

                        // Fade
                        if t > 9.3 && t < 10.8 {
                            background.opacity(goClamp01I((t - 9.3) / 1.0))
                                .ignoresSafeArea().allowsHitTesting(false)
                        }

                        // Phase 3: Text
                        if t > 11.0 && t < 12.8 { layerB(t) }

                        // Phase 4: Habit-Stats
                        if t > 12.8 {
                            GIHabitStats(t: t, accent: accent)
                                .ignoresSafeArea()
                                .scaleEffect(CGFloat(1.0 + 0.06 * goProgI(t, 13.8, 4.0)))
                                .opacity(goProgI(t, 12.8, 0.7))
                                .allowsHitTesting(false)
                        }

                        // Phase 5: Logo
                        if t > 17.0 { layerD(t) }

                        // Auto-Finish
                        if t > 19.5 { Color.clear.onAppear { finishNow() } }

                    } else {
                        // Vor dem ersten Drücken – kein Text, nur Icon auf Button
                        EmptyView()
                    }
                }
            }

            // 3D Hold-Button – tiefer unten positioniert
            VStack {
                Spacer()
                GI3DButton(
                    ringProgress: ringProgress,
                    isHolding: startTick != nil,
                    isPressed: buttonPressed,
                    wiggle: endWiggle,
                    accent: accent
                )
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in
                            if !buttonPressed {
                                buttonPressed = true
                                giHaptic(2)  // Sofortige starke Vibration beim Drücken
                            }
                            if startTick == nil {
                                startTick = Date()
                                ringProgress = 0
                                lastHapticProgress = 0
                                schedule()
                            }
                        }
                        .onEnded { _ in
                            buttonPressed = false
                            startTick = nil
                            audio.stop()
                            withAnimation(.easeOut(duration: 0.5)) { ringProgress = 0 }
                            endWiggle = 0
                        }
                )
                .padding(.bottom, 40)
            }
        }
        .onReceive(Timer.publish(every: 0.03, on: .main, in: .common).autoconnect()) { _ in
            guard let tick = startTick else { return }
            let elapsed = Date().timeIntervalSince(tick)
            ringProgress = min(1.0, elapsed / kIntroDuration)

            // Wackeln in den letzten 2 Sekunden
            if elapsed > kIntroDuration - 2.0 {
                let wiggleT = elapsed - (kIntroDuration - 2.0)
                endWiggle = wiggleT
                let wStep = (wiggleT * 3).rounded(.down)
                if wStep > (endWiggle * 3 - 1).rounded(.down) {
                    giHaptic(2)
                }
            }

            // Haptik alle 20%
            let step = (ringProgress * 5).rounded(.down) / 5
            if step > lastHapticProgress {
                lastHapticProgress = step
                giHaptic(ringProgress > 0.8 ? 2 : 1)
            }
        }
        .onDisappear { alive = false }
    }

    // MARK: - Aktionen

    private func finishNow() { alive = false; onFinish() }

    private func schedule() {
        audio.start(enabled: soundEnabled)
        for event in giEvents {
            DispatchQueue.main.asyncAfter(deadline: .now() + event.0) {
                guard alive else { return }
                fire(event.1)
            }
        }
    }

    private func fire(_ kind: GIKind) {
        switch kind {
        case .beat:  giHaptic(0); audio.beat()
        case .slam:  giHaptic(2); audio.slam()
        case .bloom: giHaptic(0); audio.shimmer()
        case .logo:  giHaptic(2); audio.slam()
        }
    }

    // MARK: - Herzschlag

    @ViewBuilder
    private func heartbeat(_ t: Double) -> some View {
        let r = 5.0 + 18.0 * giPulse(t, 0.3) + 18.0 * giPulse(t, 0.6)
        let a = goProgI(t, 0.0, 0.3)
        ZStack {
            Circle().fill(Color.white.opacity(0.18 * a))
                .frame(width: CGFloat(r * 4), height: CGFloat(r * 4)).blur(radius: 14)
            Circle().fill(Color.white.opacity(a))
                .frame(width: CGFloat(r), height: CGFloat(r))
        }
    }

    // MARK: - Layer A: Continuous Speed + Slam

    @ViewBuilder
    private func layerA(_ t: Double) -> some View {
        let cut = 1.0 - goClamp01I((t - 9.3) / 0.6)
        let idx = currentSlam(t)
        let slam = slams[idx]
        let local = t - slam.start
        ZStack {
            // Speed-Linien als ununterbrochener Strahl nach vorne
            GISpeedLines(t: t).ignoresSafeArea()
            GISlam(big: slam.big, small: slam.small, local: local, color: warning)
            background.opacity(0.65 * exp(-max(0.0, local) * 10.0))
                .ignoresSafeArea().allowsHitTesting(false)
        }
        .opacity(cut)
    }

    private func currentSlam(_ t: Double) -> Int {
        var idx = 0
        for i in 0..<slams.count where t >= slams[i].start { idx = i }
        return idx
    }

    // MARK: - Layer B: Text

    @ViewBuilder
    private func layerB(_ t: Double) -> some View {
        let fade = 1.0 - goClamp01I((t - 12.3) / 0.4)
        let a1 = goOutI(goProgI(t, 11.1, 0.7))
        let a2 = goOutI(goProgI(t, 11.9, 1.0))
        VStack(spacing: 12) {
            Text(String(localized: "intro_text_line1", defaultValue: "Dein Gehirn will mehr."))
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(Color.primary)
                .opacity(a1).offset(y: CGFloat((1.0 - a1) * 16.0))
            Text(String(localized: "intro_text_line2", defaultValue: "Nicht besser."))
                .font(.system(size: 36, weight: .heavy, design: .rounded))
                .tracking(CGFloat(10.0 - 8.0 * a2))
                .foregroundColor(warning).opacity(a2)
        }
        .multilineTextAlignment(.center).opacity(fade)
    }

    // MARK: - Layer D: Logo

    @ViewBuilder
    private func layerD(_ t: Double) -> some View {
        let lp = goProgI(t, 17.1, 1.4); let lpE = goOutI(lp)
        let sweep = goInOutI(goProgI(t, 17.8, 1.1))
        let tag = goProgI(t, 18.2, 0.8)
        let btn = goOutI(goProgI(t, 18.6, 0.6))
        let word = Text("GROVY")
            .font(.system(size: 58, weight: .black, design: .rounded))
            .tracking(CGFloat(26.0 - 20.0 * lpE))
        ZStack {
            VStack(spacing: 14) {
                word.foregroundColor(.white)
                    .overlay {
                        LinearGradient(colors: [.clear, accent, .clear],
                                       startPoint: .leading, endPoint: .trailing)
                            .frame(width: 80).offset(x: CGFloat(-220.0 + 440.0 * sweep))
                            .blendMode(.plusLighter).mask(word)
                    }
                    .shadow(color: accent.opacity(0.7 * lp), radius: 24)
                    .scaleEffect(CGFloat(1.25 - 0.25 * lpE)).opacity(lp)
                Text(String(localized: "intro_tagline", defaultValue: "Aus Gewohnheiten wächst dein Garten."))
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.75)).opacity(tag)
                    .offset(y: CGFloat((1.0 - tag) * 10.0))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top).padding(.top, 110)
            VStack {
                Spacer()
                Button(action: finishNow) {
                    Text(buttonTitle)
                        .font(.system(size: 19, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.03, green: 0.20, blue: 0.12))
                        .frame(maxWidth: .infinity).padding(.vertical, 17)
                        .background(Capsule().fill(accent))
                        .shadow(color: accent.opacity(0.5), radius: 16, x: 0, y: 6)
                }
                .padding(.horizontal, 32).padding(.bottom, 48)
                .scaleEffect(CGFloat(0.8 + 0.2 * btn)).opacity(btn)
            }
        }
    }
}

// MARK: - 3D Hold-Button (Standard App Style)

private struct GI3DButton: View {
    let ringProgress: Double
    let isHolding: Bool
    let isPressed: Bool
    let wiggle: Double
    let accent: Color

    private let btnSize: CGFloat = 84
    private let ringSize: CGFloat = 112
    private let depth: CGFloat = 7  // Standard 3D-Tiefe (entspricht Item3DButton Shadow-Depth)
    private let lineW: CGFloat = 6

    var body: some View {
        ZStack {
            // Hintergrund-Ring (immer an gleicher Position)
            Circle()
                .stroke(Color.white.opacity(0.14), lineWidth: lineW)
                .frame(width: ringSize, height: ringSize)

            // Fortschritts-Ring
            Circle()
                .trim(from: 0, to: CGFloat(ringProgress))
                .stroke(
                    LinearGradient(colors: [.yellow, .orange],
                                   startPoint: .topLeading, endPoint: .bottomTrailing),
                    style: StrokeStyle(lineWidth: lineW, lineCap: .round)
                )
                .frame(width: ringSize, height: ringSize)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.05), value: ringProgress)

            // 3D-Button Container (Sockel & Top Layer)
            ZStack {
                // Sockel (Schatten)
                Circle()
                    .fill(Color(red: 0.8, green: 0.4, blue: 0.0)) // Dunkleres Orange
                    .overlay(Circle().stroke(Color.black.opacity(0.1), lineWidth: 1))
                    .frame(width: btnSize, height: btnSize)
                
                // Top-Layer (Bewegt sich beim Drücken runter zum Sockel)
                Circle()
                    .fill(Color.orange) // Basis-Farbe
                    .overlay(Circle().stroke(Color.black.opacity(0.15), lineWidth: 1))
                    .frame(width: btnSize, height: btnSize)
                    .overlay {
                        Image(systemName: isHolding ? "fingerprint" : "hand.tap.fill")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                    }
                    .offset(y: isPressed ? 0 : -depth)
            }
            .offset(y: depth / 2) // Ausgleich für optische Mitte
            
        }
        // Wackeln am Ende
        .offset(
            x: wiggle > 0 ? CGFloat(sin(wiggle * 28.0) * min(wiggle * 6, 8)) : 0,
            y: wiggle > 0 ? CGFloat(cos(wiggle * 21.0) * min(wiggle * 4, 5)) : 0
        )
        .animation(.spring(response: 0.22, dampingFraction: 0.5, blendDuration: 0), value: isPressed)
    }
}

// MARK: - TikTok Word Build-Up mit 3D Text Style

private struct GIWordBuildUp: View {
    let t: Double

    private struct WordScene {
        struct Step { let words: [String]; let colors: [Color]; let sizes: [CGFloat] }
        let steps: [Step]
        let start: Double
        let stepDur: Double
        let gap: Double
    }

    // Lokalisierte Wörter
    private let scenes: [WordScene] = [
        WordScene(steps: [
            .init(words: [String(localized: "intro_flash_you", defaultValue: "DU.")], colors: [.white], sizes: [88]),
            .init(words: [String(localized: "intro_flash_you", defaultValue: "DU."), String(localized: "intro_flash_scroll", defaultValue: "SCROLLST.")], colors: [.white, .yellow], sizes: [56, 64]),
            .init(words: [String(localized: "intro_flash_you", defaultValue: "DU."), String(localized: "intro_flash_scroll", defaultValue: "SCROLLST."), String(localized: "intro_flash_everyday", defaultValue: "TÄGLICH.")], colors: [.white, .yellow, .orange], sizes: [44, 52, 60]),
        ], start: 0.0, stepDur: 0.45, gap: 0.25),

        WordScene(steps: [
            .init(words: [String(localized: "intro_flash_how_long", defaultValue: "WIE LANGE")], colors: [.red], sizes: [72]),
            .init(words: [String(localized: "intro_flash_how_long", defaultValue: "WIE LANGE"), String(localized: "intro_flash_tap", defaultValue: "TIPPST.")], colors: [.red, .white], sizes: [56, 56]),
            .init(words: [String(localized: "intro_flash_how_long", defaultValue: "WIE LANGE"), String(localized: "intro_flash_tap", defaultValue: "TIPPST."), String(localized: "intro_flash_really", defaultValue: "WIRKLICH?")], colors: [.red, .white, .gray], sizes: [46, 46, 42]),
        ], start: 1.7, stepDur: 0.40, gap: 0.25),

        WordScene(steps: [
            .init(words: [String(localized: "intro_flash_way_too", defaultValue: "VIEL ZU")], colors: [.yellow], sizes: [90]),
            .init(words: [String(localized: "intro_flash_way_too", defaultValue: "VIEL ZU"), String(localized: "intro_flash_long", defaultValue: "LANGE.")], colors: [.yellow, .white], sizes: [72, 64]),
        ], start: 3.2, stepDur: 0.45, gap: 0.25),
    ]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ForEach(Array(scenes.enumerated()), id: \.offset) { _, scene in
                let sceneLocal = t - scene.start
                let sceneDur = Double(scene.steps.count) * scene.stepDur + scene.gap
                if sceneLocal >= 0 && sceneLocal < sceneDur {
                    let stepIdx = min(scene.steps.count - 1, Int(sceneLocal / scene.stepDur))
                    let step = scene.steps[stepIdx]
                    let stepLocal = sceneLocal - Double(stepIdx) * scene.stepDur
                    let fadeIn = min(1.0, stepLocal / 0.08)
                    let totalFade = sceneLocal > sceneDur - 0.15 ?
                        max(0.0, 1.0 - (sceneLocal - (sceneDur - 0.15)) / 0.12) : 1.0

                    VStack(spacing: 14) {
                        ForEach(Array(step.words.enumerated()), id: \.offset) { wordIdx, word in
                            let isNew = wordIdx == stepIdx
                            let decay = isNew ? exp(-stepLocal * 12.0) : 0.0
                            
                            // 3D Text Style
                            ZStack {
                                // Schatten-Layer
                                Text(word)
                                    .font(.system(size: step.sizes[wordIdx], weight: .black, design: .rounded))
                                    .foregroundColor(step.colors[wordIdx].opacity(0.35))
                                    .offset(y: 4)
                                // Top-Layer
                                Text(word)
                                    .font(.system(size: step.sizes[wordIdx], weight: .black, design: .rounded))
                                    .foregroundColor(step.colors[wordIdx])
                            }
                            .shadow(color: step.colors[wordIdx].opacity(0.5), radius: 20)
                            .scaleEffect(CGFloat(1.0 + (isNew ? 0.16 * exp(-stepLocal * 14.0) : 0.0)))
                            .rotation3DEffect(
                                .degrees(isNew ? 18.0 * decay : 0),
                                axis: (x: 0.7, y: -0.5, z: 0.1)
                            )
                        }
                    }
                    .opacity(fadeIn * totalFade)
                }
            }

            // Vignette
            RadialGradient(colors: [.clear, Color.black.opacity(0.5)],
                           center: .center, startRadius: 120, endRadius: 340)
                .ignoresSafeArea().allowsHitTesting(false)
        }
    }
}

// MARK: - Events

private enum GIKind { case beat, slam, bloom, logo }

private let giEvents: [(Double, GIKind)] = [
    (5.0, .beat), (5.3, .beat),
    (6.2, .slam), (7.5, .slam), (8.8, .slam), (9.5, .slam),
    (13.8, .bloom), (17.8, .logo)
]

private func giHaptic(_ level: Int) {
    #if canImport(UIKit)
    let style: UIImpactFeedbackGenerator.FeedbackStyle = level == 0 ? .light : (level == 1 ? .medium : .heavy)
    UIImpactFeedbackGenerator(style: style).impactOccurred()
    #endif
}

// MARK: - Helfer

private func goClamp01I(_ x: Double) -> Double { min(1.0, max(0.0, x)) }
private func goProgI(_ t: Double, _ start: Double, _ dur: Double) -> Double { goClamp01I((t - start) / dur) }
private func goOutI(_ x: Double) -> Double { 1.0 - pow(1.0 - x, 3.0) }
private func goInOutI(_ x: Double) -> Double {
    x < 0.5 ? 4.0 * x * x * x : 1.0 - pow(-2.0 * x + 2.0, 3.0) / 2.0
}
private func giPulse(_ t: Double, _ at: Double) -> Double { t >= at ? exp(-(t - at) * 9.0) : 0.0 }
private func giFract(_ x: Double) -> Double { x - floor(x) }

private struct GITimed<Content: View>: View {
    let startDate: Date?
    private let content: (Double) -> Content
    init(startDate: Date?, @ViewBuilder _ content: @escaping (Double) -> Content) {
        self.startDate = startDate; self.content = content
    }
    var body: some View {
        TimelineView(.animation) { ctx in
            if let start = startDate {
                content(max(0, ctx.date.timeIntervalSince(start)))
            } else { content(0.0) }
        }
    }
}

// MARK: - Continuous Speed-Linien (Warp Effekt)

private struct GISpeedLines: View {
    let t: Double
    var body: some View {
        Canvas { ctx, size in
            let w = Double(size.width); let h = Double(size.height)
            let cx = w / 2.0; let cy = h / 2.0; let n = 100
            
            // Kontinuierliche Vorwärtsbewegung
            let speed = 0.8
            
            for i in 0..<n {
                let ang = Double(i) / Double(n) * Double.pi * 2.0
                
                // Jede Linie hat einen eigenen Offset, um sie zu verteilen
                let phase = Double(i * 13 % 100) / 100.0
                
                // Distanz wächst von 0.0 bis 1.0, dann loop
                let dist = giFract(t * speed + phase)
                
                // Vermeide das Flackern in der Mitte, indem Linien erst ab dist > 0.1 auftauchen
                if dist < 0.05 { continue }
                
                // Radius skaliert exponentiell für Warp-Effekt
                let r = pow(dist, 1.5) * max(w, h)
                let lineLen = dist * 120.0 + 10.0
                
                var lp = Path()
                let x = cx + cos(ang) * r; let y = cy + sin(ang) * r
                let xStart = cx + cos(ang) * (r - lineLen); let yStart = cy + sin(ang) * (r - lineLen)
                
                lp.move(to: CGPoint(x: xStart, y: yStart))
                lp.addLine(to: CGPoint(x: x, y: y))
                
                let lc = i % 5 == 0 ? Color.red : (i % 3 == 0 ? Color.white : Color.gray)
                let alpha = sin(dist * Double.pi) // Fade in am Anfang, fade out am Rand
                
                ctx.stroke(lp, with: .color(lc.opacity(alpha * (i % 5 == 0 ? 0.8 : 0.4))),
                           style: StrokeStyle(lineWidth: CGFloat(1.5 + dist * 3.0), lineCap: .round))
            }
        }
    }
}

// MARK: - Slam-Zahl (3D Text Style)

private struct GISlam: View {
    let big: String; let small: String; let local: Double; let color: Color
    var body: some View {
        let p = goOutI(goClamp01I(local / 0.25))
        let decay = exp(-max(0.0, local) * 9.0)
        let s = CGFloat(1.4 - 0.4 * p)
        let offsetX = CGFloat(sin(local * 90.0) * 20.0 * decay)
        let offsetY = CGFloat(20.0 * (1.0 - p) + cos(local * 70.0) * 15.0 * decay)
        let rotDeg = 15.0 * decay
        return VStack(spacing: 12) {
            
            // 3D Text Style für die große Zahl
            ZStack {
                Text(big)
                    .font(.system(size: 110, weight: .black, design: .rounded))
                    .foregroundColor(color.opacity(0.35))
                    .offset(y: 6)
                
                Text(big)
                    .font(.system(size: 110, weight: .black, design: .rounded))
                    .foregroundColor(.white)
            }
            .scaleEffect(s)
            .rotation3DEffect(.degrees(rotDeg), axis: (x: 1, y: -0.5, z: 0))
            
            if !small.isEmpty {
                Text(small)
                    .font(.system(size: 28, weight: .heavy, design: .rounded)).tracking(10)
                    .foregroundColor(color).padding(.horizontal, 24).padding(.vertical, 8)
                    .background(Capsule().fill(Color(white: 0.12)))
                    .scaleEffect(CGFloat(1.0 + decay * 0.5))
                    .opacity(goClamp01I(local * 12.0) * p)
            }
        }
        .offset(x: offsetX, y: offsetY)
        .opacity(goClamp01I(local * 12.0))
    }
}

// MARK: - Habit-Statistiken

private struct GIHabitStats: View {
    let t: Double; let accent: Color

    var body: some View {
        Canvas { ctx, size in
            let w = Double(size.width); let h = Double(size.height)
            let cx = w / 2.0
            let p = goInOutI(goProgI(t, 13.8, 2.5))

            guard p > 0 else { return }

            let facts: [(value: String, label: String, sub: String, color: Color)] = [
                ("8 %",  "erreichen ihre Ziele",     "ohne System",          .red),
                ("3×",   "erfolgreicher",              "mit täglichem Tracking", accent),
                ("66",   "Tage",                      "bis eine Gewohnheit sitzt", .orange),
                ("40 %", "deines Tages",               "sind Gewohnheiten",   Color(white: 0.7)),
            ]

            let cardW = w * 0.76; let cardH = h * 0.14
            let startY = h * 0.18

            for (i, fact) in facts.enumerated() {
                let delay = Double(i) * 0.6
                let fp = goOutI(goProgI(t, 13.8 + delay, 0.5))
                guard fp > 0 else { continue }
                let fy = startY + Double(i) * (cardH + h * 0.03)
                let fx = (w - cardW) / 2.0

                let cardRect = CGRect(x: fx, y: fy, width: cardW * fp, height: cardH)
                ctx.fill(Path(roundedRect: cardRect, cornerRadius: 16),
                         with: .color(Color(white: 0.12).opacity(fp)))

                let accentRect = CGRect(x: fx, y: fy, width: 5, height: cardH)
                ctx.fill(Path(roundedRect: accentRect, cornerRadius: 2),
                         with: .color(fact.color.opacity(fp)))

                if fp > 0.5 {
                    ctx.draw(Text(fact.value)
                        .font(.system(size: 32, weight: .black, design: .rounded))
                        .foregroundColor(fact.color.opacity(fp)),
                             at: CGPoint(x: fx + cardW * 0.22, y: fy + cardH * 0.4),
                             anchor: .center)
                    ctx.draw(Text(fact.label)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(Color.white.opacity(fp)),
                             at: CGPoint(x: fx + cardW * 0.6, y: fy + cardH * 0.32),
                             anchor: .center)
                    ctx.draw(Text(fact.sub)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(Color(white: 0.55).opacity(fp)),
                             at: CGPoint(x: fx + cardW * 0.6, y: fy + cardH * 0.68),
                             anchor: .center)
                }
            }

            let titleP = goProgI(t, 13.8, 0.5)
            ctx.draw(Text(String(localized: "intro_stats_title", defaultValue: "GEWOHNHEITEN & ERFOLG"))
                .font(.system(size: 12, weight: .heavy, design: .rounded))
                .foregroundColor(Color(white: 0.4).opacity(titleP)),
                     at: CGPoint(x: cx, y: h * 0.11), anchor: .center)

            let fireP = goProgI(t, 15.5, 2.0)
            if fireP > 0 {
                for i in 0..<20 {
                    let fi = Double(i)
                    let fx2 = cx + sin(fi * 1.9 + t * 0.5) * w * 0.42
                    let fy2 = h * 0.85 - fi / 20.0 * h * 0.6 - giFract(t * 0.05 + fi * 0.08) * h * 0.08
                    let fa = fireP * (0.5 + 0.5 * sin(t * 2.8 + fi))
                    let fr = 2.5 + sin(fi * 1.7 + t) * 1.2
                    ctx.fill(Path(ellipseIn: CGRect(x: fx2-fr, y: fy2-fr, width: fr*2, height: fr*2)),
                             with: .color(accent.opacity(fa)))
                }
            }
        }
    }
}

// MARK: - Sound

private final class GIAudio: ObservableObject {
    private let engine = AVAudioEngine(); private let player = AVAudioPlayerNode()
    private let sr = 44100.0; private var ready = false

    func start(enabled: Bool) {
        guard enabled, !ready else { return }
        #if os(iOS)
        try? AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [.mixWithOthers])
        try? AVAudioSession.sharedInstance().setActive(true)
        #endif
        guard let fmt = AVAudioFormat(standardFormatWithSampleRate: sr, channels: 1) else { return }
        engine.attach(player); engine.connect(player, to: engine.mainMixerNode, format: fmt)
        do { try engine.start(); player.play(); ready = true } catch { ready = false }
    }
    func stop() { if ready { player.stop(); engine.stop(); ready = false } }

    private func play(_ s: [Float]) {
        guard ready, let fmt = AVAudioFormat(standardFormatWithSampleRate: sr, channels: 1),
              let buf = AVAudioPCMBuffer(pcmFormat: fmt, frameCapacity: AVAudioFrameCount(s.count)) else { return }
        buf.frameLength = AVAudioFrameCount(s.count)
        if let ch = buf.floatChannelData?[0] { for i in 0..<s.count { ch[i] = s[i] } }
        player.scheduleBuffer(buf, completionHandler: nil)
    }

    func slam() {
        let n = Int(0.9*sr); var s=[Float](repeating:0,count:n); var ph=0.0
        for i in 0..<n{let x=Double(i)/sr;let f=48.0+120.0*exp(-x*22.0);ph+=2.0 * .pi*f/sr;let e=exp(-x*4.5);s[i]=Float((sin(ph)+0.25*sin(ph*2)*e)*e*0.9)}
        play(s)
    }
    func beat() {
        let n=Int(0.25*sr); var s=[Float](repeating:0,count:n); var ph=0.0
        for i in 0..<n{let x=Double(i)/sr;ph+=2.0 * .pi*(62.0+40.0*exp(-x*30.0))/sr;s[i]=Float(sin(ph)*exp(-x*16.0)*0.8)}
        play(s)
    }
    func shimmer() {
        let n=Int(3.0*sr); var s=[Float](repeating:0,count:n); var ph=0.0
        for i in 0..<n{let x=Double(i)/sr;let k=x/3.0;ph+=2.0 * .pi*(400.0+1300.0*k*k)/sr;s[i]=Float((sin(ph)+0.4*sin(ph*1.5))*sin(.pi*k)*0.18)}
        play(s)
    }
}

// MARK: - Preview
struct GrovyIntroView_Previews: PreviewProvider {
    static var previews: some View { GrovyIntroView() }
}
