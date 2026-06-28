import Foundation

// MARK: - Growth Assessment Profile

enum GrowthProfile: String, Codable, CaseIterable {
    case level1
    case level2
    case level3
    case level4

    var titleKey: String { "assessment.growth.profile.\(rawValue).title" }
    var descKey:  String { "assessment.growth.profile.\(rawValue).desc" }
    var actionKey: String { "assessment.growth.profile.\(rawValue).action" }
    var buildHabitsKey: String { "assessment.growth.profile.\(rawValue).build" }
    var breakHabitsKey: String { "assessment.growth.profile.\(rawValue).break" }

    var icon: String {
        switch self {
        case .level1: return "exclamationmark.triangle.fill"
        case .level2: return "arrow.up.right.circle.fill"
        case .level3: return "star.fill"
        case .level4: return "crown.fill"
        }
    }

    var color: String {
        switch self {
        case .level1: return "#FF6B6B"
        case .level2: return "#FFB347"
        case .level3: return "#4FC3F7"
        case .level4: return "#4CAF50"
        }
    }
}
// MARK: - Growth Score Deltas



// MARK: - Growth Answer



// MARK: - Growth Question



// MARK: - Growth Raw Score



// MARK: - Growth Assessment Result

struct GrowthAssessmentResult: Codable {
    let profile: GrowthProfile
    let score: Int
    let date: Date
}

// MARK: - Growth Scoring Engine

enum GrowthScoringEngine {
    static func computeProfile(from score: Int) -> GrowthProfile {
        switch score {
        case ..<(-9): return .level1
        case (-9)...5: return .level2
        case 6...20: return .level3
        default: return .level4
        }
    }
}

// MARK: - Growth Quiz Data

struct GrowthQuiz {
    static let questions: [AssessmentQuestion] = [
        
        // F1: Der Motivationstod
        AssessmentQuestion(id: 1, textKey: "assessment.growth.q1", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.growth.q1.a", delta: -2),
            AssessmentAnswer(id: 1, textKey: "assessment.growth.q1.b", delta: -1),
            AssessmentAnswer(id: 2, textKey: "assessment.growth.q1.c", delta: 1),
            AssessmentAnswer(id: 3, textKey: "assessment.growth.q1.d", delta: 2)
        ]),
        
        // F2: Die Fake-Arbeit
        AssessmentQuestion(id: 2, textKey: "assessment.growth.q2", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.growth.q2.a", delta: -1),
            AssessmentAnswer(id: 1, textKey: "assessment.growth.q2.b", delta: 1),
            AssessmentAnswer(id: 2, textKey: "assessment.growth.q2.c", delta: 2),
            AssessmentAnswer(id: 3, textKey: "assessment.growth.q2.d", delta: -2)
        ]),
        
        // F3: Die Perfektionismus-Falle (80/20)
        AssessmentQuestion(id: 3, textKey: "assessment.growth.q3", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.growth.q3.a", delta: 1),
            AssessmentAnswer(id: 1, textKey: "assessment.growth.q3.b", delta: 2),
            AssessmentAnswer(id: 2, textKey: "assessment.growth.q3.c", delta: -2),
            AssessmentAnswer(id: 3, textKey: "assessment.growth.q3.d", delta: -1)
        ]),
        
        // F4: Revenge Bedtime Procrastination
        AssessmentQuestion(id: 4, textKey: "assessment.growth.q4", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.growth.q4.a", delta: -2),
            AssessmentAnswer(id: 1, textKey: "assessment.growth.q4.b", delta: 2),
            AssessmentAnswer(id: 2, textKey: "assessment.growth.q4.c", delta: 1),
            AssessmentAnswer(id: 3, textKey: "assessment.growth.q4.d", delta: -1)
        ]),
        
        // F5: Der Dopamin-Kick
        AssessmentQuestion(id: 5, textKey: "assessment.growth.q5", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.growth.q5.a", delta: -2),
            AssessmentAnswer(id: 1, textKey: "assessment.growth.q5.b", delta: -1),
            AssessmentAnswer(id: 2, textKey: "assessment.growth.q5.c", delta: 2),
            AssessmentAnswer(id: 3, textKey: "assessment.growth.q5.d", delta: 1)
        ]),
        
        // F6: Das Shiny Object Syndrome
        AssessmentQuestion(id: 6, textKey: "assessment.growth.q6", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.growth.q6.a", delta: -1),
            AssessmentAnswer(id: 1, textKey: "assessment.growth.q6.b", delta: -2),
            AssessmentAnswer(id: 2, textKey: "assessment.growth.q6.c", delta: 2),
            AssessmentAnswer(id: 3, textKey: "assessment.growth.q6.d", delta: 1)
        ]),
        
        // F7: Der Kontrollverlust
        AssessmentQuestion(id: 7, textKey: "assessment.growth.q7", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.growth.q7.a", delta: 2),
            AssessmentAnswer(id: 1, textKey: "assessment.growth.q7.b", delta: -2),
            AssessmentAnswer(id: 2, textKey: "assessment.growth.q7.c", delta: 1),
            AssessmentAnswer(id: 3, textKey: "assessment.growth.q7.d", delta: -1)
        ]),
        
        // F8: Die tote Zeit
        AssessmentQuestion(id: 8, textKey: "assessment.growth.q8", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.growth.q8.a", delta: -1),
            AssessmentAnswer(id: 1, textKey: "assessment.growth.q8.b", delta: 1),
            AssessmentAnswer(id: 2, textKey: "assessment.growth.q8.c", delta: -2),
            AssessmentAnswer(id: 3, textKey: "assessment.growth.q8.d", delta: 2)
        ]),
        
        // F9: Der gebrochene Streak
        AssessmentQuestion(id: 9, textKey: "assessment.growth.q9", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.growth.q9.a", delta: -2),
            AssessmentAnswer(id: 1, textKey: "assessment.growth.q9.b", delta: -1),
            AssessmentAnswer(id: 2, textKey: "assessment.growth.q9.c", delta: 2),
            AssessmentAnswer(id: 3, textKey: "assessment.growth.q9.d", delta: 1)
        ]),
        
        // F10: Das Feedback-Vakuum
        AssessmentQuestion(id: 10, textKey: "assessment.growth.q10", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.growth.q10.a", delta: -1),
            AssessmentAnswer(id: 1, textKey: "assessment.growth.q10.b", delta: 2),
            AssessmentAnswer(id: 2, textKey: "assessment.growth.q10.c", delta: 1),
            AssessmentAnswer(id: 3, textKey: "assessment.growth.q10.d", delta: -2)
        ]),
        
        // F11: Die Delegation
        AssessmentQuestion(id: 11, textKey: "assessment.growth.q11", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.growth.q11.a", delta: 1),
            AssessmentAnswer(id: 1, textKey: "assessment.growth.q11.b", delta: 2),
            AssessmentAnswer(id: 2, textKey: "assessment.growth.q11.c", delta: -1),
            AssessmentAnswer(id: 3, textKey: "assessment.growth.q11.d", delta: -2)
        ]),
        
        // F12: Die Informations-Diät
        AssessmentQuestion(id: 12, textKey: "assessment.growth.q12", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.growth.q12.a", delta: -2),
            AssessmentAnswer(id: 1, textKey: "assessment.growth.q12.b", delta: 2),
            AssessmentAnswer(id: 2, textKey: "assessment.growth.q12.c", delta: -1),
            AssessmentAnswer(id: 3, textKey: "assessment.growth.q12.d", delta: 1)
        ]),
        
        // F13: Der Dopamin-Detox
        AssessmentQuestion(id: 13, textKey: "assessment.growth.q13", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.growth.q13.a", delta: 1),
            AssessmentAnswer(id: 1, textKey: "assessment.growth.q13.b", delta: 2),
            AssessmentAnswer(id: 2, textKey: "assessment.growth.q13.c", delta: -2),
            AssessmentAnswer(id: 3, textKey: "assessment.growth.q13.d", delta: -1)
        ]),
        
        // F14: Das leere Wochenende
        AssessmentQuestion(id: 14, textKey: "assessment.growth.q14", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.growth.q14.a", delta: -2),
            AssessmentAnswer(id: 1, textKey: "assessment.growth.q14.b", delta: 2),
            AssessmentAnswer(id: 2, textKey: "assessment.growth.q14.c", delta: -1),
            AssessmentAnswer(id: 3, textKey: "assessment.growth.q14.d", delta: 1)
        ]),
        
        // F15: Die harte Wahrheit
        AssessmentQuestion(id: 15, textKey: "assessment.growth.q15", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.growth.q15.a", delta: 1),
            AssessmentAnswer(id: 1, textKey: "assessment.growth.q15.b", delta: -2),
            AssessmentAnswer(id: 2, textKey: "assessment.growth.q15.c", delta: -1),
            AssessmentAnswer(id: 3, textKey: "assessment.growth.q15.d", delta: 2)
        ])
    ]
}
