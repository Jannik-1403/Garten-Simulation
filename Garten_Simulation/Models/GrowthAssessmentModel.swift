import Foundation

// MARK: - Growth Assessment Profile

enum GrowthProfile: String, Codable, CaseIterable {
    case traeumer        // Schwächster Parameter: umsetzung
    case fakeWorker      // Schwächster Parameter: effizienz
    case aufgeber        // Schwächster Parameter: disziplin
    case macher          // Alle Parameter >= 0

    var titleKey: String { "assessment.growth.profile.\(rawValue).title" }
    var descKey:  String { "assessment.growth.profile.\(rawValue).desc" }
    var actionKey: String { "assessment.growth.profile.\(rawValue).action" }
    var buildHabitsKey: String { "assessment.growth.profile.\(rawValue).build" }
    var breakHabitsKey: String { "assessment.growth.profile.\(rawValue).break" }

    var icon: String {
        switch self {
        case .traeumer:    return "cloud.fill"
        case .fakeWorker:  return "briefcase.fill"
        case .aufgeber:    return "flag.slash.fill"
        case .macher:      return "flame.fill"
        }
    }

    var color: String {
        switch self {
        case .traeumer:    return "#4A90E2" // Blue
        case .fakeWorker:  return "#F5A623" // Orange
        case .aufgeber:    return "#D0021B" // Red
        case .macher:      return "#417505" // Green
        }
    }
}

// MARK: - Growth Score Deltas

struct GrowthScoreDeltas {
    let disziplin: Int
    let effizienz: Int
    let umsetzung: Int
}

// MARK: - Growth Answer

struct GrowthAnswer: Identifiable {
    let id: Int
    let textKey: String
    let delta: GrowthScoreDeltas
}

// MARK: - Growth Question

struct GrowthQuestion: Identifiable {
    let id: Int
    let textKey: String
    let answers: [GrowthAnswer]
}

// MARK: - Growth Raw Score

struct GrowthRawScore {
    var disziplin: Int = 0
    var effizienz: Int = 0
    var umsetzung: Int = 0
}

// MARK: - Growth Assessment Result

struct GrowthAssessmentResult: Codable {
    let profile: GrowthProfile
    let rawDisziplin: Int
    let rawEffizienz: Int
    let rawUmsetzung: Int
    let date: Date
}

// MARK: - Growth Scoring Engine

enum GrowthScoringEngine {
    private static let disziplinRange: Double = 39.0
    private static let effizienzRange: Double = 37.0
    private static let umsetzungRange: Double = 31.0

    static func computeProfile(from score: GrowthRawScore) -> GrowthProfile {
        if score.disziplin >= 0 && score.effizienz >= 0 && score.umsetzung >= 0 {
            return .macher
        }

        let normDisziplin = Double(score.disziplin) / disziplinRange
        let normEffizienz = Double(score.effizienz) / effizienzRange
        let normUmsetzung = Double(score.umsetzung) / umsetzungRange

        let candidates: [(value: Double, priority: Int, profile: GrowthProfile)] = [
            (normUmsetzung, 0, .traeumer),
            (normEffizienz, 1, .fakeWorker),
            (normDisziplin, 2, .aufgeber)
        ]

        let negatives = candidates.filter { $0.value < 0 }
        guard !negatives.isEmpty else { return .macher }

        let dominant = negatives.min { lhs, rhs in
            if lhs.value != rhs.value { return lhs.value < rhs.value }
            return lhs.priority < rhs.priority
        }!

        return dominant.profile
    }
}

// MARK: - Growth Quiz Data

struct GrowthQuiz {
    static let questions: [GrowthQuestion] = [
        
        // F1: Der Motivationstod
        GrowthQuestion(id: 1, textKey: "assessment.growth.q1", answers: [
            GrowthAnswer(id: 0, textKey: "assessment.growth.q1.a", delta: GrowthScoreDeltas(disziplin: -3, effizienz:  0, umsetzung: -3)),
            GrowthAnswer(id: 1, textKey: "assessment.growth.q1.b", delta: GrowthScoreDeltas(disziplin: -1, effizienz: -1, umsetzung: -2)),
            GrowthAnswer(id: 2, textKey: "assessment.growth.q1.c", delta: GrowthScoreDeltas(disziplin:  2, effizienz:  1, umsetzung:  3)),
            GrowthAnswer(id: 3, textKey: "assessment.growth.q1.d", delta: GrowthScoreDeltas(disziplin:  3, effizienz:  2, umsetzung:  2))
        ]),
        
        // F2: Die Fake-Arbeit
        GrowthQuestion(id: 2, textKey: "assessment.growth.q2", answers: [
            GrowthAnswer(id: 0, textKey: "assessment.growth.q2.a", delta: GrowthScoreDeltas(disziplin: -1, effizienz: -3, umsetzung: -2)),
            GrowthAnswer(id: 1, textKey: "assessment.growth.q2.b", delta: GrowthScoreDeltas(disziplin:  0, effizienz: -2, umsetzung:  1)),
            GrowthAnswer(id: 2, textKey: "assessment.growth.q2.c", delta: GrowthScoreDeltas(disziplin:  3, effizienz:  3, umsetzung:  3)),
            GrowthAnswer(id: 3, textKey: "assessment.growth.q2.d", delta: GrowthScoreDeltas(disziplin: -3, effizienz:  0, umsetzung: -3))
        ]),
        
        // F3: Die Perfektionismus-Falle (80/20)
        GrowthQuestion(id: 3, textKey: "assessment.growth.q3", answers: [
            GrowthAnswer(id: 0, textKey: "assessment.growth.q3.a", delta: GrowthScoreDeltas(disziplin:  1, effizienz: -3, umsetzung:  0)),
            GrowthAnswer(id: 1, textKey: "assessment.growth.q3.b", delta: GrowthScoreDeltas(disziplin:  0, effizienz:  3, umsetzung:  2)),
            GrowthAnswer(id: 2, textKey: "assessment.growth.q3.c", delta: GrowthScoreDeltas(disziplin: -1, effizienz: -2, umsetzung: -2)),
            GrowthAnswer(id: 3, textKey: "assessment.growth.q3.d", delta: GrowthScoreDeltas(disziplin: -2, effizienz:  0, umsetzung: -1))
        ]),
        
        // F4: Revenge Bedtime Procrastination
        GrowthQuestion(id: 4, textKey: "assessment.growth.q4", answers: [
            GrowthAnswer(id: 0, textKey: "assessment.growth.q4.a", delta: GrowthScoreDeltas(disziplin: -3, effizienz: -2, umsetzung: -1)),
            GrowthAnswer(id: 1, textKey: "assessment.growth.q4.b", delta: GrowthScoreDeltas(disziplin:  3, effizienz:  3, umsetzung:  1)),
            GrowthAnswer(id: 2, textKey: "assessment.growth.q4.c", delta: GrowthScoreDeltas(disziplin:  1, effizienz:  0, umsetzung:  0)),
            GrowthAnswer(id: 3, textKey: "assessment.growth.q4.d", delta: GrowthScoreDeltas(disziplin: -1, effizienz: -1, umsetzung: -1))
        ]),
        
        // F5: Der Dopamin-Kick
        GrowthQuestion(id: 5, textKey: "assessment.growth.q5", answers: [
            GrowthAnswer(id: 0, textKey: "assessment.growth.q5.a", delta: GrowthScoreDeltas(disziplin: -2, effizienz: -3, umsetzung:  0)),
            GrowthAnswer(id: 1, textKey: "assessment.growth.q5.b", delta: GrowthScoreDeltas(disziplin: -1, effizienz: -2, umsetzung:  0)),
            GrowthAnswer(id: 2, textKey: "assessment.growth.q5.c", delta: GrowthScoreDeltas(disziplin:  3, effizienz:  3, umsetzung:  2)),
            GrowthAnswer(id: 3, textKey: "assessment.growth.q5.d", delta: GrowthScoreDeltas(disziplin:  0, effizienz: -1, umsetzung: -1))
        ]),
        
        // F6: Das Shiny Object Syndrome
        GrowthQuestion(id: 6, textKey: "assessment.growth.q6", answers: [
            GrowthAnswer(id: 0, textKey: "assessment.growth.q6.a", delta: GrowthScoreDeltas(disziplin: -3, effizienz: -2, umsetzung:  1)),
            GrowthAnswer(id: 1, textKey: "assessment.growth.q6.b", delta: GrowthScoreDeltas(disziplin: -1, effizienz: -3, umsetzung:  0)),
            GrowthAnswer(id: 2, textKey: "assessment.growth.q6.c", delta: GrowthScoreDeltas(disziplin:  3, effizienz:  2, umsetzung:  2)),
            GrowthAnswer(id: 3, textKey: "assessment.growth.q6.d", delta: GrowthScoreDeltas(disziplin:  2, effizienz:  3, umsetzung:  1))
        ]),
        
        // F7: Der Kontrollverlust
        GrowthQuestion(id: 7, textKey: "assessment.growth.q7", answers: [
            GrowthAnswer(id: 0, textKey: "assessment.growth.q7.a", delta: GrowthScoreDeltas(disziplin:  1, effizienz:  3, umsetzung:  2)),
            GrowthAnswer(id: 1, textKey: "assessment.growth.q7.b", delta: GrowthScoreDeltas(disziplin: -3, effizienz: -2, umsetzung: -3)),
            GrowthAnswer(id: 2, textKey: "assessment.growth.q7.c", delta: GrowthScoreDeltas(disziplin:  2, effizienz: -2, umsetzung:  1)),
            GrowthAnswer(id: 3, textKey: "assessment.growth.q7.d", delta: GrowthScoreDeltas(disziplin: -1, effizienz: -3, umsetzung: -2))
        ]),
        
        // F8: Die tote Zeit
        GrowthQuestion(id: 8, textKey: "assessment.growth.q8", answers: [
            GrowthAnswer(id: 0, textKey: "assessment.growth.q8.a", delta: GrowthScoreDeltas(disziplin: -1, effizienz: -2, umsetzung: -1)),
            GrowthAnswer(id: 1, textKey: "assessment.growth.q8.b", delta: GrowthScoreDeltas(disziplin:  1, effizienz:  1, umsetzung:  0)),
            GrowthAnswer(id: 2, textKey: "assessment.growth.q8.c", delta: GrowthScoreDeltas(disziplin: -2, effizienz: -2, umsetzung:  0)),
            GrowthAnswer(id: 3, textKey: "assessment.growth.q8.d", delta: GrowthScoreDeltas(disziplin:  2, effizienz:  3, umsetzung:  2))
        ]),
        
        // F9: Der gebrochene Streak
        GrowthQuestion(id: 9, textKey: "assessment.growth.q9", answers: [
            GrowthAnswer(id: 0, textKey: "assessment.growth.q9.a", delta: GrowthScoreDeltas(disziplin: -3, effizienz: -1, umsetzung: -3)),
            GrowthAnswer(id: 1, textKey: "assessment.growth.q9.b", delta: GrowthScoreDeltas(disziplin: -1, effizienz: -1, umsetzung: -1)),
            GrowthAnswer(id: 2, textKey: "assessment.growth.q9.c", delta: GrowthScoreDeltas(disziplin:  3, effizienz:  3, umsetzung:  3)),
            GrowthAnswer(id: 3, textKey: "assessment.growth.q9.d", delta: GrowthScoreDeltas(disziplin:  0, effizienz: -1, umsetzung:  1))
        ]),
        
        // F10: Das Feedback-Vakuum
        GrowthQuestion(id: 10, textKey: "assessment.growth.q10", answers: [
            GrowthAnswer(id: 0, textKey: "assessment.growth.q10.a", delta: GrowthScoreDeltas(disziplin: -2, effizienz: -1, umsetzung: -1)),
            GrowthAnswer(id: 1, textKey: "assessment.growth.q10.b", delta: GrowthScoreDeltas(disziplin:  2, effizienz:  3, umsetzung:  2)),
            GrowthAnswer(id: 2, textKey: "assessment.growth.q10.c", delta: GrowthScoreDeltas(disziplin:  3, effizienz: -3, umsetzung:  1)),
            GrowthAnswer(id: 3, textKey: "assessment.growth.q10.d", delta: GrowthScoreDeltas(disziplin: -1, effizienz: -1, umsetzung: -2))
        ]),
        
        // F11: Die Delegation
        GrowthQuestion(id: 11, textKey: "assessment.growth.q11", answers: [
            GrowthAnswer(id: 0, textKey: "assessment.growth.q11.a", delta: GrowthScoreDeltas(disziplin:  2, effizienz: -3, umsetzung:  2)),
            GrowthAnswer(id: 1, textKey: "assessment.growth.q11.b", delta: GrowthScoreDeltas(disziplin:  1, effizienz:  3, umsetzung:  1)),
            GrowthAnswer(id: 2, textKey: "assessment.growth.q11.c", delta: GrowthScoreDeltas(disziplin: -1, effizienz:  0, umsetzung: -1)),
            GrowthAnswer(id: 3, textKey: "assessment.growth.q11.d", delta: GrowthScoreDeltas(disziplin: -3, effizienz: -2, umsetzung: -2))
        ]),
        
        // F12: Die Informations-Diät
        GrowthQuestion(id: 12, textKey: "assessment.growth.q12", answers: [
            GrowthAnswer(id: 0, textKey: "assessment.growth.q12.a", delta: GrowthScoreDeltas(disziplin:  0, effizienz: -2, umsetzung: -3)),
            GrowthAnswer(id: 1, textKey: "assessment.growth.q12.b", delta: GrowthScoreDeltas(disziplin:  1, effizienz:  3, umsetzung:  3)),
            GrowthAnswer(id: 2, textKey: "assessment.growth.q12.c", delta: GrowthScoreDeltas(disziplin: -1, effizienz:  0, umsetzung: -3)),
            GrowthAnswer(id: 3, textKey: "assessment.growth.q12.d", delta: GrowthScoreDeltas(disziplin:  0, effizienz: -1, umsetzung:  0))
        ]),
        
        // F13: Der Dopamin-Detox
        GrowthQuestion(id: 13, textKey: "assessment.growth.q13", answers: [
            GrowthAnswer(id: 0, textKey: "assessment.growth.q13.a", delta: GrowthScoreDeltas(disziplin: -1, effizienz: -1, umsetzung:  0)),
            GrowthAnswer(id: 1, textKey: "assessment.growth.q13.b", delta: GrowthScoreDeltas(disziplin:  2, effizienz:  3, umsetzung:  2)),
            GrowthAnswer(id: 2, textKey: "assessment.growth.q13.c", delta: GrowthScoreDeltas(disziplin: -3, effizienz: -2, umsetzung: -2)),
            GrowthAnswer(id: 3, textKey: "assessment.growth.q13.d", delta: GrowthScoreDeltas(disziplin: -2, effizienz:  0, umsetzung: -2))
        ]),
        
        // F14: Das leere Wochenende
        GrowthQuestion(id: 14, textKey: "assessment.growth.q14", answers: [
            GrowthAnswer(id: 0, textKey: "assessment.growth.q14.a", delta: GrowthScoreDeltas(disziplin: -3, effizienz: -2, umsetzung: -3)),
            GrowthAnswer(id: 1, textKey: "assessment.growth.q14.b", delta: GrowthScoreDeltas(disziplin:  3, effizienz:  3, umsetzung:  3)),
            GrowthAnswer(id: 2, textKey: "assessment.growth.q14.c", delta: GrowthScoreDeltas(disziplin:  0, effizienz: -3, umsetzung:  0)),
            GrowthAnswer(id: 3, textKey: "assessment.growth.q14.d", delta: GrowthScoreDeltas(disziplin: -1, effizienz:  0, umsetzung: -1))
        ]),
        
        // F15: Die harte Wahrheit
        GrowthQuestion(id: 15, textKey: "assessment.growth.q15", answers: [
            GrowthAnswer(id: 0, textKey: "assessment.growth.q15.a", delta: GrowthScoreDeltas(disziplin: -3, effizienz: -1, umsetzung:  0)),
            GrowthAnswer(id: 1, textKey: "assessment.growth.q15.b", delta: GrowthScoreDeltas(disziplin:  0, effizienz: -3, umsetzung: -2)),
            GrowthAnswer(id: 2, textKey: "assessment.growth.q15.c", delta: GrowthScoreDeltas(disziplin: -3, effizienz:  0, umsetzung: -1)),
            GrowthAnswer(id: 3, textKey: "assessment.growth.q15.d", delta: GrowthScoreDeltas(disziplin:  3, effizienz:  2, umsetzung:  2))
        ])
    ]
}
