import SwiftUI

// MARK: - DopamineStoryView
// Komprimierte, stark animierte Story (Zoom & Haptics)

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
    private let durations: [Double] = [5.0, 5.0, 5.0, 0]
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
        case 1: GOReducedProblemScene(theme: theme)
        case 2: GOReducedSolutionScene(theme: theme)
        default:
            GOReducedFinaleScene(
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

// MARK: - Szene 1: Das Problem
private struct GOReducedProblemScene: View {
    let theme: DopamineStoryTheme
    @State private var pulse = false
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            GOWhite3DContainer {
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(theme.warning.opacity(0.1))
                            .frame(width: 140, height: 140)
                            .scaleEffect(pulse ? 1.2 : 0.8)
                            .opacity(pulse ? 0 : 1)
                        
                        Image(systemName: "heart.fill")
                            .font(.system(size: 60))
                            .foregroundColor(theme.warning)
                            .scaleEffect(pulse ? 1.1 : 0.9)
                    }
                    .frame(height: 160)
                    
                    VStack(spacing: 8) {
                        Text(String(localized: "dopamine_story_prob_title", defaultValue: "Der Dopamin-Kick"))
                            .font(.system(size: 22, weight: .heavy, design: theme.fontDesign))
                            .foregroundColor(theme.primaryText)
                        
                        Text(String(localized: "dopamine_story_prob_sub", defaultValue: "Social Media liefert schnelle, unerwartete Belohnungen. Das Gehirn will immer mehr, der echte Fokus sinkt."))
                            .font(.system(size: 15, weight: .medium, design: theme.fontDesign))
                            .foregroundColor(theme.secondaryText)
                            .multilineTextAlignment(.center)
                    }
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 24)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }
}

// MARK: - Szene 2: Die Lösung
private struct GOReducedSolutionScene: View {
    let theme: DopamineStoryTheme
    @State private var grow = false
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            GOWhite3DContainer {
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(theme.accent.opacity(0.2))
                            .frame(width: 140, height: 140)
                        
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 60))
                            .foregroundColor(theme.accent)
                            .scaleEffect(grow ? 1.0 : 0.2)
                            .rotationEffect(.degrees(grow ? 0 : -30))
                    }
                    .frame(height: 160)
                    
                    VStack(spacing: 8) {
                        Text(String(localized: "dopamine_story_sol_title", defaultValue: "Nachhaltige Routinen"))
                            .font(.system(size: 22, weight: .heavy, design: theme.fontDesign))
                            .foregroundColor(theme.primaryText)
                        
                        Text(String(localized: "dopamine_story_sol_sub", defaultValue: "Statt schnellen Kicks baust du echte Gewohnheiten auf. Im Schnitt dauert es 66 Tage, bis sie automatisch ablaufen."))
                            .font(.system(size: 15, weight: .medium, design: theme.fontDesign))
                            .foregroundColor(theme.secondaryText)
                            .multilineTextAlignment(.center)
                    }
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 24)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                withAnimation(.spring(response: 0.6, dampingFraction: 0.5)) {
                    grow = true
                }
            }
        }
    }
}

// MARK: - Szene 3: Finale
private struct GOReducedFinaleScene: View {
    let theme: DopamineStoryTheme
    let showsButton: Bool
    let buttonTitle: String
    let onFinish: () -> Void

    @State private var appear = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "sparkles")
                .font(.system(size: 80))
                .foregroundColor(Color.orange)
                .scaleEffect(appear ? 1 : 0.5)
                .opacity(appear ? 1 : 0)
            
            Text(String(localized: "dopamine_story_fin_title", defaultValue: "Dein Garten wartet"))
                .font(.system(size: 32, weight: .black, design: theme.fontDesign))
                .foregroundColor(theme.primaryText)
                .multilineTextAlignment(.center)
                .scaleEffect(appear ? 1 : 0.8)
                .opacity(appear ? 1 : 0)
            
            Text(String(localized: "dopamine_story_fin_sub", defaultValue: "Tausche endlose Feeds gegen echte Erfolge."))
                .font(.system(size: 16, weight: .semibold, design: theme.fontDesign))
                .foregroundColor(theme.secondaryText)
                .multilineTextAlignment(.center)
                .opacity(appear ? 1 : 0)

            Spacer()
            
            if showsButton {
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
                .padding(.horizontal, 32)
                .padding(.bottom, 20)
                .scaleEffect(appear ? 1 : 0.8)
                .opacity(appear ? 1 : 0)
            }
        }
        .padding(.horizontal, 24)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    appear = true
                }
            }
        }
    }
}
