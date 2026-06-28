import Foundation

// MARK: - Assessment Answer Option

struct AssessmentAnswer: Identifiable {
    let id: Int
    let textKey: String
    let delta: Int
}

// MARK: - Score Deltas (pro Antwort)



// MARK: - Assessment Question

struct AssessmentQuestion: Identifiable {
    let id: Int
    let textKey: String           // Lokalisierungsschlüssel für Frage
    let answers: [AssessmentAnswer]
}

// MARK: - Finance Assessment Profile

enum FinanceProfile: String, Codable, CaseIterable {
    case level1
    case level2
    case level3
    case level4

    var titleKey: String { "assessment.finance.profile.\(rawValue).title" }
    var descKey:  String { "assessment.finance.profile.\(rawValue).desc" }
    var actionKey: String { "assessment.finance.profile.\(rawValue).action" }
    var buildHabitsKey: String { "assessment.finance.profile.\(rawValue).build" }
    var breakHabitsKey: String { "assessment.finance.profile.\(rawValue).break" }

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
// MARK: - Raw Score Container



// MARK: - Assessment Result

struct AssessmentResult: Codable {
    let profile: FinanceProfile
    let score: Int
    let date: Date
}

// MARK: - Scoring Engine

enum AssessmentScoringEngine {
    static func computeProfile(from score: Int) -> FinanceProfile {
        switch score {
        case ..<(-9): return .level1
        case (-9)...5: return .level2
        case 6...20: return .level3
        default: return .level4
        }
    }
}

// MARK: - Finance Quiz Data (statisch, keine KI, kein Server)

struct FinanceQuiz {

    static let questions: [AssessmentQuestion] = [

        // F1: Unerwartete Rückzahlung
        AssessmentQuestion(id: 1, textKey: "assessment.finance.q1", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.finance.q1.a",
                             delta: -1),
            AssessmentAnswer(id: 1, textKey: "assessment.finance.q1.b",
                             delta: 1),
            AssessmentAnswer(id: 2, textKey: "assessment.finance.q1.c",
                             delta: 2),
            AssessmentAnswer(id: 3, textKey: "assessment.finance.q1.d",
                             delta: -2),
        ]),

        // F2: Investment-App
        AssessmentQuestion(id: 2, textKey: "assessment.finance.q2", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.finance.q2.a",
                             delta: -2),
            AssessmentAnswer(id: 1, textKey: "assessment.finance.q2.b",
                             delta: 1),
            AssessmentAnswer(id: 2, textKey: "assessment.finance.q2.c",
                             delta: -1),
            AssessmentAnswer(id: 3, textKey: "assessment.finance.q2.d",
                             delta: 2),
        ]),

        // F3: Kontostand ohne Nachschauen
        AssessmentQuestion(id: 3, textKey: "assessment.finance.q3", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.finance.q3.a",
                             delta: 1),
            AssessmentAnswer(id: 1, textKey: "assessment.finance.q3.b",
                             delta: -1),
            AssessmentAnswer(id: 2, textKey: "assessment.finance.q3.c",
                             delta: -2),
            AssessmentAnswer(id: 3, textKey: "assessment.finance.q3.d",
                             delta: 2),
        ]),

        // F4: Unnötiges Abo
        AssessmentQuestion(id: 4, textKey: "assessment.finance.q4", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.finance.q4.a",
                             delta: 2),
            AssessmentAnswer(id: 1, textKey: "assessment.finance.q4.b",
                             delta: -1),
            AssessmentAnswer(id: 2, textKey: "assessment.finance.q4.c",
                             delta: 1),
            AssessmentAnswer(id: 3, textKey: "assessment.finance.q4.d",
                             delta: -2),
        ]),

        // F5: Langzeit-Investment
        AssessmentQuestion(id: 5, textKey: "assessment.finance.q5", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.finance.q5.a",
                             delta: 2),
            AssessmentAnswer(id: 1, textKey: "assessment.finance.q5.b",
                             delta: -1),
            AssessmentAnswer(id: 2, textKey: "assessment.finance.q5.c",
                             delta: 1), // Neutral
            AssessmentAnswer(id: 3, textKey: "assessment.finance.q5.d",
                             delta: -2),
        ]),

        // F6: Der Lifestyle-Creep
        AssessmentQuestion(id: 6, textKey: "assessment.finance.q6", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.finance.q6.a",
                             delta: 1),
            AssessmentAnswer(id: 1, textKey: "assessment.finance.q6.b",
                             delta: -2),
            AssessmentAnswer(id: 2, textKey: "assessment.finance.q6.c",
                             delta: 2),
            AssessmentAnswer(id: 3, textKey: "assessment.finance.q6.d",
                             delta: -1),
        ]),

        // F7: Status vs. Vernunft
        AssessmentQuestion(id: 7, textKey: "assessment.finance.q7", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.finance.q7.a",
                             delta: 1),
            AssessmentAnswer(id: 1, textKey: "assessment.finance.q7.b",
                             delta: 2),
            AssessmentAnswer(id: 2, textKey: "assessment.finance.q7.c",
                             delta: -2),
            AssessmentAnswer(id: 3, textKey: "assessment.finance.q7.d",
                             delta: -1),
        ]),

        // F8: Der soziale Druck
        AssessmentQuestion(id: 8, textKey: "assessment.finance.q8", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.finance.q8.a",
                             delta: -1),
            AssessmentAnswer(id: 1, textKey: "assessment.finance.q8.b",
                             delta: 2),
            AssessmentAnswer(id: 2, textKey: "assessment.finance.q8.c",
                             delta: 1),
            AssessmentAnswer(id: 3, textKey: "assessment.finance.q8.d",
                             delta: -2),
        ]),

        // F9: Der Notfall-Schock
        AssessmentQuestion(id: 9, textKey: "assessment.finance.q9", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.finance.q9.a",
                             delta: 2),
            AssessmentAnswer(id: 1, textKey: "assessment.finance.q9.b",
                             delta: 1),
            AssessmentAnswer(id: 2, textKey: "assessment.finance.q9.c",
                             delta: -1),
            AssessmentAnswer(id: 3, textKey: "assessment.finance.q9.d",
                             delta: -2),
        ]),

        // F10: Die Sunk-Cost-Fallacy
        AssessmentQuestion(id: 10, textKey: "assessment.finance.q10", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.finance.q10.a",
                             delta: -1),
            AssessmentAnswer(id: 1, textKey: "assessment.finance.q10.b",
                             delta: 1),
            AssessmentAnswer(id: 2, textKey: "assessment.finance.q10.c",
                             delta: 2),
            AssessmentAnswer(id: 3, textKey: "assessment.finance.q10.d",
                             delta: -2),
        ]),

        // F11: Das finanzielle Tabu
        AssessmentQuestion(id: 11, textKey: "assessment.finance.q11", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.finance.q11.a",
                             delta: -2),
            AssessmentAnswer(id: 1, textKey: "assessment.finance.q11.b",
                             delta: 2),
            AssessmentAnswer(id: 2, textKey: "assessment.finance.q11.c",
                             delta: -1),
            AssessmentAnswer(id: 3, textKey: "assessment.finance.q11.d",
                             delta: 1),
        ]),

        // F12: Die Gier-Falle
        AssessmentQuestion(id: 12, textKey: "assessment.finance.q12", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.finance.q12.a",
                             delta: -2),
            AssessmentAnswer(id: 1, textKey: "assessment.finance.q12.b",
                             delta: -1),
            AssessmentAnswer(id: 2, textKey: "assessment.finance.q12.c",
                             delta: 2),
            AssessmentAnswer(id: 3, textKey: "assessment.finance.q12.d",
                             delta: 1),
        ]),

        // F13: Das Mathe-Paradoxon
        AssessmentQuestion(id: 13, textKey: "assessment.finance.q13", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.finance.q13.a",
                             delta: 2),
            AssessmentAnswer(id: 1, textKey: "assessment.finance.q13.b",
                             delta: 1),
            AssessmentAnswer(id: 2, textKey: "assessment.finance.q13.c",
                             delta: -1),
            AssessmentAnswer(id: 3, textKey: "assessment.finance.q13.d",
                             delta: -2),
        ]),

        // F14: Die Mikrolecks
        AssessmentQuestion(id: 14, textKey: "assessment.finance.q14", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.finance.q14.a",
                             delta: -2),
            AssessmentAnswer(id: 1, textKey: "assessment.finance.q14.b",
                             delta: 1),
            AssessmentAnswer(id: 2, textKey: "assessment.finance.q14.c",
                             delta: 2),
            AssessmentAnswer(id: 3, textKey: "assessment.finance.q14.d",
                             delta: -1),
        ]),

        // F15: Das ultimative Endziel
        AssessmentQuestion(id: 15, textKey: "assessment.finance.q15", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.finance.q15.a",
                             delta: 2),
            AssessmentAnswer(id: 1, textKey: "assessment.finance.q15.b",
                             delta: -1),
            AssessmentAnswer(id: 2, textKey: "assessment.finance.q15.c",
                             delta: -2),
            AssessmentAnswer(id: 3, textKey: "assessment.finance.q15.d",
                             delta: 1),
        ]),
    ]
}

// MARK: - Mental Assessment Answer Deltas



// MARK: - Mental Assessment Answer



// MARK: - Mental Assessment Question



// MARK: - Mental Profile

enum MentalProfile: String, Codable, CaseIterable {
    case level1
    case level2
    case level3
    case level4

    var titleKey: String { "assessment.mental.profile.\(rawValue).title" }
    var descKey:  String { "assessment.mental.profile.\(rawValue).desc" }
    var actionKey: String { "assessment.mental.profile.\(rawValue).action" }
    var buildHabitsKey: String { "assessment.mental.profile.\(rawValue).build" }
    var breakHabitsKey: String { "assessment.mental.profile.\(rawValue).break" }

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
// MARK: - Mental Raw Score



// MARK: - Mental Assessment Result

struct MentalAssessmentResult: Codable {
    let profile: MentalProfile
    let score: Int
    let date: Date
}

// MARK: - Mental Scoring Engine

enum MentalScoringEngine {
    static func computeProfile(from score: Int) -> MentalProfile {
        switch score {
        case ..<(-9): return .level1
        case (-9)...5: return .level2
        case 6...20: return .level3
        default: return .level4
        }
    }
}

// MARK: - Mental Quiz Data (15 Fragen, keine KI, kein Server)

struct MentalQuiz {

    static let questions: [AssessmentQuestion] = [

        // F1: Der erste Einbruch
        AssessmentQuestion(id: 1, textKey: "assessment.mental.q1", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.mental.q1.a",
                         delta: -2),
            AssessmentAnswer(id: 1, textKey: "assessment.mental.q1.b",
                         delta: -1),
            AssessmentAnswer(id: 2, textKey: "assessment.mental.q1.c",
                         delta: 2),
            AssessmentAnswer(id: 3, textKey: "assessment.mental.q1.d",
                         delta: 1),
        ]),

        // F2: Das Nein-Problem
        AssessmentQuestion(id: 2, textKey: "assessment.mental.q2", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.mental.q2.a",
                         delta: -2),
            AssessmentAnswer(id: 1, textKey: "assessment.mental.q2.b",
                         delta: 1),
            AssessmentAnswer(id: 2, textKey: "assessment.mental.q2.c",
                         delta: 2),
            AssessmentAnswer(id: 3, textKey: "assessment.mental.q2.d",
                         delta: -1),
        ]),

        // F3: Der Komfort-Trap
        AssessmentQuestion(id: 3, textKey: "assessment.mental.q3", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.mental.q3.a",
                         delta: 1),
            AssessmentAnswer(id: 1, textKey: "assessment.mental.q3.b",
                         delta: -1),
            AssessmentAnswer(id: 2, textKey: "assessment.mental.q3.c",
                         delta: 2),
            AssessmentAnswer(id: 3, textKey: "assessment.mental.q3.d",
                         delta: -2),
        ]),

        // F4: Die Bewunderungssucht
        AssessmentQuestion(id: 4, textKey: "assessment.mental.q4", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.mental.q4.a",
                         delta: -1),
            AssessmentAnswer(id: 1, textKey: "assessment.mental.q4.b",
                         delta: -2),
            AssessmentAnswer(id: 2, textKey: "assessment.mental.q4.c",
                         delta: 2),
            AssessmentAnswer(id: 3, textKey: "assessment.mental.q4.d",
                         delta: 1),
        ]),

        // F5: Der unverdiente Sieg
        AssessmentQuestion(id: 5, textKey: "assessment.mental.q5", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.mental.q5.a",
                         delta: -2),
            AssessmentAnswer(id: 1, textKey: "assessment.mental.q5.b",
                         delta: 1),
            AssessmentAnswer(id: 2, textKey: "assessment.mental.q5.c",
                         delta: 2),
            AssessmentAnswer(id: 3, textKey: "assessment.mental.q5.d",
                         delta: -1),
        ]),

        // F6: Die toxische Isolation
        AssessmentQuestion(id: 6, textKey: "assessment.mental.q6", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.mental.q6.a",
                         delta: -1),
            AssessmentAnswer(id: 1, textKey: "assessment.mental.q6.b",
                         delta: 2),
            AssessmentAnswer(id: 2, textKey: "assessment.mental.q6.c",
                         delta: -2),
            AssessmentAnswer(id: 3, textKey: "assessment.mental.q6.d",
                         delta: 1),
        ]),

        // F7: Der Triumph des Feindes
        AssessmentQuestion(id: 7, textKey: "assessment.mental.q7", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.mental.q7.a",
                         delta: -1),
            AssessmentAnswer(id: 1, textKey: "assessment.mental.q7.b",
                         delta: -2),
            AssessmentAnswer(id: 2, textKey: "assessment.mental.q7.c",
                         delta: 2),
            AssessmentAnswer(id: 3, textKey: "assessment.mental.q7.d",
                         delta: 1),
        ]),

        // F8: Die öffentliche Demütigung
        AssessmentQuestion(id: 8, textKey: "assessment.mental.q8", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.mental.q8.a",
                         delta: -2),
            AssessmentAnswer(id: 1, textKey: "assessment.mental.q8.b",
                         delta: -1),
            AssessmentAnswer(id: 2, textKey: "assessment.mental.q8.c",
                         delta: 2),
            AssessmentAnswer(id: 3, textKey: "assessment.mental.q8.d",
                         delta: 1),
        ]),

        // F9: Die falsche Anschuldigung
        AssessmentQuestion(id: 9, textKey: "assessment.mental.q9", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.mental.q9.a",
                         delta: -2),
            AssessmentAnswer(id: 1, textKey: "assessment.mental.q9.b",
                         delta: 1),
            AssessmentAnswer(id: 2, textKey: "assessment.mental.q9.c",
                         delta: 2),
            AssessmentAnswer(id: 3, textKey: "assessment.mental.q9.d",
                         delta: -1),
        ]),

        // F10: Die absolute Erschöpfung
        AssessmentQuestion(id: 10, textKey: "assessment.mental.q10", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.mental.q10.a",
                         delta: 1),
            AssessmentAnswer(id: 1, textKey: "assessment.mental.q10.b",
                         delta: -1),
            AssessmentAnswer(id: 2, textKey: "assessment.mental.q10.c",
                         delta: 2),
            AssessmentAnswer(id: 3, textKey: "assessment.mental.q10.d",
                         delta: -2),
        ]),

        // F11: Der dumme Befehl
        AssessmentQuestion(id: 11, textKey: "assessment.mental.q11", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.mental.q11.a",
                         delta: -1),
            AssessmentAnswer(id: 1, textKey: "assessment.mental.q11.b",
                         delta: -2),
            AssessmentAnswer(id: 2, textKey: "assessment.mental.q11.c",
                         delta: 1),
            AssessmentAnswer(id: 3, textKey: "assessment.mental.q11.d",
                         delta: 2),
        ]),

        // F12: Die emotionale Erpressung
        AssessmentQuestion(id: 12, textKey: "assessment.mental.q12", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.mental.q12.a",
                         delta: -2),
            AssessmentAnswer(id: 1, textKey: "assessment.mental.q12.b",
                         delta: -1),
            AssessmentAnswer(id: 2, textKey: "assessment.mental.q12.c",
                         delta: 1),
            AssessmentAnswer(id: 3, textKey: "assessment.mental.q12.d",
                         delta: 2),
        ]),

        // F13: Der Mitläufer-Test
        AssessmentQuestion(id: 13, textKey: "assessment.mental.q13", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.mental.q13.a",
                         delta: -2),
            AssessmentAnswer(id: 1, textKey: "assessment.mental.q13.b",
                         delta: 1),
            AssessmentAnswer(id: 2, textKey: "assessment.mental.q13.c",
                         delta: 2),
            AssessmentAnswer(id: 3, textKey: "assessment.mental.q13.d",
                         delta: -1),
        ]),

        // F14: Die versenkte Zeit (Sunk Cost)
        AssessmentQuestion(id: 14, textKey: "assessment.mental.q14", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.mental.q14.a",
                         delta: -2),
            AssessmentAnswer(id: 1, textKey: "assessment.mental.q14.b",
                         delta: -1),
            AssessmentAnswer(id: 2, textKey: "assessment.mental.q14.c",
                         delta: 2),
            AssessmentAnswer(id: 3, textKey: "assessment.mental.q14.d",
                         delta: 1),
        ]),

        // F15: Die Sabotage
        AssessmentQuestion(id: 15, textKey: "assessment.mental.q15", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.mental.q15.a",
                         delta: -1),
            AssessmentAnswer(id: 1, textKey: "assessment.mental.q15.b",
                         delta: -2),
            AssessmentAnswer(id: 2, textKey: "assessment.mental.q15.c",
                         delta: 2),
            AssessmentAnswer(id: 3, textKey: "assessment.mental.q15.d",
                         delta: 1),
        ]),
    ]
}

// MARK: - Health Assessment Score Deltas



// MARK: - Health Assessment Answer



// MARK: - Health Assessment Question



// MARK: - Health Profile

enum HealthProfile: String, Codable, CaseIterable {
    case level1
    case level2
    case level3
    case level4

    var titleKey: String { "assessment.health.profile.\(rawValue).title" }
    var descKey:  String { "assessment.health.profile.\(rawValue).desc" }
    var actionKey: String { "assessment.health.profile.\(rawValue).action" }
    var buildHabitsKey: String { "assessment.health.profile.\(rawValue).build" }
    var breakHabitsKey: String { "assessment.health.profile.\(rawValue).break" }

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
// MARK: - Health Raw Score



// MARK: - Health Assessment Result

struct HealthAssessmentResult: Codable {
    let profile: HealthProfile
    let score: Int
    let date: Date
}

// MARK: - Health Scoring Engine

enum HealthScoringEngine {
    static func computeProfile(from score: Int) -> HealthProfile {
        switch score {
        case ..<(-9): return .level1
        case (-9)...5: return .level2
        case 6...20: return .level3
        default: return .level4
        }
    }
}

// MARK: - Health Quiz Data (15 Szenarien, keine KI, kein Server)

struct HealthQuiz {

    static let questions: [AssessmentQuestion] = [

        // F1: Der kognitive Crash
        AssessmentQuestion(id: 1, textKey: "assessment.health.q1", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.health.q1.a",
                         delta: -2),
            AssessmentAnswer(id: 1, textKey: "assessment.health.q1.b",
                         delta: 1),
            AssessmentAnswer(id: 2, textKey: "assessment.health.q1.c",
                         delta: 2),
            AssessmentAnswer(id: 3, textKey: "assessment.health.q1.d",
                         delta: -1),
        ]),

        // F2: Die Rache des Weckers
        AssessmentQuestion(id: 2, textKey: "assessment.health.q2", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.health.q2.a",
                         delta: -1),
            AssessmentAnswer(id: 1, textKey: "assessment.health.q2.b",
                         delta: -2),
            AssessmentAnswer(id: 2, textKey: "assessment.health.q2.c",
                         delta: 2),
            AssessmentAnswer(id: 3, textKey: "assessment.health.q2.d",
                         delta: 1),
        ]),

        // F3: Der Krankheits-Ego-Trip
        AssessmentQuestion(id: 3, textKey: "assessment.health.q3", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.health.q3.a",
                         delta: -1),
            AssessmentAnswer(id: 1, textKey: "assessment.health.q3.b",
                         delta: -2),
            AssessmentAnswer(id: 2, textKey: "assessment.health.q3.c",
                         delta: 2),
            AssessmentAnswer(id: 3, textKey: "assessment.health.q3.d",
                         delta: 1),
        ]),

        // F4: Die Notfall-Betankung
        AssessmentQuestion(id: 4, textKey: "assessment.health.q4", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.health.q4.a",
                         delta: -2),
            AssessmentAnswer(id: 1, textKey: "assessment.health.q4.b",
                         delta: 1),
            AssessmentAnswer(id: 2, textKey: "assessment.health.q4.c",
                         delta: 2),
            AssessmentAnswer(id: 3, textKey: "assessment.health.q4.d",
                         delta: -1),
        ]),

        // F5: Der Dopamin-Schlaf
        AssessmentQuestion(id: 5, textKey: "assessment.health.q5", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.health.q5.a",
                         delta: -1),
            AssessmentAnswer(id: 1, textKey: "assessment.health.q5.b",
                         delta: 1),
            AssessmentAnswer(id: 2, textKey: "assessment.health.q5.c",
                         delta: 2),
            AssessmentAnswer(id: 3, textKey: "assessment.health.q5.d",
                         delta: -2),
        ]),

        // F6: Die Wasser-Lüge
        AssessmentQuestion(id: 6, textKey: "assessment.health.q6", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.health.q6.a",
                         delta: -1),
            AssessmentAnswer(id: 1, textKey: "assessment.health.q6.b",
                         delta: -2),
            AssessmentAnswer(id: 2, textKey: "assessment.health.q6.c",
                         delta: 2),
            AssessmentAnswer(id: 3, textKey: "assessment.health.q6.d",
                         delta: 1),
        ]),

        // F7: Das Wochenend-Koma
        AssessmentQuestion(id: 7, textKey: "assessment.health.q7", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.health.q7.a",
                         delta: -1),
            AssessmentAnswer(id: 1, textKey: "assessment.health.q7.b",
                         delta: 2),
            AssessmentAnswer(id: 2, textKey: "assessment.health.q7.c",
                         delta: -2),
            AssessmentAnswer(id: 3, textKey: "assessment.health.q7.d",
                         delta: 1),
        ]),

        // F8: Soziales Gift
        AssessmentQuestion(id: 8, textKey: "assessment.health.q8", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.health.q8.a",
                         delta: -2),
            AssessmentAnswer(id: 1, textKey: "assessment.health.q8.b",
                         delta: -1),
            AssessmentAnswer(id: 2, textKey: "assessment.health.q8.c",
                         delta: 2),
            AssessmentAnswer(id: 3, textKey: "assessment.health.q8.d",
                         delta: 1),
        ]),

        // F9: Schmerz-Ignoranz
        AssessmentQuestion(id: 9, textKey: "assessment.health.q9", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.health.q9.a",
                         delta: -2),
            AssessmentAnswer(id: 1, textKey: "assessment.health.q9.b",
                         delta: -1),
            AssessmentAnswer(id: 2, textKey: "assessment.health.q9.c",
                         delta: 2),
            AssessmentAnswer(id: 3, textKey: "assessment.health.q9.d",
                         delta: 1),
        ]),

        // F10: Die Alibi-Vitamine
        AssessmentQuestion(id: 10, textKey: "assessment.health.q10", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.health.q10.a",
                         delta: -2),
            AssessmentAnswer(id: 1, textKey: "assessment.health.q10.b",
                         delta: 1),
            AssessmentAnswer(id: 2, textKey: "assessment.health.q10.c",
                         delta: 2),
            AssessmentAnswer(id: 3, textKey: "assessment.health.q10.d",
                         delta: -1),
        ]),

        // F11: Der Bildschirm-Kredit
        AssessmentQuestion(id: 11, textKey: "assessment.health.q11", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.health.q11.a",
                         delta: -2),
            AssessmentAnswer(id: 1, textKey: "assessment.health.q11.b",
                         delta: -1),
            AssessmentAnswer(id: 2, textKey: "assessment.health.q11.c",
                         delta: 2),
            AssessmentAnswer(id: 3, textKey: "assessment.health.q11.d",
                         delta: 1),
        ]),

        // F12: Die Basis-Hygiene
        AssessmentQuestion(id: 12, textKey: "assessment.health.q12", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.health.q12.a",
                         delta: -2),
            AssessmentAnswer(id: 1, textKey: "assessment.health.q12.b",
                         delta: -1),
            AssessmentAnswer(id: 2, textKey: "assessment.health.q12.c",
                         delta: 2),
            AssessmentAnswer(id: 3, textKey: "assessment.health.q12.d",
                         delta: 1),
        ]),

        // F13: Der Stress-Atem
        AssessmentQuestion(id: 13, textKey: "assessment.health.q13", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.health.q13.a",
                         delta: -2),
            AssessmentAnswer(id: 1, textKey: "assessment.health.q13.b",
                         delta: 1),
            AssessmentAnswer(id: 2, textKey: "assessment.health.q13.c",
                         delta: 2),
            AssessmentAnswer(id: 3, textKey: "assessment.health.q13.d",
                         delta: -1),
        ]),

        // F14: Die blinde Ignoranz
        AssessmentQuestion(id: 14, textKey: "assessment.health.q14", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.health.q14.a",
                         delta: -2),
            AssessmentAnswer(id: 1, textKey: "assessment.health.q14.b",
                         delta: 1),
            AssessmentAnswer(id: 2, textKey: "assessment.health.q14.c",
                         delta: 2),
            AssessmentAnswer(id: 3, textKey: "assessment.health.q14.d",
                         delta: -1),
        ]),

        // F15: Das wahre Motiv
        AssessmentQuestion(id: 15, textKey: "assessment.health.q15", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.health.q15.a",
                         delta: -1),
            AssessmentAnswer(id: 1, textKey: "assessment.health.q15.b",
                         delta: 1),
            AssessmentAnswer(id: 2, textKey: "assessment.health.q15.c",
                         delta: 2),
            AssessmentAnswer(id: 3, textKey: "assessment.health.q15.d",
                         delta: -2),
        ]),
    ]
}


// MARK: - Fitness Assessment Score Deltas



// MARK: - Fitness Assessment Answer



// MARK: - Fitness Assessment Question



// MARK: - Fitness Profile

enum FitnessProfile: String, Codable, CaseIterable {
    case level1
    case level2
    case level3
    case level4

    var titleKey: String { "assessment.fitness.profile.\(rawValue).title" }
    var descKey:  String { "assessment.fitness.profile.\(rawValue).desc" }
    var actionKey: String { "assessment.fitness.profile.\(rawValue).action" }
    var buildHabitsKey: String { "assessment.fitness.profile.\(rawValue).build" }
    var breakHabitsKey: String { "assessment.fitness.profile.\(rawValue).break" }

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
// MARK: - Fitness Raw Score



// MARK: - Fitness Assessment Result

struct FitnessAssessmentResult: Codable {
    let profile: FitnessProfile
    let score: Int
    let date: Date
}

// MARK: - Fitness Scoring Engine

enum FitnessScoringEngine {
    static func computeProfile(from score: Int) -> FitnessProfile {
        switch score {
        case ..<(-9): return .level1
        case (-9)...5: return .level2
        case 6...20: return .level3
        default: return .level4
        }
    }
}

// MARK: - Fitness Quiz Data

struct FitnessQuiz {
    static let questions: [AssessmentQuestion] = [


        // F1
        AssessmentQuestion(id: 1, textKey: "assessment.fitness.q1", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.fitness.q1.a",
                          delta: -1),
            AssessmentAnswer(id: 1, textKey: "assessment.fitness.q1.b",
                          delta: -2),
            AssessmentAnswer(id: 2, textKey: "assessment.fitness.q1.c",
                          delta: 1),
            AssessmentAnswer(id: 3, textKey: "assessment.fitness.q1.d",
                          delta: 2),
        ]),

        // F2
        AssessmentQuestion(id: 2, textKey: "assessment.fitness.q2", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.fitness.q2.a",
                          delta: -2),
            AssessmentAnswer(id: 1, textKey: "assessment.fitness.q2.b",
                          delta: -1),
            AssessmentAnswer(id: 2, textKey: "assessment.fitness.q2.c",
                          delta: 1),
            AssessmentAnswer(id: 3, textKey: "assessment.fitness.q2.d",
                          delta: 2),
        ]),

        // F3
        AssessmentQuestion(id: 3, textKey: "assessment.fitness.q3", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.fitness.q3.a",
                          delta: -2),
            AssessmentAnswer(id: 1, textKey: "assessment.fitness.q3.b",
                          delta: -1),
            AssessmentAnswer(id: 2, textKey: "assessment.fitness.q3.c",
                          delta: 1),
            AssessmentAnswer(id: 3, textKey: "assessment.fitness.q3.d",
                          delta: 2),
        ]),

        // F4
        AssessmentQuestion(id: 4, textKey: "assessment.fitness.q4", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.fitness.q4.a",
                          delta: -1),
            AssessmentAnswer(id: 1, textKey: "assessment.fitness.q4.b",
                          delta: -2),
            AssessmentAnswer(id: 2, textKey: "assessment.fitness.q4.c",
                          delta: 1),
            AssessmentAnswer(id: 3, textKey: "assessment.fitness.q4.d",
                          delta: 2),
        ]),

        // F5
        AssessmentQuestion(id: 5, textKey: "assessment.fitness.q5", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.fitness.q5.a",
                          delta: -1),
            AssessmentAnswer(id: 1, textKey: "assessment.fitness.q5.b",
                          delta: -2),
            AssessmentAnswer(id: 2, textKey: "assessment.fitness.q5.c",
                          delta: 1),
            AssessmentAnswer(id: 3, textKey: "assessment.fitness.q5.d",
                          delta: 2),
        ]),

        // F6
        AssessmentQuestion(id: 6, textKey: "assessment.fitness.q6", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.fitness.q6.a",
                          delta: -2),
            AssessmentAnswer(id: 1, textKey: "assessment.fitness.q6.b",
                          delta: -1),
            AssessmentAnswer(id: 2, textKey: "assessment.fitness.q6.c",
                          delta: 1),
            AssessmentAnswer(id: 3, textKey: "assessment.fitness.q6.d",
                          delta: 2),
        ]),

        // F7
        AssessmentQuestion(id: 7, textKey: "assessment.fitness.q7", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.fitness.q7.a",
                          delta: 1),
            AssessmentAnswer(id: 1, textKey: "assessment.fitness.q7.b",
                          delta: -2),
            AssessmentAnswer(id: 2, textKey: "assessment.fitness.q7.c",
                          delta: 2),
            AssessmentAnswer(id: 3, textKey: "assessment.fitness.q7.d",
                          delta: -1),
        ]),

        // F8
        AssessmentQuestion(id: 8, textKey: "assessment.fitness.q8", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.fitness.q8.a",
                          delta: -2),
            AssessmentAnswer(id: 1, textKey: "assessment.fitness.q8.b",
                          delta: -1),
            AssessmentAnswer(id: 2, textKey: "assessment.fitness.q8.c",
                          delta: 1),
            AssessmentAnswer(id: 3, textKey: "assessment.fitness.q8.d",
                          delta: 2),
        ]),

        // F9
        AssessmentQuestion(id: 9, textKey: "assessment.fitness.q9", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.fitness.q9.a",
                          delta: -2),
            AssessmentAnswer(id: 1, textKey: "assessment.fitness.q9.b",
                          delta: -1),
            AssessmentAnswer(id: 2, textKey: "assessment.fitness.q9.c",
                          delta: 1),
            AssessmentAnswer(id: 3, textKey: "assessment.fitness.q9.d",
                          delta: 2),
        ]),

        // F10
        AssessmentQuestion(id: 10, textKey: "assessment.fitness.q10", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.fitness.q10.a",
                          delta: -1),
            AssessmentAnswer(id: 1, textKey: "assessment.fitness.q10.b",
                          delta: -2),
            AssessmentAnswer(id: 2, textKey: "assessment.fitness.q10.c",
                          delta: 1),
            AssessmentAnswer(id: 3, textKey: "assessment.fitness.q10.d",
                          delta: 2),
        ]),

        // F11
        AssessmentQuestion(id: 11, textKey: "assessment.fitness.q11", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.fitness.q11.a",
                          delta: -2),
            AssessmentAnswer(id: 1, textKey: "assessment.fitness.q11.b",
                          delta: 1),
            AssessmentAnswer(id: 2, textKey: "assessment.fitness.q11.c",
                          delta: 2),
            AssessmentAnswer(id: 3, textKey: "assessment.fitness.q11.d",
                          delta: -1),
        ]),

        // F12
        AssessmentQuestion(id: 12, textKey: "assessment.fitness.q12", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.fitness.q12.a",
                          delta: -2),
            AssessmentAnswer(id: 1, textKey: "assessment.fitness.q12.b",
                          delta: -1),
            AssessmentAnswer(id: 2, textKey: "assessment.fitness.q12.c",
                          delta: 1),
            AssessmentAnswer(id: 3, textKey: "assessment.fitness.q12.d",
                          delta: 2),
        ]),

        // F13
        AssessmentQuestion(id: 13, textKey: "assessment.fitness.q13", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.fitness.q13.a",
                          delta: -1),
            AssessmentAnswer(id: 1, textKey: "assessment.fitness.q13.b",
                          delta: -2),
            AssessmentAnswer(id: 2, textKey: "assessment.fitness.q13.c",
                          delta: 1),
            AssessmentAnswer(id: 3, textKey: "assessment.fitness.q13.d",
                          delta: 2),
        ]),

        // F14
        AssessmentQuestion(id: 14, textKey: "assessment.fitness.q14", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.fitness.q14.a",
                          delta: -2),
            AssessmentAnswer(id: 1, textKey: "assessment.fitness.q14.b",
                          delta: -1),
            AssessmentAnswer(id: 2, textKey: "assessment.fitness.q14.c",
                          delta: 1),
            AssessmentAnswer(id: 3, textKey: "assessment.fitness.q14.d",
                          delta: 2),
        ]),

        // F15
        AssessmentQuestion(id: 15, textKey: "assessment.fitness.q15", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.fitness.q15.a",
                          delta: -1),
            AssessmentAnswer(id: 1, textKey: "assessment.fitness.q15.b",
                          delta: -2),
            AssessmentAnswer(id: 2, textKey: "assessment.fitness.q15.c",
                          delta: 1),
            AssessmentAnswer(id: 3, textKey: "assessment.fitness.q15.d",
                          delta: 2),
        ]),


    ]
}
