import SwiftUI

// MARK: - DopamineStoryView
// Komprimierte, stark animierte Story (Zoom & Haptics)
// Scene 0: Zeit (Kästchen füllen sich rot)
// Scene 1: Dopamin-Score (iTunes 3D Balkendiagramm + Ende)

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
        warning: Color(red: 1.0, green: 0.36, blue: 0.45),
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
    private let durations: [Double] = [6.0, 0] // Nur noch 2 Szenen!
    private var lastIndex: Int { durations.count - 1 }

    init(
        theme: DopamineStoryTheme = .grovy,
        showsProgress: Bool = true,
        showsFinishButton: Bool = true,
        finishTitle: String = String(localized: "dop_btn_gewohnheiten", defaultValue: "Gewohnheiten wählen"),
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
            if !Task.isCancelled { next() }
        }
    }

    @ViewBuilder
    private var currentScene: some View {
        switch scene {
        case 0: GOVisualTimeScene(theme: theme)
        default:
            GODopamineScoreScene(
                theme: theme,
                showsButton: showsFinishButton,
                buttonTitle: finishTitle,
                onFinish: onFinish
            )
        }
    }

    private func next() {
        guard scene < lastIndex else { return }
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

// MARK: - Szene 0: Visual Time Boxes
private struct GOVisualTimeScene: View {
    let theme: DopamineStoryTheme
    @State private var fillLife = 0.0
    @State private var fillYear = 0.0
    @State private var fillDay = 0.0
    
    @State private var show1 = false
    @State private var show2 = false
    @State private var show3 = false
    
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
                        color: Color.orange
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
            
            Spacer()
        }
        .padding(.horizontal, 24)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) { show1 = true }
                withAnimation(.easeOut(duration: 1.0).delay(0.2)) { fillLife = 10.0 }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) { show2 = true }
                withAnimation(.easeOut(duration: 0.6).delay(0.2)) { fillYear = 1.5 } // 1.5 Monate = 46 Tage
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) { show3 = true }
                withAnimation(.easeOut(duration: 0.6).delay(0.2)) { fillDay = 3.5 } // 3.5 Stunden
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
                            }
                        }
                        .aspectRatio(1, contentMode: .fit)
                    }
                }
            }
        }
    }
}

// MARK: - Szene 1: Das Dopamin Problem (iTunes 3D Score)
private struct GODopamineScoreScene: View {
    let theme: DopamineStoryTheme
    let showsButton: Bool
    let buttonTitle: String
    let onFinish: () -> Void
    
    @State private var showBars = false
    @State private var tiktokExplode = false
    @State private var showButton = false
    
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
                        .offset(y: -50) // Baseline at 100% (50 height)
                    }
                    .padding(.bottom, 60)
                    .opacity(showBars ? 1 : 0)
                    
                    HStack(alignment: .bottom, spacing: 20) {
                        // Bar 1: Essen
                        GOiTunes3DBar(
                            score: 150,
                            title: String(localized: "dop_score_food", defaultValue: "Essen"),
                            icon: "🍔",
                            color: Color.blue.opacity(0.8),
                            show: showBars,
                            isWarning: false,
                            theme: theme
                        )
                        
                        // Bar 2: Sport
                        GOiTunes3DBar(
                            score: 200,
                            title: String(localized: "dop_score_sport", defaultValue: "Sport"),
                            icon: "🏃‍♂️",
                            color: theme.accent,
                            show: showBars,
                            isWarning: false,
                            theme: theme
                        )
                        
                        // Bar 3: TikTok
                        GOiTunes3DBar(
                            score: 400,
                            title: String(localized: "dop_score_tiktok", defaultValue: "Scrolling"),
                            icon: "📱",
                            color: tiktokExplode ? theme.warning : Color.purple,
                            show: showBars,
                            isWarning: tiktokExplode,
                            theme: theme
                        )
                    }
                    .frame(height: 250, alignment: .bottom)
                }
            }
            
            Text(String(localized: "dopamine_story_prob_sub", defaultValue: "Social Media liefert schnelle, unerwartete Belohnungen. Das Gehirn will immer mehr, der echte Fokus sinkt."))
                .font(.system(size: 15, weight: .medium, design: theme.fontDesign))
                .foregroundColor(theme.secondaryText)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            if showsButton && showButton {
                Button {
                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                    onFinish()
                } label: {
                    Text(buttonTitle)
                        .font(.system(size: 19, weight: .bold, design: theme.fontDesign))
                }
                .buttonStyle(DuolingoButtonStyle(
                    size: .large,
                    backgroundColor: Color.blauPrimary,
                    shadowColor: Color.blauPrimary.darker(),
                    foregroundColor: .white
                ))
                .padding(.horizontal, 8)
                .padding(.bottom, 20)
                .transition(.scale(scale: 0.8).combined(with: .opacity))
            }
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
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    showButton = true
                }
            }
        }
    }
}

// iTunes 3D Bar
struct GOiTunes3DBar: View {
    let score: Int
    let title: String
    let icon: String
    let color: Color
    let show: Bool
    let isWarning: Bool
    let theme: DopamineStoryTheme
    
    var body: some View {
        VStack(spacing: 8) {
            VStack(spacing: 2) {
                Text("\(score)%")
                    .font(.system(size: isWarning && show ? 18 : 14, weight: .heavy))
                    .foregroundColor(isWarning && show ? color : theme.primaryText)
                
                Text(String(localized: "dop_unit_percent", defaultValue: "% vom Basiswert"))
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(theme.secondaryText)
            }
            .opacity(show ? 1 : 0)
            
            // 3D Bar
            ZStack(alignment: .bottom) {
                // Background Track (Limits the height)
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(UIColor.systemGray6))
                    .frame(width: 48, height: 200) // max height is 200
                
                // Filled Bar (clipped to max height so it doesn't break out)
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(color)
                    .frame(width: 48, height: show ? min(200, CGFloat(score) * 0.5) : 0)
                    .shadow(color: color.opacity(0.3), radius: 6, x: 0, y: 0)
            }
            .frame(height: 200, alignment: .bottom)
            .clipped()
            
            Text(icon)
                .font(.system(size: 26))
            Text(title)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(theme.secondaryText)
                .lineLimit(1)
                .frame(width: 80) // Prevents wrapping
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
