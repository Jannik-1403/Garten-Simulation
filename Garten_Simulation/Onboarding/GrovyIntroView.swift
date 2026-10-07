import SwiftUI
import AVFoundation
import Combine

// MARK: - GrovyIntroView  v10
//
// Ablauf (GNADENLOSE TRANSITIONS):
//   0.0 -  5.2  Teil 1: DU. SCROLLST. TÄGLICH. WIE LANGE?
//   --- PAUSE FÜR INPUT ---
//   5.2 -  9.2  Teil 2: WIRKLICH? VIEL ZU LANGE.
//   7.6         -> Speed-Linien beginnen nahtlos mit "LANGE." ! Hintergrund wird schwarz!
//   8.8 - 10.5  Herzschlag
//   9.6 - 14.5  Dynamische Slam-Zahlen (TikTok 3D Style, verzögerter Aufbau, kein Springen)
//  14.5 - 23.0  Solution Text (Ebenfalls im TikTok 3D Style!)
//  22.5 - 25.5  GROVY-Logo + Button

private let kIntroDuration: Double = 27.0

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

    private var textScenes: [GIWordScene] {
        let mins = max(1, selectedMinutes)
        let hoursPerYear = (mins * 365) / 60
        let daysInLife = (mins * 365 * 60) / 1440
        return [
            GIWordScene(
                words: [String(localized: "intro_flash_you", defaultValue: "DU."), String(localized: "intro_flash_scroll", defaultValue: "SCROLLST."), String(localized: "intro_flash_everyday", defaultValue: "TÄGLICH.")],
                colors: [.white, .yellow, .orange],
                sizes: [88, 64, 60],
                start: 0.0, stepDur: 1.2, gap: 0.4, fadeOutAt: 4.0
            ),
            GIWordScene(
                words: [String(localized: "intro_flash_how_long", defaultValue: "WIE LANGE?")],
                colors: [.red],
                sizes: [72],
                start: 4.0, stepDur: 1.2, gap: 0.0, fadeOutAt: 5.2
            ),
            GIWordScene(
                words: [String(localized: "intro_flash_really", defaultValue: "WIRKLICH?"), String(localized: "intro_flash_way_too", defaultValue: "VIEL ZU"), String(localized: "intro_flash_long", defaultValue: "LANGE.")],
                colors: [.gray, .yellow, .white],
                sizes: [46, 72, 64],
                start: 5.2, stepDur: 1.2, gap: 0.8, fadeOutAt: 9.6
            ),
            // SLAMS
            GIWordScene(
                words: ["\(hoursPerYear)", String(localized: "intro_slam_hours_year", defaultValue: "STUNDEN PRO JAHR")],
                colors: [.white, warning],
                sizes: [110, 24],
                start: 9.6, stepDur: 1.2, gap: 1.0, fadeOutAt: 12.0
            ),
            GIWordScene(
                words: ["\(daysInLife)", String(localized: "intro_slam_days_life", defaultValue: "TAGE DEINES LEBENS")],
                colors: [.white, warning],
                sizes: [110, 24],
                start: 12.0, stepDur: 1.2, gap: 1.0, fadeOutAt: 14.5
            ),
            // SOLUTION TEXTS – 1:1 wie Intro (gleiche Größen, Farben, Timing)
            GIWordScene(
                words: [
                    String(localized: "intro_sol_time_1", defaultValue: "WIE VIEL ZEIT"),
                    String(localized: "intro_sol_time_2", defaultValue: "HÄTTEST DU"),
                    String(localized: "intro_sol_time_3", defaultValue: "FÜR ANDERE SACHEN?")
                ],
                colors: [.white, .yellow, .orange],
                sizes: [88, 64, 56],
                start: 14.5, stepDur: 1.2, gap: 0.4, fadeOutAt: 18.5
            ),
            GIWordScene(
                words: [
                    String(localized: "intro_sol_invest_1", defaultValue: "INVESTIERE"),
                    String(localized: "intro_sol_invest_2", defaultValue: "DIESE ZEIT"),
                    String(localized: "intro_sol_invest_3", defaultValue: "IN DICH.")
                ],
                colors: [.white, .yellow, accent],
                sizes: [88, 64, 72],
                start: 18.5, stepDur: 1.2, gap: 0.4, fadeOutAt: 22.5
            ),
            GIWordScene(
                words: [
                    String(localized: "intro_sol_build_1", defaultValue: "BAUE ECHTE"),
                    String(localized: "intro_sol_build_2", defaultValue: "GEWOHNHEITEN"),
                    String(localized: "intro_sol_build_3", defaultValue: "AUF.")
                ],
                colors: [.white, accent, .orange],
                sizes: [72, 64, 88],
                start: 22.5, stepDur: 1.2, gap: 0.4, fadeOutAt: 26.5
            )
        ]
    }

    var body: some View {
        ZStack {
            // Immer schwarzer Hintergrund
            Color.black.ignoresSafeArea()

            ZStack {

                // Speed-Linien beginnen nahtlos exakt bei 7.6
                if t > 7.6 && t < 15.0 { 
                    let fadeIn = goClamp01I((t - 7.6) / 1.0)
                    let fadeOut = 1.0 - goClamp01I((t - 14.5) / 0.5)
                    GISpeedLines(t: t)
                        .opacity(fadeIn * fadeOut)
                        .ignoresSafeArea()
                }

                // Herzschlag
                if t > 8.8 && t < 10.5 { heartbeat(t - 8.8) }

                // Einheitliche 3D Text Szenen (inkl. TikTok Wörter, Slams und Solution)
                if t < 27.0 {
                    GIWordBuildUp(t: t, scenes: textScenes).ignoresSafeArea()
                }

                // Phase 5: Logo
                if t > 26.0 { layerD(t) }

                // Auto-Finish
                if t > 29.0 { Color.clear.onAppear { finishNow() } }
            }
            // Ganzer Screen schüttelt am Ende – nicht nur der Button
            .offset(
                x: endWiggle > 0 ? CGFloat(sin(endWiggle * 28.0) * min(endWiggle * 5, 7)) : 0,
                y: endWiggle > 0 ? CGFloat(cos(endWiggle * 21.0) * min(endWiggle * 3, 4)) : 0
            )

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
                        Text(String(localized: "intro_input_confirm", defaultValue: "Bestätigen"))
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .buttonStyle(GIConfirmButtonStyle(accent: accent)) // Korrekter Item3D Button Style
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
            
            // Wackeln am Ende – ganzer Screen + starke Vibration
            if t > kIntroDuration - 2.0 {
                let wiggleT = t - (kIntroDuration - 2.0)
                endWiggle = wiggleT
                let wStep = (wiggleT * 4).rounded(.down)
                let prevStep = ((wiggleT - 0.02) * 4).rounded(.down)
                if wStep > prevStep {
                    #if canImport(UIKit)
                    UINotificationFeedbackGenerator().notificationOccurred(.warning)
                    #endif
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

    // MARK: - Layer D: Logo

    @ViewBuilder
    private func layerD(_ t: Double) -> some View {
        let lp = goProgI(t, 26.1, 1.4); let lpE = goOutI(lp)
        let sweep = goInOutI(goProgI(t, 26.8, 1.1))
        let btn = goOutI(goProgI(t, 27.3, 0.6))
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

// MARK: - Input Confirm Button Style

private struct GIConfirmButtonStyle: ButtonStyle {
    let accent: Color
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            // Sockel
            Capsule().fill(Color.black.opacity(0.4))
                .overlay(Capsule().stroke(Color.black.opacity(0.2), lineWidth: 1))
            
            // Top-Layer
            Capsule().fill(accent)
                .overlay(Capsule().stroke(Color.white.opacity(0.15), lineWidth: 1))
                .overlay { configuration.label }
                .offset(y: configuration.isPressed ? 0 : -6)
        }
        .offset(y: 6)
        .frame(height: 56)
        .animation(.spring(response: 0.22, dampingFraction: 0.5), value: configuration.isPressed)
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

// MARK: - Einheitliche TikTok 3D Text Szenen

private struct GIWordScene {
    let words: [String]
    let colors: [Color]
    let sizes: [CGFloat]
    let start: Double
    let stepDur: Double
    let gap: Double
    let fadeOutAt: Double
}

private struct GIWordBuildUp: View {
    let t: Double
    let scenes: [GIWordScene]

    var body: some View {
        ZStack {
            ForEach(Array(scenes.enumerated()), id: \.offset) { _, scene in
                let sceneLocal = t - scene.start
                
                if sceneLocal >= 0 && t < scene.fadeOutAt {
                    let stepIdx = min(scene.words.count - 1, Int(sceneLocal / scene.stepDur))
                    let stepLocal = sceneLocal - Double(stepIdx) * scene.stepDur
                    
                    let fadeOutT = scene.fadeOutAt - t
                    let totalFade = fadeOutT < 0.2 ? max(0.0, fadeOutT / 0.2) : 1.0

                    // Dynamischer ForEach: Nur bereits sichtbare W\u00f6rter werden gerendert
                    // -> Kein reservierter Platz, echtes Wort-f\u00fcr-Wort wie am Anfang
                    VStack(spacing: 14) {
                        let visibleRange = 0...min(stepIdx, scene.words.count - 1)
                        ForEach(visibleRange, id: \.self) { wordIdx in
                            let isNew = wordIdx == stepIdx
                            let decay = isNew ? exp(-stepLocal * 8.0) : 0.0
                            let pop = isNew ? 0.12 * exp(-stepLocal * 10.0) : 0.0
                            let fadeIn = isNew ? min(1.0, stepLocal / 0.15) : 1.0

                            ZStack {
                                Text(scene.words[wordIdx])
                                    .font(.system(size: scene.sizes[wordIdx], weight: .black, design: .rounded))
                                    .foregroundColor(scene.colors[wordIdx].opacity(0.35))
                                    .offset(y: 4)
                                Text(scene.words[wordIdx])
                                    .font(.system(size: scene.sizes[wordIdx], weight: .black, design: .rounded))
                                    .foregroundColor(scene.colors[wordIdx])
                            }
                            .shadow(color: scene.colors[wordIdx].opacity(0.5), radius: 20)
                            .scaleEffect(CGFloat(1.0 + pop))
                            .rotation3DEffect(
                                .degrees(isNew ? 12.0 * decay : 0),
                                axis: (x: 0.7, y: -0.5, z: 0.1)
                            )
                            .opacity(fadeIn)
                        }
                    }
                    .opacity(totalFade)
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
    (9.6, .slam), (10.8, .beat),
    (12.0, .slam), (13.2, .beat),
    (14.5, .beat), (15.7, .beat),
    (18.0, .beat), (19.2, .beat),
    (20.5, .beat), (21.7, .beat),
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
