import SwiftUI

struct QuizScreenshotView: View {
    let assessmentStore: AssessmentStore
    
    private func getQuizData() -> [(String, String, String, String)] {
        var data: [(String, String, String, String)] = []
        if let res = assessmentStore.financeResult {
            data.append((String(localized: "quiz.finance", defaultValue: "Finanzen"), NSLocalizedString(res.profile.titleKey, comment: ""), NSLocalizedString(res.profile.descKey, comment: ""), NSLocalizedString(res.profile.actionKey, comment: "")))
        }
        if let res = assessmentStore.mentalResult {
            data.append((String(localized: "quiz.mental", defaultValue: "Mental"), NSLocalizedString(res.profile.titleKey, comment: ""), NSLocalizedString(res.profile.descKey, comment: ""), NSLocalizedString(res.profile.actionKey, comment: "")))
        }
        if let res = assessmentStore.growthResult {
            data.append((String(localized: "quiz.growth", defaultValue: "Wachstum"), NSLocalizedString(res.profile.titleKey, comment: ""), NSLocalizedString(res.profile.descKey, comment: ""), NSLocalizedString(res.profile.actionKey, comment: "")))
        }
        if let res = assessmentStore.healthResult {
            data.append((String(localized: "quiz.health", defaultValue: "Gesundheit"), NSLocalizedString(res.profile.titleKey, comment: ""), NSLocalizedString(res.profile.descKey, comment: ""), NSLocalizedString(res.profile.actionKey, comment: "")))
        }
        if let res = assessmentStore.fitnessResult {
            data.append((String(localized: "quiz.fitness", defaultValue: "Fitness"), NSLocalizedString(res.profile.titleKey, comment: ""), NSLocalizedString(res.profile.descKey, comment: ""), NSLocalizedString(res.profile.actionKey, comment: "")))
        }
        if let res = assessmentStore.lifestyleResult {
            data.append((String(localized: "quiz.lifestyle", defaultValue: "Lifestyle"), NSLocalizedString(res.profile.titleKey, comment: ""), NSLocalizedString(res.profile.descKey, comment: ""), NSLocalizedString(res.profile.actionKey, comment: "")))
        }
        return data
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text(String(localized: "export.quiz.title", defaultValue: "Quiz Ergebnisse"))
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .padding(.bottom, 8)
            
            let completedQuizzes = getQuizData()
            
            if completedQuizzes.isEmpty {
                Text(String(localized: "export.no_data", defaultValue: "Keine Daten momentan drin."))
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
            } else {
                VStack(spacing: 20) {
                    ForEach(completedQuizzes, id: \.0) { quiz in
                        VStack(alignment: .leading, spacing: 12) {
                            Text(quiz.0) // Kategorie (z.B. Fitness)
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundStyle(.secondary)
                            
                            Text(quiz.1) // Profil Title
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.blauPrimary)
                                
                            Text(quiz.2) // Profil Beschreibung
                                .font(.system(size: 14, weight: .regular, design: .rounded))
                                .foregroundStyle(.primary)
                                .fixedSize(horizontal: false, vertical: true)
                                
                            VStack(alignment: .leading, spacing: 4) {
                                Text(String(localized: "export.quiz.action.title", defaultValue: "Was man verbessern kann:"))
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .foregroundStyle(Color.orange)
                                Text(quiz.3) // Action text
                                    .font(.system(size: 14, weight: .regular, design: .rounded))
                                    .foregroundStyle(.primary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(hex: "#F2F2F7"))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }
            }
        }
        .padding(32)
        .background(Color.white)
        // Fixed size for the screenshot to ensure it renders predictably
        .frame(width: 600)
    }
}
