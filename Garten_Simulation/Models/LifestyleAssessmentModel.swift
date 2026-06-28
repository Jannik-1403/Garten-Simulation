import Foundation

// MARK: - Lifestyle Assessment Profile

enum LifestyleProfile: String, Codable, CaseIterable {
    case gefangener      // Schwächster Parameter: umfeld
    case chaot           // Schwächster Parameter: standards
    case mitlaeufer      // Schwächster Parameter: einfluss
    case elite           // Alle Parameter >= 0

    var titleKey: String { "assessment.lifestyle.profile.\(rawValue).title" }
    var descKey:  String { "assessment.lifestyle.profile.\(rawValue).desc" }
    var actionKey: String { "assessment.lifestyle.profile.\(rawValue).action" }
    var buildHabitsKey: String { "assessment.lifestyle.profile.\(rawValue).build" }
    var breakHabitsKey: String { "assessment.lifestyle.profile.\(rawValue).break" }

    var icon: String {
        switch self {
        case .gefangener:  return "person.3.sequence.fill"
        case .chaot:       return "trash.fill"
        case .mitlaeufer:  return "figure.walk.motion"
        case .elite:       return "star.fill"
        }
    }

    var color: String {
        switch self {
        case .gefangener:  return "#FF6B6B" // Red
        case .chaot:       return "#F5A623" // Orange
        case .mitlaeufer:  return "#4A90E2" // Blue
        case .elite:       return "#4CAF50" // Green
        }
    }
}

// MARK: - Lifestyle Score Deltas

struct LifestyleScoreDeltas {
    let umfeld: Int
    let standards: Int
    let einfluss: Int
}

// MARK: - Lifestyle Answer

struct LifestyleAnswer: Identifiable {
    let id: Int
    let textKey: String
    let delta: LifestyleScoreDeltas
}

// MARK: - Lifestyle Question

struct LifestyleQuestion: Identifiable {
    let id: Int
    let textKey: String
    let answers: [LifestyleAnswer]
}

// MARK: - Lifestyle Raw Score

struct LifestyleRawScore {
    var umfeld: Int = 0
    var standards: Int = 0
    var einfluss: Int = 0
}

// MARK: - Lifestyle Assessment Result

struct LifestyleAssessmentResult: Codable {
    let profile: LifestyleProfile
    let rawUmfeld: Int
    let rawStandards: Int
    let rawEinfluss: Int
    let date: Date
}

// MARK: - Lifestyle Scoring Engine

enum LifestyleScoringEngine {
    private static let umfeldRange: Double = 28.0
    private static let standardsRange: Double = 37.0
    private static let einflussRange: Double = 34.0

    static func computeProfile(from score: LifestyleRawScore) -> LifestyleProfile {
        if score.umfeld >= 0 && score.standards >= 0 && score.einfluss >= 0 {
            return .elite
        }

        let normUmfeld = Double(score.umfeld) / umfeldRange
        let normStandards = Double(score.standards) / standardsRange
        let normEinfluss = Double(score.einfluss) / einflussRange

        let candidates: [(value: Double, priority: Int, profile: LifestyleProfile)] = [
            (normUmfeld, 0, .gefangener),
            (normStandards, 1, .chaot),
            (normEinfluss, 2, .mitlaeufer)
        ]

        let negatives = candidates.filter { $0.value < 0 }
        guard !negatives.isEmpty else { return .elite }

        let dominant = negatives.min { lhs, rhs in
            if lhs.value != rhs.value { return lhs.value < rhs.value }
            return lhs.priority < rhs.priority
        }!

        return dominant.profile
    }
}

// MARK: - Lifestyle Quiz Data

struct LifestyleQuiz {
    static let questions: [LifestyleQuestion] = [
        
        // F1: Das dreckige Zimmer
        LifestyleQuestion(id: 1, textKey: "assessment.lifestyle.q1", answers: [
            LifestyleAnswer(id: 0, textKey: "assessment.lifestyle.q1.a", delta: LifestyleScoreDeltas(umfeld:  0, standards: -3, einfluss: -2)),
            LifestyleAnswer(id: 1, textKey: "assessment.lifestyle.q1.b", delta: LifestyleScoreDeltas(umfeld:  0, standards: -2, einfluss: -1)),
            LifestyleAnswer(id: 2, textKey: "assessment.lifestyle.q1.c", delta: LifestyleScoreDeltas(umfeld:  0, standards:  1, einfluss:  0)),
            LifestyleAnswer(id: 3, textKey: "assessment.lifestyle.q1.d", delta: LifestyleScoreDeltas(umfeld:  0, standards:  3, einfluss:  2))
        ]),
        
        // F2: Der toxische Kreis
        LifestyleQuestion(id: 2, textKey: "assessment.lifestyle.q2", answers: [
            LifestyleAnswer(id: 0, textKey: "assessment.lifestyle.q2.a", delta: LifestyleScoreDeltas(umfeld: -3, standards: -2, einfluss: -2)),
            LifestyleAnswer(id: 1, textKey: "assessment.lifestyle.q2.b", delta: LifestyleScoreDeltas(umfeld: -1, standards: -1, einfluss:  0)),
            LifestyleAnswer(id: 2, textKey: "assessment.lifestyle.q2.c", delta: LifestyleScoreDeltas(umfeld:  1, standards:  0, einfluss:  1)),
            LifestyleAnswer(id: 3, textKey: "assessment.lifestyle.q2.d", delta: LifestyleScoreDeltas(umfeld:  3, standards:  2, einfluss:  3))
        ]),
        
        // F3: Die Rüstung
        LifestyleQuestion(id: 3, textKey: "assessment.lifestyle.q3", answers: [
            LifestyleAnswer(id: 0, textKey: "assessment.lifestyle.q3.a", delta: LifestyleScoreDeltas(umfeld: -1, standards: -3, einfluss: -3)),
            LifestyleAnswer(id: 1, textKey: "assessment.lifestyle.q3.b", delta: LifestyleScoreDeltas(umfeld:  0, standards: -1, einfluss: -1)),
            LifestyleAnswer(id: 2, textKey: "assessment.lifestyle.q3.c", delta: LifestyleScoreDeltas(umfeld:  1, standards:  2, einfluss:  1)),
            LifestyleAnswer(id: 3, textKey: "assessment.lifestyle.q3.d", delta: LifestyleScoreDeltas(umfeld:  2, standards:  3, einfluss:  3))
        ]),
        
        // F4: Das Wort als Gesetz
        LifestyleQuestion(id: 4, textKey: "assessment.lifestyle.q4", answers: [
            LifestyleAnswer(id: 0, textKey: "assessment.lifestyle.q4.a", delta: LifestyleScoreDeltas(umfeld: -2, standards: -3, einfluss: -2)),
            LifestyleAnswer(id: 1, textKey: "assessment.lifestyle.q4.b", delta: LifestyleScoreDeltas(umfeld:  0, standards: -1, einfluss: -1)),
            LifestyleAnswer(id: 2, textKey: "assessment.lifestyle.q4.c", delta: LifestyleScoreDeltas(umfeld:  1, standards:  1, einfluss:  0)),
            LifestyleAnswer(id: 3, textKey: "assessment.lifestyle.q4.d", delta: LifestyleScoreDeltas(umfeld:  3, standards:  3, einfluss:  3))
        ]),
        
        // F5: Der Raum betreten
        LifestyleQuestion(id: 5, textKey: "assessment.lifestyle.q5", answers: [
            LifestyleAnswer(id: 0, textKey: "assessment.lifestyle.q5.a", delta: LifestyleScoreDeltas(umfeld: -1, standards: -2, einfluss: -3)),
            LifestyleAnswer(id: 1, textKey: "assessment.lifestyle.q5.b", delta: LifestyleScoreDeltas(umfeld:  0, standards: -1, einfluss: -2)),
            LifestyleAnswer(id: 2, textKey: "assessment.lifestyle.q5.c", delta: LifestyleScoreDeltas(umfeld:  1, standards:  1, einfluss:  1)),
            LifestyleAnswer(id: 3, textKey: "assessment.lifestyle.q5.d", delta: LifestyleScoreDeltas(umfeld:  2, standards:  2, einfluss:  3))
        ]),
        
        // F6: Der digitale Müll
        LifestyleQuestion(id: 6, textKey: "assessment.lifestyle.q6", answers: [
            LifestyleAnswer(id: 0, textKey: "assessment.lifestyle.q6.a", delta: LifestyleScoreDeltas(umfeld: -3, standards: -3, einfluss: -1)),
            LifestyleAnswer(id: 1, textKey: "assessment.lifestyle.q6.b", delta: LifestyleScoreDeltas(umfeld: -1, standards: -1, einfluss:  0)),
            LifestyleAnswer(id: 2, textKey: "assessment.lifestyle.q6.c", delta: LifestyleScoreDeltas(umfeld:  1, standards:  1, einfluss:  0)),
            LifestyleAnswer(id: 3, textKey: "assessment.lifestyle.q6.d", delta: LifestyleScoreDeltas(umfeld:  3, standards:  3, einfluss:  2))
        ]),
        
        // F7: Der Umgang mit Servicekräften
        LifestyleQuestion(id: 7, textKey: "assessment.lifestyle.q7", answers: [
            LifestyleAnswer(id: 0, textKey: "assessment.lifestyle.q7.a", delta: LifestyleScoreDeltas(umfeld: -2, standards: -3, einfluss: -3)),
            LifestyleAnswer(id: 1, textKey: "assessment.lifestyle.q7.b", delta: LifestyleScoreDeltas(umfeld: -1, standards: -2, einfluss: -1)),
            LifestyleAnswer(id: 2, textKey: "assessment.lifestyle.q7.c", delta: LifestyleScoreDeltas(umfeld:  0, standards: -1, einfluss:  0)),
            LifestyleAnswer(id: 3, textKey: "assessment.lifestyle.q7.d", delta: LifestyleScoreDeltas(umfeld:  2, standards:  3, einfluss:  3))
        ]),
        
        // F8: Das Gossip-Protokoll
        LifestyleQuestion(id: 8, textKey: "assessment.lifestyle.q8", answers: [
            LifestyleAnswer(id: 0, textKey: "assessment.lifestyle.q8.a", delta: LifestyleScoreDeltas(umfeld: -3, standards: -3, einfluss: -2)),
            LifestyleAnswer(id: 1, textKey: "assessment.lifestyle.q8.b", delta: LifestyleScoreDeltas(umfeld: -1, standards: -1, einfluss: -1)),
            LifestyleAnswer(id: 2, textKey: "assessment.lifestyle.q8.c", delta: LifestyleScoreDeltas(umfeld:  1, standards:  1, einfluss:  0)),
            LifestyleAnswer(id: 3, textKey: "assessment.lifestyle.q8.d", delta: LifestyleScoreDeltas(umfeld:  3, standards:  3, einfluss:  3))
        ]),
        
        // F9: Das schwache 'Ja'
        LifestyleQuestion(id: 9, textKey: "assessment.lifestyle.q9", answers: [
            LifestyleAnswer(id: 0, textKey: "assessment.lifestyle.q9.a", delta: LifestyleScoreDeltas(umfeld: -1, standards: -2, einfluss: -3)),
            LifestyleAnswer(id: 1, textKey: "assessment.lifestyle.q9.b", delta: LifestyleScoreDeltas(umfeld: -1, standards: -3, einfluss: -2)),
            LifestyleAnswer(id: 2, textKey: "assessment.lifestyle.q9.c", delta: LifestyleScoreDeltas(umfeld:  0, standards: -1, einfluss: -1)),
            LifestyleAnswer(id: 3, textKey: "assessment.lifestyle.q9.d", delta: LifestyleScoreDeltas(umfeld:  2, standards:  3, einfluss:  3))
        ]),
        
        // F10: Die Wochenend-Vergiftung
        LifestyleQuestion(id: 10, textKey: "assessment.lifestyle.q10", answers: [
            LifestyleAnswer(id: 0, textKey: "assessment.lifestyle.q10.a", delta: LifestyleScoreDeltas(umfeld: -3, standards: -3, einfluss: -1)),
            LifestyleAnswer(id: 1, textKey: "assessment.lifestyle.q10.b", delta: LifestyleScoreDeltas(umfeld: -2, standards: -2, einfluss:  0)),
            LifestyleAnswer(id: 2, textKey: "assessment.lifestyle.q10.c", delta: LifestyleScoreDeltas(umfeld:  0, standards:  1, einfluss:  1)),
            LifestyleAnswer(id: 3, textKey: "assessment.lifestyle.q10.d", delta: LifestyleScoreDeltas(umfeld:  3, standards:  3, einfluss:  3))
        ]),
        
        // F11: Konsument vs. Produzent
        LifestyleQuestion(id: 11, textKey: "assessment.lifestyle.q11", answers: [
            LifestyleAnswer(id: 0, textKey: "assessment.lifestyle.q11.a", delta: LifestyleScoreDeltas(umfeld:  0, standards: -3, einfluss: -3)),
            LifestyleAnswer(id: 1, textKey: "assessment.lifestyle.q11.b", delta: LifestyleScoreDeltas(umfeld:  1, standards: -1, einfluss: -1)),
            LifestyleAnswer(id: 2, textKey: "assessment.lifestyle.q11.c", delta: LifestyleScoreDeltas(umfeld:  1, standards:  0, einfluss:  1)),
            LifestyleAnswer(id: 3, textKey: "assessment.lifestyle.q11.d", delta: LifestyleScoreDeltas(umfeld:  2, standards:  3, einfluss:  3))
        ]),
        
        // F12: Die Sprache des Versagers
        LifestyleQuestion(id: 12, textKey: "assessment.lifestyle.q12", answers: [
            LifestyleAnswer(id: 0, textKey: "assessment.lifestyle.q12.a", delta: LifestyleScoreDeltas(umfeld:  0, standards: -2, einfluss: -2)),
            LifestyleAnswer(id: 1, textKey: "assessment.lifestyle.q12.b", delta: LifestyleScoreDeltas(umfeld: -1, standards: -3, einfluss: -3)),
            LifestyleAnswer(id: 2, textKey: "assessment.lifestyle.q12.c", delta: LifestyleScoreDeltas(umfeld:  0, standards: -1, einfluss: -1)),
            LifestyleAnswer(id: 3, textKey: "assessment.lifestyle.q12.d", delta: LifestyleScoreDeltas(umfeld:  0, standards:  3, einfluss:  3))
        ]),
        
        // F13: Der Respekt der anderen
        LifestyleQuestion(id: 13, textKey: "assessment.lifestyle.q13", answers: [
            LifestyleAnswer(id: 0, textKey: "assessment.lifestyle.q13.a", delta: LifestyleScoreDeltas(umfeld: -3, standards:  0, einfluss: -3)),
            LifestyleAnswer(id: 1, textKey: "assessment.lifestyle.q13.b", delta: LifestyleScoreDeltas(umfeld: -1, standards:  0, einfluss: -2)),
            LifestyleAnswer(id: 2, textKey: "assessment.lifestyle.q13.c", delta: LifestyleScoreDeltas(umfeld:  1, standards:  0, einfluss:  1)),
            LifestyleAnswer(id: 3, textKey: "assessment.lifestyle.q13.d", delta: LifestyleScoreDeltas(umfeld:  3, standards:  0, einfluss:  3))
        ]),
        
        // F14: Die Mittelmaß-Akzeptanz
        LifestyleQuestion(id: 14, textKey: "assessment.lifestyle.q14", answers: [
            LifestyleAnswer(id: 0, textKey: "assessment.lifestyle.q14.a", delta: LifestyleScoreDeltas(umfeld: -2, standards: -3, einfluss: -2)),
            LifestyleAnswer(id: 1, textKey: "assessment.lifestyle.q14.b", delta: LifestyleScoreDeltas(umfeld:  0, standards: -2, einfluss: -1)),
            LifestyleAnswer(id: 2, textKey: "assessment.lifestyle.q14.c", delta: LifestyleScoreDeltas(umfeld:  0, standards:  0, einfluss:  0)),
            LifestyleAnswer(id: 3, textKey: "assessment.lifestyle.q14.d", delta: LifestyleScoreDeltas(umfeld:  0, standards:  3, einfluss:  2))
        ]),
        
        // F15: Das parasitäre Umfeld
        LifestyleQuestion(id: 15, textKey: "assessment.lifestyle.q15", answers: [
            LifestyleAnswer(id: 0, textKey: "assessment.lifestyle.q15.a", delta: LifestyleScoreDeltas(umfeld: -3, standards:  0, einfluss: -1)),
            LifestyleAnswer(id: 1, textKey: "assessment.lifestyle.q15.b", delta: LifestyleScoreDeltas(umfeld: -2, standards:  0, einfluss:  0)),
            LifestyleAnswer(id: 2, textKey: "assessment.lifestyle.q15.c", delta: LifestyleScoreDeltas(umfeld:  1, standards:  0, einfluss:  0)),
            LifestyleAnswer(id: 3, textKey: "assessment.lifestyle.q15.d", delta: LifestyleScoreDeltas(umfeld:  3, standards:  0, einfluss:  1))
        ])
    ]
}
