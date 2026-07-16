import SwiftUI

// MARK: - Entry Point: Category Selector Button (für ProfilView)

struct AssessmentEntryButton: View {
    @EnvironmentObject var assessmentStore: AssessmentStore
    @EnvironmentObject var settings: SettingsStore
    @State private var showAssessment = false

    var body: some View {
        DuolingoCard(action: { showAssessment = true }) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color(hex: "#FFD700").opacity(0.15))
                        .frame(width: 52, height: 52)
                    Image(systemName: "brain.filled.head.profile")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Color(hex: "#FFD700"))
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(String(localized: "assessment.entry.title"))
                        .font(.system(size: 15, weight: .black, design: .rounded))
                        .foregroundStyle(.primary)

                    if let result = assessmentStore.financeResult {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(.green)
                            Text(NSLocalizedString(result.profile.titleKey, comment: ""))
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        Text(String(localized: "assessment.entry.subtitle"))
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.quaternary)
            }
        }
        .fullScreenCover(isPresented: $showAssessment) {
            AssessmentCategoryView()
                .environmentObject(assessmentStore)
                .environmentObject(settings)
        }
    }
}

// MARK: - Category Selection Screen

struct AssessmentCategoryView: View {
    @EnvironmentObject var assessmentStore: AssessmentStore
    @EnvironmentObject var settings: SettingsStore
    @Environment(\.dismiss) private var dismiss

    @State private var selectedCategory: HabitCategory? = nil
    @State private var resultCategory: HabitCategory? = nil

    // Definiert welche Kategorien bereits Quizzes haben
    private let available: Set<HabitCategory> = [.finance, .mental, .growth, .health, .fitness, .lifestyle]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appHintergrund.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {

                        // Header
                        VStack(spacing: 8) {
                            Text(String(localized: "assessment.category.headline"))
                                .font(.system(size: 28, weight: .black, design: .rounded))
                                .multilineTextAlignment(.center)

                            Text(String(localized: "assessment.category.sub.15q", defaultValue: "15 Fragen. 5 Minuten. Keine Selbsttäuschung."))
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 12)
                        .padding(.horizontal, 24)

                        // Category Grid
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                            ForEach(HabitCategory.allCases.filter { $0 != .seeds }, id: \.self) { category in
                                Category3DCard(
                                    category: category,
                                    isAvailable: available.contains(category),
                                    hasResult: resultExists(for: category)
                                ) {
                                    guard available.contains(category) else { return }
                                    if resultExists(for: category) {
                                        // Direkt Ergebnis zeigen
                                        resultCategory = category
                                    } else {
                                        selectedCategory = category
                                    }
                                }
                                .environmentObject(settings)
                            }
                        }
                        .padding(.horizontal, 20)

                        Color.clear.frame(height: 40)
                    }
                }
            }
            .navigationTitle(String(localized: "assessment.nav.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    LiquidGlassDismissButton { dismiss() }
                }
            }
            .navigationDestination(item: $selectedCategory) { category in
                quizView(for: category)
            }
            .navigationDestination(item: $resultCategory) { category in
                resultView(for: category)
            }
        }
    }

    @ViewBuilder
    private func quizView(for category: HabitCategory) -> some View {
        switch category {
        case .finance:
            FinanceAssessmentQuizView()
                .environmentObject(assessmentStore)
                .environmentObject(settings)
        case .mental:
            MentalAssessmentQuizView()
                .environmentObject(assessmentStore)
                .environmentObject(settings)
        case .growth:
            GrowthAssessmentQuizView()
                .environmentObject(assessmentStore)
                .environmentObject(settings)
        case .health:
            HealthAssessmentQuizView()
                .environmentObject(assessmentStore)
                .environmentObject(settings)
        case .fitness:
            FitnessAssessmentQuizView()
                .environmentObject(assessmentStore)
                .environmentObject(settings)
        case .lifestyle:
            LifestyleAssessmentQuizView()
                .environmentObject(assessmentStore)
                .environmentObject(settings)
        case .seeds:
            EmptyView()
        }
    }

    @ViewBuilder
    private func resultView(for category: HabitCategory) -> some View {
        switch category {
        case .finance:
            if let r = assessmentStore.financeResult {
                FinanceResultView(result: r, onRetake: { assessmentStore.resetFinanceResult(); resultCategory = nil; selectedCategory = .finance })
                    .environmentObject(settings)
            }
        case .mental:

            if let r = assessmentStore.mentalResult {
                MentalResultView(result: r, onRetake: { assessmentStore.resetMentalResult(); resultCategory = nil; selectedCategory = .mental })
                    .environmentObject(settings)
            }
        case .growth:
            if let r = assessmentStore.growthResult {
                GrowthResultView(result: r, onRetake: { assessmentStore.resetGrowthResult(); resultCategory = nil; selectedCategory = .growth })
                    .environmentObject(settings)
            }
        case .health:
            if let r = assessmentStore.healthResult {
                HealthResultView(result: r, onRetake: { assessmentStore.resetHealthResult(); resultCategory = nil; selectedCategory = .health })
                    .environmentObject(settings)
            }
        case .fitness:
            if let r = assessmentStore.fitnessResult {
                FitnessResultView(result: r, onRetake: { assessmentStore.resetFitnessResult(); resultCategory = nil; selectedCategory = .fitness })
                    .environmentObject(settings)
            }
        case .lifestyle:
            if let r = assessmentStore.lifestyleResult {
                LifestyleResultView(result: r, onRetake: { assessmentStore.resetLifestyleResult(); resultCategory = nil; selectedCategory = .lifestyle })
                    .environmentObject(settings)
            }
        case .seeds:
            EmptyView()
        }
    }

    private func resultExists(for category: HabitCategory) -> Bool {
        switch category {
        case .finance: return assessmentStore.financeResult != nil
        case .mental:  return assessmentStore.mentalResult  != nil
        case .growth:  return assessmentStore.growthResult  != nil
        case .health:  return assessmentStore.healthResult  != nil
        case .fitness: return assessmentStore.fitnessResult != nil
        case .lifestyle: return assessmentStore.lifestyleResult != nil
        case .seeds: return false
        }
    }
}

// MARK: - Category 3D Card

struct Category3DCardStyle: ButtonStyle {
    let isAvailable: Bool
    @AppStorage("isHapticEnabled") private var isHapticEnabled: Bool = true
    private let shadowDepth: CGFloat = 6

    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed

        configuration.label
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(isAvailable ? Color.white : Color(hex: "#F2F2F7"))
                }
            )
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(isAvailable ? Color.secondary.opacity(0.18) : Color.secondary.opacity(0.08))
                    .offset(y: isPressed ? 0 : shadowDepth)
            )
            .offset(y: isPressed ? shadowDepth : 0)
            .animation(isPressed ? nil : .spring(response: 0.15, dampingFraction: 0.6), value: isPressed)
            .sensoryFeedback(trigger: isPressed) { _, newValue in
                (isHapticEnabled && newValue) ? .impact(flexibility: .soft, intensity: 0.8) : nil
            }
    }
}

struct Category3DCard: View {
    let category: HabitCategory
    let isAvailable: Bool
    let hasResult: Bool
    let action: () -> Void
    @EnvironmentObject var settings: SettingsStore
    private let shadowDepth: CGFloat = 6

    var body: some View {
        Button(action: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                action()
            }
        }) {
            VStack(spacing: 14) {
                Color.clear
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(category.assetName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 150)
                            .opacity(isAvailable ? 1.0 : 0.4)
                            .saturation(isAvailable ? 1.0 : 0.0)
                    )

                Text(NSLocalizedString(category.localizationKey, comment: ""))
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    .foregroundStyle(isAvailable ? .primary : .tertiary)

                if hasResult {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(.green)
                } else if !isAvailable {
                    Text(String(localized: "assessment.soon"))
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(.quaternary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.secondary.opacity(0.1), in: Capsule())
                } else {
                    // Platzhalter für gleiche Höhe
                    Color.clear.frame(height: 22)
                }
            }
            .padding(.vertical, 24)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(Category3DCardStyle(isAvailable: isAvailable))
        .padding(.bottom, shadowDepth)
        .disabled(!isAvailable)
    }
}

// MARK: - Finance Quiz Screen

struct FinanceAssessmentQuizView: View {
    @EnvironmentObject var assessmentStore: AssessmentStore
    @EnvironmentObject var settings: SettingsStore
    @Environment(\.dismiss) private var dismiss

    @State private var currentIndex: Int = 0
    @State private var shuffledAnswers: [AssessmentAnswer] = []
    @State private var selectedAnswers: [Int: AssessmentAnswer] = [:]   // questionId → Antwort
    @State private var selectedAnswerID: Int? = nil
    @State private var showResult = false
    @State private var cardOffset: CGFloat = 0
    @State private var cardOpacity: Double = 1.0

    private let questions = FinanceQuiz.questions

    private var currentQuestion: AssessmentQuestion {
        questions[currentIndex]
    }

    private var progress: Double {
        Double(currentIndex) / Double(questions.count)
    }

    var body: some View {
        ZStack {
            Color.appHintergrund.ignoresSafeArea()

            if showResult {
                FinanceResultView(
                    result: assessmentStore.financeResult!,
                    onRetake: {
                        assessmentStore.resetFinanceResult()
                        resetQuiz()
                    }
                )
                .environmentObject(settings)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .opacity
                ))
            } else {
                quizBody
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .opacity
                    ))
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle(NSLocalizedString(HabitCategory.finance.localizationKey, comment: ""))
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

    private var quizBody: some View {
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
                    // Placeholder spacing to keep the bar slightly right? User wanted arrow to push it. 
                    // No placeholder means it expands to the left. The user said: 
                    // "Machst du den Pfeil hin dass die Bar mehr nach rechts geschoben wird"
                    // If we add an empty placeholder, the bar is always shifted:
                    Color.clear.frame(width: 36, height: 36)
                }

                // Progress Bar 3D
                GeometryReader { geo in
                    ZStack(alignment: .bottomLeading) {
                        // Track Shadow Layer
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Color.secondary.opacity(0.18))
                        
                        // Track Top Layer
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Color.secondary.opacity(0.08))
                            .padding(.bottom, 4)

                        // Fill Shadow Layer
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Color(hex: "#007A99")) // Darker Coin Blue
                            .frame(width: max(0, geo.size.width * progress))
                            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: currentIndex)

                        // Fill Top Layer
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Color.coinBlue)
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

            // Step Counter
            Text(verbatim: "\(currentIndex + 1) / \(questions.count)")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(.secondary)
                .padding(.top, 14)
                .padding(.bottom, 10)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {



                    // Question Card
                    QuizQuestionCard(text: NSLocalizedString(currentQuestion.textKey, comment: ""))
                        .padding(.horizontal, 24)
                        .padding(.top, 16)
                        .offset(x: cardOffset)
                        .opacity(cardOpacity)

                    // Answer Options — 3D Bars
                    VStack(spacing: 10) {
                        ForEach(shuffledAnswers) { answer in
                            QuizAnswerButton(
                                text: NSLocalizedString(answer.textKey, comment: ""),
                                isSelected: selectedAnswerID == answer.id,
                                color: .coinBlue,
                                shadowColor: Color(hex: "#007A99"),
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

            // Next / Submit Button
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
                    backgroundColor: .coinBlue,
                    shadowColor: Color(hex: "#007A99")
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

    private var isLastQuestion: Bool {
        currentIndex == questions.count - 1
    }

    private func selectAnswer(_ answer: AssessmentAnswer) {
        selectedAnswerID = answer.id
        selectedAnswers[currentQuestion.id] = answer
    }

    private func advance() {
        guard selectedAnswerID != nil else { return }

        if isLastQuestion {
            assessmentStore.submitFinanceQuiz(answers: selectedAnswers)
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

// MARK: - Answer 3D Bar

/// Eigener 3D-Bar für Antwort-Optionen mit dynamischer Höhe.
/// Gleiche visuelle Sprache wie Item3DButton, aber ohne fixed-height constraint.
struct QuizAnswerButtonStyle: ButtonStyle {
    let isSelected: Bool
    let color: Color
    let shadowBaseColor: Color
    @AppStorage("isHapticEnabled") private var isHapticEnabled: Bool = true
    private let shadowDepth: CGFloat = 4
    private let cornerRadius: CGFloat = 12

    private var topColor: Color {
        isSelected ? color : Color(UIColor.systemBackground)
    }

    private var borderColor: Color {
        isSelected ? shadowBaseColor : Color.gray.opacity(0.15)
    }

    private var shadowColor: Color {
        isSelected ? shadowBaseColor.opacity(0.8) : Color.gray.opacity(0.3)
    }

    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed

        configuration.label
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(topColor)
                }
                .shadow(
                    color: shadowColor,
                    radius: 0,
                    y: isPressed ? 0 : shadowDepth
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(borderColor, lineWidth: isSelected ? 2 : 1)
            )
            .offset(y: isPressed ? shadowDepth : 0)
            .animation(isPressed ? nil : .spring(response: 0.15, dampingFraction: 0.6), value: isPressed)
            .sensoryFeedback(trigger: isPressed) { _, newValue in
                (isHapticEnabled && newValue) ? .impact(flexibility: .soft, intensity: 0.75) : nil
            }
    }
}

struct QuizAnswerButton: View {
    let text: String
    let isSelected: Bool
    let color: Color
    let shadowColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                action()
            }
        }) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .strokeBorder(
                            isSelected ? .white.opacity(0.6) : Color.gray.opacity(0.3),
                            lineWidth: 2
                        )
                        .frame(width: 22, height: 22)
                    if isSelected {
                        Circle()
                            .fill(.white)
                            .frame(width: 12, height: 12)
                    }
                }

                Text(text)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(isSelected ? .white : .primary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
            .contentShape(Rectangle())
        }
        .buttonStyle(QuizAnswerButtonStyle(isSelected: isSelected, color: color, shadowBaseColor: shadowColor))
        .padding(.bottom, 4)
    }
}

// MARK: - Quiz Components


struct QuizQuestionCard: View {
    let text: String

    var body: some View {
        ZStack(alignment: .center) {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: Color.gray.opacity(0.3), radius: 0, y: 4)
            
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.gray.opacity(0.15), lineWidth: 1)

            Text(text)
                .font(.system(size: 20, weight: .black, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundStyle(.primary)
                .padding(.horizontal, 24)
                .padding(.vertical, 28)
        }
    }
}

// MARK: - Result Screen

struct FinanceResultView: View {
    let result: AssessmentResult
    let onRetake: () -> Void

    @EnvironmentObject var settings: SettingsStore
    @Environment(\.dismiss) private var dismiss

    @State private var barAnimated = false

    private var profile: FinanceProfile { result.profile }

    private var rarityTag: String {
        switch profile {
        case .verdraenger:    return "mystic"
        case .prokrastinator: return "legendary"
        case .impulsiver:     return "epic"
        case .kontrolleur:    return "plant"
        }
    }

    var body: some View {
        ZStack {
            Color.appHintergrund
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {

                    // Profile Icon + Title
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
                            Image(HabitCategory.finance.assetName)
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

                    // Detailed Analysis
                    DetailedAssessmentAnalysisView(
                        result: result,
                        color: AppColors.color(for: profile.color)
                    )
                    .padding(.bottom, 6)

                    // Dynamic Insights
                    DynamicAssessmentInsightsView(
                        category: .finance,
                        color: AppColors.color(for: profile.color)
                    )
                    .padding(.bottom, 6)

                    // Score Bars
                    ScoreBreakdownCard(result: result)
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

// MARK: - Score Breakdown Card

struct ScoreBreakdownCard: View {
    let result: AssessmentResult

    @EnvironmentObject var settings: SettingsStore
    @State private var animated = false

    // Display-Normalisierung über 15 Fragen (max/min aus Matrix)
    private var kontrolleNorm: Double  { normalizedDisplay(result.rawKontrolle,    max: 30, min: -25) }
    private var entscheidungNorm: Double { normalizedDisplay(result.rawEntscheidung, max: 23, min: -21) }
    private var risikoNorm: Double     { normalizedDisplay(result.rawRisiko,         max: 20, min: -20) }

    /// Skaliert einen Rohwert auf [0,1] für die visuelle Darstellung.
    private func normalizedDisplay(_ value: Int, max: Int, min: Int) -> Double {
        let range = Double(max - min)
        let shifted = Double(value - min)
        return shifted / range
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(String(localized: "assessment.result.breakdown"))
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .tracking(1)

            ScoreBar(
                label: String(localized: "assessment.score.kontrolle"),
                value: animated ? kontrolleNorm : 0,
                color: Color(hex: "#4FC3F7"),
                rawValue: result.rawKontrolle
            )
            ScoreBar(
                label: String(localized: "assessment.score.entscheidung"),
                value: animated ? entscheidungNorm : 0,
                color: Color(hex: "#81C784"),
                rawValue: result.rawEntscheidung
            )
            ScoreBar(
                label: String(localized: "assessment.score.risiko"),
                value: animated ? risikoNorm : 0,
                color: Color(hex: "#FFB74D"),
                rawValue: result.rawRisiko
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

struct ScoreBar: View {
    let label: String
    let value: Double       // 0.0 ... 1.0 (normalisiert für Anzeige)
    let color: Color
    let rawValue: Int

    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Text(label)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(.primary)
                Spacer()
                Text(rawValue >= 0 ? "+\(rawValue)" : "\(rawValue)")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(rawValue >= 0 ? .green : .red)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    // Track
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(Color.secondary.opacity(0.12))
                        .frame(height: 10)

                    // Fill
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(color)
                        .frame(width: max(6, geo.size.width * value), height: 10)
                }
            }
            .frame(height: 10)
        }
    }
}
