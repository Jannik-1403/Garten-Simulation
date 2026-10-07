import SwiftUI
import AVFoundation
import Combine

// MARK: - GrovyIntroView  v9
//
// Ablauf:
//   0.0 -  5.2  Teil 1: DU. SCROLLST. TÄGLICH. WIE LANGE?
//   --- PAUSE FÜR INPUT ---
//   5.2 -  9.2  Teil 2: WIRKLICH? VIEL ZU LANGE.
//   8.8 - 10.5  Herzschlag
//   9.5 - 25.5  Black Background Fade-In
//  10.0 - 14.0  Speed-Linien (Continuous Warp) + Dynamische Slam-Zahlen (Nur 2)
//  14.0 - 18.0  "Wie viel Zeit hättest du für andere Sachen?"
//  18.0 - 22.5  Solution Text ("Investiere diese Zeit...", "Baue Gewohnheiten...", "Garten wächst...")
//  22.5 - 25.5  GROVY-Logo + Button

private let kIntroDuration: Double = 25.5

struct GrovyIntroView: View {
    let accent: Color
    let warning: Color
    let background: Color
    let soundEnabled: Bool
    let buttonTitle: String
    let onFinish: () -> Void

    @State private var t: Double = 0.0
    @State private var lastT: Double = 0.0
    @State private var isHolding: Bool = false
    @State private var inputMode: Bool = false
    @State private var hasPassedInput: Bool = false
    @State private var endWiggle: Double = 0.0
    
    // User Input (in Minuten, Standard: 3h = 180)
    @State private var selectedMinutes: Int = 180

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

    private var slams: [(start: Double, big: String, small: String)] {
        let mins = max(1, selectedMinutes)
        let hoursPerYear = (mins * 365) / 60
        let daysInLife = (mins * 365 * 60) / 1440 // assuming 60 years remaining life
        return [
            (10.5, "\(hoursPerYear)", String(localized: "intro_slam_hours_year", defaultValue: "STUNDEN PRO JAHR")),
            (12.0, "\(daysInLife)", String(localized: "intro_slam_days_life", defaultValue: "TAGE DEINES LEBENS"))
        ]
    }

    var body: some View {
        ZStack {
            background.ignoresSafeArea()

            ZStack {
                // Phase 0/1: TikTok Word Build-Up
                if t < 9.5 {
                    GIWordBuildUp(t: t).ignoresSafeArea()
                }

                // Ab hier (Slam-Phase) wird der Hintergrund schwarz
                if t > 9.5 {
                    Color.black
                        .opacity(goClamp01I((t - 9.5) / 0.5))
                        .ignoresSafeArea().allowsHitTesting(false)
                }

                // Phase 1.5: Herzschlag
                if t > 8.8 && t < 10.5 { heartbeat(t - 8.8) }

                // Phase 2: Speed-Linien + Slams
                if t > 10.0 && t < 14.0 { layerA(t) }

                // Phase 3: Wie viel Zeit...
                if t > 14.0 && t < 18.0 { layerB(t) }

                // Phase 4: Solution (Grovy)
                if t > 18.0 && t < 22.5 { layerC(t) }

                // Phase 5: Logo
                if t > 22.5 { layerD(t) }

                // Auto-Finish
                if t > 25.5 { Color.clear.onAppear { finishNow() } }
            }

            // --- INPUT SCREEN ---
            if inputMode {
                VStack(spacing: 24) {
                    Text(String(localized: "intro_flash_how_long", defaultValue: "WIE LANGE?"))
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .shadow(color: .white.opacity(0.3), radius: 10)
                        .padding(.top, 16)
                    
                    // Nativer Apple Countdown-Picker
                    GIDurationPicker(durationInMinutes: $selectedMinutes)
                        .frame(height: 200)
                        .background(Color.white.opacity(0.001))
                    
                    Button(action: {
                        giHaptic(2)
                        withAnimation(.spring()) {
                            inputMode = false
                            hasPassedInput = true
                        }
                    }) {
                        // 3D Button Style für "Bestätigen"
                        ZStack {
                            Capsule().fill(Color(red: 0.0, green: 0.35, blue: 0.1)) // Schatten
                                .offset(y: 6)
                            
                            Capsule().fill(accent)
                                .overlay(Capsule().stroke(Color.white.opacity(0.2), lineWidth: 1))
                            
                            Text(String(localized: "intro_input_confirm", defaultValue: "Bestätigen"))
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(Color(red: 0.03, green: 0.20, blue: 0.12))
                        }
                        .frame(height: 56)
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 24)
                }
                .background(
                    // 3D-Karte als Hintergrund
                    ZStack {
                        RoundedRectangle(cornerRadius: 24).fill(Color(white: 0.08)) // Schatten
                            .offset(y: 8)
                        RoundedRectangle(cornerRadius: 24).fill(Color(white: 0.14))
                            .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.white.opacity(0.1), lineWidth: 1))
                    }
                )
                .padding(.horizontal, 24)
                .transition(.opacity.combined(with: .scale(scale: 0.9)))
                .zIndex(10)
            }

            // --- 3D Hold-Button ---
            if !inputMode {
                VStack {
                    Spacer()
                    GI3DButton(
                        ringProgress: t / kIntroDuration,
                        isHolding: isHolding,
                        isPressed: isHolding,
                        wiggle: endWiggle,
                        accent: accent
                    )
                    .onLongPressGesture(minimumDuration: 100.0, maximumDistance: 100, pressing: { isPressing in
                        isHolding = isPressing
                        if isPressing {
                            giHaptic(2)
                        } else {
                            endWiggle = 0
                        }
                    }, perform: {})
                    .padding(.bottom, 40)
                    .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .onReceive(Timer.publish(every: 0.02, on: .main, in: .common).autoconnect()) { _ in
            if inputMode { return }
            
            // Vorlauf
            if isHolding {
                if !hasPassedInput && t >= 5.2 {
                    // Checkpoint 1 erreicht -> Pausiere und frage Input ab
                    isHolding = false
                    withAnimation(.spring()) {
                        inputMode = true
                    }
                } else {
                    t = min(t + 0.02, kIntroDuration)
                }
            }
            // Rücklauf (Zurückspulen, wenn man loslässt)
            else {
                let checkpoint = hasPassedInput ? 5.2 : 0.0
                if t > checkpoint {
                    t = max(checkpoint, t - 0.12) // schnelles Zurückspulen
                }
            }
            
            // Wackeln am Ende
            if t > kIntroDuration - 2.0 {
                let wiggleT = t - (kIntroDuration - 2.0)
                endWiggle = wiggleT
                let wStep = (wiggleT * 3).rounded(.down)
                if wStep > (endWiggle * 3 - 1).rounded(.down) {
                    giHaptic(2)
                }
            }
            
            // Haptik-Events abspielen
            for event in giEvents {
                if lastT < event.0 && t >= event.0 {
                    fire(event.1)
                }
            }
            lastT = t
        }
    }

    // MARK: - Aktionen

    private func finishNow() { onFinish() }

    private func fire(_ kind: GIKind) {
        // Sound deaktiviert per User Feedback
        switch kind {
        case .beat:  giHaptic(0)
        case .slam:  giHaptic(2)
        case .bloom: break
        case .logo:  giHaptic(2)
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
        let cut = 1.0 - goClamp01I((t - 13.5) / 0.5)
        let idx = currentSlam(t)
        let slam = slams[idx]
        let local = t - slam.start
        ZStack {
            GISpeedLines(t: t).ignoresSafeArea()
            GISlam(big: slam.big, small: slam.small, local: local, color: warning)
        }
        .opacity(cut)
    }

    private func currentSlam(_ t: Double) -> Int {
        var idx = 0
        let currentSlams = slams
        for i in 0..<currentSlams.count where t >= currentSlams[i].start { idx = i }
        return idx
    }

    // MARK: - Layer B: "Wie viel Zeit hättest du für andere Sachen?"

    @ViewBuilder
    private func layerB(_ t: Double) -> some View {
        let fade = 1.0 - goClamp01I((t - 17.5) / 0.4)
        let a1 = goOutI(goProgI(t, 14.2, 0.7))
        
        Text(String(localized: "intro_text_time_for_things", defaultValue: "Wie viel Zeit hättest du für andere Sachen?"))
            .font(.system(size: 38, weight: .black, design: .rounded))
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 24)
            .opacity(a1)
            .offset(y: CGFloat((1.0 - a1) * 20.0))
            .opacity(fade)
    }
    
    // MARK: - Layer C: Solution Texts

    @ViewBuilder
    private func layerC(_ t: Double) -> some View {
        let fade = 1.0 - goClamp01I((t - 22.0) / 0.4)
        
        let a1 = goOutI(goProgI(t, 18.0, 0.8))
        let a2 = goOutI(goProgI(t, 19.2, 0.8))
        let a3 = goOutI(goProgI(t, 20.4, 0.8))

        VStack(spacing: 32) {
            Text(String(localized: "intro_text_invest_time", defaultValue: "Investiere diese Zeit in dich."))
                .font(.system(size: 28, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
                .opacity(a1).offset(y: CGFloat((1.0 - a1) * 16.0))
            
            Text(String(localized: "intro_text_build_habits", defaultValue: "Baue echte Gewohnheiten auf."))
                .font(.system(size: 32, weight: .black, design: .rounded))
                .foregroundColor(accent)
                .opacity(a2).offset(y: CGFloat((1.0 - a2) * 16.0))
            
            Text(String(localized: "intro_text_grow_garden", defaultValue: "Und lass deinen Garten wachsen."))
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.8))
                .opacity(a3).offset(y: CGFloat((1.0 - a3) * 16.0))
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, 24)
        .opacity(fade)
    }

    // MARK: - Layer D: Logo

    @ViewBuilder
    private func layerD(_ t: Double) -> some View {
        let lp = goProgI(t, 22.6, 1.4); let lpE = goOutI(lp)
        let sweep = goInOutI(goProgI(t, 23.3, 1.1))
        let tag = goProgI(t, 23.7, 0.8)
        let btn = goOutI(goProgI(t, 24.1, 0.6))
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

// MARK: - 3D Hold-Button

private struct GI3DButton: View {
    let ringProgress: Double
    let isHolding: Bool
    let isPressed: Bool
    let wiggle: Double
    let accent: Color

    private let btnSize: CGFloat = 84
    private let ringSize: CGFloat = 112
    private let depth: CGFloat = 7
    private let lineW: CGFloat = 6

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.14), lineWidth: lineW)
                .frame(width: ringSize, height: ringSize)

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

            ZStack {
                // Sockel
                Circle()
                    .fill(Color(red: 0.8, green: 0.4, blue: 0.0))
                    .overlay(Circle().stroke(Color.black.opacity(0.1), lineWidth: 1))
                    .frame(width: btnSize, height: btnSize)
                
                // Top-Layer
                Circle()
                    .fill(Color.orange)
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
            .offset(y: depth / 2)
            
        }
        .offset(
            x: wiggle > 0 ? CGFloat(sin(wiggle * 28.0) * min(wiggle * 6, 8)) : 0,
            y: wiggle > 0 ? CGFloat(cos(wiggle * 21.0) * min(wiggle * 4, 5)) : 0
        )
        .animation(.spring(response: 0.22, dampingFraction: 0.5, blendDuration: 0), value: isPressed)
    }
}

// MARK: - Native Apple Countdown Picker

private struct GIDurationPicker: UIViewRepresentable {
    @Binding var durationInMinutes: Int

    func makeUIView(context: Context) -> UIDatePicker {
        let picker = UIDatePicker()
        picker.datePickerMode = .countDownTimer
        picker.overrideUserInterfaceStyle = .dark
        picker.addTarget(context.coordinator, action: #selector(Coordinator.changed(_:)), for: .valueChanged)
        picker.countDownDuration = TimeInterval(durationInMinutes * 60)
        return picker
    }

    func updateUIView(_ uiView: UIDatePicker, context: Context) {
        if Int(uiView.countDownDuration / 60) != durationInMinutes {
            uiView.countDownDuration = TimeInterval(durationInMinutes * 60)
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    class Coordinator: NSObject {
        var parent: GIDurationPicker
        init(_ parent: GIDurationPicker) { self.parent = parent }
        @objc func changed(_ sender: UIDatePicker) {
            parent.durationInMinutes = Int(sender.countDownDuration / 60)
        }
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

    private let scenes: [WordScene] = [
        WordScene(steps: [
            .init(words: [String(localized: "intro_flash_you", defaultValue: "DU.")], colors: [.white], sizes: [88]),
            .init(words: [String(localized: "intro_flash_you", defaultValue: "DU."), String(localized: "intro_flash_scroll", defaultValue: "SCROLLST.")], colors: [.white, .yellow], sizes: [56, 64]),
            .init(words: [String(localized: "intro_flash_you", defaultValue: "DU."), String(localized: "intro_flash_scroll", defaultValue: "SCROLLST."), String(localized: "intro_flash_everyday", defaultValue: "TÄGLICH.")], colors: [.white, .yellow, .orange], sizes: [44, 52, 60]),
        ], start: 0.0, stepDur: 1.20, gap: 0.4),

        WordScene(steps: [
            .init(words: [String(localized: "intro_flash_how_long", defaultValue: "WIE LANGE?")], colors: [.red], sizes: [72])
        ], start: 4.0, stepDur: 1.20, gap: 0.0),

        WordScene(steps: [
            .init(words: [String(localized: "intro_flash_really", defaultValue: "WIRKLICH?")], colors: [.gray], sizes: [46]),
            .init(words: [String(localized: "intro_flash_really", defaultValue: "WIRKLICH?"), String(localized: "intro_flash_way_too", defaultValue: "VIEL ZU")], colors: [.gray, .yellow], sizes: [46, 90]),
            .init(words: [String(localized: "intro_flash_really", defaultValue: "WIRKLICH?"), String(localized: "intro_flash_way_too", defaultValue: "VIEL ZU"), String(localized: "intro_flash_long", defaultValue: "LANGE.")], colors: [.gray, .yellow, .white], sizes: [46, 72, 64]),
        ], start: 5.2, stepDur: 1.20, gap: 0.4),
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
                    let fadeIn = min(1.0, stepLocal / 0.15)
                    let totalFade = sceneLocal > sceneDur - 0.2 ?
                        max(0.0, 1.0 - (sceneLocal - (sceneDur - 0.2)) / 0.15) : 1.0

                    VStack(spacing: 14) {
                        ForEach(Array(step.words.enumerated()), id: \.offset) { wordIdx, word in
                            let isNew = wordIdx == stepIdx
                            let decay = isNew ? exp(-stepLocal * 8.0) : 0.0
                            
                            ZStack {
                                Text(word)
                                    .font(.system(size: step.sizes[wordIdx], weight: .black, design: .rounded))
                                    .foregroundColor(step.colors[wordIdx].opacity(0.35))
                                    .offset(y: 4)
                                Text(word)
                                    .font(.system(size: step.sizes[wordIdx], weight: .black, design: .rounded))
                                    .foregroundColor(step.colors[wordIdx])
                            }
                            .shadow(color: step.colors[wordIdx].opacity(0.5), radius: 20)
                            .scaleEffect(CGFloat(1.0 + (isNew ? 0.12 * exp(-stepLocal * 10.0) : 0.0)))
                            .rotation3DEffect(
                                .degrees(isNew ? 12.0 * decay : 0),
                                axis: (x: 0.7, y: -0.5, z: 0.1)
                            )
                        }
                    }
                    .opacity(fadeIn * totalFade)
                }
            }

            RadialGradient(colors: [.clear, Color.black.opacity(0.5)],
                           center: .center, startRadius: 120, endRadius: 340)
                .ignoresSafeArea().allowsHitTesting(false)
        }
    }
}

// MARK: - Events

private enum GIKind { case beat, slam, bloom, logo }

private let giEvents: [(Double, GIKind)] = [
    (0.0, .beat), (1.2, .beat), (2.4, .beat),
    (4.0, .slam),
    (5.2, .beat), (6.4, .beat), (7.6, .slam),
    (10.5, .slam), (12.0, .slam),
    (14.2, .beat), (18.0, .beat), (19.2, .beat), (20.4, .beat),
    (23.3, .logo)
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

// MARK: - Continuous Speed-Linien (Warp Effekt)

private struct GISpeedLines: View {
    let t: Double
    var body: some View {
        Canvas { ctx, size in
            let w = Double(size.width); let h = Double(size.height)
            let cx = w / 2.0; let cy = h / 2.0; let n = 100
            
            let speed = 0.8
            
            for i in 0..<n {
                let ang = Double(i) / Double(n) * Double.pi * 2.0
                let phase = Double(i * 13 % 100) / 100.0
                let dist = giFract(t * speed + phase)
                
                if dist < 0.05 { continue }
                
                let r = pow(dist, 1.5) * max(w, h)
                let lineLen = dist * 120.0 + 10.0
                
                var lp = Path()
                let x = cx + cos(ang) * r; let y = cy + sin(ang) * r
                let xStart = cx + cos(ang) * (r - lineLen); let yStart = cy + sin(ang) * (r - lineLen)
                
                lp.move(to: CGPoint(x: xStart, y: yStart))
                lp.addLine(to: CGPoint(x: x, y: y))
                
                let lc = i % 5 == 0 ? Color.red : (i % 3 == 0 ? Color.white : Color.gray)
                let alpha = sin(dist * Double.pi)
                
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
                ZStack {
                    Text(small)
                        .font(.system(size: 24, weight: .heavy, design: .rounded))
                        .tracking(3)
                        .foregroundColor(color.opacity(0.35))
                        .offset(y: 3)
                        
                    Text(small)
                        .font(.system(size: 24, weight: .heavy, design: .rounded))
                        .tracking(3)
                        .foregroundColor(color)
                }
                .scaleEffect(CGFloat(1.0 + decay * 0.5))
                .opacity(goClamp01I(local * 12.0) * p)
            }
        }
        .offset(x: offsetX, y: offsetY)
        .opacity(goClamp01I(local * 12.0))
    }
}
