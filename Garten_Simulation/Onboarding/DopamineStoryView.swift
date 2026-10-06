import SwiftUI

// MARK: - DopamineStoryView
//
// Story-Animation fürs Grovy-Onboarding: Was Dopamin wirklich macht -> warum das Problem ist -> Grovy als Lösung.
// Eigene Datei (ersetzt NICHT GrovyOnboardingView.swift), wird als EIN Schritt ins bestehende Onboarding eingebaut.
// Benötigt iOS 15+ (TimelineView, Canvas).

// MARK: - Theme (hier an das restliche Onboarding anpassen)

struct DopamineStoryTheme {
    var background: [Color]?
    var primaryText: Color
    var secondaryText: Color
    var accent: Color
    var onAccent: Color
    var warning: Color
    var fontDesign: Font.Design

    static let grovy = DopamineStoryTheme(
        background: nil,
        primaryText: .white,
        secondaryText: Color.white.opacity(0.72),
        accent: Color(red: 0.36, green: 0.86, blue: 0.52),
        onAccent: Color(red: 0.03, green: 0.20, blue: 0.12),
        warning: Color(red: 1.0, green: 0.36, blue: 0.45),
        fontDesign: .rounded
    )
}

// MARK: - Haupt-View

struct DopamineStoryView: View {
    let theme: DopamineStoryTheme
    let showsProgress: Bool
    let showsFinishButton: Bool
    let finishTitle: String
    let onFinish: () -> Void

    @State private var scene = 0
    private let durations: [Double] = [6.0, 7.4, 6.6, 6.2, 7.2, 0]
    private var lastIndex: Int { durations.count - 1 }

    init(
        theme: DopamineStoryTheme = .grovy,
        showsProgress: Bool = true,
        showsFinishButton: Bool = true,
        finishTitle: String = String(localized: "grovy_story_btn_los", defaultValue: "Los geht's"),
        onFinish: @escaping () -> Void = {}
    ) {
        self.theme = theme
        self.showsProgress = showsProgress
        self.showsFinishButton = showsFinishButton
        self.finishTitle = finishTitle
        self.onFinish = onFinish
    }

    var body: some View {
        ZStack {
            if let colors = theme.background {
                LinearGradient(colors: colors, startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
            }

            currentScene
                .id(scene)
                .transition(
                    .asymmetric(
                        insertion: AnyTransition.opacity.combined(with: .scale(scale: 0.96)),
                        removal: AnyTransition.opacity
                    )
                )

            if showsProgress {
                topBar
            } else if scene < lastIndex {
                skipOnly
            }
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

    @ViewBuilder
    private var currentScene: some View {
        switch scene {
        case 0: GOMoleculeScene(theme: theme)
        case 1: GOSurpriseScene(theme: theme)
        case 2: GOYearScene(theme: theme)
        case 3: GOFocusScene(theme: theme)
        case 4: GOHabitScene(theme: theme)
        default:
            GOFinaleScene(
                theme: theme,
                showsButton: showsFinishButton,
                buttonTitle: finishTitle,
                onFinish: onFinish
            )
        }
    }

    private func next() {
        guard scene < lastIndex else { return }
        #if canImport(UIKit)
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        #endif
        withAnimation(.easeInOut(duration: 0.55)) {
            scene += 1
        }
    }

    private func segmentState(_ i: Int) -> Int {
        if i < scene { return 2 }
        if i == scene { return 1 }
        return 0
    }

    private var topBar: some View {
        VStack(spacing: 12) {
            HStack(spacing: 6) {
                ForEach(0..<durations.count, id: \.self) { i in
                    GOProgressSegment(state: segmentState(i), duration: durations[i], theme: theme)
                        .id("\(i)-\(segmentState(i))")
                }
            }
            HStack {
                Spacer()
                if scene < lastIndex {
                    skipButton
                }
            }
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }

    private var skipOnly: some View {
        VStack {
            HStack {
                Spacer()
                skipButton
            }
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }

    private var skipButton: some View {
        Button(action: onFinish) {
            Text(String(localized: "grovy_story_skip", defaultValue: "Überspringen"))
                .font(.system(size: 14, weight: .semibold, design: theme.fontDesign))
                .foregroundColor(theme.secondaryText)
        }
    }
}

// MARK: - Farben für 3D-Kacheln

private enum GOColors {
    static let pink: [Color] = [Color(red: 1.00, green: 0.60, blue: 0.70), Color(red: 0.90, green: 0.18, blue: 0.40)]
    static let orange: [Color] = [Color(red: 1.00, green: 0.80, blue: 0.40), Color(red: 0.95, green: 0.48, blue: 0.12)]
    static let blue: [Color] = [Color(red: 0.55, green: 0.72, blue: 1.00), Color(red: 0.28, green: 0.36, blue: 0.88)]
    static let cyan: [Color] = [Color(red: 0.50, green: 0.90, blue: 1.00), Color(red: 0.10, green: 0.55, blue: 0.85)]
    static let purple: [Color] = [Color(red: 0.78, green: 0.62, blue: 1.00), Color(red: 0.48, green: 0.25, blue: 0.85)]
    static let green: [Color] = [Color(red: 0.58, green: 0.96, blue: 0.62), Color(red: 0.10, green: 0.62, blue: 0.36)]
    static let amber: [Color] = [Color(red: 1.00, green: 0.88, blue: 0.45), Color(red: 0.92, green: 0.58, blue: 0.10)]
}

// MARK: - Easing-Helfer

private func goClamp01(_ x: Double) -> Double { min(1.0, max(0.0, x)) }
private func goProg(_ t: Double, _ start: Double, _ dur: Double) -> Double { goClamp01((t - start) / dur) }
private func goOut(_ x: Double) -> Double { 1.0 - pow(1.0 - x, 3.0) }
private func goInOut(_ x: Double) -> Double {
    x < 0.5 ? 4.0 * x * x * x : 1.0 - pow(-2.0 * x + 2.0, 3.0) / 2.0
}
private func goBack(_ x: Double) -> Double {
    let c1 = 1.70158
    let c3 = c1 + 1.0
    return 1.0 + c3 * pow(x - 1.0, 3.0) + c1 * pow(x - 1.0, 2.0)
}

// MARK: - Zeitgeber

private struct GOTimed<Content: View>: View {
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

// MARK: - Progress-Segment

private struct GOProgressSegment: View {
    let state: Int
    let duration: Double
    let theme: DopamineStoryTheme
    @State private var fill: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(theme.primaryText.opacity(0.2))
                Capsule()
                    .fill(theme.primaryText)
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

// MARK: - Wiederverwendbare Bausteine

private struct GOCaption: View {
    let title: String
    let subtitle: String
    let t: Double
    let theme: DopamineStoryTheme
    var delay: Double = 0.2

    var body: some View {
        let a = goOut(goProg(t, delay, 0.7))
        let b = goOut(goProg(t, delay + 0.25, 0.7))
        VStack(spacing: 10) {
            Text(title)
                .font(.system(size: 29, weight: .heavy, design: theme.fontDesign))
                .multilineTextAlignment(.center)
                .foregroundColor(theme.primaryText)
                .opacity(a)
                .offset(y: CGFloat((1.0 - a) * 22.0))
            Text(subtitle)
                .font(.system(size: 16, weight: .medium, design: theme.fontDesign))
                .multilineTextAlignment(.center)
                .foregroundColor(theme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
                .opacity(b)
                .offset(y: CGFloat((1.0 - b) * 22.0))
        }
        .padding(.horizontal, 28)
    }
}

private struct GOSource: View {
    let text: String
    let t: Double
    let theme: DopamineStoryTheme
    var delay: Double = 1.2

    var body: some View {
        Text(text)
            .font(.system(size: 11, weight: .medium, design: theme.fontDesign))
            .foregroundColor(theme.secondaryText.opacity(0.8))
            .multilineTextAlignment(.center)
            .padding(.horizontal, 32)
            .opacity(goProg(t, delay, 0.6))
    }
}

private struct GOGlow: View {
    let color: Color
    let t: Double

    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [color.opacity(0.42), color.opacity(0.0)],
                    center: .center,
                    startRadius: 0,
                    endRadius: 170
                )
            )
            .frame(width: 340, height: 340)
            .scaleEffect(CGFloat(1.0 + 0.06 * sin(t * 2.0)))
            .allowsHitTesting(false)
    }
}

private struct GOOrb: View {
    let tint: Color
    let size: CGFloat
    var symbol: String? = nil

    var body: some View {
        ZStack {
            Circle().fill(tint)
            Circle().fill(
                RadialGradient(
                    colors: [Color.white.opacity(0.65), Color.white.opacity(0.0)],
                    center: UnitPoint(x: 0.3, y: 0.25),
                    startRadius: 0,
                    endRadius: size * 0.55
                )
            )
            Circle().fill(
                RadialGradient(
                    colors: [Color.black.opacity(0.0), Color.black.opacity(0.38)],
                    center: UnitPoint(x: 0.35, y: 0.3),
                    startRadius: size * 0.25,
                    endRadius: size * 0.75
                )
            )
            if let s = symbol {
                Image(systemName: s)
                    .font(.system(size: size * 0.5, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: Color.black.opacity(0.3), radius: 1.5, x: 0, y: 1.5)
            }
        }
        .frame(width: size, height: size)
        .shadow(color: tint.opacity(0.55), radius: size * 0.3, x: 0, y: size * 0.12)
    }
}

private struct GOGlossTile: View {
    let symbol: String
    let colors: [Color]
    var size: CGFloat = 60

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: size * 0.28, style: .continuous)
        ZStack {
            shape.fill(LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing))
            shape.fill(
                LinearGradient(
                    colors: [Color.white.opacity(0.5), Color.white.opacity(0.0)],
                    startPoint: .top,
                    endPoint: .center
                )
            )
            shape.strokeBorder(
                LinearGradient(
                    colors: [Color.white.opacity(0.85), Color.white.opacity(0.05), Color.black.opacity(0.25)],
                    startPoint: .top,
                    endPoint: .bottom
                ),
                lineWidth: 1.5
            )
            Image(systemName: symbol)
                .font(.system(size: size * 0.46, weight: .bold))
                .foregroundColor(.white)
                .shadow(color: Color.black.opacity(0.28), radius: 2, x: 0, y: 2)
        }
        .frame(width: size, height: size)
        .shadow(color: (colors.last ?? Color.black).opacity(0.45), radius: size * 0.22, x: 0, y: size * 0.16)
    }
}

private struct GOSlab: View {
    let symbol: String
    let colors: [Color]
    var size: CGFloat = 120
    var depth: Int = 9

    var body: some View {
        let corner = size * 0.27
        let side = colors.last ?? Color.gray
        ZStack {
            Ellipse()
                .fill(Color.black.opacity(0.35))
                .frame(width: size * 0.95, height: size * 0.22)
                .blur(radius: 10)
                .offset(y: size * 0.62 + CGFloat(depth))
            ForEach(0..<depth, id: \.self) { i in
                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .fill(side)
                    .brightness(-0.35)
                    .frame(width: size, height: size)
                    .offset(y: CGFloat(depth - i))
            }
            GOGlossTile(symbol: symbol, colors: colors, size: size)
        }
    }
}

private struct GOChip: View {
    let symbol: String
    let text: String
    let tint: Color
    let theme: DopamineStoryTheme

    var body: some View {
        HStack(spacing: 8) {
            GOOrb(tint: tint, size: 26, symbol: symbol)
            Text(text)
                .font(.system(size: 13, weight: .bold, design: theme.fontDesign))
                .foregroundColor(theme.primaryText)
        }
        .padding(.leading, 6)
        .padding(.trailing, 14)
        .padding(.vertical, 6)
        .background(Capsule().fill(theme.primaryText.opacity(0.09)))
        .overlay(Capsule().strokeBorder(theme.primaryText.opacity(0.14), lineWidth: 1))
    }
}

// MARK: - Szene 1: Dopamin-Molekül in 3D

private struct GOAtom {
    let x: Double
    let y: Double
    let z: Double
    let radius: Double
    let tint: Color
}

private struct GOProj {
    var x: Double
    var y: Double
    var s: Double
    var z: Double
}

private enum GOMolecule {
    static let carbon = Color(red: 0.50, green: 0.56, blue: 0.68)
    static let oxygen = Color(red: 0.95, green: 0.25, blue: 0.28)
    static let nitrogen = Color(red: 0.25, green: 0.45, blue: 0.98)

    static let atoms: [GOAtom] = {
        var a: [GOAtom] = []
        let ringAngles: [Double] = [150, 90, 30, -30, -90, -150]
        for deg in ringAngles {
            let r = deg * Double.pi / 180.0
            a.append(GOAtom(x: cos(r), y: sin(r), z: 0, radius: 0.34, tint: carbon))
        }
        a.append(GOAtom(x: 2.0 * cos(150.0 * Double.pi / 180.0), y: 2.0 * sin(150.0 * Double.pi / 180.0), z: 0.2, radius: 0.38, tint: oxygen))
        a.append(GOAtom(x: 2.0 * cos(-150.0 * Double.pi / 180.0), y: 2.0 * sin(-150.0 * Double.pi / 180.0), z: -0.2, radius: 0.38, tint: oxygen))
        a.append(GOAtom(x: 1.73, y: -1.0, z: 0.35, radius: 0.34, tint: carbon))
        a.append(GOAtom(x: 2.6, y: -0.5, z: -0.3, radius: 0.34, tint: carbon))
        a.append(GOAtom(x: 3.5, y: -1.0, z: 0.3, radius: 0.40, tint: nitrogen))
        return a
    }()

    static let bonds: [(Int, Int)] = [
        (0, 1), (1, 2), (2, 3), (3, 4), (4, 5), (5, 0),
        (0, 6), (5, 7), (3, 8), (8, 9), (9, 10)
    ]
}

private struct GOMoleculeCanvas: View {
    let t: Double

    var body: some View {
        Canvas { ctx, size in
            let cx = Double(size.width) / 2.0
            let cy = Double(size.height) / 2.0
            let scale = 46.0
            let ang = t * 0.8
            let tilt = 0.45
            let ca = cos(ang)
            let sa = sin(ang)
            let ct = cos(tilt)
            let st = sin(tilt)

            var pts: [GOProj] = []
            for atom in GOMolecule.atoms {
                let x0 = atom.x - 0.885
                let y0 = atom.y
                let z0 = atom.z
                let x1 = x0 * ca + z0 * sa
                let z1 = -x0 * sa + z0 * ca
                let y1 = y0 * ct - z1 * st
                let z2 = y0 * st + z1 * ct
                let persp = 9.0 / (9.0 - z2)
                pts.append(GOProj(x: cx + x1 * scale * persp, y: cy - y1 * scale * persp, s: persp, z: z2))
            }

            for (i, j) in GOMolecule.bonds {
                var path = Path()
                path.move(to: CGPoint(x: pts[i].x, y: pts[i].y))
                path.addLine(to: CGPoint(x: pts[j].x, y: pts[j].y))
                let w = 7.0 * (pts[i].s + pts[j].s) / 2.0
                ctx.stroke(path, with: .color(Color.white.opacity(0.5)), style: StrokeStyle(lineWidth: CGFloat(w), lineCap: .round))
            }

            let order = pts.indices.sorted { pts[$0].z < pts[$1].z }
            for idx in order {
                let atom = GOMolecule.atoms[idx]
                let p = pts[idx]
                let r = atom.radius * scale * p.s
                let rect = CGRect(x: p.x - r, y: p.y - r, width: r * 2.0, height: r * 2.0)
                let grad = Gradient(colors: [Color.white.opacity(0.95), atom.tint, atom.tint.opacity(0.55)])
                ctx.fill(
                    Path(ellipseIn: rect),
                    with: .radialGradient(
                        grad,
                        center: CGPoint(x: p.x - r * 0.35, y: p.y - r * 0.4),
                        startRadius: 0,
                        endRadius: CGFloat(r * 1.7)
                    )
                )
            }
        }
    }
}

private struct GOMeter: View {
    let label: String
    let icon: String
    let value: Double
    let color: Color
    let theme: DopamineStoryTheme

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(color)
                .frame(width: 22)
            Text(label)
                .font(.system(size: 14, weight: .bold, design: theme.fontDesign))
                .foregroundColor(theme.primaryText)
                .frame(width: 64, alignment: .leading)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(theme.primaryText.opacity(0.10))
                    Capsule()
                        .fill(LinearGradient(colors: [color.opacity(0.65), color], startPoint: .leading, endPoint: .trailing))
                        .frame(width: max(8.0, geo.size.width * CGFloat(value)))
                        .overlay(alignment: .top) {
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.white.opacity(0.55), Color.white.opacity(0.0)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(height: 5)
                                .padding(.horizontal, 3)
                                .padding(.top, 1)
                        }
                        .shadow(color: color.opacity(0.6), radius: 6)
                }
            }
            .frame(height: 16)
        }
    }
}

private struct GOMoleculeScene: View {
    let theme: DopamineStoryTheme

    var body: some View {
        GOTimed { t in
            let intro = goBack(goProg(t, 0.0, 0.9))
            let rise = goOut(goProg(t, 1.4, 1.6))
            let pulse = t > 3.0 ? 0.03 * sin(t * 7.0) : 0.0
            let want = min(1.0, 0.12 + 0.88 * rise + pulse)
            let like = 0.10 + 0.08 * rise

            VStack(spacing: 18) {
                Spacer(minLength: 64)

                ZStack {
                    GOGlow(color: theme.warning, t: t)
                    GOMoleculeCanvas(t: t)
                        .frame(width: 300, height: 230)
                }
                .scaleEffect(CGFloat(0.5 + 0.5 * intro))
                .opacity(goProg(t, 0.0, 0.5))

                Text(String(localized: "dopamine_story_formula", defaultValue: "Dopamin · C₈H₁₁NO₂"))
                    .font(.system(size: 13, weight: .bold, design: theme.fontDesign))
                    .foregroundColor(theme.primaryText)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(theme.primaryText.opacity(0.10)))
                    .opacity(goProg(t, 0.7, 0.5))

                VStack(spacing: 10) {
                    GOMeter(label: String(localized: "dopamine_story_want", defaultValue: "Wollen"), icon: "flame.fill", value: want, color: theme.warning, theme: theme)
                    GOMeter(label: String(localized: "dopamine_story_like", defaultValue: "Genuss"), icon: "face.smiling", value: like, color: theme.secondaryText, theme: theme)
                }
                .padding(.horizontal, 32)
                .opacity(goProg(t, 1.1, 0.5))

                GOCaption(
                    title: String(localized: "dopamine_story_s1_title", defaultValue: "Dopamin ist nicht\ndein Glücksgefühl."),
                    subtitle: String(localized: "dopamine_story_s1_sub", defaultValue: "Es treibt vor allem das Wollen an – nicht den Genuss. Beides läuft im Gehirn getrennt."),
                    t: t,
                    theme: theme,
                    delay: 0.9
                )

                GOSource(text: String(localized: "dopamine_story_s1_source", defaultValue: "Prinzip-Grafik nach Berridge & Robinson (Wollen ≠ Mögen)"), t: t, theme: theme, delay: 2.4)

                Spacer(minLength: 40)
            }
        }
    }
}

// MARK: - Szene 2: Überraschung

private enum GOTraceKind {
    case spike
    case flat
    case dip
}

private struct GOTrace: View {
    let kind: GOTraceKind
    let progress: Double
    let color: Color
    let theme: DopamineStoryTheme

    private func value(_ x: Double) -> Double {
        let base = 0.62
        switch kind {
        case .spike: return base - 0.55 * exp(-pow((x - 0.5) / 0.055, 2.0))
        case .flat: return base
        case .dip: return base + 0.30 * exp(-pow((x - 0.5) / 0.07, 2.0))
        }
    }

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let curve = Path { p in
                let steps = 140
                for i in 0...steps {
                    let x = Double(i) / Double(steps)
                    let pt = CGPoint(x: CGFloat(x) * w, y: CGFloat(value(x)) * h)
                    if i == 0 {
                        p.move(to: pt)
                    } else {
                        p.addLine(to: pt)
                    }
                }
            }
            ZStack {
                Path { p in
                    p.move(to: CGPoint(x: w * 0.5, y: 0))
                    p.addLine(to: CGPoint(x: w * 0.5, y: h))
                }
                .stroke(theme.secondaryText.opacity(0.5), style: StrokeStyle(lineWidth: 1, dash: [3, 3]))

                Path { p in
                    p.move(to: CGPoint(x: 0, y: h * 0.62))
                    p.addLine(to: CGPoint(x: w, y: h * 0.62))
                }
                .stroke(theme.primaryText.opacity(0.14), lineWidth: 1)

                curve
                    .trim(from: 0, to: CGFloat(progress))
                    .stroke(color, style: StrokeStyle(lineWidth: 3.5, lineCap: .round, lineJoin: .round))
                    .shadow(color: color.opacity(0.7), radius: 5)
            }
        }
    }
}

private struct GOTraceRow: View {
    let t: Double
    let start: Double
    let kind: GOTraceKind
    let symbol: String
    let tileColors: [Color]
    let title: String
    let tag: String
    let color: Color
    let theme: DopamineStoryTheme

    var body: some View {
        let appear = goOut(goProg(t, start, 0.5))
        let prog = goInOut(goProg(t, start + 0.3, 1.4))
        let shape = RoundedRectangle(cornerRadius: 20, style: .continuous)

        HStack(spacing: 14) {
            GOGlossTile(symbol: symbol, colors: tileColors, size: 50)
                .scaleEffect(CGFloat(0.6 + 0.4 * appear))
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(title)
                        .font(.system(size: 15, weight: .bold, design: theme.fontDesign))
                        .foregroundColor(theme.primaryText)
                    Spacer()
                    Text(tag)
                        .font(.system(size: 12, weight: .heavy, design: theme.fontDesign))
                        .foregroundColor(color)
                        .opacity(goProg(t, start + 1.2, 0.4))
                }
                GOTrace(kind: kind, progress: prog, color: color, theme: theme)
                    .frame(height: 44)
            }
        }
        .padding(12)
        .background(shape.fill(theme.primaryText.opacity(0.07)))
        .overlay(shape.strokeBorder(theme.primaryText.opacity(0.12), lineWidth: 1))
        .opacity(appear)
        .offset(y: CGFloat((1.0 - appear) * 20.0))
        .padding(.horizontal, 24)
    }
}

private struct GOSurpriseScene: View {
    let theme: DopamineStoryTheme

    var body: some View {
        GOTimed { t in
            VStack(spacing: 14) {
                Spacer(minLength: 64)

                Text(String(localized: "dopamine_story_s2_label", defaultValue: "Dopamin-Signal im Moment der Belohnung (gestrichelt)"))
                    .font(.system(size: 12, weight: .semibold, design: theme.fontDesign))
                    .foregroundColor(theme.secondaryText)
                    .opacity(goProg(t, 0.2, 0.5))

                VStack(spacing: 10) {
                    GOTraceRow(
                        t: t, start: 0.5, kind: .spike,
                        symbol: "heart.fill", tileColors: GOColors.pink,
                        title: String(localized: "dopamine_story_s2_t1", defaultValue: "Unerwarteter Like"), tag: String(localized: "dopamine_story_s2_tag1", defaultValue: "Peak"),
                        color: theme.warning, theme: theme
                    )
                    GOTraceRow(
                        t: t, start: 1.9, kind: .flat,
                        symbol: "bell.fill", tileColors: GOColors.orange,
                        title: String(localized: "dopamine_story_s2_t2", defaultValue: "Erwartete Belohnung"), tag: String(localized: "dopamine_story_s2_tag2", defaultValue: "kein Peak"),
                        color: theme.secondaryText, theme: theme
                    )
                    GOTraceRow(
                        t: t, start: 3.3, kind: .dip,
                        symbol: "hand.thumbsdown.fill", tileColors: GOColors.blue,
                        title: String(localized: "dopamine_story_s2_t3", defaultValue: "Like bleibt aus"), tag: String(localized: "dopamine_story_s2_tag3", defaultValue: "Dip unter Normal"),
                        color: Color(red: 0.50, green: 0.70, blue: 1.0), theme: theme
                    )
                }

                GOCaption(
                    title: String(localized: "dopamine_story_s2_title", defaultValue: "Überraschung ist\nder Treibstoff."),
                    subtitle: String(localized: "dopamine_story_s2_sub", defaultValue: "Unerwartete Belohnungen feuern Dopamin am stärksten. Genau dieses „Mal gibt's was, mal nicht“ steckt in jedem Feed."),
                    t: t,
                    theme: theme,
                    delay: 4.4
                )

                GOSource(text: String(localized: "dopamine_story_s2_source", defaultValue: "Nach Wolfram Schultz et al. (Belohnungsvorhersagefehler)"), t: t, theme: theme, delay: 5.2)

                Spacer(minLength: 40)
            }
        }
    }
}

// MARK: - Szene 3: Jahres-Punkte

private struct GOYearDots: View {
    let t: Double
    let theme: DopamineStoryTheme

    var body: some View {
        Canvas { ctx, size in
            let cols = 20
            let cell = size.width / CGFloat(cols)
            let lit = Int(46.0 * goOut(goProg(t, 1.0, 2.4)))
            for i in 0..<365 {
                let c = i % cols
                let r = i / cols
                let cx = (CGFloat(c) + 0.5) * cell
                let cy = (CGFloat(r) + 0.5) * cell
                if i < lit {
                    let isNew = (i == lit - 1)
                    let rad = cell * (isNew ? 0.52 : 0.38)
                    let glowRect = CGRect(x: cx - rad * 1.8, y: cy - rad * 1.8, width: rad * 3.6, height: rad * 3.6)
                    ctx.fill(Path(ellipseIn: glowRect), with: .color(theme.warning.opacity(0.18)))
                    let rect = CGRect(x: cx - rad, y: cy - rad, width: rad * 2, height: rad * 2)
                    ctx.fill(
                        Path(ellipseIn: rect),
                        with: .radialGradient(
                            Gradient(colors: [Color.white.opacity(0.95), theme.warning]),
                            center: CGPoint(x: cx - rad * 0.3, y: cy - rad * 0.35),
                            startRadius: 0,
                            endRadius: rad * 1.3
                        )
                    )
                } else {
                    let rad = cell * 0.26
                    let rect = CGRect(x: cx - rad, y: cy - rad, width: rad * 2, height: rad * 2)
                    ctx.fill(Path(ellipseIn: rect), with: .color(theme.primaryText.opacity(0.14)))
                }
            }
        }
    }
}

private struct GOYearScene: View {
    let theme: DopamineStoryTheme

    var body: some View {
        GOTimed { t in
            let minutes = Int(180.0 * goOut(goProg(t, 0.2, 1.6)))
            let days = Int(46.0 * goOut(goProg(t, 1.0, 2.4)))

            VStack(spacing: 14) {
                Spacer(minLength: 64)

                VStack(spacing: 0) {
                    Text("\(minutes)")
                        .font(.system(size: 76, weight: .black, design: theme.fontDesign))
                        .monospacedDigit()
                        .foregroundColor(theme.primaryText)
                    Text(String(localized: "dopamine_story_s3_minutes", defaultValue: "Minuten pro Tag am Smartphone"))
                        .font(.system(size: 15, weight: .semibold, design: theme.fontDesign))
                        .foregroundColor(theme.secondaryText)
                }
                .opacity(goProg(t, 0.0, 0.5))

                ZStack(alignment: .bottom) {
                    GOYearDots(t: t, theme: theme)
                        .frame(width: 270, height: 257)
                }
                .overlay(alignment: .topTrailing) {
                    let ds = String(format: String(localized: "dopamine_story_s3_days", defaultValue: "%lld / 365 Tage"), days)
                    Text(ds)
                        .font(.system(size: 12, weight: .heavy, design: theme.fontDesign))
                        .monospacedDigit()
                        .foregroundColor(theme.warning)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Capsule().fill(theme.warning.opacity(0.16)))
                        .offset(x: 8, y: -14)
                        .opacity(goProg(t, 1.0, 0.4))
                }

                GOCaption(
                    title: String(localized: "dopamine_story_s3_title", defaultValue: "Das sind 46 Tage\npro Jahr."),
                    subtitle: String(localized: "dopamine_story_s3_sub", defaultValue: "Fast anderthalb Monate nur am Handy. Bei 16- bis 29-Jährigen sind es mit 216 Minuten sogar rund 55 Tage."),
                    t: t,
                    theme: theme,
                    delay: 3.4
                )

                GOSource(text: String(localized: "dopamine_story_s3_source", defaultValue: "Quelle: Bitkom 2026, Ø in Deutschland (Selbsteinschätzung)"), t: t, theme: theme, delay: 4.4)

                Spacer(minLength: 36)
            }
        }
    }
}

// MARK: - Szene 4: Fokus

private struct GOBarFront: Shape {
    var depth: CGFloat
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.addRect(CGRect(x: 0, y: depth, width: rect.width - depth, height: max(0, rect.height - depth)))
        return p
    }
}

private struct GOBarTop: Shape {
    var depth: CGFloat
    func path(in rect: CGRect) -> Path {
        let w = rect.width - depth
        var p = Path()
        p.move(to: CGPoint(x: 0, y: depth))
        p.addLine(to: CGPoint(x: depth, y: 0))
        p.addLine(to: CGPoint(x: w + depth, y: 0))
        p.addLine(to: CGPoint(x: w, y: depth))
        p.closeSubpath()
        return p
    }
}

private struct GOBarSide: Shape {
    var depth: CGFloat
    func path(in rect: CGRect) -> Path {
        let w = rect.width - depth
        var p = Path()
        p.move(to: CGPoint(x: w, y: depth))
        p.addLine(to: CGPoint(x: w + depth, y: 0))
        p.addLine(to: CGPoint(x: w + depth, y: max(0, rect.height - depth)))
        p.addLine(to: CGPoint(x: w, y: rect.height))
        p.closeSubpath()
        return p
    }
}

private struct GOBar3D: View {
    let width: CGFloat
    let height: CGFloat
    let depth: CGFloat
    let colors: [Color]

    var body: some View {
        ZStack(alignment: .topLeading) {
            GOBarFront(depth: depth)
                .fill(LinearGradient(colors: colors, startPoint: .top, endPoint: .bottom))
            GOBarFront(depth: depth)
                .fill(LinearGradient(colors: [Color.white.opacity(0.35), Color.white.opacity(0.0)], startPoint: .leading, endPoint: .center))
            GOBarTop(depth: depth)
                .fill(colors.first ?? Color.gray)
                .brightness(0.22)
            GOBarSide(depth: depth)
                .fill(colors.last ?? Color.gray)
                .brightness(-0.28)
        }
        .frame(width: width + depth, height: max(1, height) + depth)
        .shadow(color: (colors.last ?? Color.black).opacity(0.4), radius: 14, x: 0, y: 8)
    }
}

private struct GOFocusScene: View {
    let theme: DopamineStoryTheme

    private let labels: [String] = ["2004", "2012", "2016–20"]
    private let values: [Double] = [150, 75, 47]
    private let palette: [[Color]] = [GOColors.green, GOColors.amber, GOColors.pink]
    private let delays: [Double] = [0.5, 1.4, 2.3]

    var body: some View {
        GOTimed { t in
            VStack(spacing: 18) {
                Spacer(minLength: 64)

                ZStack {
                    GOGlow(color: theme.warning, t: t)
                        .offset(y: 30)
                    HStack(alignment: .bottom, spacing: 20) {
                        ForEach(0..<3, id: \.self) { i in
                            let prog = goOut(goProg(t, delays[i], 1.2))
                            VStack(spacing: 8) {
                                let fmt = String(format: String(localized: "dopamine_story_seconds", defaultValue: "%lld s"), Int(values[i] * prog))
                                Text(fmt)
                                    .font(.system(size: 20, weight: .heavy, design: theme.fontDesign))
                                    .monospacedDigit()
                                    .foregroundColor(theme.primaryText)
                                    .opacity(goProg(t, delays[i], 0.4))
                                GOBar3D(
                                    width: 62,
                                    height: CGFloat(168.0 * (values[i] / 150.0) * prog),
                                    depth: 16,
                                    colors: palette[i]
                                )
                                Text(labels[i])
                                    .font(.system(size: 13, weight: .bold, design: theme.fontDesign))
                                    .foregroundColor(theme.secondaryText)
                            }
                        }
                    }
                }
                .frame(height: 270)

                GOChip(
                    symbol: "hourglass",
                    text: String(localized: "dopamine_story_s4_return", defaultValue: "Zurück im Fokus: fast eine halbe Stunde"),
                    tint: theme.warning,
                    theme: theme
                )
                .opacity(goProg(t, 3.2, 0.5))
                .offset(y: CGFloat((1.0 - goOut(goProg(t, 3.2, 0.5))) * 14.0))

                GOCaption(
                    title: String(localized: "dopamine_story_s4_title", defaultValue: "Dein Fokus\nschrumpft."),
                    subtitle: String(localized: "dopamine_story_s4_sub", defaultValue: "Im Schnitt bleibt dein Blick nur noch 47 Sekunden auf einem Bildschirm. 2004 waren es 150."),
                    t: t,
                    theme: theme,
                    delay: 3.6
                )

                GOSource(text: String(localized: "dopamine_story_s4_source", defaultValue: "Quelle: Gloria Mark, UC Irvine · Ø Sekunden pro Bildschirm"), t: t, theme: theme, delay: 4.6)

                Spacer(minLength: 36)
            }
        }
    }
}

// MARK: - Szene 5: Gewohnheiten

private struct GOHabitCurve: View {
    let p: Double
    let theme: DopamineStoryTheme

    private let tau = 22.03

    private func auto(_ x: Double) -> Double { 1.0 - exp(-x * 100.0 / tau) }

    private func pt(_ x: Double, _ w: CGFloat, _ plotH: CGFloat) -> CGPoint {
        let top: CGFloat = 18
        let y = top + (plotH - top) * CGFloat(1.0 - auto(x))
        return CGPoint(x: CGFloat(x) * w, y: y)
    }

    private func curve(_ upTo: Double, closed: Bool, w: CGFloat, plotH: CGFloat) -> Path {
        var path = Path()
        let steps = 300
        let n = max(1, Int(Double(steps) * upTo))
        for i in 0...n {
            let point = pt(Double(i) / Double(steps), w, plotH)
            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        if closed {
            let last = pt(Double(n) / Double(steps), w, plotH)
            path.addLine(to: CGPoint(x: last.x, y: plotH))
            path.addLine(to: CGPoint(x: 0, y: plotH))
            path.closeSubpath()
        }
        return path
    }

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let plotH = geo.size.height - 28
            let tip = pt(p, w, plotH)
            let markerX = CGFloat(0.66) * w
            let markerA = goClamp01((p - 0.66) / 0.05)

            ZStack(alignment: .topLeading) {
                curve(p, closed: true, w: w, plotH: plotH)
                    .fill(
                        LinearGradient(
                            colors: [theme.accent.opacity(0.40), theme.accent.opacity(0.0)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                Path { path in
                    path.move(to: CGPoint(x: 0, y: plotH))
                    path.addLine(to: CGPoint(x: w, y: plotH))
                }
                .stroke(theme.primaryText.opacity(0.22), lineWidth: 1.5)

                Path { path in
                    path.move(to: CGPoint(x: markerX, y: 0))
                    path.addLine(to: CGPoint(x: markerX, y: plotH))
                }
                .stroke(theme.primaryText.opacity(0.5), style: StrokeStyle(lineWidth: 1.5, dash: [4, 4]))
                .opacity(markerA)

                curve(p, closed: false, w: w, plotH: plotH)
                    .stroke(theme.accent, style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
                    .shadow(color: theme.accent.opacity(0.7), radius: 8)

                GOOrb(tint: theme.accent, size: CGFloat(28.0 + 26.0 * auto(p)), symbol: "leaf.fill")
                    .position(tip)

                Text(String(localized: "dopamine_story_s5_habit", defaultValue: "Gewohnheit sitzt"))
                    .font(.system(size: 12, weight: .heavy, design: theme.fontDesign))
                    .foregroundColor(theme.onAccent)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Capsule().fill(theme.accent))
                    .position(x: max(70, markerX - 62), y: plotH * 0.72)
                    .opacity(markerA)
                    .scaleEffect(CGFloat(0.7 + 0.3 * markerA))

                Text(String(localized: "dopamine_story_s5_d0", defaultValue: "Tag 0"))
                    .font(.system(size: 11, weight: .semibold, design: theme.fontDesign))
                    .foregroundColor(theme.secondaryText)
                    .position(x: 18, y: plotH + 16)
                Text(String(localized: "dopamine_story_s5_d66", defaultValue: "Tag 66"))
                    .font(.system(size: 11, weight: .heavy, design: theme.fontDesign))
                    .foregroundColor(theme.primaryText)
                    .position(x: markerX, y: plotH + 16)
                    .opacity(markerA)
                Text(String(localized: "dopamine_story_s5_d100", defaultValue: "Tag 100"))
                    .font(.system(size: 11, weight: .semibold, design: theme.fontDesign))
                    .foregroundColor(theme.secondaryText)
                    .position(x: w - 22, y: plotH + 16)
            }
        }
    }
}

private struct GOHabitScene: View {
    let theme: DopamineStoryTheme

    var body: some View {
        GOTimed { t in
            let p = goInOut(goProg(t, 0.5, 3.2))
            let shape = RoundedRectangle(cornerRadius: 24, style: .continuous)

            VStack(spacing: 16) {
                Spacer(minLength: 64)

                VStack(alignment: .leading, spacing: 8) {
                    Text(String(localized: "dopamine_story_s5_label", defaultValue: "Wie automatisch fühlt sich die Gewohnheit an?"))
                        .font(.system(size: 12, weight: .semibold, design: theme.fontDesign))
                        .foregroundColor(theme.secondaryText)
                    GOHabitCurve(p: p, theme: theme)
                        .frame(height: 190)
                }
                .padding(16)
                .background(shape.fill(theme.primaryText.opacity(0.07)))
                .overlay(shape.strokeBorder(theme.primaryText.opacity(0.12), lineWidth: 1))
                .padding(.horizontal, 24)
                .opacity(goProg(t, 0.0, 0.5))

                VStack(spacing: 8) {
                    GOChip(symbol: "calendar", text: String(localized: "dopamine_story_s5_range", defaultValue: "Spanne: 18 bis 254 Tage"), tint: GOColors.orange[1], theme: theme)
                    GOChip(symbol: "checkmark.seal.fill", text: String(localized: "dopamine_story_s5_miss", defaultValue: "Ein verpasster Tag schadet kaum"), tint: Color(red: 0.2, green: 0.7, blue: 0.4), theme: theme)
                }
                .opacity(goProg(t, 3.6, 0.5))
                .offset(y: CGFloat((1.0 - goOut(goProg(t, 3.6, 0.5))) * 14.0))

                GOCaption(
                    title: String(localized: "dopamine_story_s5_title", defaultValue: "Grovy gibt deinen\nGewohnheiten Zeit."),
                    subtitle: String(localized: "dopamine_story_s5_sub", defaultValue: "Im Schnitt läuft etwas nach 66 Tagen automatisch. In deinem Garten wird jeder dieser Tage sichtbar – statt dem nächsten Kick."),
                    t: t,
                    theme: theme,
                    delay: 3.9
                )

                GOSource(text: String(localized: "dopamine_story_s5_source", defaultValue: "Quelle: Lally et al., University College London (96 Teilnehmende)"), t: t, theme: theme, delay: 5.0)

                Spacer(minLength: 36)
            }
        }
    }
}

// MARK: - Szene 6: Finale

private struct GOFinaleScene: View {
    let theme: DopamineStoryTheme
    let showsButton: Bool
    let buttonTitle: String
    let onFinish: () -> Void

    private let orbit: [(symbol: String, colors: [Color])] = [
        ("figure.run", GOColors.pink),
        ("book.fill", GOColors.blue),
        ("drop.fill", GOColors.cyan),
        ("moon.zzz.fill", GOColors.purple),
        ("sun.max.fill", GOColors.orange)
    ]

    var body: some View {
        GOTimed { t in
            let intro = goBack(goProg(t, 0.0, 1.0))
            let count = orbit.count

            VStack(spacing: 24) {
                Spacer(minLength: 64)

                ZStack {
                    GOGlow(color: theme.accent, t: t)

                    Ellipse()
                        .stroke(theme.primaryText.opacity(0.16), lineWidth: 1.5)
                        .frame(width: 280, height: 84)
                        .offset(y: 34)

                    ForEach(0..<count, id: \.self) { i in
                        let a = t * 0.7 + Double(i) * 2.0 * Double.pi / Double(count)
                        let z = sin(a)
                        let x = 128.0 * cos(a)
                        let y = 34.0 + 36.0 * z
                        GOGlossTile(symbol: orbit[i].symbol, colors: orbit[i].colors, size: 50)
                            .scaleEffect(CGFloat(0.8 + 0.22 * z))
                            .opacity(0.7 + 0.3 * (z + 1.0) / 2.0)
                            .offset(x: CGFloat(x), y: CGFloat(y))
                            .zIndex(z)
                    }

                    GOSlab(symbol: "leaf.fill", colors: GOColors.green, size: 112)
                        .rotation3DEffect(.degrees(12.0 * sin(t * 1.2)), axis: (x: 0, y: 1, z: 0), perspective: 0.5)
                        .offset(y: CGFloat(-18.0 + 6.0 * sin(t * 1.6)))
                        .zIndex(0)
                }
                .frame(height: 270)
                .scaleEffect(CGFloat(0.3 + 0.7 * intro))
                .opacity(goProg(t, 0.0, 0.4))

                GOCaption(
                    title: String(localized: "grovy_story_scene5_title", defaultValue: "Dein Garten\nwartet."),
                    subtitle: String(localized: "grovy_story_scene5_sub", defaultValue: "Kleine Schritte, die sich Tag für Tag summieren – statt dem nächsten Kick."),
                    t: t,
                    theme: theme,
                    delay: 0.7
                )

                if showsButton {
                    let b = goOut(goProg(t, 1.6, 0.6))
                    Button(action: onFinish) {
                        Text(buttonTitle)
                            .font(.system(size: 19, weight: .bold, design: theme.fontDesign))
                            .foregroundColor(theme.onAccent)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 17)
                            .background(Capsule().fill(theme.accent))
                            .shadow(color: theme.accent.opacity(0.5), radius: 16, x: 0, y: 6)
                    }
                    .padding(.horizontal, 32)
                    .scaleEffect(CGFloat(0.8 + 0.2 * b))
                    .opacity(b)
                }

                Spacer(minLength: 30)
            }
        }
    }
}
