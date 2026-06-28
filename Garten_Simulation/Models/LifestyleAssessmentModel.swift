import Foundation

// MARK: - Lifestyle Assessment Profile

enum LifestyleProfile: String, Codable, CaseIterable {
    case level1
    case level2
    case level3
    case level4

    var titleKey: String { "assessment.lifestyle.profile.\(rawValue).title" }
    var descKey:  String { "assessment.lifestyle.profile.\(rawValue).desc" }
    var actionKey: String { "assessment.lifestyle.profile.\(rawValue).action" }
    var buildHabitsKey: String { "assessment.lifestyle.profile.\(rawValue).build" }
    var breakHabitsKey: String { "assessment.lifestyle.profile.\(rawValue).break" }

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
// MARK: - Lifestyle Score Deltas



// MARK: - Lifestyle Answer



// MARK: - Lifestyle Question



// MARK: - Lifestyle Raw Score



// MARK: - Lifestyle Assessment Result

struct LifestyleAssessmentResult: Codable {
    let profile: LifestyleProfile
    let score: Int
    let date: Date
}

// MARK: - Lifestyle Scoring Engine

enum LifestyleScoringEngine {
    static func computeProfile(from score: Int) -> LifestyleProfile {
        switch score {
        case ..<(-9): return .level1
        case (-9)...5: return .level2
        case 6...20: return .level3
        default: return .level4
        }
    }
}

// MARK: - Lifestyle Quiz Data

struct LifestyleQuiz {
    static let questions: [AssessmentQuestion] = [
        
        // F1: Das dreckige Zimmer
        AssessmentQuestion(id: 1, textKey: "assessment.lifestyle.q1", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.lifestyle.q1.a", delta: -2),
            AssessmentAnswer(id: 1, textKey: "assessment.lifestyle.q1.b", delta: -1),
            AssessmentAnswer(id: 2, textKey: "assessment.lifestyle.q1.c", delta: 1),
            AssessmentAnswer(id: 3, textKey: "assessment.lifestyle.q1.d", delta: 2)
        ]),
        
        // F2: Der toxische Kreis
        AssessmentQuestion(id: 2, textKey: "assessment.lifestyle.q2", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.lifestyle.q2.a", delta: -2),
            AssessmentAnswer(id: 1, textKey: "assessment.lifestyle.q2.b", delta: -1),
            AssessmentAnswer(id: 2, textKey: "assessment.lifestyle.q2.c", delta: 1),
            AssessmentAnswer(id: 3, textKey: "assessment.lifestyle.q2.d", delta: 2)
        ]),
        
        // F3: Die Rüstung
        AssessmentQuestion(id: 3, textKey: "assessment.lifestyle.q3", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.lifestyle.q3.a", delta: -2),
            AssessmentAnswer(id: 1, textKey: "assessment.lifestyle.q3.b", delta: -1),
            AssessmentAnswer(id: 2, textKey: "assessment.lifestyle.q3.c", delta: 1),
            AssessmentAnswer(id: 3, textKey: "assessment.lifestyle.q3.d", delta: 2)
        ]),
        
        // F4: Das Wort als Gesetz
        AssessmentQuestion(id: 4, textKey: "assessment.lifestyle.q4", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.lifestyle.q4.a", delta: -2),
            AssessmentAnswer(id: 1, textKey: "assessment.lifestyle.q4.b", delta: -1),
            AssessmentAnswer(id: 2, textKey: "assessment.lifestyle.q4.c", delta: 1),
            AssessmentAnswer(id: 3, textKey: "assessment.lifestyle.q4.d", delta: 2)
        ]),
        
        // F5: Der Raum betreten
        AssessmentQuestion(id: 5, textKey: "assessment.lifestyle.q5", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.lifestyle.q5.a", delta: -2),
            AssessmentAnswer(id: 1, textKey: "assessment.lifestyle.q5.b", delta: -1),
            AssessmentAnswer(id: 2, textKey: "assessment.lifestyle.q5.c", delta: 1),
            AssessmentAnswer(id: 3, textKey: "assessment.lifestyle.q5.d", delta: 2)
        ]),
        
        // F6: Der digitale Müll
        AssessmentQuestion(id: 6, textKey: "assessment.lifestyle.q6", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.lifestyle.q6.a", delta: -2),
            AssessmentAnswer(id: 1, textKey: "assessment.lifestyle.q6.b", delta: -1),
            AssessmentAnswer(id: 2, textKey: "assessment.lifestyle.q6.c", delta: 1),
            AssessmentAnswer(id: 3, textKey: "assessment.lifestyle.q6.d", delta: 2)
        ]),
        
        // F7: Der Umgang mit Servicekräften
        AssessmentQuestion(id: 7, textKey: "assessment.lifestyle.q7", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.lifestyle.q7.a", delta: -2),
            AssessmentAnswer(id: 1, textKey: "assessment.lifestyle.q7.b", delta: -1),
            AssessmentAnswer(id: 2, textKey: "assessment.lifestyle.q7.c", delta: 1),
            AssessmentAnswer(id: 3, textKey: "assessment.lifestyle.q7.d", delta: 2)
        ]),
        
        // F8: Das Gossip-Protokoll
        AssessmentQuestion(id: 8, textKey: "assessment.lifestyle.q8", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.lifestyle.q8.a", delta: -2),
            AssessmentAnswer(id: 1, textKey: "assessment.lifestyle.q8.b", delta: -1),
            AssessmentAnswer(id: 2, textKey: "assessment.lifestyle.q8.c", delta: 1),
            AssessmentAnswer(id: 3, textKey: "assessment.lifestyle.q8.d", delta: 2)
        ]),
        
        // F9: Das schwache 'Ja'
        AssessmentQuestion(id: 9, textKey: "assessment.lifestyle.q9", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.lifestyle.q9.a", delta: -1),
            AssessmentAnswer(id: 1, textKey: "assessment.lifestyle.q9.b", delta: -2),
            AssessmentAnswer(id: 2, textKey: "assessment.lifestyle.q9.c", delta: 1),
            AssessmentAnswer(id: 3, textKey: "assessment.lifestyle.q9.d", delta: 2)
        ]),
        
        // F10: Die Wochenend-Vergiftung
        AssessmentQuestion(id: 10, textKey: "assessment.lifestyle.q10", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.lifestyle.q10.a", delta: -2),
            AssessmentAnswer(id: 1, textKey: "assessment.lifestyle.q10.b", delta: -1),
            AssessmentAnswer(id: 2, textKey: "assessment.lifestyle.q10.c", delta: 1),
            AssessmentAnswer(id: 3, textKey: "assessment.lifestyle.q10.d", delta: 2)
        ]),
        
        // F11: Konsument vs. Produzent
        AssessmentQuestion(id: 11, textKey: "assessment.lifestyle.q11", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.lifestyle.q11.a", delta: -2),
            AssessmentAnswer(id: 1, textKey: "assessment.lifestyle.q11.b", delta: -1),
            AssessmentAnswer(id: 2, textKey: "assessment.lifestyle.q11.c", delta: 1),
            AssessmentAnswer(id: 3, textKey: "assessment.lifestyle.q11.d", delta: 2)
        ]),
        
        // F12: Die Sprache des Versagers
        AssessmentQuestion(id: 12, textKey: "assessment.lifestyle.q12", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.lifestyle.q12.a", delta: -1),
            AssessmentAnswer(id: 1, textKey: "assessment.lifestyle.q12.b", delta: -2),
            AssessmentAnswer(id: 2, textKey: "assessment.lifestyle.q12.c", delta: 1),
            AssessmentAnswer(id: 3, textKey: "assessment.lifestyle.q12.d", delta: 2)
        ]),
        
        // F13: Der Respekt der anderen
        AssessmentQuestion(id: 13, textKey: "assessment.lifestyle.q13", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.lifestyle.q13.a", delta: -2),
            AssessmentAnswer(id: 1, textKey: "assessment.lifestyle.q13.b", delta: -1),
            AssessmentAnswer(id: 2, textKey: "assessment.lifestyle.q13.c", delta: 1),
            AssessmentAnswer(id: 3, textKey: "assessment.lifestyle.q13.d", delta: 2)
        ]),
        
        // F14: Die Mittelmaß-Akzeptanz
        AssessmentQuestion(id: 14, textKey: "assessment.lifestyle.q14", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.lifestyle.q14.a", delta: -2),
            AssessmentAnswer(id: 1, textKey: "assessment.lifestyle.q14.b", delta: -1),
            AssessmentAnswer(id: 2, textKey: "assessment.lifestyle.q14.c", delta: 1),
            AssessmentAnswer(id: 3, textKey: "assessment.lifestyle.q14.d", delta: 2)
        ]),
        
        // F15: Das parasitäre Umfeld
        AssessmentQuestion(id: 15, textKey: "assessment.lifestyle.q15", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.lifestyle.q15.a", delta: -2),
            AssessmentAnswer(id: 1, textKey: "assessment.lifestyle.q15.b", delta: -1),
            AssessmentAnswer(id: 2, textKey: "assessment.lifestyle.q15.c", delta: 1),
            AssessmentAnswer(id: 3, textKey: "assessment.lifestyle.q15.d", delta: 2)
        ])
    ]
}
