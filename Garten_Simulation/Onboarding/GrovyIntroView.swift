import SwiftUI
import AVFoundation
import Combine

// MARK: - GrovyIntroView
//
// Cinematic-Intro (~15 s), komplett in Swift – keine Video-/Audio-Dateien, kein Metal, keine Fremd-Libs.
//
// Ablauf:
//   0.0 - 1.2  Schwarz, Herzschlag (Haptik + Bass)
//   1.2 - 5.6  Kachel-Sturm auf die Kamera + 3 Slam-Zahlen (180 MIN / 47 SEK / 46 TAGE), Screen-Shake, Glitch
//   5.4 - 6.4  Weißer Blitz, Cut to Black
//   6.4 - 8.4  "Dein Gehirn will mehr. Nicht besser."
//   8.4 - 12.5 Samen leuchtet, Pflanze wächst, Lichtstrahlen, Glühwürmchen
//  12.5 - 15   GROVY-Logo mit Lichtsweep, Tagline, Button
//
// Zahlen: Bitkom 2026 (180 Min./Tag -> ca. 46 Tage/Jahr), Gloria Mark/UC Irvine (47 s Aufmerksamkeit pro Bildschirm).
// Sound wird im Code synthetisiert (AVAudioEngine). soundEnabled: false schaltet ihn ab.
//
// Nutzung:
//   GrovyIntroView(onFinish: { /* weiter im Onboarding */ })

struct GrovyIntroView: View {
    let accent: Color
    let warning: Color
    let background: Color
    let soundEnabled: Bool
    let buttonTitle: String
    let onFinish: () -> Void

    @StateObject private var audio = GIAudio()
    @State private var alive = true

    init(
        accent: Color = .blauPrimary, // Angepasst an Grovy
        warning: Color = .red, // Angepasst an Grovy Warn-Farbe
        background: Color = Color(UIColor.systemBackground),
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
        (1.4, "180", "MIN. AM TAG"),
        (2.6, "47", "SEK. FOKUS"),
        (3.8, "46", "TAGE IM JAHR")
    ]

    var body: some View {
        GITimed { t in
            ZStack {
                background.ignoresSafeArea()

                if t < 1.5 {
                    heartbeat(t)
                }

                if t > 1.1 && t < 5.6 {
                    layerA(t)
                }

                // Weicher Fadeout statt harter Blitz
                if t > 5.0 && t < 6.0 {
                    background
                        .opacity(goClamp01I((t - 5.0) / 0.6))
                        .ignoresSafeArea()
                        .allowsHitTesting(false)
                }

                if t > 6.4 && t < 8.5 {
                    layerB(t)
                }

                if t > 8.3 {
                    GIStats(t: t, accent: accent)
                        .ignoresSafeArea()
                        .scaleEffect(CGFloat(1.0 + 0.08 * goProgI(t, 9.4, 5.0)))
                        .opacity(goProgI(t, 8.3, 0.8))
                        .allowsHitTesting(false)
                }

                if t > 12.3 {
                    layerD(t)
                }

                if t < 13.5 {
                    VStack {
                        HStack {
                            Spacer()
                            Button(action: finishNow) {
                                Text("Überspringen")
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color.white.opacity(0.6))
                            }
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                }
            }
        }
        .onAppear { schedule() }
        .onDisappear { alive = false }
    }

    // MARK: Aktionen

    private func finishNow() {
        alive = false
        onFinish()
    }

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
        case .beat:
            giHaptic(0)
            audio.beat()
        case .slam:
            giHaptic(2)
            audio.slam()
        case .bloom:
            giHaptic(0)
            audio.shimmer()
        case .logo:
            giHaptic(2)
            audio.slam()
        }
    }

    // MARK: Layer 0: Herzschlag

    @ViewBuilder
    private func heartbeat(_ t: Double) -> some View {
        let r = 5.0 + 18.0 * giPulse(t, 0.3) + 18.0 * giPulse(t, 0.6)
        let a = goProgI(t, 0.0, 0.3)
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.18 * a))
                .frame(width: CGFloat(r * 4.0), height: CGFloat(r * 4.0))
                .blur(radius: 14)
            Circle()
                .fill(Color.white.opacity(a))
                .frame(width: CGFloat(r), height: CGFloat(r))
        }
    }

    // MARK: Layer A: Kachel-Sturm + Slams

    @ViewBuilder
    private func layerA(_ t: Double) -> some View {
        let cut = 1.0 - goClamp01I((t - 5.0) / 0.6) // Weicher, längerer Fade-out
        let idx = currentSlam(t)
        let slam = slams[idx]
        let local = t - slam.start

        ZStack {
            GIDopamineIcons(t: t - 1.2)
                .ignoresSafeArea()
            GISlam(big: slam.big, small: slam.small, local: local, color: warning)
            background
                .opacity(0.65 * exp(-max(0.0, local) * 10.0))
                .ignoresSafeArea()
                .allowsHitTesting(false)
        }
        .opacity(cut)
    }

    private func currentSlam(_ t: Double) -> Int {
        var idx = 0
        for i in 0..<slams.count where t >= slams[i].start {
            idx = i
        }
        return idx
    }

    // MARK: Layer B: Text

    @ViewBuilder
    private func layerB(_ t: Double) -> some View {
        let fade = 1.0 - goClamp01I((t - 8.0) / 0.4)
        let a1 = goOutI(goProgI(t, 6.5, 0.7))
        let a2 = goOutI(goProgI(t, 7.3, 1.0))
        VStack(spacing: 12) {
            Text("Dein Gehirn will mehr.")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(Color.primary)
                .opacity(a1)
                .offset(y: CGFloat((1.0 - a1) * 16.0))
            Text("Nicht besser.")
                .font(.system(size: 36, weight: .heavy, design: .rounded))
                .tracking(CGFloat(10.0 - 8.0 * a2))
                .foregroundColor(warning)
                .opacity(a2)
        }
        .multilineTextAlignment(.center)
        .opacity(fade)
    }

    // MARK: Layer D: Logo + Button

    @ViewBuilder
    private func layerD(_ t: Double) -> some View {
        let lp = goProgI(t, 12.5, 1.4)
        let lpE = goOutI(lp)
        let sweep = goInOutI(goProgI(t, 13.2, 1.1))
        let tag = goProgI(t, 13.6, 0.8)
        let btn = goOutI(goProgI(t, 14.2, 0.6))
        let word = Text("GROVY")
            .font(.system(size: 58, weight: .black, design: .rounded))
            .tracking(CGFloat(26.0 - 20.0 * lpE))

        ZStack {
            VStack(spacing: 14) {
                word
                    .foregroundColor(.white)
                    .overlay {
                        ZStack {
                            LinearGradient(
                                colors: [Color.clear, accent, Color.clear],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            .frame(width: 80)
                            .offset(x: CGFloat(-220.0 + 440.0 * sweep))
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .blendMode(.plusLighter)
                        .mask(word)
                    }
                    .shadow(color: accent.opacity(0.7 * lp), radius: 24)
                    .scaleEffect(CGFloat(1.25 - 0.25 * lpE))
                    .opacity(lp)

                Text("Aus Gewohnheiten wächst dein Garten.")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(Color.white.opacity(0.75))
                    .opacity(tag)
                    .offset(y: CGFloat((1.0 - tag) * 10.0))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.top, 110)

            VStack {
                Spacer()
                Button(action: finishNow) {
                    Text(buttonTitle)
                        .font(.system(size: 19, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.03, green: 0.20, blue: 0.12))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 17)
                        .background(Capsule().fill(accent))
                        .shadow(color: accent.opacity(0.5), radius: 16, x: 0, y: 6)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 48)
                .scaleEffect(CGFloat(0.8 + 0.2 * btn))
                .opacity(btn)
            }
        }
    }
}

// MARK: - Events (Haptik + Sound)

private enum GIKind {
    case beat
    case slam
    case bloom
    case logo
}

private let giEvents: [(Double, GIKind)] = [
    (0.3, .beat), (0.6, .beat),
    (1.4, .slam), (2.6, .slam), (3.8, .slam), (5.4, .slam),
    (9.4, .bloom),
    (13.2, .logo)
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
private func giFract(_ x: Double) -> Double { x - floor(x) }
private func giPulse(_ t: Double, _ at: Double) -> Double { t >= at ? exp(-(t - at) * 9.0) : 0.0 }
private func giFlash(_ t: Double) -> Double { 0.0 } // Nicht mehr genutzt, durch weichen Fade ersetzt
private func giRect(_ x: Double, _ y: Double, _ w: Double, _ h: Double) -> CGRect {
    CGRect(x: x, y: y, width: w, height: h)
}

private struct GITimed<Content: View>: View {
    @State private var start = Date()
    private let content: (Double) -> Content

    init(@ViewBuilder _ content: @escaping (Double) -> Content) {
        self.content = content
    }

    var body: some View {
        TimelineView(.animation) { ctx in
            content(ctx.date.timeIntervalSince(start))
        }
    }
}

// MARK: - Dopamin Icons (Canvas)

private struct GIDopamineIcons: View {
    let t: Double
    let icons = ["📱", "💬", "🎮", "▶️", "❤️"]

    var body: some View {
        Canvas { ctx, size in
            let cx = Double(size.width) / 2.0
            let cy = Double(size.height) / 2.0
            let reach = max(Double(size.width), Double(size.height)) * 0.8

            for i in 0..<60 {
                let seed = Double(i)
                let ang = giFract(sin(seed * 12.9898) * 43758.5453) * 2.0 * Double.pi
                let delay = giFract(seed * 0.37) * 1.6
                let local = t - delay
                if local <= 0 { continue }

                let period = 2.2
                let p = local.truncatingRemainder(dividingBy: period) / period
                let r = pow(p, 2.5) * reach * 1.5
                let w = 40.0 * (0.15 + 3.0 * pow(p, 1.8))
                let x = cx + cos(ang) * r
                let y = cy + sin(ang) * r
                let fadeOut = 1.0 - max(0.0, p - 0.85) / 0.15
                let alpha = min(1.0, local * 4.0) * fadeOut

                // Dezente Speed-Linien
                if i % 4 == 0 {
                    let lineLen = r * 0.4
                    let lineW = 2.0 * p
                    var linePath = Path()
                    linePath.move(to: CGPoint(x: cx + cos(ang) * (r - lineLen), y: cy + sin(ang) * (r - lineLen)))
                    linePath.addLine(to: CGPoint(x: x, y: y))
                    ctx.stroke(linePath, with: .color(Color.gray.opacity(alpha * 0.3)), style: StrokeStyle(lineWidth: CGFloat(lineW), lineCap: .round))
                }

                ctx.opacity = alpha
                let leafAngle = t * 3.0 + seed * 5.0
                let tf = CGAffineTransform(rotationAngle: CGFloat(leafAngle))
                    .concatenating(CGAffineTransform(translationX: x, y: y))
                
                let iconStr = icons[i % icons.count]
                let resolvedText = ctx.resolve(Text(iconStr).font(.system(size: CGFloat(w))))
                ctx.draw(resolvedText, at: CGPoint(x: x, y: y))
            }
            ctx.opacity = 1.0
        }
    }
}

// MARK: - Slam-Zahl mit Glitch

private struct GISlam: View {
    let big: String
    let small: String
    let local: Double
    let color: Color

    var body: some View {
        let p = goOutI(goClamp01I(local / 0.25))
        let decay = exp(-max(0.0, local) * 9.0)
        let s = 3.6 - 2.6 * p // Viel größer! Bildschirmfüllend!

        VStack(spacing: 2) {
            ZStack {
                // 3D-Extrusion (Fake) - Besser Lesbar
                ForEach(0..<18, id: \.self) { i in
                    Text(big)
                        .foregroundColor(Color(white: 0.1))
                        .offset(x: CGFloat(i) * 2.0, y: CGFloat(i) * 2.0)
                        .opacity(1.0 - Double(i) / 18.0)
                }

                Text(big)
                    .foregroundColor(Color.red.opacity(0.8))
                    .offset(x: CGFloat(-14.0 * decay))
                    .blendMode(.plusLighter)
                Text(big)
                    .foregroundColor(Color.cyan.opacity(0.8))
                    .offset(x: CGFloat(14.0 * decay))
                    .blendMode(.plusLighter)
                Text(big)
                    .foregroundColor(.white)
                    .shadow(color: Color.black.opacity(1.0), radius: 10, x: 0, y: 5) // Stärkerer Kontrast-Schatten
                    .shadow(color: color.opacity(0.7), radius: 30) // Sanfterer Farb-Glow
            }
            .font(.system(size: 170, weight: .black, design: .rounded))
            .rotation3DEffect(.degrees(12 * decay), axis: (x: 1, y: -1, z: 0.2)) // 3D-Kippen beim Einschlag

            Text(small)
                .font(.system(size: 28, weight: .heavy, design: .rounded))
                .tracking(10)
                .foregroundColor(color)
                .shadow(color: Color.black.opacity(0.8), radius: 5, x: 0, y: 3) // Lesbarkeit verbessert
        }
        .scaleEffect(CGFloat(s))
        .offset(
            x: CGFloat(sin(local * 90.0) * 20.0 * decay),
            y: CGFloat(cos(local * 70.0) * 15.0 * decay)
        )
        .opacity(goClamp01I(local * 12.0))
    }
}

// MARK: - Statistik (Canvas)

private struct GIStats: View {
    let t: Double
    let accent: Color

    var body: some View {
        Canvas { ctx, size in
            let w = Double(size.width)
            let h = Double(size.height)
            let cx = w / 2.0
            let baseY = h * 0.72

            // Stat-Wachstum
            let statP = goInOutI(goProgI(t, 8.5, 3.0))

            if statP > 0 {
                // Hintergrund-Grid
                for i in 0..<5 {
                    let y = baseY - Double(i) * 60.0
                    var gridLine = Path()
                    gridLine.move(to: CGPoint(x: cx - 120, y: y))
                    gridLine.addLine(to: CGPoint(x: cx + 120, y: y))
                    ctx.stroke(gridLine, with: .color(Color.gray.opacity(0.2 * statP)), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                }

                // Balken
                let bars = [0.2, 0.4, 0.6, 0.8, 1.0]
                for (i, targetH) in bars.enumerated() {
                    let localP = goInOutI(goProgI(t, 8.5 + Double(i) * 0.2, 1.0))
                    let barH = 200.0 * targetH * localP
                    let x = cx - 90.0 + Double(i) * 45.0
                    
                    let barRect = giRect(x - 12.0, baseY - barH, 24.0, barH)
                    ctx.fill(
                        Path(roundedRect: barRect, cornerRadius: 4.0),
                        with: .linearGradient(
                            Gradient(colors: [accent.opacity(0.8), accent]),
                            startPoint: CGPoint(x: barRect.minX, y: barRect.maxY),
                            endPoint: CGPoint(x: barRect.minX, y: barRect.minY)
                        )
                    )
                }

                // Trend-Pfeil (steigt)
                if statP > 0.5 {
                    let arrowP = goInOutI(goProgI(t, 9.8, 1.5))
                    var arrow = Path()
                    let startPoint = CGPoint(x: cx - 90.0, y: baseY - 40.0)
                    let endPoint = CGPoint(x: cx + 90.0, y: baseY - 200.0)
                    
                    let currentX = startPoint.x + (endPoint.x - startPoint.x) * arrowP
                    let currentY = startPoint.y + (endPoint.y - startPoint.y) * arrowP

                    arrow.move(to: startPoint)
                    arrow.addLine(to: CGPoint(x: currentX, y: currentY))

                    ctx.stroke(arrow, with: .color(Color.orange.opacity(arrowP)), style: StrokeStyle(lineWidth: 6.0, lineCap: .round, lineJoin: .round))
                    
                    if arrowP > 0.95 {
                        var tip = Path()
                        tip.move(to: CGPoint(x: currentX, y: currentY - 12.0))
                        tip.addLine(to: CGPoint(x: currentX - 10.0, y: currentY + 5.0))
                        tip.addLine(to: CGPoint(x: currentX + 10.0, y: currentY + 5.0))
                        tip.closeSubpath()
                        
                        let angle = atan2(endPoint.y - startPoint.y, endPoint.x - startPoint.x)
                        let tf = CGAffineTransform(translationX: -currentX, y: -currentY)
                            .concatenating(CGAffineTransform(rotationAngle: angle + .pi / 2))
                            .concatenating(CGAffineTransform(translationX: currentX, y: currentY))
                            
                        ctx.fill(tip.applying(tf), with: .color(Color.orange))
                    }
                }
            }

            // Aufsteigende Partikel
            let flyK = goProgI(t, 9.8, 1.5)
            if flyK > 0 {
                ctx.blendMode = .plusLighter
                for i in 0..<20 {
                    let seed = Double(i)
                    let rise = (t * 40.0 + seed * 37.0).truncatingRemainder(dividingBy: 250.0)
                    let px = cx + 150.0 * sin(seed * 7.1 + t * 0.35)
                    let py = baseY - rise
                    let r = 2.0 + giFract(seed * 0.618) * 3.0
                    let flicker = 0.5 + 0.5 * sin(t * 4.0 + seed)
                    ctx.fill(
                        Path(ellipseIn: giRect(px - r, py - r, r * 2.0, r * 2.0)),
                        with: .color(accent.opacity(0.8 * flicker * flyK))
                    )
                }
                ctx.blendMode = .normal
            }
            
            // Text: Statistiken / Gewonnene Zeit
            if statP > 0.8 {
                let textP = goInOutI(goProgI(t, 10.2, 1.0))
                if textP > 0 {
                    ctx.opacity = textP
                    let text = ctx.resolve(Text(String(localized: "intro.stats.focus_gain", defaultValue: "Mehr Fokus & Zeit")).font(.system(size: 26, weight: .bold, design: .rounded)).foregroundColor(Color.primary))
                    ctx.draw(text, at: CGPoint(x: cx, y: baseY - 260.0))
                    
                    let sub = ctx.resolve(Text(String(localized: "intro.stats.subtitle", defaultValue: "Dein Fortschritt mit Grovy")).font(.system(size: 16, weight: .medium, design: .rounded)).foregroundColor(Color.gray))
                    ctx.draw(sub, at: CGPoint(x: cx, y: baseY - 230.0))
                    ctx.opacity = 1.0
                }
            }
        }
    }
}

// MARK: - Sound (im Code synthetisiert, keine Dateien)

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
        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: format)
        do {
            try engine.start()
            player.play()
            ready = true
        } catch {
            ready = false
        }
    }

    private func play(_ samples: [Float]) {
        guard ready,
              let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1),
              let buf = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(samples.count))
        else { return }
        buf.frameLength = AVAudioFrameCount(samples.count)
        if let ch = buf.floatChannelData?[0] {
            for i in 0..<samples.count {
                ch[i] = samples[i]
            }
        }
        player.scheduleBuffer(buf, completionHandler: nil)
    }

    /// Tiefer Impact mit Pitch-Drop
    func slam() {
        let dur = 0.9
        let n = Int(dur * sampleRate)
        var s = [Float](repeating: 0, count: n)
        var phase = 0.0
        for i in 0..<n {
            let x = Double(i) / sampleRate
            let f = 48.0 + 120.0 * exp(-x * 22.0)
            phase += 2.0 * Double.pi * f / sampleRate
            let env = exp(-x * 4.5)
            let v = (sin(phase) + 0.25 * sin(phase * 2.0) * env) * env * 0.9
            s[i] = Float(v)
        }
        play(s)
    }

    /// Weicher Herzschlag-Thud
    func beat() {
        let dur = 0.25
        let n = Int(dur * sampleRate)
        var s = [Float](repeating: 0, count: n)
        var phase = 0.0
        for i in 0..<n {
            let x = Double(i) / sampleRate
            let f = 62.0 + 40.0 * exp(-x * 30.0)
            phase += 2.0 * Double.pi * f / sampleRate
            let env = exp(-x * 16.0)
            s[i] = Float(sin(phase) * env * 0.8)
        }
        play(s)
    }

    /// Aufsteigender Schimmer fürs Wachstum
    func shimmer() {
        let dur = 3.0
        let n = Int(dur * sampleRate)
        var s = [Float](repeating: 0, count: n)
        var phase = 0.0
        for i in 0..<n {
            let x = Double(i) / sampleRate
            let k = x / dur
            let f = 400.0 + 1300.0 * k * k
            phase += 2.0 * Double.pi * f / sampleRate
            let env = sin(Double.pi * k)
            let v = (sin(phase) + 0.4 * sin(phase * 1.5)) * env * 0.18
            s[i] = Float(v)
        }
        play(s)
    }
}

// MARK: - Preview

struct GrovyIntroView_Previews: PreviewProvider {
    static var previews: some View {
        GrovyIntroView()
    }
}
