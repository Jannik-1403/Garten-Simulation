import SwiftUI
import AVFoundation
import Combine

// MARK: - GrovyIntroView
//
// Ablauf (gedrückt halten):
//   0.0 - 4.0   TikTok-Edit: Wort-Flash ("DU.", "SCROLLST.", "WIE LANG?", ...)
//   4.0 - 5.5   Herzschlag
//   5.2 - 9.5   Speed-Linien + 3 Slam-Zahlen (180 MIN / 47 SEK / 46 TAGE)
//   9.5 - 10.5  Weicher Fade-out
//  10.5 - 12.5  "Dein Gehirn will mehr."
//  12.5 - 17.0  Statistik-Canvas mit Balkendiagramm
//  17.0 - 19.0  GROVY-Logo + Button
//
// Nutzung:
//   GrovyIntroView(onFinish: { /* weiter im Onboarding */ })

private let kIntroDuration: Double = 19.0

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

    init(
        accent: Color = .blauPrimary,
        warning: Color = .red,
        background: Color = .clear,
        soundEnabled: Bool = true,
        buttonTitle: String = "Los geht's",
        onFinish: @escaping () -> Void = {}
    ) {
        self.accent = accent
        self.warning = warning
        self.background = background
        self.soundEnabled = soundEnabled
        self.buttonTitle = buttonTitle
        self.onFinish = onFinish
    }

    private let slams: [(start: Double, big: String, small: String)] = [
        (5.8, "180", "MIN. AM TAG"),
        (7.0, "47", "SEK. FOKUS"),
        (8.2, "46", "TAGE IM JAHR")
    ]

    var body: some View {
        ZStack {
            background.ignoresSafeArea()

            GITimed(startDate: startTick) { t in
                ZStack {
                    if startTick != nil {
                        // Phase 0: TikTok Word Flash
                        if t < 4.5 { GIWordFlash(t: t).ignoresSafeArea() }

                        // Phase 1: Herzschlag
                        if t > 4.0 && t < 5.5 { heartbeat(t - 4.0) }

                        // Phase 2: Speed-Linien + Slam-Zahlen
                        if t > 5.2 && t < 9.5 { layerA(t) }

                        // Weicher Fade
                        if t > 9.0 && t < 10.5 {
                            background
                                .opacity(goClamp01I((t - 9.0) / 1.0))
                                .ignoresSafeArea()
                                .allowsHitTesting(false)
                        }

                        // Phase 3: Text
                        if t > 10.5 && t < 12.5 { layerB(t) }

                        // Phase 4: Statistik
                        if t > 12.3 {
                            GIStats(t: t, accent: accent)
                                .ignoresSafeArea()
                                .scaleEffect(CGFloat(1.0 + 0.08 * goProgI(t, 13.4, 5.0)))
                                .opacity(goProgI(t, 12.3, 0.8))
                                .allowsHitTesting(false)
                        }

                        // Phase 5: Logo
                        if t > 17.0 { layerD(t) }

                        // Auto-Finish
                        if t > 19.0 { Color.clear.onAppear { finishNow() } }

                    } else {
                        // Noch nicht gedrückt
                        VStack {
                            Spacer()
                            VStack(spacing: 6) {
                                Image(systemName: "hand.tap.fill")
                                    .font(.system(size: 36))
                                    .foregroundColor(.gray.opacity(0.45))
                                Text(String(localized: "intro_hold_to_play",
                                            defaultValue: "Gedrückt halten um zu starten"))
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(.gray.opacity(0.5))
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.bottom, 130)
                        }
                    }
                }
            }

            // Runder Hold-Button + Kreisring – immer sichtbar
            VStack {
                Spacer()
                GIHoldButton(ringProgress: ringProgress, isHolding: startTick != nil, accent: accent)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in
                                if startTick == nil {
                                    startTick = Date()
                                    ringProgress = 0
                                    lastHapticProgress = 0
                                    giHaptic(1)
                                    schedule()
                                }
                            }
                            .onEnded { _ in
                                startTick = nil
                                audio.stop()
                                withAnimation(.easeOut(duration: 0.5)) { ringProgress = 0 }
                            }
                    )
                    .padding(.bottom, 52)
            }
        }
        .onReceive(Timer.publish(every: 0.03, on: .main, in: .common).autoconnect()) { _ in
            guard let tick = startTick else { return }
            let elapsed = Date().timeIntervalSince(tick)
            ringProgress = min(1.0, elapsed / kIntroDuration)
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

    // MARK: - Layer A: Speed + Slam

    @ViewBuilder
    private func layerA(_ t: Double) -> some View {
        let cut = 1.0 - goClamp01I((t - 9.0) / 0.6)
        let idx = currentSlam(t)
        let slam = slams[idx]
        let local = t - slam.start
        ZStack {
            GISpeedLines(t: t - 5.2).ignoresSafeArea()
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
        let fade = 1.0 - goClamp01I((t - 12.0) / 0.4)
        let a1 = goOutI(goProgI(t, 10.6, 0.7))
        let a2 = goOutI(goProgI(t, 11.4, 1.0))
        VStack(spacing: 12) {
            Text("Dein Gehirn will mehr.")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(Color.primary)
                .opacity(a1).offset(y: CGFloat((1.0 - a1) * 16.0))
            Text("Nicht besser.")
                .font(.system(size: 36, weight: .heavy, design: .rounded))
                .tracking(CGFloat(10.0 - 8.0 * a2))
                .foregroundColor(warning).opacity(a2)
        }
        .multilineTextAlignment(.center).opacity(fade)
    }

    // MARK: - Layer D: Logo

    @ViewBuilder
    private func layerD(_ t: Double) -> some View {
        let lp = goProgI(t, 17.1, 1.4)
        let lpE = goOutI(lp)
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
                        LinearGradient(colors: [.clear, accent, .clear], startPoint: .leading, endPoint: .trailing)
                            .frame(width: 80).offset(x: CGFloat(-220.0 + 440.0 * sweep))
                            .blendMode(.plusLighter).mask(word)
                    }
                    .shadow(color: accent.opacity(0.7 * lp), radius: 24)
                    .scaleEffect(CGFloat(1.25 - 0.25 * lpE)).opacity(lp)
                Text("Aus Gewohnheiten wächst dein Garten.")
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

// MARK: - Hold-Button mit Kreisring

private struct GIHoldButton: View {
    let ringProgress: Double
    let isHolding: Bool
    let accent: Color

    private let buttonSize: CGFloat = 80
    private let ringSize: CGFloat = 98
    private let lineWidth: CGFloat = 6

    var body: some View {
        ZStack {
            // Hintergrund-Ring (immer sichtbar, dezent)
            Circle()
                .stroke(Color.white.opacity(0.14), lineWidth: lineWidth)
                .frame(width: ringSize, height: ringSize)

            // Fortschritts-Ring
            Circle()
                .trim(from: 0, to: CGFloat(ringProgress))
                .stroke(
                    LinearGradient(colors: [.yellow, .orange],
                                   startPoint: .topLeading, endPoint: .bottomTrailing),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .frame(width: ringSize, height: ringSize)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.05), value: ringProgress)

            // 3D-Schatten
            Circle()
                .fill(Color.orange.opacity(0.6))
                .frame(width: buttonSize, height: buttonSize)
                .offset(y: 7)

            // Haupt-Button
            Circle()
                .fill(LinearGradient(colors: [.yellow, Color.orange.opacity(0.9)],
                                     startPoint: .top, endPoint: .bottom))
                .frame(width: buttonSize, height: buttonSize)

            // Icon
            Image(systemName: isHolding ? "fingerprint" : "hand.tap.fill")
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
        }
        .scaleEffect(isHolding ? 0.93 : 1.0)
        .animation(.spring(response: 0.25, dampingFraction: 0.6), value: isHolding)
    }
}

// MARK: - TikTok Word Flash (Phase 0)

private struct GIWordFlash: View {
    let t: Double

    private struct FlashWord {
        let text: String; let start: Double; let dur: Double
        let color: Color; let size: CGFloat
    }

    private let words: [FlashWord] = [
        FlashWord(text: "DU.",       start: 0.0,  dur: 0.32, color: .white,      size: 90),
        FlashWord(text: "SCROLLST.", start: 0.4,  dur: 0.32, color: .yellow,     size: 68),
        FlashWord(text: "WISCHT.",   start: 0.78, dur: 0.32, color: .white,      size: 78),
        FlashWord(text: "TIPPST.",   start: 1.16, dur: 0.32, color: .orange,     size: 74),
        FlashWord(text: "TÄGLICH.",  start: 1.54, dur: 0.42, color: .white,      size: 84),
        FlashWord(text: "ABER",      start: 2.05, dur: 0.28, color: Color(white: 0.5), size: 56),
        FlashWord(text: "WIE",       start: 2.38, dur: 0.26, color: .white,      size: 76),
        FlashWord(text: "LANG?",     start: 2.70, dur: 0.55, color: .red,        size: 100),
        FlashWord(text: "180",       start: 3.35, dur: 0.30, color: .yellow,     size: 120),
        FlashWord(text: "MINUTEN.",  start: 3.72, dur: 0.50, color: .white,      size: 66),
    ]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ForEach(Array(words.enumerated()), id: \.offset) { _, word in
                let local = t - word.start
                if local >= 0 && local < word.dur + 0.12 {
                    let fadeIn = min(1.0, local / 0.06)
                    let fadeOut = local > word.dur ? max(0.0, 1.0 - (local - word.dur) / 0.1) : 1.0
                    let scale = CGFloat(1.0 + 0.14 * exp(-local * 14.0))
                    let rot = 12.0 * exp(-local * 10.0)

                    Text(word.text)
                        .font(.system(size: word.size, weight: .black, design: .rounded))
                        .foregroundColor(word.color)
                        .shadow(color: word.color.opacity(0.55), radius: 24)
                        .scaleEffect(scale)
                        .rotation3DEffect(.degrees(rot), axis: (x: 0.8, y: -0.5, z: 0.1))
                        .opacity(fadeIn * fadeOut)
                }
            }

            // Vignette
            RadialGradient(
                colors: [.clear, Color.black.opacity(0.55)],
                center: .center, startRadius: 100, endRadius: 320
            )
            .ignoresSafeArea().allowsHitTesting(false)
        }
    }
}

// MARK: - Events

private enum GIKind { case beat, slam, bloom, logo }

private let giEvents: [(Double, GIKind)] = [
    (4.3, .beat), (4.6, .beat),
    (5.8, .slam), (7.0, .slam), (8.2, .slam), (9.0, .slam),
    (13.4, .bloom),
    (17.8, .logo)
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
private func giRect(_ x: Double, _ y: Double, _ w: Double, _ h: Double) -> CGRect {
    CGRect(x: x, y: y, width: w, height: h)
}

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
            } else {
                content(0.0)
            }
        }
    }
}

// MARK: - Speed-Linien

private struct GISpeedLines: View {
    let t: Double
    var body: some View {
        Canvas { ctx, size in
            let w = Double(size.width); let h = Double(size.height)
            let cx = w / 2.0; let cy = h / 2.0
            let n = 80
            let p = goClamp01I(t / 0.6)
            let fadeOut = 1.0 - goClamp01I((t - 3.5) / 0.7)
            let speed = 1.0 + t * 1.5
            for i in 0..<n {
                let ang = Double(i) / Double(n) * Double.pi * 2.0
                let r = (Double(i % 7) / 7.0 * 0.3 + 0.35) * min(w, h) * speed
                let alpha = min(1.0, t * 4.0) * fadeOut
                let lineLen = r * 0.5 + 40.0
                let lineW = 3.0 * p + 1.0
                var lp = Path()
                let x = cx + cos(ang) * r; let y = cy + sin(ang) * r
                lp.move(to: CGPoint(x: cx + cos(ang) * (r - lineLen), y: cy + sin(ang) * (r - lineLen)))
                lp.addLine(to: CGPoint(x: x, y: y))
                let lc = i % 5 == 0 ? Color.red : (i % 3 == 0 ? Color.white : Color.gray)
                ctx.stroke(lp, with: .color(lc.opacity(alpha * (i % 5 == 0 ? 0.8 : 0.4))),
                           style: StrokeStyle(lineWidth: CGFloat(lineW), lineCap: .round))
            }
        }
    }
}

// MARK: - Slam-Zahl (3D Button Style)

private struct GISlam: View {
    let big: String; let small: String; let local: Double; let color: Color
    var body: some View {
        let p = goOutI(goClamp01I(local / 0.25))
        let decay = exp(-max(0.0, local) * 9.0)
        let s = CGFloat(1.4 - 0.4 * p)
        let offsetX = CGFloat(sin(local * 90.0) * 20.0 * decay)
        let offsetY = CGFloat(20.0 * (1.0 - p) + cos(local * 70.0) * 15.0 * decay)
        let rotDegrees = 15.0 * decay
        let scale2 = CGFloat(1.0 + decay * 0.5)
        let opac = goClamp01I(local * 12.0)
        return VStack(spacing: 12) {
            Text(big)
                .font(.system(size: 80, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 40).padding(.vertical, 16)
                .background(ZStack {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color(white: 0.1)).offset(y: 16)
                    RoundedRectangle(cornerRadius: 24, style: .continuous).fill(color)
                })
                .scaleEffect(s)
                .rotation3DEffect(.degrees(rotDegrees), axis: (x: 1, y: -0.5, z: 0))
            if !small.isEmpty {
                Text(small)
                    .font(.system(size: 28, weight: .heavy, design: .rounded)).tracking(10)
                    .foregroundColor(color).padding(.horizontal, 24).padding(.vertical, 8)
                    .background(Capsule().fill(Color(white: 0.1)))
                    .scaleEffect(scale2).opacity(p)
            }
        }
        .offset(x: offsetX, y: offsetY).opacity(opac)
    }
}

// MARK: - Statistik (Canvas)

private struct GIStats: View {
    let t: Double; let accent: Color
    var body: some View {
        Canvas { ctx, size in
            let w = Double(size.width); let h = Double(size.height)
            let cx = w / 2.0; let baseY = h * 0.72
            let statP = goInOutI(goProgI(t, 13.4, 3.0))
            if statP > 0 {
                let gridAlpha = statP * 0.12
                for col in 0..<8 {
                    var gp = Path()
                    let x = w * Double(col) / 7.0
                    gp.move(to: CGPoint(x: x, y: h * 0.2)); gp.addLine(to: CGPoint(x: x, y: h * 0.85))
                    ctx.stroke(gp, with: .color(Color.white.opacity(gridAlpha)), style: StrokeStyle(lineWidth: 1))
                }
                let bars: [(label: String, val: Double, color: Color)] = [
                    ("Heute", 0.72, .red),
                    ("Vorwoche", 0.65, Color(white: 0.5)),
                    ("Ziel", 0.30, accent),
                ]
                let barW = w * 0.14; let gap = w * 0.07
                let totalW = Double(bars.count) * barW + Double(bars.count - 1) * gap
                var bx = cx - totalW / 2.0
                for bar in bars {
                    let barH = h * 0.45 * bar.val * statP
                    let barRect = CGRect(x: bx, y: baseY - barH, width: barW, height: barH)
                    ctx.fill(Path(roundedRect: barRect, cornerRadius: 10), with: .color(bar.color.opacity(0.9)))
                    ctx.draw(Text(bar.label).font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.7)),
                             at: CGPoint(x: bx + barW / 2, y: baseY + 18), anchor: .center)
                    bx += barW + gap
                }
                var bp = Path()
                bp.move(to: CGPoint(x: cx - totalW / 2, y: baseY))
                bp.addLine(to: CGPoint(x: cx + totalW / 2, y: baseY))
                ctx.stroke(bp, with: .color(Color.white.opacity(0.3 * statP)), style: StrokeStyle(lineWidth: 2))
                let ta = goProgI(t, 13.4, 0.6)
                ctx.draw(Text("BILDSCHIRMZEIT").font(.system(size: 13, weight: .heavy, design: .rounded))
                    .foregroundColor(.white.opacity(0.45 * ta)),
                         at: CGPoint(x: cx, y: h * 0.18), anchor: .center)
                ctx.draw(Text("Dein Durchschnitt vs. Ziel").font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundColor(.white.opacity(ta)),
                         at: CGPoint(x: cx, y: h * 0.24), anchor: .center)
            }
            let fireflyP = goProgI(t, 14.5, 2.0)
            if fireflyP > 0 {
                for i in 0..<28 {
                    let fi = Double(i)
                    let fx = cx + sin(fi * 1.37 + t * 0.6) * w * 0.38
                    let fy = baseY - fi / 28.0 * h * 0.55 - giFract(t * 0.04 + fi * 0.07) * h * 0.1
                    let fa = fireflyP * (0.4 + 0.6 * sin(t * 2.5 + fi * 0.9))
                    let fr = 3.0 + sin(fi * 2.1 + t) * 1.5
                    ctx.fill(Path(ellipseIn: CGRect(x: fx - fr, y: fy - fr, width: fr * 2, height: fr * 2)),
                             with: .color(accent.opacity(fa)))
                }
            }
        }
    }
}

private func giFract(_ x: Double) -> Double { x - floor(x) }

// MARK: - Sound

private final class GIAudio: ObservableObject {
    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()
    private let sampleRate = 44100.0
    private var ready = false

    func start(enabled: Bool) {
        guard enabled, !ready else { return }
        #if os(iOS)
        try? AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [.mixWithOthers])
        try? AVAudioSession.sharedInstance().setActive(true)
        #endif
        guard let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1) else { return }
        engine.attach(player); engine.connect(player, to: engine.mainMixerNode, format: format)
        do { try engine.start(); player.play(); ready = true } catch { ready = false }
    }

    func stop() {
        if ready { player.stop(); engine.stop(); ready = false }
    }

    private func play(_ samples: [Float]) {
        guard ready,
              let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1),
              let buf = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(samples.count))
        else { return }
        buf.frameLength = AVAudioFrameCount(samples.count)
        if let ch = buf.floatChannelData?[0] { for i in 0..<samples.count { ch[i] = samples[i] } }
        player.scheduleBuffer(buf, completionHandler: nil)
    }

    func slam() {
        let n = Int(0.9 * sampleRate); var s = [Float](repeating: 0, count: n); var ph = 0.0
        for i in 0..<n { let x = Double(i)/sampleRate; let f = 48.0 + 120.0 * exp(-x * 22.0); ph += 2.0 * .pi * f / sampleRate; let e = exp(-x * 4.5); s[i] = Float((sin(ph) + 0.25 * sin(ph*2)*e)*e*0.9) }
        play(s)
    }

    func beat() {
        let n = Int(0.25 * sampleRate); var s = [Float](repeating: 0, count: n); var ph = 0.0
        for i in 0..<n { let x = Double(i)/sampleRate; let f = 62.0 + 40.0 * exp(-x*30.0); ph += 2.0 * .pi * f / sampleRate; s[i] = Float(sin(ph) * exp(-x*16.0) * 0.8) }
        play(s)
    }

    func shimmer() {
        let n = Int(3.0 * sampleRate); var s = [Float](repeating: 0, count: n); var ph = 0.0
        for i in 0..<n { let x = Double(i)/sampleRate; let k = x/3.0; let f = 400.0 + 1300.0*k*k; ph += 2.0 * .pi * f / sampleRate; let e = sin(.pi*k); s[i] = Float((sin(ph)+0.4*sin(ph*1.5))*e*0.18) }
        play(s)
    }
}

// MARK: - Preview

struct GrovyIntroView_Previews: PreviewProvider {
    static var previews: some View { GrovyIntroView() }
}
