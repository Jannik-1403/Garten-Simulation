import SwiftUI

// MARK: - DopamineStoryView
// ZackZack Intro-Story
// Szene 1: Riesiges Grid zoomt rein, rote Kästchen knallen rein (Haptic!)
// Szene 2: Dopamin-Säulen wachsen (Canvas 3D) (Haptic!)
// Szene 3: Kamera zoomt ins Unendliche -> Habit Auswahl (onFinish)

struct DopamineStoryTheme {
    var primaryText: Color
    var secondaryText: Color
    var accent: Color
    var warning: Color
    var fontDesign: Font.Design

    static let grovy = DopamineStoryTheme(
        primaryText: .primary,
        secondaryText: .secondary,
        accent: Color(red: 0.36, green: 0.86, blue: 0.52),
        warning: Color(red: 0.9, green: 0.1, blue: 0.15), // Blutrot!
        fontDesign: .rounded
    )
}

// "Altes 3D Design" Modifier (iTunes/iOS6 Skeuomorphism)
struct ITunes3DTextModifier: ViewModifier {
    let color: Color
    func body(content: Content) -> some View {
        content
            .foregroundColor(color)
            // Heller Rand oben (Highlight)
            .shadow(color: .white.opacity(0.8), radius: 1, x: 0, y: -1)
            // Harter Schatten unten (Drop Shadow)
            .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 2)
    }
}

extension View {
    func iTunes3DStyle(color: Color) -> some View {
        self.modifier(ITunes3DTextModifier(color: color))
    }
}

struct DopamineStoryView: View {
    let theme: DopamineStoryTheme
    let onFinish: () -> Void

    // Timeline Phases
    // 0 = Start (Unsichtbar)
    // 1 = Grid zoomt auf
    // 2 = Rote Boxen knallen rein
    // 3 = Grid weg, Dopamin-Szene rein
    // 4 = Dopamin-Balken schießen hoch
    // 5 = TikTok flackert
    // 6 = Mega-Zoom in den Bildschirm (Übergang)
    @State private var phase = 0

    init(
        theme: DopamineStoryTheme = .grovy,
        showsProgress: Bool = false, // Ignoriert, wir machen ein Kino-Intro
        showsFinishButton: Bool = false,
        finishTitle: String = "",
        onFinish: @escaping () -> Void = {}
    ) {
        self.theme = theme
        self.onFinish = onFinish
    }

    var body: some View {
        ZStack {
            Color(UIColor.systemBackground)
                .ignoresSafeArea()

            // Szene 1: Leben-Grid
            if phase >= 1 && phase < 3 {
                LifeGridScene(theme: theme, showRed: phase >= 2)
                    .transition(.scale(scale: 0.0).combined(with: .opacity))
                    .zIndex(1)
            }

            // Szene 2: Dopamin-Balken
            if phase >= 3 {
                DopamineScene(theme: theme, showBars: phase >= 4, tiktokWarning: phase >= 5)
                    .transition(.scale(scale: 0.0).combined(with: .opacity))
                    .zIndex(2)
            }
        }
        // Mega Zoom für den Übergang am Ende (Phase 6)
        .scaleEffect(phase == 6 ? 50.0 : 1.0)
        .opacity(phase == 6 ? 0.0 : 1.0)
        .onAppear {
            runZackZackTimeline()
        }
    }

    private func runZackZackTimeline() {
        // Timeline zack zack zack
        
        // 1. Grid erscheint groß und wird kleiner
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) { phase = 1 }
        }
        
        // 2. Rote Boxen knallen rein!
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) { phase = 2 }
        }
        
        // 3. Grid weg, Dopamin Szene rein
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { phase = 3 }
        }
        
        // 4. Balken schießen hoch!
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.8) {
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) { phase = 4 }
        }
        
        // 5. TikTok wird blutrot!
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) { phase = 5 }
        }
        
        // 6. MEGA ZOOM in den Bildschirm und Finish
        DispatchQueue.main.asyncAfter(deadline: .now() + 7.5) {
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
            withAnimation(.easeIn(duration: 0.5)) { phase = 6 }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                onFinish() // Nahtloser Übergang
            }
        }
    }
}

// MARK: - Szene 1: Grid
private struct LifeGridScene: View {
    let theme: DopamineStoryTheme
    let showRed: Bool
    
    var body: some View {
        VStack(spacing: 30) {
            Text(String(localized: "dop_box_life", defaultValue: "Dein Leben in Kästchen"))
                .font(.system(size: 32, weight: .heavy, design: theme.fontDesign))
                .iTunes3DStyle(color: theme.primaryText)
                .multilineTextAlignment(.center)
            
            // 80 Kästchen (10x8)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 10), spacing: 6) {
                ForEach(0..<80, id: \.self) { i in
                    let isRed = i < 10 // 10 Jahre am Bildschirm
                    
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(isRed && showRed ? theme.warning : theme.primaryText.opacity(0.1))
                        .aspectRatio(1, contentMode: .fit)
                        .scaleEffect(isRed && showRed ? 1.1 : 1.0)
                        .shadow(color: isRed && showRed ? theme.warning.opacity(0.5) : .clear, radius: 4, x: 0, y: 0)
                }
            }
            .padding(.horizontal, 30)
            
            Text(String(localized: "dopamine_story_time_title", defaultValue: "10 Jahre deines Lebens verschwinden auf Bildschirmen."))
                .font(.system(size: 16, weight: .bold, design: theme.fontDesign))
                .iTunes3DStyle(color: theme.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
                .opacity(showRed ? 1 : 0)
                .offset(y: showRed ? 0 : 20)
        }
    }
}

// MARK: - Szene 2: Dopamin
private struct DopamineScene: View {
    let theme: DopamineStoryTheme
    let showBars: Bool
    let tiktokWarning: Bool
    
    var body: some View {
        VStack(spacing: 30) {
            Text(String(localized: "dop_score_title", defaultValue: "Warum passiert das?"))
                .font(.system(size: 32, weight: .heavy, design: theme.fontDesign))
                .iTunes3DStyle(color: theme.primaryText)
                .multilineTextAlignment(.center)
            
            ZStack(alignment: .bottom) {
                // Baseline
                VStack {
                    Spacer()
                    HStack {
                        Text(String(localized: "dop_baseline", defaultValue: "Gehirn Normalwert"))
                            .font(.system(size: 12, weight: .bold))
                            .iTunes3DStyle(color: theme.secondaryText)
                        Line()
                            .stroke(style: StrokeStyle(lineWidth: 2, dash: [6]))
                            .frame(height: 2)
                            .foregroundColor(theme.secondaryText.opacity(0.5))
                    }
                    .offset(y: -40) // 100% is 40px
                }
                .padding(.bottom, 70) // Text offset
                
                HStack(alignment: .bottom, spacing: 30) {
                    DopamineBarView(
                        title: String(localized: "dop_score_food", defaultValue: "Essen"),
                        icon: "🍔",
                        score: 150,
                        color: Color.blue,
                        show: showBars,
                        isWarning: false,
                        theme: theme
                    )
                    
                    DopamineBarView(
                        title: String(localized: "dop_score_sport", defaultValue: "Workout"),
                        icon: "🏃‍♂️",
                        score: 200,
                        color: theme.accent,
                        show: showBars,
                        isWarning: false,
                        theme: theme
                    )
                    
                    DopamineBarView(
                        title: String(localized: "dop_score_tiktok", defaultValue: "Infinite Scrolling"),
                        icon: "📱",
                        score: 400,
                        color: tiktokWarning ? theme.warning : Color.purple,
                        show: showBars,
                        isWarning: tiktokWarning,
                        theme: theme
                    )
                }
            }
            .frame(height: 350)
            .padding(.horizontal, 20)
            
            Text(String(localized: "dopamine_story_prob_sub", defaultValue: "Social Media liefert unnatürliche Dopamin-Spitzen. Das Gehirn wird süchtig nach dem Bildschirm."))
                .font(.system(size: 16, weight: .bold, design: theme.fontDesign))
                .iTunes3DStyle(color: theme.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
                .opacity(showBars ? 1 : 0)
        }
    }
}

// Einzelne Säule + Text
private struct DopamineBarView: View {
    let title: String
    let icon: String
    let score: Int
    let color: Color
    let show: Bool
    let isWarning: Bool
    let theme: DopamineStoryTheme
    
    var body: some View {
        VStack(spacing: 12) {
            Text("\(score)%")
                .font(.system(size: isWarning ? 20 : 16, weight: .heavy, design: theme.fontDesign))
                .iTunes3DStyle(color: isWarning ? color : theme.primaryText)
                .scaleEffect(isWarning ? 1.2 : 1.0)
                .opacity(show ? 1 : 0)
            
            // Die echte 3D Canvas Säule!
            SolidIsometricBar(
                width: 36,
                maxHeight: 200,
                scoreHeight: show ? min(200, CGFloat(score) * 0.4) : 0,
                depth: 14,
                color: color
            )
            .shadow(color: isWarning ? color.opacity(0.8) : .clear, radius: 20, x: 0, y: 0)
            
            Text(icon)
                .font(.system(size: 32))
            
            Text(title)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(theme.secondaryText)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(width: 80, height: 30) // Feste Box damit Text nicht abschneidet
        }
    }
}

// MARK: - Echte 3D Säule (Von unten nach oben!)
private struct SolidIsometricBar: View {
    let width: CGFloat
    let maxHeight: CGFloat
    let scoreHeight: CGFloat
    let depth: CGFloat
    let color: Color
    
    var body: some View {
        Canvas { context, size in
            let bottomY = size.height
            let startX: CGFloat = 0
            
            // Wenn keine Höhe da ist, malen wir nichts
            guard scoreHeight > 0.5 else { return }
            
            // Front (Gesicht zur Kamera)
            var front = Path()
            front.move(to: CGPoint(x: startX, y: bottomY))
            front.addLine(to: CGPoint(x: startX + width, y: bottomY))
            front.addLine(to: CGPoint(x: startX + width, y: bottomY - scoreHeight))
            front.addLine(to: CGPoint(x: startX, y: bottomY - scoreHeight))
            front.closeSubpath()
            context.fill(front, with: .color(color))
            
            // Rechts (Seite)
            var right = Path()
            right.move(to: CGPoint(x: startX + width, y: bottomY))
            right.addLine(to: CGPoint(x: startX + width + depth, y: bottomY - depth))
            right.addLine(to: CGPoint(x: startX + width + depth, y: bottomY - scoreHeight - depth))
            right.addLine(to: CGPoint(x: startX + width, y: bottomY - scoreHeight))
            right.closeSubpath()
            context.fill(right, with: .color(color.opacity(0.7)))
            
            // Oben (Deckel)
            var top = Path()
            top.move(to: CGPoint(x: startX, y: bottomY - scoreHeight))
            top.addLine(to: CGPoint(x: startX + width, y: bottomY - scoreHeight))
            top.addLine(to: CGPoint(x: startX + width + depth, y: bottomY - scoreHeight - depth))
            top.addLine(to: CGPoint(x: startX + depth, y: bottomY - scoreHeight - depth))
            top.closeSubpath()
            context.fill(top, with: .color(color.opacity(0.85)))
        }
        .frame(width: width + depth, height: maxHeight + depth)
    }
}

private struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        return path
    }
}
