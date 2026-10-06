import SwiftUI

// MARK: - DopamineStoryView
// Komprimierte, stark animierte Story (Zoom & Haptics)
// Scene 0: Zeit (Karten ploppen auf)
// Scene 1: Dopamin-Score (Balkendiagramm explodiert)
// Scene 2: Routinen-Grid (Kacheln ploppen auf + Finale)

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
    private let durations: [Double] = [5.5, 6.0, 0]
    private var lastIndex: Int { durations.count - 1 }

    init(
        theme: DopamineStoryTheme = .grovy,
        showsProgress: Bool = true,
        showsFinishButton: Bool = true,
        finishTitle: String = String(localized: "dop_btn_ziele", defaultValue: "Ziele definieren"),
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
        case 0: GOReducedTimeScene(theme: theme)
        case 1: GODopamineScoreScene(theme: theme)
        default:
            GORoutinesGridScene(
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
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(20)
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

// MARK: - Szene 0: Zeitverlust
private struct GOReducedTimeScene: View {
    let theme: DopamineStoryTheme
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
                    timeCard(
                        title: String(localized: "dopamine_story_time_life", defaultValue: "In deinem Leben"),
                        value: String(localized: "dopamine_story_time_10y", defaultValue: "10 Jahre"),
                        icon: "infinity",
                        color: theme.warning
                    )
                    .transition(.scale(scale: 0.5).combined(with: .opacity))
                }
                
                if show2 {
                    timeCard(
                        title: String(localized: "dopamine_story_time_year", defaultValue: "Im Jahr"),
                        value: String(localized: "dopamine_story_time_46d", defaultValue: "46 Tage"),
                        icon: "calendar",
                        color: Color.orange
                    )
                    .transition(.scale(scale: 0.5).combined(with: .opacity))
                }
                
                if show3 {
                    timeCard(
                        title: String(localized: "dopamine_story_time_day", defaultValue: "Am Tag"),
                        value: String(localized: "dopamine_story_time_3h", defaultValue: "3+ Stunden"),
                        icon: "clock.fill",
                        color: theme.accent
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
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) { show2 = true }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.1) {
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) { show3 = true }
            }
        }
    }
    
    private func timeCard(title: String, value: String, icon: String, color: Color) -> some View {
        GOWhite3DContainer {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(color)
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 14, weight: .bold, design: theme.fontDesign))
                        .foregroundColor(theme.secondaryText)
                    Text(value)
                        .font(.system(size: 24, weight: .black, design: theme.fontDesign))
                        .foregroundColor(theme.primaryText)
                }
                Spacer()
            }
        }
    }
}

// MARK: - Szene 1: Das Dopamin Problem (TikTok Score)
private struct GODopamineScoreScene: View {
    let theme: DopamineStoryTheme
    
    @State private var showBars = false
    @State private var tiktokExplode = false
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Text(String(localized: "dop_score_title", defaultValue: "Dopamin-Ausschüttung"))
                .font(.system(size: 28, weight: .heavy, design: theme.fontDesign))
                .foregroundColor(theme.primaryText)
                .multilineTextAlignment(.center)
            
            GOWhite3DContainer {
                HStack(alignment: .bottom, spacing: 24) {
                    // Bar 1: Essen
                    VStack(spacing: 8) {
                        Text("50")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(theme.secondaryText)
                            .opacity(showBars ? 1 : 0)
                        
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.blue.opacity(0.8))
                            .frame(width: 40, height: showBars ? 50 : 0)
                        
                        Text("🍔")
                            .font(.system(size: 24))
                        Text(String(localized: "dop_score_food", defaultValue: "Essen"))
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(theme.secondaryText)
                            .lineLimit(1)
                    }
                    
                    // Bar 2: Sport
                    VStack(spacing: 8) {
                        Text("130")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(theme.secondaryText)
                            .opacity(showBars ? 1 : 0)
                        
                        RoundedRectangle(cornerRadius: 12)
                            .fill(theme.accent)
                            .frame(width: 40, height: showBars ? 130 : 0)
                        
                        Text("🏃‍♂️")
                            .font(.system(size: 24))
                        Text(String(localized: "dop_score_sport", defaultValue: "Sport"))
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(theme.secondaryText)
                            .lineLimit(1)
                    }
                    
                    // Bar 3: TikTok
                    VStack(spacing: 8) {
                        Text("400+")
                            .font(.system(size: tiktokExplode ? 20 : 14, weight: .heavy))
                            .foregroundColor(tiktokExplode ? theme.warning : theme.secondaryText)
                            .opacity(showBars ? 1 : 0)
                        
                        RoundedRectangle(cornerRadius: 12)
                            .fill(tiktokExplode ? theme.warning : Color.purple)
                            .frame(width: 40, height: showBars ? (tiktokExplode ? 240 : 20) : 0)
                            .shadow(color: tiktokExplode ? theme.warning.opacity(0.6) : .clear, radius: 10, x: 0, y: 0)
                        
                        Text("📱")
                            .font(.system(size: 24))
                        Text(String(localized: "dop_score_tiktok", defaultValue: "Scrolling"))
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(tiktokExplode ? theme.warning : theme.secondaryText)
                            .lineLimit(1)
                    }
                }
                .frame(height: 300, alignment: .bottom)
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
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            }
        }
    }
}

// MARK: - Szene 2: Die Routinen & Button
private struct GORoutinesGridScene: View {
    let theme: DopamineStoryTheme
    let showsButton: Bool
    let buttonTitle: String
    let onFinish: () -> Void
    
    @State private var itemsAppeared = 0
    @State private var buttonAppeared = false
    
    private let routines = [
        (icon: "book.fill", text: String(localized: "dop_routines_read", defaultValue: "Lesen"), color: Color.blue),
        (icon: "drop.fill", text: String(localized: "dop_routines_water", defaultValue: "Wasser"), color: Color.cyan),
        (icon: "figure.run", text: String(localized: "dop_routines_run", defaultValue: "Sport"), color: Color.green),
        (icon: "moon.zzz.fill", text: String(localized: "dop_routines_sleep", defaultValue: "Schlaf"), color: Color.purple),
        (icon: "brain", text: String(localized: "dop_routines_learn", defaultValue: "Lernen"), color: Color.orange),
        (icon: "leaf.fill", text: String(localized: "dop_routines_meditate", defaultValue: "Meditation"), color: Color(red: 0.36, green: 0.86, blue: 0.52))
    ]
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Text(String(localized: "dop_routines_title", defaultValue: "Echte Routinen aufbauen"))
                .font(.system(size: 28, weight: .heavy, design: theme.fontDesign))
                .foregroundColor(theme.primaryText)
                .multilineTextAlignment(.center)
            
            Text(String(localized: "dop_routines_sub", defaultValue: "Statt schnellen Kicks baust du einen Garten voller Gewohnheiten."))
                .font(.system(size: 16, weight: .medium, design: theme.fontDesign))
                .foregroundColor(theme.secondaryText)
                .multilineTextAlignment(.center)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(0..<routines.count, id: \.self) { i in
                    if itemsAppeared > i {
                        routineCard(routine: routines[i])
                            .transition(.scale(scale: 0.5).combined(with: .opacity))
                    } else {
                        Color.clear.frame(height: 80)
                    }
                }
            }
            .padding(.vertical, 16)
            
            Spacer()
            
            if showsButton && buttonAppeared {
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
            for i in 0..<routines.count {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3 + Double(i) * 0.15) {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                        itemsAppeared += 1
                    }
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3 + Double(routines.count) * 0.15 + 0.4) {
                UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    buttonAppeared = true
                }
            }
        }
    }
    
    private func routineCard(routine: (icon: String, text: String, color: Color)) -> some View {
        VStack(spacing: 8) {
            Image(systemName: routine.icon)
                .font(.system(size: 24))
                .foregroundColor(routine.color)
            Text(routine.text)
                .font(.system(size: 13, weight: .bold, design: theme.fontDesign))
                .foregroundColor(theme.primaryText)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 80)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: Color.black.opacity(0.08), radius: 0, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color.black.opacity(0.05), lineWidth: 1)
        )
    }
}
