import SwiftUI
import AVFoundation

// MARK: - DopamineStoryView
// Komprimierte, stark animierte Story (Zoom & Haptics)
// Scene 0: Zeit (Kästchen füllen sich blutrot, pulse)
// Scene 1: Dopamin-Score (Echte isometrische 3D Balken)
// Scene 2: Transition (Automatischer Wechsel zu Habits)

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
        primaryText: .primary,
        secondaryText: .secondary,
        accent: Color(red: 0.36, green: 0.86, blue: 0.52),
        onAccent: Color(red: 0.03, green: 0.20, blue: 0.12),
        warning: Color(red: 0.95, green: 0.15, blue: 0.25), // Dramatischeres, dunkleres Rot
        fontDesign: .rounded
    )
}

struct DopamineStoryView: View {
    let theme: DopamineStoryTheme
    let showsProgress: Bool
    let showsFinishButton: Bool
    let finishTitle: String
    let onFinish: () -> Void

    @State private var scene = 0
    private let durations: [Double] = [5.5, 6.0, 3.5] // 3. Szene ist der Auto-Übergang
    private var lastIndex: Int { durations.count - 1 }

    init(
        theme: DopamineStoryTheme = .grovy,
        showsProgress: Bool = true,
        showsFinishButton: Bool = false, // Wird nicht mehr benötigt für manuellen Klick
        finishTitle: String = "",
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
                .transition(.scale(scale: 0.7).combined(with: .opacity))

            if showsProgress {
                topBar
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { next() }
        .task(id: scene) {
            let d = durations[scene]
            guard d > 0 else { return }
            try? await Task.sleep(nanoseconds: UInt64(d * 1_000_000_000))
            if !Task.isCancelled {
                if scene == lastIndex {
                    onFinish() // Automatischer Übergang ganz am Ende!
                } else {
                    next()
                }
            }
        }
    }

    @ViewBuilder
    private var currentScene: some View {
        switch scene {
        case 0: GOVisualTimeScene(theme: theme)
        case 1: GODopamineScoreScene(theme: theme)
        default: GODopamineTransitionScene(theme: theme)
        }
    }

    private func next() {
        guard scene < lastIndex else {
            onFinish()
            return
        }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
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
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }
}

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

// MARK: - 3D Container
struct GOWhite3DContainer<Content: View>: View {
    let content: Content
    let horizontalPadding: CGFloat
    
    init(horizontalPadding: CGFloat = 20, @ViewBuilder content: () -> Content) {
        self.horizontalPadding = horizontalPadding
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color(UIColor.systemBackground))
                    .shadow(color: Color.black.opacity(0.1), radius: 0, x: 0, y: 5)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .strokeBorder(Color.black.opacity(0.05), lineWidth: 1)
            )
    }
}

// MARK: - Szene 0: Visual Time Boxes (Dramatisch)
private struct GOVisualTimeScene: View {
    let theme: DopamineStoryTheme
    @State private var fillLife = 0.0
    @State private var fillYear = 0.0
    @State private var fillDay = 0.0
    
    @State private var show1 = false
    @State private var show2 = false
    @State private var show3 = false
    
    // Heartbeat Pulse Animation
    @State private var pulse = false
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Text(String(localized: "dopamine_story_time_title", defaultValue: "Deine Bildschirmzeit"))
                .font(.system(size: 28, weight: .heavy, design: theme.fontDesign))
                .foregroundColor(theme.primaryText)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 16) {
                if show1 {
                    timeBoxCard(
                        title: String(localized: "dop_box_life", defaultValue: "Leben (80 Jahre)"),
                        icon: "hourglass.bottomhalf.filled",
                        total: 80,
                        cols: 10,
                        highlighted: fillLife,
                        color: theme.warning
                    )
                    .transition(.scale(scale: 0.5).combined(with: .opacity))
                }
                
                if show2 {
                    timeBoxCard(
                        title: String(localized: "dop_box_year", defaultValue: "Jahr (12 Monate)"),
                        icon: "calendar",
                        total: 12,
                        cols: 6,
                        highlighted: fillYear,
                        color: theme.warning
                    )
                    .transition(.scale(scale: 0.5).combined(with: .opacity))
                }
                
                if show3 {
                    timeBoxCard(
                        title: String(localized: "dop_box_day", defaultValue: "Tag (24 Stunden)"),
                        icon: "timer",
                        total: 24,
                        cols: 8,
                        highlighted: fillDay,
                        color: theme.warning
                    )
                    .transition(.scale(scale: 0.5).combined(with: .opacity))
                }
            }
            .scaleEffect(pulse ? 1.02 : 1.0)
            
            Spacer()
        }
        .padding(.horizontal, 24)
        .onAppear {
            // Heartbeat Haptic Loop for Drama
            Timer.scheduledTimer(withTimeInterval: 0.8, repeats: true) { timer in
                guard show3 else { return }
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                withAnimation(.easeInOut(duration: 0.1)) { pulse = true }
                withAnimation(.easeInOut(duration: 0.3).delay(0.1)) { pulse = false }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) { show1 = true }
                withAnimation(.easeOut(duration: 1.0).delay(0.2)) { fillLife = 10.0 }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) { show2 = true }
                withAnimation(.easeOut(duration: 0.6).delay(0.2)) { fillYear = 1.5 }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) { show3 = true }
                withAnimation(.easeOut(duration: 0.6).delay(0.2)) { fillDay = 3.5 }
            }
        }
    }
    
    private func timeBoxCard(title: String, icon: String, total: Int, cols: Int, highlighted: Double, color: Color) -> some View {
        GOWhite3DContainer {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(color)
                    Text(title)
                        .font(.system(size: 14, weight: .bold, design: theme.fontDesign))
                        .foregroundColor(theme.primaryText)
                }
                
                // Box Grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: cols), spacing: 4) {
                    ForEach(0..<total, id: \.self) { i in
                        let fill = max(0.0, min(1.0, highlighted - Double(i)))
                        
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(theme.primaryText.opacity(0.08))
                            
                            GeometryReader { geo in
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(color)
                                    .frame(width: geo.size.width * CGFloat(fill))
                                    .opacity(pulse && fill > 0 ? 0.7 : 1.0)
                            }
                        }
                        .aspectRatio(1, contentMode: .fit)
                    }
                }
            }
        }
    }
}

// MARK: - Szene 1: Das Dopamin Problem (Isometrische 3D Score Säulen)
private struct GODopamineScoreScene: View {
    let theme: DopamineStoryTheme
    
    @State private var showBars = false
    @State private var tiktokExplode = false
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Text(String(localized: "dop_score_title", defaultValue: "Dopamin-Ausschüttung"))
                .font(.system(size: 28, weight: .heavy, design: theme.fontDesign))
                .foregroundColor(theme.primaryText)
                .multilineTextAlignment(.center)
            
            GOWhite3DContainer(horizontalPadding: 16) {
                ZStack {
                    // Dotted Baseline
                    VStack {
                        Spacer()
                        HStack {
                            Text(String(localized: "dop_baseline", defaultValue: "Basiswert"))
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(theme.secondaryText)
                            
                            Line()
                                .stroke(style: StrokeStyle(lineWidth: 1, dash: [4]))
                                .frame(height: 1)
                                .foregroundColor(theme.secondaryText.opacity(0.5))
                        }
                        .offset(y: -40) // Baseline at 100% (40 height scaling)
                    }
                    .padding(.bottom, 50) // offset from bottom text
                    .opacity(showBars ? 1 : 0)
                    
                    HStack(alignment: .bottom, spacing: 18) {
                        // Bar 1: Essen
                        GOIsometricBar(
                            score: 150,
                            title: String(localized: "dop_score_food", defaultValue: "Essen"),
                            icon: "🍔",
                            color: Color.blue,
                            show: showBars,
                            isWarning: false,
                            theme: theme
                        )
                        
                        // Bar 2: Sport
                        GOIsometricBar(
                            score: 200,
                            title: String(localized: "dop_score_sport", defaultValue: "Workout"),
                            icon: "🏃‍♂️",
                            color: theme.accent,
                            show: showBars,
                            isWarning: false,
                            theme: theme
                        )
                        
                        // Bar 3: TikTok
                        GOIsometricBar(
                            score: 400,
                            title: String(localized: "dop_score_tiktok", defaultValue: "Infinite Scrolling"),
                            icon: "📱",
                            color: tiktokExplode ? theme.warning : Color.purple,
                            show: showBars,
                            isWarning: tiktokExplode,
                            theme: theme
                        )
                    }
                    .frame(height: 250, alignment: .bottom) // Fixe Höhe für den Container
                }
            }
            
            Text(String(localized: "dopamine_story_prob_sub", defaultValue: "Social Media liefert schnelle, unerwartete Belohnungen. Das Gehirn will immer mehr, der echte Fokus sinkt."))
                .font(.system(size: 15, weight: .medium, design: theme.fontDesign))
                .foregroundColor(theme.secondaryText)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .padding(.horizontal, 24)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    showBars = true
                }
                UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.4)) {
                    tiktokExplode = true
                }
                // Haptic Explosion
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                }
            }
        }
    }
}

// Isometrischer 3D Balken (Custom Path)
struct GOIsometricBar: View {
    let score: Int
    let title: String
    let icon: String
    let color: Color
    let show: Bool
    let isWarning: Bool
    let theme: DopamineStoryTheme
    
    // Pulse State
    @State private var pulse = false
    
    var body: some View {
        VStack(spacing: 8) {
            VStack(spacing: 2) {
                Text("\(score)%")
                    .font(.system(size: isWarning && show ? 18 : 14, weight: .heavy))
                    .foregroundColor(isWarning && show ? color : theme.primaryText)
            }
            .opacity(show ? 1 : 0)
            
            // Echter 3D Bar Graph (Isometrisch)
            ZStack(alignment: .bottom) {
                let w: CGFloat = 36
                let d: CGFloat = 12 // Tiefe
                let h: CGFloat = show ? min(200, CGFloat(score) * 0.4) : 0 // max height 200
                
                // Rechte Seite
                Path { path in
                    path.move(to: CGPoint(x: w, y: h))
                    path.addLine(to: CGPoint(x: w + d, y: h - d))
                    path.addLine(to: CGPoint(x: w + d, y: -d))
                    path.addLine(to: CGPoint(x: w, y: 0))
                    path.closeSubpath()
                }
                .fill(color.opacity(0.6))
                
                // Oben (Top Deckel)
                Path { path in
                    path.move(to: CGPoint(x: 0, y: 0))
                    path.addLine(to: CGPoint(x: d, y: -d))
                    path.addLine(to: CGPoint(x: w + d, y: -d))
                    path.addLine(to: CGPoint(x: w, y: 0))
                    path.closeSubpath()
                }
                .fill(color.opacity(0.8))
                
                // Front
                Path { path in
                    path.addRect(CGRect(x: 0, y: 0, width: w, height: h))
                }
                .fill(color)
            }
            .frame(width: 48, height: 200, alignment: .bottom) // Fixe Breite für alignment, höhe dynamisch durch Path aber Frame 200 max
            .scaleEffect(pulse && isWarning ? 1.05 : 1.0)
            .shadow(color: isWarning ? color.opacity(0.6) : .clear, radius: 10, x: 0, y: 0)
            
            Text(icon)
                .font(.system(size: 26))
            
            Text(title)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(theme.secondaryText)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(width: 70) // Textumbruch erlauben für längere Texte wie "Infinite Scrolling"
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                guard isWarning && show else { return }
                withAnimation(.easeInOut(duration: 0.2)) { pulse = true }
                withAnimation(.easeInOut(duration: 0.2).delay(0.2)) { pulse = false }
            }
        }
    }
}

// MARK: - Szene 2: Der Automatische Übergang (Intro-Stil)
private struct GODopamineTransitionScene: View {
    let theme: DopamineStoryTheme
    
    @State private var appear = false
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "sparkles")
                .font(.system(size: 48))
                .foregroundColor(theme.accent)
                .scaleEffect(appear ? 1.2 : 0.5)
                .opacity(appear ? 1 : 0)
            
            Text(String(localized: "dop_transition_title", defaultValue: "Zeit für Veränderung"))
                .font(.system(size: 32, weight: .heavy, design: theme.fontDesign))
                .foregroundColor(theme.primaryText)
                .multilineTextAlignment(.center)
                .opacity(appear ? 1 : 0)
                .offset(y: appear ? 0 : 20)
            
            Text(String(localized: "dop_transition_sub", defaultValue: "Wähle deine Gewohnheiten und hol dir den Fokus zurück."))
                .font(.system(size: 18, weight: .medium, design: theme.fontDesign))
                .foregroundColor(theme.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .opacity(appear ? 1 : 0)
                .offset(y: appear ? 0 : 20)
            
            Spacer()
        }
        .onAppear {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            withAnimation(.easeOut(duration: 0.8)) {
                appear = true
            }
        }
    }
}

struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        return path
    }
}
