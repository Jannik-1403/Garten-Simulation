import SwiftUI

// MARK: - Mental Quiz Screen

struct MentalAssessmentQuizView: View {
    @EnvironmentObject var assessmentStore: AssessmentStore
    @EnvironmentObject var settings: SettingsStore
    @Environment(\.dismiss) private var dismiss

    @State private var currentIndex: Int = 0
    @State private var shuffledAnswers: [MentalAnswer] = []
    @State private var selectedAnswers: [Int: MentalAnswer] = [:]
    @State private var selectedAnswerID: Int? = nil
    @State private var showResult = false
    @State private var cardOffset: CGFloat = 0
    @State private var cardOpacity: Double = 1.0

    private let questions = MentalQuiz.questions

    private var currentQuestion: MentalQuestion { questions[currentIndex] }
    private var progress: Double { Double(currentIndex) / Double(questions.count) }
    private var isLastQuestion: Bool { currentIndex == questions.count - 1 }

    var body: some View {
        ZStack {
            Color.appHintergrund.ignoresSafeArea()

            if showResult {
                MentalResultView(
                    result: assessmentStore.mentalResult!,
                    onRetake: {
                        assessmentStore.resetMentalResult()
                        resetQuiz()
                    }
                )
                .environmentObject(settings)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .opacity
                ))
            } else {
                mentalQuizBody
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .opacity
                    ))
            }
        }
        .navigationBarHidden(showResult)
        .navigationBarBackButtonHidden(true)
        .navigationTitle(settings.localizedString(for: HabitCategory.mental.localizationKey))
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

    private var mentalQuizBody: some View {
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

                // 3D Progress Bar — lila
                GeometryReader { geo in
                    ZStack(alignment: .bottomLeading) {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Color.secondary.opacity(0.18))
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Color.secondary.opacity(0.08))
                            .padding(.bottom, 4)
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Color(hex: "#7B2FBE"))
                            .frame(width: max(0, geo.size.width * progress))
                            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: currentIndex)
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Color.lilaPrimary)
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

            Text("\(currentIndex + 1) / \(questions.count)")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(.secondary)
                .padding(.top, 14)
                .padding(.bottom, 10)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    QuizQuestionCard(text: settings.localizedString(for: currentQuestion.textKey))
                        .padding(.horizontal, 24)
                        .padding(.top, 16)
                        .offset(x: cardOffset)
                        .opacity(cardOpacity)

                    VStack(spacing: 10) {
                        ForEach(shuffledAnswers) { answer in
                            QuizAnswerButton(
                                text: settings.localizedString(for: answer.textKey),
                                isSelected: selectedAnswerID == answer.id,
                                color: .lilaPrimary,
                                shadowColor: Color(hex: "#7B2FBE"),
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
                             ? settings.localizedString(for: "assessment.btn.result")
                             : settings.localizedString(for: "assessment.btn.next"))
                        Image(systemName: isLastQuestion ? "chart.bar.fill" : "arrow.right")
                    }
                }
                .buttonStyle(DuolingoButtonStyle(
                    size: .large,
                    backgroundColor: .lilaPrimary,
                    shadowColor: Color(hex: "#7B2FBE")
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

    private func selectAnswer(_ answer: MentalAnswer) {
        selectedAnswerID = answer.id
        selectedAnswers[currentQuestion.id] = answer
    }

    private func advance() {
        guard selectedAnswerID != nil else { return }
        if isLastQuestion {
            assessmentStore.submitMentalQuiz(answers: selectedAnswers)
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
// MARK: - Mental Result Screen

struct MentalResultView: View {
    let result: MentalAssessmentResult
    let onRetake: () -> Void

    @EnvironmentObject var settings: SettingsStore
    @Environment(\.dismiss) private var dismiss

    private var profile: MentalProfile { result.profile }

    private var rarityTag: String {
        switch profile {
        case .glaeserner:          return "mystic"
        case .getriebener:         return "epic"
        case .spiegel:             return "legendary"
        case .unerschuetterlicher: return "plant"
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
                            Image(HabitCategory.mental.assetName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 153, height: 153)
                        }

                        VStack(spacing: 6) {
                            Text(settings.localizedString(for: "assessment.result.youare"))
                                .font(.system(size: 13, weight: .black, design: .rounded))
                                .foregroundStyle(.secondary)
                                .textCase(.uppercase)
                                .tracking(1.5)

                            Text(settings.localizedString(for: profile.titleKey))
                                .font(.system(size: 30, weight: .black, design: .rounded))
                                .foregroundStyle(.primary)
                                
                        }
                    }

                    // Description Card
                    Text(settings.localizedString(for: profile.descKey))
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(.primary.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 24)
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
                        .padding(.horizontal, 20)

                    // Habits
                    ResultHabitsCard(
                        buildHabitsKey: profile.buildHabitsKey,
                        breakHabitsKey: profile.breakHabitsKey
                    )
                    .padding(.bottom, 6)

                    // Score Bars
                    MentalScoreBreakdownCard(result: result)
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

// MARK: - Mental Score Breakdown Card

struct MentalScoreBreakdownCard: View {
    let result: MentalAssessmentResult

    @EnvironmentObject var settings: SettingsStore
    @State private var animated = false

    // Theoretical display range across 15 questions
    private var resilienzNorm: Double { normalizedDisplay(result.rawResilienz, max: 44, min: -37) }
    private var fokusNorm: Double     { normalizedDisplay(result.rawFokus,     max: 45, min: -38) }
    private var egoNorm: Double       { normalizedDisplay(result.rawEgo,        max: 30, min: -37) }

    private func normalizedDisplay(_ value: Int, max maxVal: Int, min minVal: Int) -> Double {
        let range = Double(maxVal - minVal)
        let shifted = Double(value - minVal)
        return min(max(shifted / range, 0), 1)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(settings.localizedString(for: "assessment.result.breakdown"))
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .tracking(1)

            ScoreBar(
                label: settings.localizedString(for: "assessment.score.resilienz"),
                value: animated ? resilienzNorm : 0,
                color: Color(hex: "#FF6B6B"),
                rawValue: result.rawResilienz
            )
            ScoreBar(
                label: settings.localizedString(for: "assessment.score.fokus"),
                value: animated ? fokusNorm : 0,
                color: Color(hex: "#4FC3F7"),
                rawValue: result.rawFokus
            )
            ScoreBar(
                label: settings.localizedString(for: "assessment.score.ego"),
                value: animated ? egoNorm : 0,
                color: Color(hex: "#DA70D6"),
                rawValue: result.rawEgo
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
