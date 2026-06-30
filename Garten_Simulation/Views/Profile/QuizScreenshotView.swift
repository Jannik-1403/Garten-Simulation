import SwiftUI

struct QuizScreenshotView: View {
    let assessmentStore: AssessmentStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text(String(localized: "export.quiz.title", defaultValue: "Quiz Ergebnisse"))
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .padding(.bottom, 8)
            
            let quizzes: [(String, String?)] = [
                (String(localized: "quiz.finance", defaultValue: "Finanzen"), assessmentStore.financeResult?.profile.rawValue),
                (String(localized: "quiz.mental", defaultValue: "Mental"), assessmentStore.mentalResult?.profile.rawValue),
                (String(localized: "quiz.growth", defaultValue: "Wachstum"), assessmentStore.growthResult?.profile.rawValue),
                (String(localized: "quiz.health", defaultValue: "Gesundheit"), assessmentStore.healthResult?.profile.rawValue),
                (String(localized: "quiz.fitness", defaultValue: "Fitness"), assessmentStore.fitnessResult?.profile.rawValue),
                (String(localized: "quiz.lifestyle", defaultValue: "Lifestyle"), assessmentStore.lifestyleResult?.profile.rawValue)
            ]
            
            let completedQuizzes = quizzes.compactMap { quiz -> (String, String)? in
                if let val = quiz.1 {
                    return (quiz.0, val)
                }
                return nil
            }
            
            if completedQuizzes.isEmpty {
                Text(String(localized: "export.no_data", defaultValue: "Keine Daten momentan drin."))
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(completedQuizzes, id: \.0) { quiz in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(quiz.0)
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundStyle(.secondary)
                            
                            Text(quiz.1)
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.blauPrimary)
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
