import SwiftUI

// MARK: - Health Quiz Screen

struct HealthAssessmentQuizView: View {
    @EnvironmentObject var assessmentStore: AssessmentStore
    @EnvironmentObject var settings: SettingsStore
    @Environment(\.dismiss) private var dismiss

    @State private var currentIndex: Int = 0
    @State private var shuffledAnswers: [HealthAnswer] = []
    @State private var selectedAnswers: [Int: HealthAnswer] = [:]
    @State private var selectedAnswerID: Int? = nil
    @State private var showResult = false
    @State private var cardOffset: CGFloat = 0
    @State private var cardOpacity: Double = 1.0

    private let questions = HealthQuiz.questions

    private var currentQuestion: HealthQuestion { questions[currentIndex] }
    private var progress: Double { Double(currentIndex) / Double(questions.count) }
    private var isLastQuestion: Bool { currentIndex == questions.count - 1 }

    // Akzentfarben — Gesundheits-Rot
    private let accentTop    = Color(hex: "#E8513A")
    private let accentShadow = Color(hex: "#B33A25")

    var body: some View {
        ZStack {
            Color.appHintergrund.ignoresSafeArea()

            if showResult {
                HealthResultView(
                    result: assessmentStore.healthResult!,
                    onRetake: {
                        assessmentStore.resetHealthResult()
                        resetQuiz()
                    }
                )
                .environmentObject(settings)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .opacity
                ))
            } else {
                healthQuizBody
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .opacity
                    ))
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle(NSLocalizedString(HabitCategory.health.localizationKey, comment: ""))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if !showResult {
                    LiquidGlassDismissButton { dismiss() }
                }
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: showResult)
    }

    private var healthQuizBody: some View {
        VStack(spacing: 0) {

            // Progress Bar Row
            HStack(spacing: 16) {
                if currentIndex > 0 {
                    Button(action: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            currentIndex -= 1
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.primary)
                            .frame(width: 36, height: 36)
                            .background(Color(UIColor.systemBackground))
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.08), radius: 3, y: 2)
                    }
                    .transition(.asymmetric(insertion: .scale.combined(with: .opacity), removal: .scale.combined(with: .opacity)))
                } else {
                    Color.clear.frame(width: 36, height: 36)
                }

                // 3D Progress Bar — Gesundheits-Rot
                GeometryReader { geo in
                    ZStack(alignment: .bottomLeading) {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Color.secondary.opacity(0.18))
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Color.secondary.opacity(0.08))
                            .padding(.bottom, 4)
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(accentShadow)
                            .frame(width: max(0, geo.size.width * progress))
                            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: currentIndex)
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(accentTop)
                            .frame(width: max(0, geo.size.width * progress))
                            .padding(.bottom, 4)
                            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: currentIndex)
                    }
                }
                .frame(height: 18)
            }
            .frame(height: 36)
            .padding(.horizontal, 24)
            .padding(.top, 16)

            Text(verbatim: "\(currentIndex + 1) / \(questions.count)")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(.secondary)
                .padding(.top, 14)
                .padding(.bottom, 10)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    QuizQuestionCard(text: NSLocalizedString(currentQuestion.textKey, comment: ""))
                        .padding(.horizontal, 24)
                        .padding(.top, 16)
                        .offset(x: cardOffset)
                        .opacity(cardOpacity)

                    VStack(spacing: 10) {
                        ForEach(shuffledAnswers) { answer in
                            QuizAnswerButton(
                                text: NSLocalizedString(answer.textKey, comment: ""),
                                isSelected: selectedAnswerID == answer.id,
                                color: accentTop,
                                shadowColor: accentShadow,
                                action: { selectAnswer(answer) }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .offset(x: cardOffset)
                    .opacity(cardOpacity)
                    .onAppear {
                        if shuffledAnswers.isEmpty {
                            shuffledAnswers = currentQuestion.answers.shuffled()
                        }
                    }
                    .onChange(of: currentIndex) {
                        shuffledAnswers = currentQuestion.answers.shuffled()
                    }

                    Color.clear.frame(height: 100)
                }
            }

            VStack(spacing: 0) {
                Divider().opacity(0.3)
                Button(action: advance) {
                    HStack(spacing: 8) {
                        Text(isLastQuestion
                             ? String(localized: "assessment.btn.result")
                             : String(localized: "assessment.btn.next"))
                        Image(systemName: isLastQuestion ? "chart.bar.fill" : "arrow.right")
                    }
                }
                .buttonStyle(DuolingoButtonStyle(
                    size: .large,
                    backgroundColor: accentTop,
                    shadowColor: accentShadow
                ))
                .disabled(selectedAnswerID == nil)
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .animation(.easeInOut(duration: 0.2), value: selectedAnswerID)
            }
            .background(Color.appHintergrund)
        }
    }

    // MARK: - Logic

    private func selectAnswer(_ answer: HealthAnswer) {
        selectedAnswerID = answer.id
        selectedAnswers[currentQuestion.id] = answer
    }

    private func advance() {
        guard selectedAnswerID != nil else { return }
        if isLastQuestion {
            assessmentStore.submitHealthQuiz(answers: selectedAnswers)
            withAnimation { showResult = true }
        } else {
            animateToNext()
        }
    }

    private func animateToNext() {
        withAnimation(.easeIn(duration: 0.18)) {
            cardOffset = -30
            cardOpacity = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            currentIndex += 1
            selectedAnswerID = nil
            cardOffset = 40
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                cardOffset = 0
                cardOpacity = 1
            }
        }
    }

    private func resetQuiz() {
        currentIndex = 0
        selectedAnswers = [:]
        selectedAnswerID = nil
        showResult = false
    }
}

// MARK: - Health Result Screen

struct HealthResultView: View {
    let result: HealthAssessmentResult
    let onRetake: () -> Void

    @EnvironmentObject var settings: SettingsStore
    @Environment(\.dismiss) private var dismiss

    private var profile: HealthProfile { result.profile }

    private var rarityTag: String {
        switch profile {
        case .erschoepfer: return "mystic"
        case .vergifter:   return "epic"
        case .ignorant:    return "legendary"
        case .optimierer:  return "plant"
        }
    }

    var body: some View {
        ZStack {
            Color.appHintergrund
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {

                    // Profile Icon + Label
                    VStack(spacing: 16) {
                        Item3DButton(
                            farbe: Color(hex: profile.color),
                            sekundaerFarbe: Color(hex: profile.color).darker(),
                            groesse: 96,
                            iconSkalierung: 1.6,
                            aktion: {
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            }
                        ) {
                            Image(HabitCategory.health.assetName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 153, height: 153)
                        }

                        VStack(spacing: 6) {
                            Text(String(localized: "assessment.result.youare"))
                                .font(.system(size: 13, weight: .black, design: .rounded))
                                .foregroundStyle(.secondary)
                                .textCase(.uppercase)
                                .tracking(1.5)

                            Text(NSLocalizedString(profile.titleKey, comment: ""))
                                .font(.system(size: 30, weight: .black, design: .rounded))
                                .foregroundStyle(.primary)
                                
                        }
                    }

                                        // Reality Check Description
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.title3)
                                .foregroundColor(.red)
                            Text(String(localized: "assessment.roadmap.reality_check", defaultValue: "Reality Check"))
                                .font(.headline)
                                .foregroundColor(.red)
                            Spacer()
                        }
                        
                        Text(String(localized: "assessment.roadmap.tough_love", defaultValue: "Die harte Wahrheit:"))
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(AppColors.color(for: profile.color))
                        
                        Text(String(localized: String.LocalizationValue(result.worstParameterTextKey)))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.red.opacity(0.3), lineWidth: 1)
                    )
                    .padding(.horizontal, 20)
                    .padding(.bottom, 6)

                    // Dynamic Insights
                    DynamicAssessmentInsightsView(
                        category: .health,
                        color: AppColors.color(for: profile.color)
                    )
                    .padding(.bottom, 6)

                    // Score Bars
                    HealthScoreBreakdownCard(result: result)
                        .padding(.horizontal, 20)

                    AssessmentRetakeButton(action: onRetake)
                        .environmentObject(settings)

                    Color.clear.frame(height: 40)
                }
            }
        }
        .assessmentDismissToolbar { dismiss() }
    }
}

// MARK: - Health Score Breakdown Card

struct HealthScoreBreakdownCard: View {
    let result: HealthAssessmentResult

    @EnvironmentObject var settings: SettingsStore
    @State private var animated = false

    // Display-Normalisierung über 15 Fragen
    // regeneration: theoretisch max ≈ +22 / min ≈ -34
    // kraftstoff:   theoretisch max ≈ +23 / min ≈ -37
    // prävention:   theoretisch max ≈ +23 / min ≈ -38
    private var regenerationNorm: Double { normalizedDisplay(result.rawRegeneration, max: 22, min: -34) }
    private var kraftstoffNorm:   Double { normalizedDisplay(result.rawKraftstoff,   max: 23, min: -37) }
    private var praeventionNorm:  Double { normalizedDisplay(result.rawPraevention,  max: 23, min: -38) }

    private func normalizedDisplay(_ value: Int, max maxVal: Int, min minVal: Int) -> Double {
        let range = Double(maxVal - minVal)
        let shifted = Double(value - minVal)
        return min(max(shifted / range, 0), 1)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(String(localized: "assessment.result.breakdown"))
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .tracking(1)

            ScoreBar(
                label: String(localized: "assessment.score.regeneration"),
                value: animated ? regenerationNorm : 0,
                color: Color(hex: "#5AC8FA"),
                rawValue: result.rawRegeneration
            )
            ScoreBar(
                label: String(localized: "assessment.score.kraftstoff"),
                value: animated ? kraftstoffNorm : 0,
                color: Color(hex: "#FF9500"),
                rawValue: result.rawKraftstoff
            )
            ScoreBar(
                label: String(localized: "assessment.score.praevention"),
                value: animated ? praeventionNorm : 0,
                color: Color(hex: "#E8513A"),
                rawValue: result.rawPraevention
            )
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: Color.black.opacity(0.18), radius: 0, y: 6)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.gray.opacity(0.15), lineWidth: 1)
        )
        .padding(.bottom, 6)
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2)) {
                animated = true
            }
        }
    }
}
