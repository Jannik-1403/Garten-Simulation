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
        background: Color = .black,
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

                if t > 5.0 && t < 6.0 {
                    Color.white
                        .opacity(giFlash(t))
                        .ignoresSafeArea()
                        .allowsHitTesting(false)
                }

                if t > 6.4 && t < 8.5 {
                    layerB(t)
                }

                if t > 8.3 {
                    GIPlant(t: t, accent: accent)
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
        let cut = 1.0 - goClamp01I((t - 5.3) / 0.15)
        let idx = currentSlam(t)
        let slam = slams[idx]
        let local = t - slam.start

        ZStack {
            GITiles(t: t - 1.2, warning: warning)
                .ignoresSafeArea()
            GISlam(big: slam.big, small: slam.small, local: local, color: warning)
            Color.white
                .opacity(0.45 * exp(-max(0.0, local) * 10.0))
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
                .foregroundColor(.white)
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
private func giFlash(_ t: Double) -> Double {
    let up = goClamp01I((t - 5.1) / 0.3)
    let down = 1.0 - goClamp01I((t - 5.4) / 0.4)
    return up * down
}
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

// MARK: - Kachel-Sturm (Canvas)

private let giPalette: [[Color]] = [
    [Color(red: 1.00, green: 0.60, blue: 0.70), Color(red: 0.90, green: 0.18, blue: 0.40)],
    [Color(red: 1.00, green: 0.80, blue: 0.40), Color(red: 0.95, green: 0.48, blue: 0.12)],
    [Color(red: 0.55, green: 0.72, blue: 1.00), Color(red: 0.28, green: 0.36, blue: 0.88)],
    [Color(red: 0.50, green: 0.90, blue: 1.00), Color(red: 0.10, green: 0.55, blue: 0.85)],
    [Color(red: 0.78, green: 0.62, blue: 1.00), Color(red: 0.48, green: 0.25, blue: 0.85)]
]

private struct GITiles: View {
    let t: Double
    let warning: Color

    var body: some View {
        Canvas { ctx, size in
            let cx = Double(size.width) / 2.0
            let cy = Double(size.height) / 2.0
            let reach = max(Double(size.width), Double(size.height)) * 0.8

            for i in 0..<60 { // Mehr Partikel für den Tunnel
                let seed = Double(i)
                let ang = giFract(sin(seed * 12.9898) * 43758.5453) * 2.0 * Double.pi
                let delay = giFract(seed * 0.37) * 1.6
                let local = t - delay
                if local <= 0 { continue }

                let period = 2.2
                let p = local.truncatingRemainder(dividingBy: period) / period
                let r = pow(p, 3.0) * reach * 1.5 // Schneller am Rand für Tunnel-Sog
                let w = 40.0 * (0.15 + 4.0 * pow(p, 1.8))
                let x = cx + cos(ang) * r
                let y = cy + sin(ang) * r
                let fadeOut = 1.0 - max(0.0, p - 0.85) / 0.15
                let alpha = min(1.0, local * 4.0) * fadeOut

                // Speed-Linien
                if i % 3 == 0 {
                    let lineLen = r * 0.6
                    let lineW = 3.0 * p
                    var linePath = Path()
                    linePath.move(to: CGPoint(x: cx + cos(ang) * (r - lineLen), y: cy + sin(ang) * (r - lineLen)))
                    linePath.addLine(to: CGPoint(x: x, y: y))
                    ctx.stroke(linePath, with: .color(Color.white.opacity(alpha * 0.7)), style: StrokeStyle(lineWidth: CGFloat(lineW), lineCap: .round))
                }

                let rect = giRect(x - w / 2.0, y - w / 2.0, w, w)
                let colors = giPalette[i % giPalette.count]

                ctx.opacity = alpha
                ctx.fill(
                    Path(roundedRect: rect, cornerRadius: CGFloat(w * 0.28), style: .continuous),
                    with: .linearGradient(
                        Gradient(colors: colors),
                        startPoint: CGPoint(x: rect.minX, y: rect.minY),
                        endPoint: CGPoint(x: rect.maxX, y: rect.maxY)
                    )
                )
                let gloss = giRect(x - w * 0.44, y - w * 0.45, w * 0.88, w * 0.4)
                ctx.fill(
                    Path(roundedRect: gloss, cornerRadius: CGFloat(w * 0.2), style: .continuous),
                    with: .color(Color.white.opacity(0.28))
                )
                let badge = giRect(x + w * 0.28, y - w * 0.56, w * 0.34, w * 0.34)
                ctx.fill(Path(ellipseIn: badge), with: .color(Color.red))
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
                // 3D-Extrusion (Fake)
                ForEach(0..<18, id: \.self) { i in
                    Text(big)
                        .foregroundColor(Color(white: 0.15))
                        .offset(x: CGFloat(i) * 2.0, y: CGFloat(i) * 2.0)
                        .opacity(1.0 - Double(i) / 18.0)
                }

                Text(big)
                    .foregroundColor(Color.red)
                    .offset(x: CGFloat(-14.0 * decay))
                    .blendMode(.plusLighter)
                Text(big)
                    .foregroundColor(Color.cyan)
                    .offset(x: CGFloat(14.0 * decay))
                    .blendMode(.plusLighter)
                Text(big)
                    .foregroundColor(.white)
                    .shadow(color: color.opacity(1.0), radius: 40)
            }
            .font(.system(size: 170, weight: .black, design: .rounded))
            .rotation3DEffect(.degrees(12 * decay), axis: (x: 1, y: -1, z: 0.2)) // 3D-Kippen beim Einschlag

            Text(small)
                .font(.system(size: 28, weight: .heavy, design: .rounded))
                .tracking(10)
                .foregroundColor(color)
        }
        .scaleEffect(CGFloat(s))
        .offset(
            x: CGFloat(sin(local * 90.0) * 20.0 * decay),
            y: CGFloat(cos(local * 70.0) * 15.0 * decay)
        )
        .opacity(goClamp01I(local * 12.0))
    }
}

// MARK: - Pflanze, Strahlen, Glühwürmchen (Canvas)

private struct GIPlant: View {
    let t: Double
    let accent: Color

    var body: some View {
        Canvas { ctx, size in
            let w = Double(size.width)
            let h = Double(size.height)
            let cx = w / 2.0
            let baseY = h * 0.72
            let maxH = h * 0.34

            // 1. Sonnenaufgang (Hintergrund)
            let sunP = goProgI(t, 8.4, 4.0)
            if sunP > 0 {
                let sunRect = giRect(cx - w, baseY - w, w * 2.0, w * 2.0)
                ctx.fill(
                    Path(ellipseIn: sunRect),
                    with: .radialGradient(
                        Gradient(colors: [
                            Color(red: 1.0, green: 0.8, blue: 0.4).opacity(0.4 * sunP),
                            Color(red: 0.9, green: 0.4, blue: 0.1).opacity(0.2 * sunP),
                            Color.clear
                        ]),
                        center: CGPoint(x: cx, y: baseY),
                        startRadius: 0,
                        endRadius: CGFloat(w * 0.8)
                    )
                )
            }

            // 2. Hügel und Gras
            let hillP = goInOutI(goProgI(t, 8.5, 2.0))
            if hillP > 0 {
                var hill1 = Path()
                hill1.move(to: CGPoint(x: 0, y: h))
                hill1.addLine(to: CGPoint(x: 0, y: baseY + 40.0 - 40.0 * hillP))
                hill1.addQuadCurve(to: CGPoint(x: w, y: baseY + 80.0 - 40.0 * hillP), control: CGPoint(x: cx * 0.8, y: baseY - 60.0 * hillP))
                hill1.addLine(to: CGPoint(x: w, y: h))
                ctx.fill(hill1, with: .color(Color(red: 0.05, green: 0.25, blue: 0.15).opacity(0.8 * hillP)))

                var hill2 = Path()
                hill2.move(to: CGPoint(x: 0, y: h))
                hill2.addLine(to: CGPoint(x: 0, y: baseY + 90.0 - 50.0 * hillP))
                hill2.addQuadCurve(to: CGPoint(x: w, y: baseY + 20.0 - 20.0 * hillP), control: CGPoint(x: cx * 1.4, y: baseY - 80.0 * hillP))
                hill2.addLine(to: CGPoint(x: w, y: h))
                ctx.fill(hill2, with: .color(Color(red: 0.02, green: 0.18, blue: 0.10).opacity(0.9 * hillP)))
            }

            // 3. Fallende Gewohnheiten (Tropfen)
            let dropP = goProgI(t, 8.6, 2.0)
            if dropP > 0 && dropP < 1.0 {
                for i in 0..<5 {
                    let delay = Double(i) * 0.2
                    let localP = goProgI(t, 8.6 + delay, 0.6)
                    if localP > 0 && localP < 1.0 {
                        let dropY = -50.0 + (baseY + 50.0) * pow(localP, 2.0) // Fall-Beschleunigung
                        let dropX = cx + sin(Double(i) * 123.4) * 40.0
                        let dropR = 4.0
                        
                        var drop = Path()
                        drop.move(to: CGPoint(x: dropX, y: dropY - dropR * 2.0)) // Spitze
                        drop.addQuadCurve(to: CGPoint(x: dropX - dropR, y: dropY), control: CGPoint(x: dropX - dropR, y: dropY - dropR))
                        drop.addQuadCurve(to: CGPoint(x: dropX + dropR, y: dropY), control: CGPoint(x: dropX, y: dropY + dropR))
                        drop.addQuadCurve(to: CGPoint(x: dropX, y: dropY - dropR * 2.0), control: CGPoint(x: dropX + dropR, y: dropY - dropR))
                        
                        ctx.fill(drop, with: .color(Color.cyan.opacity(1.0 - localP)))
                        ctx.blendMode = .plusLighter
                        ctx.fill(drop, with: .color(Color.white.opacity((1.0 - localP) * 0.8)))
                        ctx.blendMode = .normal
                    }
                }
            }

            let g = goInOutI(goProgI(t, 9.4, 3.0))
            func stemPoint(_ s: Double) -> CGPoint {
                CGPoint(x: cx + 16.0 * sin(s * 3.6), y: baseY - maxH * s)
            }
            let top = stemPoint(g)

            // Boden-Glow
            let groundRect = giRect(cx - 110.0, baseY - 16.0, 220.0, 32.0)
            ctx.fill(
                Path(ellipseIn: groundRect),
                with: .radialGradient(
                    Gradient(colors: [accent.opacity(0.55 * goProgI(t, 8.4, 1.0)), Color.clear]),
                    center: CGPoint(x: cx, y: baseY),
                    startRadius: 0,
                    endRadius: 110
                )
            )

            // Lichtstrahlen vom Spross
            let rayK = goProgI(t, 10.5, 2.0)
            if rayK > 0 {
                let R = max(w, h) * 0.9
                ctx.blendMode = .plusLighter
                for j in 0..<14 {
                    let a = t * 0.15 + Double(j) * 2.0 * Double.pi / 14.0
                    let spread = 0.05
                    var tri = Path()
                    tri.move(to: top)
                    tri.addLine(to: CGPoint(x: Double(top.x) + R * cos(a - spread), y: Double(top.y) + R * sin(a - spread)))
                    tri.addLine(to: CGPoint(x: Double(top.x) + R * cos(a + spread), y: Double(top.y) + R * sin(a + spread)))
                    tri.closeSubpath()
                    ctx.fill(
                        tri,
                        with: .radialGradient(
                            Gradient(colors: [accent.opacity(0.30 * rayK), Color.clear]),
                            center: top,
                            startRadius: 0,
                            endRadius: CGFloat(R)
                        )
                    )
                }
                ctx.blendMode = .normal
            }

            // Samen
            let seedA = goProgI(t, 8.4, 0.8) * (1.0 - goProgI(t, 9.6, 0.6) * 0.0)
            let pulse = 1.0 + 0.25 * sin(t * 9.0)
            let seedR = 7.0 * pulse
            ctx.blendMode = .plusLighter
            ctx.fill(
                Path(ellipseIn: giRect(cx - seedR * 4.0, baseY - seedR * 4.0, seedR * 8.0, seedR * 8.0)),
                with: .radialGradient(
                    Gradient(colors: [accent.opacity(0.6 * seedA), Color.clear]),
                    center: CGPoint(x: cx, y: baseY),
                    startRadius: 0,
                    endRadius: CGFloat(seedR * 4.0)
                )
            )
            ctx.blendMode = .normal
            ctx.fill(
                Path(ellipseIn: giRect(cx - seedR, baseY - seedR, seedR * 2.0, seedR * 2.0)),
                with: .color(Color.white.opacity(seedA))
            )

            // Stiel
            if g > 0.01 {
                var stem = Path()
                let steps = 70
                let n = max(1, Int(Double(steps) * g))
                for i in 0...n {
                    let pt = stemPoint(Double(i) / Double(steps))
                    if i == 0 {
                        stem.move(to: pt)
                    } else {
                        stem.addLine(to: pt)
                    }
                }
                ctx.stroke(stem, with: .color(accent), style: StrokeStyle(lineWidth: 7, lineCap: .round, lineJoin: .round))
            }

            // Blätter
            let nodes: [Double] = [0.28, 0.42, 0.56, 0.70, 0.84, 0.97]
            for k in 0..<nodes.count {
                let s = nodes[k]
                let lp = goOutI(goClamp01I((g - s) / 0.12))
                if lp <= 0 { continue }
                let side: Double = (k % 2 == 0) ? 1.0 : -1.0
                let len = (50.0 - 4.0 * Double(k)) * lp
                let wd = len * 0.45
                let sway = 0.06 * sin(t * 2.0 + Double(k))
                let angle = side > 0 ? (-0.6 + sway) : (Double.pi + 0.6 - sway)
                let base = stemPoint(s)

                let leaf = Path(ellipseIn: giRect(0.0, -wd / 2.0, len, wd))
                let tf = CGAffineTransform(rotationAngle: CGFloat(angle))
                    .concatenating(CGAffineTransform(translationX: base.x, y: base.y))
                let placed = leaf.applying(tf)
                let tip = CGPoint(x: Double(base.x) + len * cos(angle), y: Double(base.y) + len * sin(angle))
                ctx.fill(
                    placed,
                    with: .linearGradient(
                        Gradient(colors: [Color(red: 0.70, green: 1.0, blue: 0.70), accent, Color(red: 0.10, green: 0.55, blue: 0.30)]),
                        startPoint: base,
                        endPoint: tip
                    )
                )
            }

            // Aufblühende Blume (statt nur Knospe)
            if g > 0.02 {
                let bloomP = goInOutI(goProgI(t, 11.0, 1.5)) // Blume blüht auf
                
                // Zentrum (Knospe/Leuchten)
                let budR = 9.0 + 4.0 * sin(t * 6.0)
                ctx.blendMode = .plusLighter
                ctx.fill(
                    Path(ellipseIn: giRect(Double(top.x) - budR * 3.0, Double(top.y) - budR * 3.0, budR * 6.0, budR * 6.0)),
                    with: .radialGradient(
                        Gradient(colors: [Color.white.opacity(0.9), accent.opacity(0.8), Color.clear]),
                        center: top,
                        startRadius: 0,
                        endRadius: CGFloat(budR * 3.0)
                    )
                )
                ctx.blendMode = .normal

                // Blütenblätter
                if bloomP > 0 {
                    let numPetals = 8
                    for i in 0..<numPetals {
                        let angle = Double(i) * (2.0 * Double.pi / Double(numPetals)) + t * 0.2
                        let petalLen = 35.0 * bloomP + 3.0 * sin(t * 3.0 + Double(i))
                        let petalW = 15.0 * bloomP

                        let pPath = Path(ellipseIn: giRect(0.0, -petalW / 2.0, petalLen, petalW))
                        let tf = CGAffineTransform(rotationAngle: CGFloat(angle))
                            .concatenating(CGAffineTransform(translationX: top.x, y: top.y))
                        
                        ctx.fill(
                            pPath.applying(tf),
                            with: .radialGradient(
                                Gradient(colors: [Color(red: 1.0, green: 0.9, blue: 0.5).opacity(0.9), accent.opacity(0.7), Color.clear]),
                                center: top,
                                startRadius: 0,
                                endRadius: CGFloat(petalLen)
                            )
                        )
                    }
                }
            }

            // Glühwürmchen
            let flyK = goProgI(t, 9.8, 1.5)
            if flyK > 0 {
                ctx.blendMode = .plusLighter
                for i in 0..<28 {
                    let seed = Double(i)
                    let rise = (t * 22.0 + seed * 37.0).truncatingRemainder(dividingBy: maxH * 1.5)
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
