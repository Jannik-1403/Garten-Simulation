import SwiftUI
import DotLottie

// MARK: - Main Overlay
struct StreakIncreaseOverlayView: View {
    @Binding var isVisible: Bool
    var streak: Int
    @EnvironmentObject var streakStore: StreakStore
    @EnvironmentObject var settings: SettingsStore

    private var oldStreak: Int { max(0, streak - 1) }
    private let calendar = Calendar.current

    private var todayIndex: Int {
        let wd = calendar.component(.weekday, from: Date())
        var idx = wd - 2
        if idx < 0 { idx = 6 }
        return idx
    }

    // ── Phase state machines ──────────────────────────────────────────
    @State private var phase: AnimationPhase = .idle

    // Phase 1 — idle
    @State private var bgOpacity: Double = 0
    @State private var contentVisible = false
    @State private var pillVisible = true

    // Phase 2 — ignition
    @State private var shockwaveScale: CGFloat = 1.0
    @State private var shockwaveOpacity: Double = 0.9
    @State private var showLottie = false
    @State private var lottieScale: CGFloat = 0.3
    @State private var numberPopped = false

    // Phase 3 — reveal
    @State private var showParticles = false
    @State private var showSubtext = false
    @State private var showCalendar = false
    @State private var todaySlotFilled = false
    @State private var showFooter = false
    @State private var showMotivation = false
    @State private var motivationIndex = Int.random(in: 0..<10)

    // Phase 4 — loop
    @State private var breathing = false

    // Particles
    @State private var particleStates: [ParticleState] = []

    enum AnimationPhase {
        case idle, ignition, reveal, looping
    }

    var body: some View {
        if isVisible {
            GeometryReader { geo in
                ZStack {
                    // ── Background (fades in first) ─────────────────
                    Color.white.ignoresSafeArea()
                        .opacity(bgOpacity)

                    VStack(spacing: 0) {
                      if contentVisible {
                        Spacer()

                        // ── Central Icon Area ────────────────────────
                        ZStack {
                            // Shockwave ring
                            if phase != .idle {
                                Circle()
                                    .stroke(
                                        Color(hex: "#FFD700").opacity(0.6),
                                        lineWidth: 3
                                    )
                                    .frame(width: 80, height: 80)
                                    .scaleEffect(shockwaveScale)
                                    .opacity(shockwaveOpacity)
                            }

                            // Pill (idle state)
                            if pillVisible && !showLottie {
                                RoundedRectangle(cornerRadius: 28, style: .continuous)
                                    .fill(Color(hex: "#FFF3D0"))
                                    .frame(width: 72, height: 44)
                            }

                            // Lottie Flame (after morph)
                            if showLottie {
                                DotLottieAnimation(
                                    webURL: "https://lottie.host/b8842b8d-669c-45fe-a8cb-92cbd20903dc/9KcW3VdzUV.lottie",
                                    config: .init(autoplay: true, loop: true, speed: 0.8)
                                )
                                .view()
                                .frame(width: 200, height: 200)
                                .scaleEffect(lottieScale)
                                .scaleEffect(breathing ? 1.04 : 1.0)
                                .animation(
                                    breathing
                                        ? .easeInOut(duration: 1.8).repeatForever(autoreverses: true)
                                        : .default,
                                    value: breathing
                                )
                                .allowsHitTesting(false)
                                .transition(.scale.combined(with: .opacity))
                            }

                            // Particles
                            if showParticles {
                                ForEach(particleStates) { p in
                                    StreakParticle(particle: p)
                                }
                            }
                        }
                        .frame(width: 200, height: 200)

                        // ── Number (hard cut, no fade) ───────────────
                        Text("\(numberPopped ? streak : oldStreak)")
                            .font(.system(size: 64, weight: .black, design: .rounded))
                            .foregroundColor(
                                numberPopped
                                    ? Color(hex: "#FF4B2B")
                                    : Color(hex: "#D3D3D3")
                            )
                            .modifier(PopEffectModifier(trigger: numberPopped))
                            .padding(.top, 4)

                        // ── Subtext ──────────────────────────────────
                        if showSubtext {
                            Text(settings.appLanguage == "de" ? "Tage Streak" : "day streak")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundStyle(Color(hex: "#FF4B2B"))
                                .transition(.opacity)
                                .padding(.top, 4)
                        }

                        Spacer().frame(height: 40)

                        // ── Weekly Overview (3D Styled) ──────────────
                        if showCalendar {
                            weeklyOverview
                                .transition(.opacity)
                                .padding(.horizontal, 16)
                        }

                        // ── Motivationstext ──────────────────────────
                        if showMotivation {
                            Text(motivationText)
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                                .padding(.top, 16)
                                .transition(.opacity)
                        }

                        Spacer()

                        // ── Footer ───────────────────────────────────
                        if showFooter {
                            VStack(spacing: 16) {
                                Button {
                                    FeedbackManager.shared.playTap()
                                    withAnimation(.easeOut(duration: 0.25)) {
                                        isVisible = false
                                    }
                                } label: {
                                    Text(settings.appLanguage == "de" ? "WEITER" : "CONTINUE")
                                }
                                .buttonStyle(DuolingoButtonStyle(
                                    size: .large,
                                    fillWidth: true,
                                    backgroundColor: .blauPrimary,
                                    shadowColor: .blauSecondary,
                                    foregroundColor: .white
                                ))
                            }
                            .padding(.horizontal, 32)
                            .padding(.bottom, geo.safeAreaInsets.bottom + 24)
                            .transition(.opacity)
                        }
                    }
                  } // end contentVisible
                }
                .onAppear {
                    runSequence()
                }
            }
            .ignoresSafeArea()
            .zIndex(9999)
        }
    }

    // MARK: - Weekly Overview (3D orange cards from before)
    private var weeklyOverview: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                let labels = settings.appLanguage == "de"
                    ? ["Mo","Di","Mi","Do","Fr","Sa","So"]
                    : ["Mo","Tu","We","Th","Fr","Sa","Su"]

                ForEach(0..<7, id: \.self) { index in
                    let isToday = index == todayIndex
                    let completed = isToday ? todaySlotFilled : isDayCompleted(index)

                    VStack(spacing: 8) {
                        Text(labels[index])
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.white.opacity(0.8))

                        ZStack {
                            // 3D-Schatten (nur wenn completed)
                            if completed {
                                Circle()
                                    .fill(Color.white.opacity(0.3))
                                    .frame(width: 38, height: 38)
                                    .offset(y: 3)
                            }

                            // Haupt-Bubble
                            Circle()
                                .fill(completed ? Color.white : Color.white.opacity(0.15))
                                .frame(width: 38, height: 38)
                                .overlay(
                                    Circle()
                                        .stroke(completed ? Color.white.opacity(0.5) : .clear, lineWidth: 1.5)
                                )

                            if completed {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(Color.orangePrimary)
                                    .scaleEffect(isToday && todaySlotFilled ? 1.0 : (isToday ? 0.0 : 1.0))
                                    .animation(
                                        .spring(response: 0.35, dampingFraction: 0.45),
                                        value: todaySlotFilled
                                    )
                            }

                            // Heutiger Tag: leuchtender Rand wenn noch nicht gefüllt
                            if isToday && !completed {
                                Circle()
                                    .stroke(Color.white, lineWidth: 2)
                                    .frame(width: 38, height: 38)
                            }
                        }
                        .frame(width: 38, height: 41)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 16)
        }
        .background(
            ZStack {
                // 3D Shadow
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.orangeSecondary)
                    .offset(y: 4)

                // Main Orange Surface
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [.orangePrimary, .orangePrimary.opacity(0.9)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.2), lineWidth: 1.5)
        )
    }

    // MARK: - Sequence Orchestrator
    private func runSequence() {
        // ── Phase 0: White opens up ──────────────────────────────
        withAnimation(.easeOut(duration: 0.3)) {
            bgOpacity = 1
        }

        // ── Phase 1: Content appears after white is open ─────────
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.easeOut(duration: 0.2)) {
                contentVisible = true
            }
            phase = .idle
        }

        // ── Phase 2: Ignition ────────────────────────────────────
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.85) {
            phase = .ignition

            // Shockwave: expand + fade
            withAnimation(.easeOut(duration: 0.4)) {
                shockwaveScale = 4.5
                shockwaveOpacity = 0
            }

            // Morph pill → Lottie flame
            withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) {
                pillVisible = false
                // Small delay within the sequence to ensure layout is ready
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    showLottie = true
                    lottieScale = 1.0
                }
            }


            // Number: HARD CUT — no animation wrapper on the state change.
            // The value + color switch instantly. Only the scale pop is animated.
            numberPopped = true
            FeedbackManager.shared.playSuccess()
        }

        // ── Phase 3: Reveal ──────────────────────────────────────
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.25) {
            phase = .reveal

            // Particles
            spawnParticles()
            showParticles = true

            // Subtext fade
            withAnimation(.easeOut(duration: 0.35)) {
                showSubtext = true
            }

            // Calendar (3D orange card)
            withAnimation(.easeOut(duration: 0.4).delay(0.15)) {
                showCalendar = true
            }

            // Today slot fill with bounce
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.45)) {
                    todaySlotFilled = true
                }
                FeedbackManager.shared.playTick()
            }

            // Motivation + Footer
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                withAnimation(.easeOut(duration: 0.35)) {
                    showMotivation = true
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                withAnimation(.easeOut(duration: 0.35)) {
                    showFooter = true
                }
            }
        }

        // ── Phase 4: Loop ────────────────────────────────────────
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.3) {
            phase = .looping
            breathing = true
        }
    }

    // MARK: - Particle Spawner
    private func spawnParticles() {
        particleStates = (0..<8).map { i in
            let angle = Double(i) * (360.0 / 8.0) + Double.random(in: -15...15)
            let rad = angle * .pi / 180.0
            let dist = CGFloat.random(in: 50...100)
            return ParticleState(
                id: i,
                targetX: cos(rad) * dist,
                targetY: sin(rad) * dist - 20,
                rotation: Double.random(in: -45...45),
                isCircle: i % 3 == 0,
                color: i % 2 == 0 ? Color(hex: "#FFB800") : Color(hex: "#FF6B00")
            )
        }
    }

    // MARK: - Motivational Quotes
    private static let motivationsDe = [
        "Bleib am Ball!",
        "Jeden Tag ein kleines Stück besser.",
        "Dranbleiben zahlt sich aus!",
        "Du bist stärker als du denkst.",
        "Unkraut wächst nicht in gepflegten Gärten.",
        "Routine schlägt Motivation.",
        "Kleine Schritte, große Wirkung.",
        "Dein Garten wächst mit dir!",
        "Konsistenz ist der Schlüssel.",
        "Heute ist ein guter Tag für Fortschritt."
    ]

    private static let motivationsEn = [
        "Keep it up!",
        "A little better every single day.",
        "Consistency pays off!",
        "You are stronger than you think.",
        "Weeds don't grow in well-kept gardens.",
        "Routine beats motivation.",
        "Small steps, big impact.",
        "Your garden grows with you!",
        "Consistency is key.",
        "Today is a great day for progress."
    ]

    private var motivationText: String {
        let list = settings.appLanguage == "de"
            ? Self.motivationsDe
            : Self.motivationsEn
        return list[motivationIndex % list.count]
    }

    // MARK: - Helper
    private func isDayCompleted(_ index: Int) -> Bool {
        let today = calendar.startOfDay(for: Date())
        let weekday = calendar.component(.weekday, from: today)
        var norm = weekday - 2
        if norm < 0 { norm = 6 }
        let diff = norm - index
        guard let target = calendar.date(byAdding: .day, value: -diff, to: today) else { return false }
        return streakStore.isDateCompleted(target)
    }
}

// MARK: - Pop Effect Modifier
struct PopEffectModifier: ViewModifier {
    let trigger: Bool
    @State private var scale: CGFloat = 1.0

    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .onChange(of: trigger) {
                if trigger {
                    // Instant snap to 118% (same frame as hard cut)
                    scale = 1.18
                    // Spring bounce back: overshoot past 100%, settle at 100%
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.3)) {
                        scale = 1.0
                    }
                }
            }
    }
}

// MARK: - Particle Model & View
struct ParticleState: Identifiable {
    let id: Int
    let targetX: CGFloat
    let targetY: CGFloat
    let rotation: Double
    let isCircle: Bool
    let color: Color
}

struct StreakParticle: View {
    let particle: ParticleState

    @State private var offset: CGSize = .zero
    @State private var opacity: Double = 1
    @State private var scale: CGFloat = 1

    var body: some View {
        Group {
            if particle.isCircle {
                Circle()
                    .fill(particle.color)
                    .frame(width: 6, height: 6)
            } else {
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(particle.color)
                    .frame(width: 4, height: 12)
                    .rotationEffect(.degrees(particle.rotation))
            }
        }
        .scaleEffect(scale)
        .offset(offset)
        .opacity(opacity)
        .onAppear {
            withAnimation(.easeOut(duration: 0.55)) {
                offset = CGSize(width: particle.targetX, height: particle.targetY)
                opacity = 0
                scale = 0.3
            }
        }
    }
}

// MARK: - Preview
#Preview {
    StreakIncreaseOverlayView(isVisible: .constant(true), streak: 7)
        .environmentObject(StreakStore())
        .environmentObject(SettingsStore())
}
