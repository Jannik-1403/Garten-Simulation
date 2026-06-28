import Foundation

// MARK: - Assessment Answer Option

struct AssessmentAnswer: Identifiable {
    let id: Int
    let textKey: String        // Lokalisierungsschlüssel
    let delta: ScoreDeltas     // Welche Parameter verändert diese Antwort?
}

// MARK: - Score Deltas (pro Antwort)

struct ScoreDeltas {
    let kontrolle: Int
    let entscheidung: Int
    let risiko: Int
}

// MARK: - Assessment Question

struct AssessmentQuestion: Identifiable {
    let id: Int
    let textKey: String           // Lokalisierungsschlüssel für Frage
    let answers: [AssessmentAnswer]
}

// MARK: - Finance Assessment Profile

enum FinanceProfile: String, Codable, CaseIterable {
    case verdraenger      // Schwächster Parameter: kontrolle
    case prokrastinator   // Schwächster Parameter: entscheidung
    case impulsiver       // Schwächster Parameter: risiko
    case kontrolleur      // Alle Parameter ≥ 0

    var titleKey: String { "assessment.finance.profile.\(rawValue).title" }
    var descKey:  String { "assessment.finance.profile.\(rawValue).desc" }
    var actionKey: String { "assessment.finance.profile.\(rawValue).action" }
    var buildHabitsKey: String { "assessment.finance.profile.\(rawValue).build" }
    var breakHabitsKey: String { "assessment.finance.profile.\(rawValue).break" }

    var icon: String {
        switch self {
        case .verdraenger:    return "eye.slash.fill"
        case .prokrastinator: return "clock.badge.exclamationmark"
        case .impulsiver:     return "bolt.fill"
        case .kontrolleur:    return "checkmark.seal.fill"
        }
    }

    var color: String {
        switch self {
        case .verdraenger:    return "#FF6B6B"
        case .prokrastinator: return "#FFB347"
        case .impulsiver:     return "#DA70D6"
        case .kontrolleur:    return "#4CAF50"
        }
    }
}

// MARK: - Raw Score Container

struct AssessmentRawScore {
    var kontrolle: Int = 0
    var entscheidung: Int = 0
    var risiko: Int = 0
}

// MARK: - Assessment Result

struct AssessmentResult: Codable {
    let profile: FinanceProfile
    let rawKontrolle: Int
    let rawEntscheidung: Int
    let rawRisiko: Int
    let date: Date
}

// MARK: - Scoring Engine

enum AssessmentScoringEngine {

    // Theoretisch mögliche Minima (absoluter Betrag) über alle 9 Fragen:
    // kontrolle:    min = -17  → Teiler 17.0
    // entscheidung: min = -11  → Teiler 11.0
    // risiko:       min = -13  → Teiler 13.0
    private static let kontrolleRange:    Double = 17.0
    private static let entscheidungRange: Double = 11.0
    private static let risikoRange:       Double = 13.0

    /// Berechnet das Profil auf Basis des normierten Dominanz-Prinzips.
    /// - Kein Float-==Vergleich. Dominanz wird über Sortierung (min-Index) bestimmt.
    /// - Bei Gleichstand gilt die Priorität: kontrolle > entscheidung > risiko
    static func computeProfile(from score: AssessmentRawScore) -> FinanceProfile {

        // Alle Parameter positiv → Kontrolleur, keine Normierung nötig.
        if score.kontrolle >= 0 && score.entscheidung >= 0 && score.risiko >= 0 {
            return .kontrolleur
        }

        // Normierung: jeder Wert wird auf seinen maximalen negativen Range geteilt.
        // Ein niedriger (negativerer) normierter Wert = größte relative Schwäche.
        let normKontrolle    = Double(score.kontrolle)    / kontrolleRange
        let normEntscheidung = Double(score.entscheidung) / entscheidungRange
        let normRisiko       = Double(score.risiko)        / risikoRange

        // Kandidatenpaare: (normierter Wert, Priorität niedrig=schlechter, Profil)
        // Priorität: 0 = höchste (tritt bei Gleichstand zuerst auf)
        let candidates: [(value: Double, priority: Int, profile: FinanceProfile)] = [
            (normKontrolle,    0, .verdraenger),
            (normEntscheidung, 1, .prokrastinator),
            (normRisiko,       2, .impulsiver)
        ]

        // Nur Parameter einbeziehen, die überhaupt negativ sind.
        let negatives = candidates.filter { $0.value < 0 }

        // Sollte nicht auftreten (da oben schon alle ≥ 0 abgefangen), Fallback.
        guard !negatives.isEmpty else { return .kontrolleur }

        // Sortieren: niedrigster Wert zuerst, bei Gleichstand: niedrigste Priorität zuerst.
        let dominant = negatives.min { lhs, rhs in
            if lhs.value != rhs.value { return lhs.value < rhs.value }
            return lhs.priority < rhs.priority
        }!

        return dominant.profile
    }
}

// MARK: - Finance Quiz Data (statisch, keine KI, kein Server)

struct FinanceQuiz {

    static let questions: [AssessmentQuestion] = [

        // F1: Unerwartete Rückzahlung
        AssessmentQuestion(id: 1, textKey: "assessment.finance.q1", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.finance.q1.a",
                             delta: ScoreDeltas(kontrolle: -2, entscheidung: -1, risiko:  0)),
            AssessmentAnswer(id: 1, textKey: "assessment.finance.q1.b",
                             delta: ScoreDeltas(kontrolle: -1, entscheidung:  0, risiko: -1)),
            AssessmentAnswer(id: 2, textKey: "assessment.finance.q1.c",
                             delta: ScoreDeltas(kontrolle:  2, entscheidung:  1, risiko:  0)),
            AssessmentAnswer(id: 3, textKey: "assessment.finance.q1.d",
                             delta: ScoreDeltas(kontrolle:  0, entscheidung: -2, risiko: -1)),
        ]),

        // F2: Investment-App
        AssessmentQuestion(id: 2, textKey: "assessment.finance.q2", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.finance.q2.a",
                             delta: ScoreDeltas(kontrolle: -1, entscheidung: -1, risiko: -2)),
            AssessmentAnswer(id: 1, textKey: "assessment.finance.q2.b",
                             delta: ScoreDeltas(kontrolle:  0, entscheidung:  1, risiko:  1)),
            AssessmentAnswer(id: 2, textKey: "assessment.finance.q2.c",
                             delta: ScoreDeltas(kontrolle:  0, entscheidung: -2, risiko:  0)),
            AssessmentAnswer(id: 3, textKey: "assessment.finance.q2.d",
                             delta: ScoreDeltas(kontrolle:  2, entscheidung:  0, risiko:  1)),
        ]),

        // F3: Kontostand ohne Nachschauen
        AssessmentQuestion(id: 3, textKey: "assessment.finance.q3", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.finance.q3.a",
                             delta: ScoreDeltas(kontrolle:  1, entscheidung:  0, risiko:  0)),
            AssessmentAnswer(id: 1, textKey: "assessment.finance.q3.b",
                             delta: ScoreDeltas(kontrolle:  0, entscheidung:  0, risiko:  0)),
            AssessmentAnswer(id: 2, textKey: "assessment.finance.q3.c",
                             delta: ScoreDeltas(kontrolle: -3, entscheidung: -1, risiko:  0)),
            AssessmentAnswer(id: 3, textKey: "assessment.finance.q3.d",
                             delta: ScoreDeltas(kontrolle:  3, entscheidung:  0, risiko:  0)),
        ]),

        // F4: Unnötiges Abo
        AssessmentQuestion(id: 4, textKey: "assessment.finance.q4", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.finance.q4.a",
                             delta: ScoreDeltas(kontrolle:  2, entscheidung:  2, risiko:  0)),
            AssessmentAnswer(id: 1, textKey: "assessment.finance.q4.b",
                             delta: ScoreDeltas(kontrolle: -1, entscheidung: -2, risiko: -1)),
            AssessmentAnswer(id: 2, textKey: "assessment.finance.q4.c",
                             delta: ScoreDeltas(kontrolle: -2, entscheidung:  0, risiko:  0)),
            AssessmentAnswer(id: 3, textKey: "assessment.finance.q4.d",
                             delta: ScoreDeltas(kontrolle: -3, entscheidung: -1, risiko: -1)),
        ]),

        // F5: Langzeit-Investment
        AssessmentQuestion(id: 5, textKey: "assessment.finance.q5", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.finance.q5.a",
                             delta: ScoreDeltas(kontrolle:  1, entscheidung:  2, risiko:  2)),
            AssessmentAnswer(id: 1, textKey: "assessment.finance.q5.b",
                             delta: ScoreDeltas(kontrolle:  0, entscheidung: -1, risiko: -1)),
            AssessmentAnswer(id: 2, textKey: "assessment.finance.q5.c",
                             delta: ScoreDeltas(kontrolle:  0, entscheidung:  0, risiko:  0)), // Neutral
            AssessmentAnswer(id: 3, textKey: "assessment.finance.q5.d",
                             delta: ScoreDeltas(kontrolle:  0, entscheidung: -1, risiko: -2)),
        ]),

        // F6: Der Lifestyle-Creep
        AssessmentQuestion(id: 6, textKey: "assessment.finance.q6", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.finance.q6.a",
                             delta: ScoreDeltas(kontrolle: -1, entscheidung:  1, risiko: -3)),
            AssessmentAnswer(id: 1, textKey: "assessment.finance.q6.b",
                             delta: ScoreDeltas(kontrolle: -3, entscheidung: -2, risiko: -1)),
            AssessmentAnswer(id: 2, textKey: "assessment.finance.q6.c",
                             delta: ScoreDeltas(kontrolle:  2, entscheidung:  2, risiko:  2)),
            AssessmentAnswer(id: 3, textKey: "assessment.finance.q6.d",
                             delta: ScoreDeltas(kontrolle:  0, entscheidung: -2, risiko: -1)),
        ]),

        // F7: Status vs. Vernunft
        AssessmentQuestion(id: 7, textKey: "assessment.finance.q7", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.finance.q7.a",
                             delta: ScoreDeltas(kontrolle:  1, entscheidung:  1, risiko: -2)),
            AssessmentAnswer(id: 1, textKey: "assessment.finance.q7.b",
                             delta: ScoreDeltas(kontrolle:  2, entscheidung:  2, risiko:  3)),
            AssessmentAnswer(id: 2, textKey: "assessment.finance.q7.c",
                             delta: ScoreDeltas(kontrolle: -2, entscheidung:  0, risiko: -3)),
            AssessmentAnswer(id: 3, textKey: "assessment.finance.q7.d",
                             delta: ScoreDeltas(kontrolle:  1, entscheidung: -1, risiko: -1)),
        ]),

        // F8: Der soziale Druck
        AssessmentQuestion(id: 8, textKey: "assessment.finance.q8", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.finance.q8.a",
                             delta: ScoreDeltas(kontrolle: -1, entscheidung: -2, risiko: -1)),
            AssessmentAnswer(id: 1, textKey: "assessment.finance.q8.b",
                             delta: ScoreDeltas(kontrolle:  1, entscheidung:  2, risiko:  1)),
            AssessmentAnswer(id: 2, textKey: "assessment.finance.q8.c",
                             delta: ScoreDeltas(kontrolle:  2, entscheidung:  1, risiko:  0)),
            AssessmentAnswer(id: 3, textKey: "assessment.finance.q8.d",
                             delta: ScoreDeltas(kontrolle: -2, entscheidung:  1, risiko: -3)),
        ]),

        // F9: Der Notfall-Schock
        AssessmentQuestion(id: 9, textKey: "assessment.finance.q9", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.finance.q9.a",
                             delta: ScoreDeltas(kontrolle:  3, entscheidung:  2, risiko:  2)),
            AssessmentAnswer(id: 1, textKey: "assessment.finance.q9.b",
                             delta: ScoreDeltas(kontrolle: -1, entscheidung:  0, risiko: -1)),
            AssessmentAnswer(id: 2, textKey: "assessment.finance.q9.c",
                             delta: ScoreDeltas(kontrolle: -2, entscheidung: -1, risiko: -1)),
            AssessmentAnswer(id: 3, textKey: "assessment.finance.q9.d",
                             delta: ScoreDeltas(kontrolle:  0, entscheidung: -2, risiko: -3)),
        ]),

        // F10: Die Sunk-Cost-Fallacy
        AssessmentQuestion(id: 10, textKey: "assessment.finance.q10", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.finance.q10.a",
                             delta: ScoreDeltas(kontrolle:  0, entscheidung: -2, risiko: -2)),
            AssessmentAnswer(id: 1, textKey: "assessment.finance.q10.b",
                             delta: ScoreDeltas(kontrolle: -1, entscheidung:  1, risiko: -3)),
            AssessmentAnswer(id: 2, textKey: "assessment.finance.q10.c",
                             delta: ScoreDeltas(kontrolle:  2, entscheidung:  3, risiko:  2)),
            AssessmentAnswer(id: 3, textKey: "assessment.finance.q10.d",
                             delta: ScoreDeltas(kontrolle: -3, entscheidung: -2, risiko: -1)),
        ]),

        // F11: Das finanzielle Tabu
        AssessmentQuestion(id: 11, textKey: "assessment.finance.q11", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.finance.q11.a",
                             delta: ScoreDeltas(kontrolle: -3, entscheidung: -3, risiko: -3)),
            AssessmentAnswer(id: 1, textKey: "assessment.finance.q11.b",
                             delta: ScoreDeltas(kontrolle:  3, entscheidung:  2, risiko:  2)),
            AssessmentAnswer(id: 2, textKey: "assessment.finance.q11.c",
                             delta: ScoreDeltas(kontrolle: -2, entscheidung: -1, risiko: -2)),
            AssessmentAnswer(id: 3, textKey: "assessment.finance.q11.d",
                             delta: ScoreDeltas(kontrolle: -1, entscheidung: -1, risiko: -2)),
        ]),

        // F12: Die Gier-Falle
        AssessmentQuestion(id: 12, textKey: "assessment.finance.q12", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.finance.q12.a",
                             delta: ScoreDeltas(kontrolle: -2, entscheidung:  1, risiko: -4)),
            AssessmentAnswer(id: 1, textKey: "assessment.finance.q12.b",
                             delta: ScoreDeltas(kontrolle:  0, entscheidung:  1, risiko: -2)),
            AssessmentAnswer(id: 2, textKey: "assessment.finance.q12.c",
                             delta: ScoreDeltas(kontrolle:  2, entscheidung:  2, risiko:  3)),
            AssessmentAnswer(id: 3, textKey: "assessment.finance.q12.d",
                             delta: ScoreDeltas(kontrolle:  1, entscheidung: -1, risiko:  1)),
        ]),

        // F13: Das Mathe-Paradoxon
        AssessmentQuestion(id: 13, textKey: "assessment.finance.q13", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.finance.q13.a",
                             delta: ScoreDeltas(kontrolle:  3, entscheidung:  2, risiko:  2)),
            AssessmentAnswer(id: 1, textKey: "assessment.finance.q13.b",
                             delta: ScoreDeltas(kontrolle: -2, entscheidung:  0, risiko: -1)),
            AssessmentAnswer(id: 2, textKey: "assessment.finance.q13.c",
                             delta: ScoreDeltas(kontrolle: -1, entscheidung:  1, risiko: -3)),
            AssessmentAnswer(id: 3, textKey: "assessment.finance.q13.d",
                             delta: ScoreDeltas(kontrolle: -3, entscheidung: -1, risiko: -2)),
        ]),

        // F14: Die Mikrolecks
        AssessmentQuestion(id: 14, textKey: "assessment.finance.q14", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.finance.q14.a",
                             delta: ScoreDeltas(kontrolle: -3, entscheidung: -1, risiko:  0)),
            AssessmentAnswer(id: 1, textKey: "assessment.finance.q14.b",
                             delta: ScoreDeltas(kontrolle:  0, entscheidung:  0, risiko: -1)),
            AssessmentAnswer(id: 2, textKey: "assessment.finance.q14.c",
                             delta: ScoreDeltas(kontrolle:  2, entscheidung:  2, risiko:  1)),
            AssessmentAnswer(id: 3, textKey: "assessment.finance.q14.d",
                             delta: ScoreDeltas(kontrolle:  0, entscheidung: -2, risiko:  0)),
        ]),

        // F15: Das ultimative Endziel
        AssessmentQuestion(id: 15, textKey: "assessment.finance.q15", answers: [
            AssessmentAnswer(id: 0, textKey: "assessment.finance.q15.a",
                             delta: ScoreDeltas(kontrolle:  1, entscheidung:  0, risiko:  2)),
            AssessmentAnswer(id: 1, textKey: "assessment.finance.q15.b",
                             delta: ScoreDeltas(kontrolle:  2, entscheidung: -1, risiko:  0)),
            AssessmentAnswer(id: 2, textKey: "assessment.finance.q15.c",
                             delta: ScoreDeltas(kontrolle: -1, entscheidung:  1, risiko: -2)),
            AssessmentAnswer(id: 3, textKey: "assessment.finance.q15.d",
                             delta: ScoreDeltas(kontrolle:  1, entscheidung:  2, risiko: -1)),
        ]),
    ]
}

// MARK: - Mental Assessment Answer Deltas

struct MentalScoreDeltas {
    let resilienz:  Int
    let fokus:      Int
    let ego:        Int
}

// MARK: - Mental Assessment Answer

struct MentalAnswer: Identifiable {
    let id: Int
    let textKey: String
    let delta: MentalScoreDeltas
}

// MARK: - Mental Assessment Question

struct MentalQuestion: Identifiable {
    let id: Int
    let textKey: String
    let answers: [MentalAnswer]
}

// MARK: - Mental Profile

enum MentalProfile: String, Codable, CaseIterable {
    case glaeserner       // Schwächste: resilienz — bricht unter Druck
    case getriebener      // Schwächste: fokus     — reaktiv, kein Tunnel
    case spiegel          // Schwächste: ego       — fremdgesteuert
    case unerschuetterlicher // Alle ≥ 0

    var titleKey: String { "assessment.mental.profile.\(rawValue).title" }
    var descKey:  String { "assessment.mental.profile.\(rawValue).desc" }
    var actionKey: String { "assessment.mental.profile.\(rawValue).action" }
    var buildHabitsKey: String { "assessment.mental.profile.\(rawValue).build" }
    var breakHabitsKey: String { "assessment.mental.profile.\(rawValue).break" }

    var icon: String {
        switch self {
        case .glaeserner:         return "figure.fall"
        case .getriebener:        return "bolt.trianglebadge.exclamationmark.fill"
        case .spiegel:            return "person.fill.questionmark"
        case .unerschuetterlicher: return "mountain.2.fill"
        }
    }

    var color: String {
        switch self {
        case .glaeserner:         return "#FF6B6B"
        case .getriebener:        return "#FFB347"
        case .spiegel:            return "#DA70D6"
        case .unerschuetterlicher: return "#4CAF50"
        }
    }
}

// MARK: - Mental Raw Score

struct MentalRawScore {
    var resilienz:  Int = 0
    var fokus:      Int = 0
    var ego:        Int = 0
}

// MARK: - Mental Assessment Result

struct MentalAssessmentResult: Codable {
    let profile: MentalProfile
    let rawResilienz:  Int
    let rawFokus:      Int
    let rawEgo:        Int
    let date: Date
}

// MARK: - Mental Scoring Engine

enum MentalScoringEngine {

    // Theoretical negatives across 15 questions (absolute worst-case):
    // resilienz: min = -37  → divisor 37.0
    // fokus:     min = -38  → divisor 38.0
    // ego:       min = -37  → divisor 37.0
    private static let resialienzRange: Double = 37.0
    private static let fokusRange:      Double = 38.0
    private static let egoRange:        Double = 37.0

    static func computeProfile(from score: MentalRawScore) -> MentalProfile {
        if score.resilienz >= 0 && score.fokus >= 0 && score.ego >= 0 {
            return .unerschuetterlicher
        }

        let normResilienz = Double(score.resilienz) / resialienzRange
        let normFokus     = Double(score.fokus)     / fokusRange
        let normEgo       = Double(score.ego)        / egoRange

        let candidates: [(value: Double, priority: Int, profile: MentalProfile)] = [
            (normResilienz, 0, .glaeserner),
            (normFokus,     1, .getriebener),
            (normEgo,       2, .spiegel)
        ]

        let negatives = candidates.filter { $0.value < 0 }
        guard !negatives.isEmpty else { return .unerschuetterlicher }

        let dominant = negatives.min { lhs, rhs in
            if lhs.value != rhs.value { return lhs.value < rhs.value }
            return lhs.priority < rhs.priority
        }!

        return dominant.profile
    }
}

// MARK: - Mental Quiz Data (15 Fragen, keine KI, kein Server)

struct MentalQuiz {

    static let questions: [MentalQuestion] = [

        // F1: Der erste Einbruch
        MentalQuestion(id: 1, textKey: "assessment.mental.q1", answers: [
            MentalAnswer(id: 0, textKey: "assessment.mental.q1.a",
                         delta: MentalScoreDeltas(resilienz: -3, fokus: -3, ego: -1)),
            MentalAnswer(id: 1, textKey: "assessment.mental.q1.b",
                         delta: MentalScoreDeltas(resilienz: -1, fokus: -2, ego: -2)),
            MentalAnswer(id: 2, textKey: "assessment.mental.q1.c",
                         delta: MentalScoreDeltas(resilienz:  3, fokus:  3, ego:  2)),
            MentalAnswer(id: 3, textKey: "assessment.mental.q1.d",
                         delta: MentalScoreDeltas(resilienz: -1, fokus: -1, ego: -1)),
        ]),

        // F2: Das Nein-Problem
        MentalQuestion(id: 2, textKey: "assessment.mental.q2", answers: [
            MentalAnswer(id: 0, textKey: "assessment.mental.q2.a",
                         delta: MentalScoreDeltas(resilienz: -2, fokus: -2, ego: -1)),
            MentalAnswer(id: 1, textKey: "assessment.mental.q2.b",
                         delta: MentalScoreDeltas(resilienz:  1, fokus:  2, ego: -2)),
            MentalAnswer(id: 2, textKey: "assessment.mental.q2.c",
                         delta: MentalScoreDeltas(resilienz:  3, fokus:  3, ego:  2)),
            MentalAnswer(id: 3, textKey: "assessment.mental.q2.d",
                         delta: MentalScoreDeltas(resilienz: -1, fokus: -1, ego: -2)),
        ]),

        // F3: Der Komfort-Trap
        MentalQuestion(id: 3, textKey: "assessment.mental.q3", answers: [
            MentalAnswer(id: 0, textKey: "assessment.mental.q3.a",
                         delta: MentalScoreDeltas(resilienz: -1, fokus: -1, ego:  0)),
            MentalAnswer(id: 1, textKey: "assessment.mental.q3.b",
                         delta: MentalScoreDeltas(resilienz:  0, fokus: -2, ego: -2)),
            MentalAnswer(id: 2, textKey: "assessment.mental.q3.c",
                         delta: MentalScoreDeltas(resilienz:  3, fokus:  3, ego:  2)),
            MentalAnswer(id: 3, textKey: "assessment.mental.q3.d",
                         delta: MentalScoreDeltas(resilienz: -2, fokus: -3, ego: -1)),
        ]),

        // F4: Die Bewunderungssucht
        MentalQuestion(id: 4, textKey: "assessment.mental.q4", answers: [
            MentalAnswer(id: 0, textKey: "assessment.mental.q4.a",
                         delta: MentalScoreDeltas(resilienz:  0, fokus: -1, ego: -3)),
            MentalAnswer(id: 1, textKey: "assessment.mental.q4.b",
                         delta: MentalScoreDeltas(resilienz: -3, fokus: -2, ego: -1)),
            MentalAnswer(id: 2, textKey: "assessment.mental.q4.c",
                         delta: MentalScoreDeltas(resilienz:  3, fokus:  3, ego:  3)),
            MentalAnswer(id: 3, textKey: "assessment.mental.q4.d",
                         delta: MentalScoreDeltas(resilienz:  1, fokus:  1, ego:  1)),
        ]),

        // F5: Der unverdiente Sieg
        MentalQuestion(id: 5, textKey: "assessment.mental.q5", answers: [
            MentalAnswer(id: 0, textKey: "assessment.mental.q5.a",
                         delta: MentalScoreDeltas(resilienz: -2, fokus: -3, ego: -3)),
            MentalAnswer(id: 1, textKey: "assessment.mental.q5.b",
                         delta: MentalScoreDeltas(resilienz: -1, fokus: -2, ego: -3)),
            MentalAnswer(id: 2, textKey: "assessment.mental.q5.c",
                         delta: MentalScoreDeltas(resilienz:  3, fokus:  3, ego:  2)),
            MentalAnswer(id: 3, textKey: "assessment.mental.q5.d",
                         delta: MentalScoreDeltas(resilienz: -3, fokus: -3, ego: -1)),
        ]),

        // F6: Die toxische Isolation
        MentalQuestion(id: 6, textKey: "assessment.mental.q6", answers: [
            MentalAnswer(id: 0, textKey: "assessment.mental.q6.a",
                         delta: MentalScoreDeltas(resilienz: -3, fokus: -3, ego:  0)),
            MentalAnswer(id: 1, textKey: "assessment.mental.q6.b",
                         delta: MentalScoreDeltas(resilienz:  3, fokus:  3, ego:  1)),
            MentalAnswer(id: 2, textKey: "assessment.mental.q6.c",
                         delta: MentalScoreDeltas(resilienz: -1, fokus: -2, ego: -3)),
            MentalAnswer(id: 3, textKey: "assessment.mental.q6.d",
                         delta: MentalScoreDeltas(resilienz: -2, fokus: -1, ego: -1)),
        ]),

        // F7: Der Triumph des Feindes
        MentalQuestion(id: 7, textKey: "assessment.mental.q7", answers: [
            MentalAnswer(id: 0, textKey: "assessment.mental.q7.a",
                         delta: MentalScoreDeltas(resilienz: -1, fokus: -2, ego: -3)),
            MentalAnswer(id: 1, textKey: "assessment.mental.q7.b",
                         delta: MentalScoreDeltas(resilienz: -3, fokus: -2, ego: -2)),
            MentalAnswer(id: 2, textKey: "assessment.mental.q7.c",
                         delta: MentalScoreDeltas(resilienz:  3, fokus:  3, ego:  1)),
            MentalAnswer(id: 3, textKey: "assessment.mental.q7.d",
                         delta: MentalScoreDeltas(resilienz:  0, fokus: -1, ego: -1)),
        ]),

        // F8: Die öffentliche Demütigung
        MentalQuestion(id: 8, textKey: "assessment.mental.q8", answers: [
            MentalAnswer(id: 0, textKey: "assessment.mental.q8.a",
                         delta: MentalScoreDeltas(resilienz: -3, fokus: -3, ego: -3)),
            MentalAnswer(id: 1, textKey: "assessment.mental.q8.b",
                         delta: MentalScoreDeltas(resilienz: -2, fokus: -3, ego: -3)),
            MentalAnswer(id: 2, textKey: "assessment.mental.q8.c",
                         delta: MentalScoreDeltas(resilienz:  3, fokus:  3, ego:  3)),
            MentalAnswer(id: 3, textKey: "assessment.mental.q8.d",
                         delta: MentalScoreDeltas(resilienz: -2, fokus: -1, ego: -1)),
        ]),

        // F9: Die falsche Anschuldigung
        MentalQuestion(id: 9, textKey: "assessment.mental.q9", answers: [
            MentalAnswer(id: 0, textKey: "assessment.mental.q9.a",
                         delta: MentalScoreDeltas(resilienz: -1, fokus: -3, ego: -3)),
            MentalAnswer(id: 1, textKey: "assessment.mental.q9.b",
                         delta: MentalScoreDeltas(resilienz: -3, fokus: -2, ego: -1)),
            MentalAnswer(id: 2, textKey: "assessment.mental.q9.c",
                         delta: MentalScoreDeltas(resilienz:  3, fokus:  3, ego:  2)),
            MentalAnswer(id: 3, textKey: "assessment.mental.q9.d",
                         delta: MentalScoreDeltas(resilienz: -2, fokus: -2, ego: -2)),
        ]),

        // F10: Die absolute Erschöpfung
        MentalQuestion(id: 10, textKey: "assessment.mental.q10", answers: [
            MentalAnswer(id: 0, textKey: "assessment.mental.q10.a",
                         delta: MentalScoreDeltas(resilienz:  0, fokus: -2, ego:  0)),
            MentalAnswer(id: 1, textKey: "assessment.mental.q10.b",
                         delta: MentalScoreDeltas(resilienz: -3, fokus: -3, ego:  0)),
            MentalAnswer(id: 2, textKey: "assessment.mental.q10.c",
                         delta: MentalScoreDeltas(resilienz:  3, fokus:  3, ego:  1)),
            MentalAnswer(id: 3, textKey: "assessment.mental.q10.d",
                         delta: MentalScoreDeltas(resilienz: -2, fokus: -3, ego: -1)),
        ]),

        // F11: Der dumme Befehl
        MentalQuestion(id: 11, textKey: "assessment.mental.q11", answers: [
            MentalAnswer(id: 0, textKey: "assessment.mental.q11.a",
                         delta: MentalScoreDeltas(resilienz: -1, fokus: -2, ego: -2)),
            MentalAnswer(id: 1, textKey: "assessment.mental.q11.b",
                         delta: MentalScoreDeltas(resilienz: -1, fokus: -2, ego: -3)),
            MentalAnswer(id: 2, textKey: "assessment.mental.q11.c",
                         delta: MentalScoreDeltas(resilienz:  2, fokus:  3, ego:  1)),
            MentalAnswer(id: 3, textKey: "assessment.mental.q11.d",
                         delta: MentalScoreDeltas(resilienz:  2, fokus:  2, ego:  3)),
        ]),

        // F12: Die emotionale Erpressung
        MentalQuestion(id: 12, textKey: "assessment.mental.q12", answers: [
            MentalAnswer(id: 0, textKey: "assessment.mental.q12.a",
                         delta: MentalScoreDeltas(resilienz: -3, fokus: -3, ego:  0)),
            MentalAnswer(id: 1, textKey: "assessment.mental.q12.b",
                         delta: MentalScoreDeltas(resilienz:  1, fokus: -2, ego: -3)),
            MentalAnswer(id: 2, textKey: "assessment.mental.q12.c",
                         delta: MentalScoreDeltas(resilienz: -1, fokus: -1, ego: -1)),
            MentalAnswer(id: 3, textKey: "assessment.mental.q12.d",
                         delta: MentalScoreDeltas(resilienz:  3, fokus:  3, ego:  2)),
        ]),

        // F13: Der Mitläufer-Test
        MentalQuestion(id: 13, textKey: "assessment.mental.q13", answers: [
            MentalAnswer(id: 0, textKey: "assessment.mental.q13.a",
                         delta: MentalScoreDeltas(resilienz: -3, fokus: -2, ego: -1)),
            MentalAnswer(id: 1, textKey: "assessment.mental.q13.b",
                         delta: MentalScoreDeltas(resilienz:  1, fokus: -1, ego: -2)),
            MentalAnswer(id: 2, textKey: "assessment.mental.q13.c",
                         delta: MentalScoreDeltas(resilienz:  3, fokus:  3, ego:  2)),
            MentalAnswer(id: 3, textKey: "assessment.mental.q13.d",
                         delta: MentalScoreDeltas(resilienz:  0, fokus: -2, ego: -3)),
        ]),

        // F14: Die versenkte Zeit (Sunk Cost)
        MentalQuestion(id: 14, textKey: "assessment.mental.q14", answers: [
            MentalAnswer(id: 0, textKey: "assessment.mental.q14.a",
                         delta: MentalScoreDeltas(resilienz: -2, fokus: -3, ego: -3)),
            MentalAnswer(id: 1, textKey: "assessment.mental.q14.b",
                         delta: MentalScoreDeltas(resilienz: -3, fokus: -2, ego: -1)),
            MentalAnswer(id: 2, textKey: "assessment.mental.q14.c",
                         delta: MentalScoreDeltas(resilienz:  3, fokus:  3, ego:  2)),
            MentalAnswer(id: 3, textKey: "assessment.mental.q14.d",
                         delta: MentalScoreDeltas(resilienz:  1, fokus:  0, ego:  1)),
        ]),

        // F15: Die Sabotage
        MentalQuestion(id: 15, textKey: "assessment.mental.q15", answers: [
            MentalAnswer(id: 0, textKey: "assessment.mental.q15.a",
                         delta: MentalScoreDeltas(resilienz: -2, fokus: -2, ego: -2)),
            MentalAnswer(id: 1, textKey: "assessment.mental.q15.b",
                         delta: MentalScoreDeltas(resilienz: -1, fokus: -3, ego: -3)),
            MentalAnswer(id: 2, textKey: "assessment.mental.q15.c",
                         delta: MentalScoreDeltas(resilienz:  3, fokus:  3, ego:  2)),
            MentalAnswer(id: 3, textKey: "assessment.mental.q15.d",
                         delta: MentalScoreDeltas(resilienz: -2, fokus: -1, ego:  0)),
        ]),
    ]
}

// MARK: - Health Assessment Score Deltas

struct HealthScoreDeltas {
    let regeneration: Int
    let kraftstoff:   Int
    let praevention:  Int
}

// MARK: - Health Assessment Answer

struct HealthAnswer: Identifiable {
    let id: Int
    let textKey: String
    let delta: HealthScoreDeltas
}

// MARK: - Health Assessment Question

struct HealthQuestion: Identifiable {
    let id: Int
    let textKey: String
    let answers: [HealthAnswer]
}

// MARK: - Health Profile

enum HealthProfile: String, Codable, CaseIterable {
    case erschoepfer      // Schwächste: regeneration — schläft und pausiert kaputt
    case vergifter        // Schwächste: kraftstoff   — betankt das System falsch
    case ignorant         // Schwächste: prävention   — ignoriert Alarmsignale
    case optimierer       // Alle Parameter ≥ 0

    var titleKey:  String { "assessment.health.profile.\(rawValue).title" }
    var descKey:   String { "assessment.health.profile.\(rawValue).desc" }
    var actionKey: String { "assessment.health.profile.\(rawValue).action" }
    var buildHabitsKey: String { "assessment.health.profile.\(rawValue).build" }
    var breakHabitsKey: String { "assessment.health.profile.\(rawValue).break" }

    var icon: String {
        switch self {
        case .erschoepfer: return "bed.double.fill"
        case .vergifter:   return "fork.knife"
        case .ignorant:    return "ear.badge.waveform"
        case .optimierer:  return "heart.fill"
        }
    }

    var color: String {
        switch self {
        case .erschoepfer: return "#FF6B6B"
        case .vergifter:   return "#FFB347"
        case .ignorant:    return "#DA70D6"
        case .optimierer:  return "#4CAF50"
        }
    }
}

// MARK: - Health Raw Score

struct HealthRawScore {
    var regeneration: Int = 0
    var kraftstoff:   Int = 0
    var praevention:  Int = 0
}

// MARK: - Health Assessment Result

struct HealthAssessmentResult: Codable {
    let profile: HealthProfile
    let rawRegeneration: Int
    let rawKraftstoff:   Int
    let rawPraevention:  Int
    let date: Date
}

// MARK: - Health Scoring Engine

enum HealthScoringEngine {
    // Worst-case negatives across all 15 questions:
    // regeneration: min = -34  → divisor 34.0
    // kraftstoff:   min = -37  → divisor 37.0
    // prävention:   min = -38  → divisor 38.0
    private static let regenerationRange: Double = 34.0
    private static let kraftstoffRange:   Double = 37.0
    private static let praeventionRange:  Double = 38.0

    static func computeProfile(from score: HealthRawScore) -> HealthProfile {
        if score.regeneration >= 0 && score.kraftstoff >= 0 && score.praevention >= 0 {
            return .optimierer
        }

        let normRegeneration = Double(score.regeneration) / regenerationRange
        let normKraftstoff   = Double(score.kraftstoff)   / kraftstoffRange
        let normPraevention  = Double(score.praevention)  / praeventionRange

        let candidates: [(value: Double, priority: Int, profile: HealthProfile)] = [
            (normRegeneration, 0, .erschoepfer),
            (normKraftstoff,   1, .vergifter),
            (normPraevention,  2, .ignorant)
        ]

        let negatives = candidates.filter { $0.value < 0 }
        guard !negatives.isEmpty else { return .optimierer }

        let dominant = negatives.min { lhs, rhs in
            if lhs.value != rhs.value { return lhs.value < rhs.value }
            return lhs.priority < rhs.priority
        }!

        return dominant.profile
    }
}

// MARK: - Health Quiz Data (15 Szenarien, keine KI, kein Server)

struct HealthQuiz {

    static let questions: [HealthQuestion] = [

        // F1: Der kognitive Crash
        HealthQuestion(id: 1, textKey: "assessment.health.q1", answers: [
            HealthAnswer(id: 0, textKey: "assessment.health.q1.a",
                         delta: HealthScoreDeltas(regeneration: -2, kraftstoff: -3, praevention: -1)),
            HealthAnswer(id: 1, textKey: "assessment.health.q1.b",
                         delta: HealthScoreDeltas(regeneration: -1, kraftstoff: -3, praevention: -1)),
            HealthAnswer(id: 2, textKey: "assessment.health.q1.c",
                         delta: HealthScoreDeltas(regeneration:  3, kraftstoff:  2, praevention:  2)),
            HealthAnswer(id: 3, textKey: "assessment.health.q1.d",
                         delta: HealthScoreDeltas(regeneration: -3, kraftstoff:  0, praevention: -2)),
        ]),

        // F2: Die Rache des Weckers
        HealthQuestion(id: 2, textKey: "assessment.health.q2", answers: [
            HealthAnswer(id: 0, textKey: "assessment.health.q2.a",
                         delta: HealthScoreDeltas(regeneration: -3, kraftstoff:  0, praevention: -2)),
            HealthAnswer(id: 1, textKey: "assessment.health.q2.b",
                         delta: HealthScoreDeltas(regeneration: -2, kraftstoff: -1, praevention: -2)),
            HealthAnswer(id: 2, textKey: "assessment.health.q2.c",
                         delta: HealthScoreDeltas(regeneration:  3, kraftstoff:  2, praevention:  2)),
            HealthAnswer(id: 3, textKey: "assessment.health.q2.d",
                         delta: HealthScoreDeltas(regeneration:  0, kraftstoff: -2, praevention: -1)),
        ]),

        // F3: Der Krankheits-Ego-Trip
        HealthQuestion(id: 3, textKey: "assessment.health.q3", answers: [
            HealthAnswer(id: 0, textKey: "assessment.health.q3.a",
                         delta: HealthScoreDeltas(regeneration: -3, kraftstoff:  0, praevention: -3)),
            HealthAnswer(id: 1, textKey: "assessment.health.q3.b",
                         delta: HealthScoreDeltas(regeneration: -2, kraftstoff: -2, praevention: -3)),
            HealthAnswer(id: 2, textKey: "assessment.health.q3.c",
                         delta: HealthScoreDeltas(regeneration:  3, kraftstoff:  1, praevention:  3)),
            HealthAnswer(id: 3, textKey: "assessment.health.q3.d",
                         delta: HealthScoreDeltas(regeneration: -2, kraftstoff:  0, praevention: -2)),
        ]),

        // F4: Die Notfall-Betankung
        HealthQuestion(id: 4, textKey: "assessment.health.q4", answers: [
            HealthAnswer(id: 0, textKey: "assessment.health.q4.a",
                         delta: HealthScoreDeltas(regeneration:  0, kraftstoff: -3, praevention: -1)),
            HealthAnswer(id: 1, textKey: "assessment.health.q4.b",
                         delta: HealthScoreDeltas(regeneration:  0, kraftstoff: -2, praevention: -1)),
            HealthAnswer(id: 2, textKey: "assessment.health.q4.c",
                         delta: HealthScoreDeltas(regeneration:  0, kraftstoff:  3, praevention:  2)),
            HealthAnswer(id: 3, textKey: "assessment.health.q4.d",
                         delta: HealthScoreDeltas(regeneration: -1, kraftstoff: -2, praevention:  0)),
        ]),

        // F5: Der Dopamin-Schlaf
        HealthQuestion(id: 5, textKey: "assessment.health.q5", answers: [
            HealthAnswer(id: 0, textKey: "assessment.health.q5.a",
                         delta: HealthScoreDeltas(regeneration: -3, kraftstoff:  0, praevention: -2)),
            HealthAnswer(id: 1, textKey: "assessment.health.q5.b",
                         delta: HealthScoreDeltas(regeneration: -1, kraftstoff:  0, praevention: -1)),
            HealthAnswer(id: 2, textKey: "assessment.health.q5.c",
                         delta: HealthScoreDeltas(regeneration:  3, kraftstoff:  0, praevention:  2)),
            HealthAnswer(id: 3, textKey: "assessment.health.q5.d",
                         delta: HealthScoreDeltas(regeneration: -3, kraftstoff:  0, praevention: -2)),
        ]),

        // F6: Die Wasser-Lüge
        HealthQuestion(id: 6, textKey: "assessment.health.q6", answers: [
            HealthAnswer(id: 0, textKey: "assessment.health.q6.a",
                         delta: HealthScoreDeltas(regeneration: -1, kraftstoff: -3, praevention: -2)),
            HealthAnswer(id: 1, textKey: "assessment.health.q6.b",
                         delta: HealthScoreDeltas(regeneration: -1, kraftstoff: -2, praevention: -3)),
            HealthAnswer(id: 2, textKey: "assessment.health.q6.c",
                         delta: HealthScoreDeltas(regeneration:  1, kraftstoff:  3, praevention:  2)),
            HealthAnswer(id: 3, textKey: "assessment.health.q6.d",
                         delta: HealthScoreDeltas(regeneration: -1, kraftstoff: -1, praevention: -1)),
        ]),

        // F7: Das Wochenend-Koma
        HealthQuestion(id: 7, textKey: "assessment.health.q7", answers: [
            HealthAnswer(id: 0, textKey: "assessment.health.q7.a",
                         delta: HealthScoreDeltas(regeneration: -2, kraftstoff:  0, praevention: -1)),
            HealthAnswer(id: 1, textKey: "assessment.health.q7.b",
                         delta: HealthScoreDeltas(regeneration:  3, kraftstoff:  0, praevention:  2)),
            HealthAnswer(id: 2, textKey: "assessment.health.q7.c",
                         delta: HealthScoreDeltas(regeneration: -3, kraftstoff:  0, praevention: -2)),
            HealthAnswer(id: 3, textKey: "assessment.health.q7.d",
                         delta: HealthScoreDeltas(regeneration: -1, kraftstoff:  0, praevention:  0)),
        ]),

        // F8: Soziales Gift
        HealthQuestion(id: 8, textKey: "assessment.health.q8", answers: [
            HealthAnswer(id: 0, textKey: "assessment.health.q8.a",
                         delta: HealthScoreDeltas(regeneration: -1, kraftstoff: -3, praevention: -2)),
            HealthAnswer(id: 1, textKey: "assessment.health.q8.b",
                         delta: HealthScoreDeltas(regeneration:  0, kraftstoff: -2, praevention: -1)),
            HealthAnswer(id: 2, textKey: "assessment.health.q8.c",
                         delta: HealthScoreDeltas(regeneration:  1, kraftstoff:  3, praevention:  2)),
            HealthAnswer(id: 3, textKey: "assessment.health.q8.d",
                         delta: HealthScoreDeltas(regeneration:  1, kraftstoff:  1, praevention: -1)),
        ]),

        // F9: Schmerz-Ignoranz
        HealthQuestion(id: 9, textKey: "assessment.health.q9", answers: [
            HealthAnswer(id: 0, textKey: "assessment.health.q9.a",
                         delta: HealthScoreDeltas(regeneration:  0, kraftstoff:  0, praevention: -3)),
            HealthAnswer(id: 1, textKey: "assessment.health.q9.b",
                         delta: HealthScoreDeltas(regeneration:  0, kraftstoff:  0, praevention: -2)),
            HealthAnswer(id: 2, textKey: "assessment.health.q9.c",
                         delta: HealthScoreDeltas(regeneration:  1, kraftstoff:  0, praevention:  3)),
            HealthAnswer(id: 3, textKey: "assessment.health.q9.d",
                         delta: HealthScoreDeltas(regeneration:  0, kraftstoff:  0, praevention: -1)),
        ]),

        // F10: Die Alibi-Vitamine
        HealthQuestion(id: 10, textKey: "assessment.health.q10", answers: [
            HealthAnswer(id: 0, textKey: "assessment.health.q10.a",
                         delta: HealthScoreDeltas(regeneration:  0, kraftstoff: -3, praevention: -2)),
            HealthAnswer(id: 1, textKey: "assessment.health.q10.b",
                         delta: HealthScoreDeltas(regeneration:  0, kraftstoff: -2, praevention: -1)),
            HealthAnswer(id: 2, textKey: "assessment.health.q10.c",
                         delta: HealthScoreDeltas(regeneration:  0, kraftstoff:  3, praevention:  2)),
            HealthAnswer(id: 3, textKey: "assessment.health.q10.d",
                         delta: HealthScoreDeltas(regeneration: -1, kraftstoff: -1, praevention: -1)),
        ]),

        // F11: Der Bildschirm-Kredit
        HealthQuestion(id: 11, textKey: "assessment.health.q11", answers: [
            HealthAnswer(id: 0, textKey: "assessment.health.q11.a",
                         delta: HealthScoreDeltas(regeneration: -3, kraftstoff:  0, praevention: -2)),
            HealthAnswer(id: 1, textKey: "assessment.health.q11.b",
                         delta: HealthScoreDeltas(regeneration: -1, kraftstoff:  0, praevention: -1)),
            HealthAnswer(id: 2, textKey: "assessment.health.q11.c",
                         delta: HealthScoreDeltas(regeneration:  3, kraftstoff:  0, praevention:  2)),
            HealthAnswer(id: 3, textKey: "assessment.health.q11.d",
                         delta: HealthScoreDeltas(regeneration:  1, kraftstoff:  0, praevention: -1)),
        ]),

        // F12: Die Basis-Hygiene
        HealthQuestion(id: 12, textKey: "assessment.health.q12", answers: [
            HealthAnswer(id: 0, textKey: "assessment.health.q12.a",
                         delta: HealthScoreDeltas(regeneration:  0, kraftstoff:  0, praevention: -3)),
            HealthAnswer(id: 1, textKey: "assessment.health.q12.b",
                         delta: HealthScoreDeltas(regeneration:  0, kraftstoff:  0, praevention: -2)),
            HealthAnswer(id: 2, textKey: "assessment.health.q12.c",
                         delta: HealthScoreDeltas(regeneration:  0, kraftstoff:  0, praevention:  3)),
            HealthAnswer(id: 3, textKey: "assessment.health.q12.d",
                         delta: HealthScoreDeltas(regeneration:  0, kraftstoff:  0, praevention: -1)),
        ]),

        // F13: Der Stress-Atem
        HealthQuestion(id: 13, textKey: "assessment.health.q13", answers: [
            HealthAnswer(id: 0, textKey: "assessment.health.q13.a",
                         delta: HealthScoreDeltas(regeneration: -3, kraftstoff:  0, praevention: -1)),
            HealthAnswer(id: 1, textKey: "assessment.health.q13.b",
                         delta: HealthScoreDeltas(regeneration: -2, kraftstoff:  0, praevention: -1)),
            HealthAnswer(id: 2, textKey: "assessment.health.q13.c",
                         delta: HealthScoreDeltas(regeneration:  3, kraftstoff:  0, praevention:  2)),
            HealthAnswer(id: 3, textKey: "assessment.health.q13.d",
                         delta: HealthScoreDeltas(regeneration: -1, kraftstoff:  0, praevention: -2)),
        ]),

        // F14: Die blinde Ignoranz
        HealthQuestion(id: 14, textKey: "assessment.health.q14", answers: [
            HealthAnswer(id: 0, textKey: "assessment.health.q14.a",
                         delta: HealthScoreDeltas(regeneration: -1, kraftstoff: -3, praevention: -3)),
            HealthAnswer(id: 1, textKey: "assessment.health.q14.b",
                         delta: HealthScoreDeltas(regeneration:  0, kraftstoff: -2, praevention: -2)),
            HealthAnswer(id: 2, textKey: "assessment.health.q14.c",
                         delta: HealthScoreDeltas(regeneration:  1, kraftstoff:  3, praevention:  3)),
            HealthAnswer(id: 3, textKey: "assessment.health.q14.d",
                         delta: HealthScoreDeltas(regeneration: -1, kraftstoff: -1, praevention: -3)),
        ]),

        // F15: Das wahre Motiv
        HealthQuestion(id: 15, textKey: "assessment.health.q15", answers: [
            HealthAnswer(id: 0, textKey: "assessment.health.q15.a",
                         delta: HealthScoreDeltas(regeneration: -1, kraftstoff: -1, praevention: -2)),
            HealthAnswer(id: 1, textKey: "assessment.health.q15.b",
                         delta: HealthScoreDeltas(regeneration:  1, kraftstoff:  1, praevention:  1)),
            HealthAnswer(id: 2, textKey: "assessment.health.q15.c",
                         delta: HealthScoreDeltas(regeneration:  2, kraftstoff:  2, praevention:  2)),
            HealthAnswer(id: 3, textKey: "assessment.health.q15.d",
                         delta: HealthScoreDeltas(regeneration: -2, kraftstoff: -2, praevention: -3)),
        ]),
    ]
}


// MARK: - Fitness Assessment Score Deltas

struct FitnessScoreDeltas {
    let konsistenz: Int
    let intensitaet: Int
    let verantwortung: Int
}

// MARK: - Fitness Assessment Answer

struct FitnessAnswer: Identifiable {
    let id: Int
    let textKey: String
    let delta: FitnessScoreDeltas
}

// MARK: - Fitness Assessment Question

struct FitnessQuestion: Identifiable {
    let id: Int
    let textKey: String
    let answers: [FitnessAnswer]
}

// MARK: - Fitness Profile

enum FitnessProfile: String, Codable, CaseIterable {
    case schoenwetter_sportler // Schwächste: konsistenz
    case wohlfuehler           // Schwächste: intensitaet
    case ausreden_sucher       // Schwächste: verantwortung
    case maschine              // Alle Parameter >= 0

    var titleKey:  String { "assessment.fitness.profile.\(rawValue).title" }
    var descKey:   String { "assessment.fitness.profile.\(rawValue).desc" }
    var actionKey: String { "assessment.fitness.profile.\(rawValue).action" }
    var buildHabitsKey: String { "assessment.fitness.profile.\(rawValue).build" }
    var breakHabitsKey: String { "assessment.fitness.profile.\(rawValue).break" }

    var icon: String {
        switch self {
        case .schoenwetter_sportler: return "cloud.rain.fill"
        case .wohlfuehler:           return "sofa.fill"
        case .ausreden_sucher:       return "bubble.left.and.exclamationmark.bubble.right.fill"
        case .maschine:              return "figure.run"
        }
    }

    var color: String {
        switch self {
        case .schoenwetter_sportler: return "#FF6B6B"
        case .wohlfuehler:           return "#FFB347"
        case .ausreden_sucher:       return "#DA70D6"
        case .maschine:              return "#4CAF50"
        }
    }
}

// MARK: - Fitness Raw Score

struct FitnessRawScore {
    var konsistenz: Int = 0
    var intensitaet: Int = 0
    var verantwortung: Int = 0
}

// MARK: - Fitness Assessment Result

struct FitnessAssessmentResult: Codable {
    let profile: FitnessProfile
    let rawKonsistenz: Int
    let rawIntensitaet: Int
    let rawVerantwortung: Int
    let date: Date
}

// MARK: - Fitness Scoring Engine

enum FitnessScoringEngine {
    // We will calculate max negative points for normalization based on matrix
    // F1: K(-3) I(-2) V(-3) -> max neg: K(-3), I(-2), V(-3)
    // F2: K(-3) I(0) V(-3) -> max neg: K(-3), I(0), V(-3)
    // F3: K(0) I(-3) V(-2) -> max neg: K(0), I(-3), V(-2)
    // F4: K(-2) I(0) V(-3) -> max neg: K(-2), I(0), V(-3)
    // F5: K(-2) I(-2) V(-2) -> max neg: K(-2), I(-2), V(-2)
    // F6: K(-3) I(-3) V(-3) -> max neg: K(-3), I(-3), V(-3)
    // F7: K(0) I(-2) V(-3) -> max neg: K(0), I(-2), V(-3)
    // F8: K(-3) I(0) V(-2) -> max neg: K(-3), I(0), V(-2)
    // F9: K(-2) I(-2) V(-2) -> max neg: K(-2), I(-2), V(-2)
    // F10: K(-3) I(-2) V(-2) -> max neg: K(-3), I(-2), V(-2)
    // F11: K(-1) I(-3) V(-2) -> max neg: K(-1), I(-3), V(-2)
    // F12: K(0) I(-3) V(-1) -> max neg: K(0), I(-3), V(-1)
    // F13: K(-3) I(-1) V(-3) -> max neg: K(-3), I(-1), V(-3)
    // F14: K(-3) I(-1) V(-3) -> max neg: K(-3), I(-1), V(-3)
    // F15: K(-1) I(-1) V(-2) -> max neg: K(-1), I(-1), V(-2)
    // Sums of absolute mins:
    // konsistenz = 3+3+0+2+2+3+0+3+2+3+1+0+3+3+1 = 29
    // intensitaet = 2+0+3+0+2+3+2+0+2+2+3+3+1+1+1 = 25
    // verantwortung = 3+3+2+3+2+3+3+2+2+2+2+1+3+3+2 = 36
    
    private static let konsistenzRange: Double = 29.0
    private static let intensitaetRange: Double = 25.0
    private static let verantwortungRange: Double = 36.0

    static func computeProfile(from score: FitnessRawScore) -> FitnessProfile {
        if score.konsistenz >= 0 && score.intensitaet >= 0 && score.verantwortung >= 0 {
            return .maschine
        }

        let normKonsistenz = Double(score.konsistenz) / konsistenzRange
        let normIntensitaet = Double(score.intensitaet) / intensitaetRange
        let normVerantwortung = Double(score.verantwortung) / verantwortungRange

        let candidates: [(value: Double, priority: Int, profile: FitnessProfile)] = [
            (normKonsistenz, 0, .schoenwetter_sportler),
            (normIntensitaet, 1, .wohlfuehler),
            (normVerantwortung, 2, .ausreden_sucher)
        ]

        let negatives = candidates.filter { $0.value < 0 }
        guard !negatives.isEmpty else { return .maschine }

        let dominant = negatives.min { lhs, rhs in
            if lhs.value != rhs.value { return lhs.value < rhs.value }
            return lhs.priority < rhs.priority
        }!

        return dominant.profile
    }
}

// MARK: - Fitness Quiz Data

struct FitnessQuiz {
    static let questions: [FitnessQuestion] = [


        // F1
        FitnessQuestion(id: 1, textKey: "assessment.fitness.q1", answers: [
            FitnessAnswer(id: 0, textKey: "assessment.fitness.q1.a",
                          delta: FitnessScoreDeltas(konsistenz: -3, intensitaet:  0, verantwortung: -2)),
            FitnessAnswer(id: 1, textKey: "assessment.fitness.q1.b",
                          delta: FitnessScoreDeltas(konsistenz: -2, intensitaet:  0, verantwortung: -3)),
            FitnessAnswer(id: 2, textKey: "assessment.fitness.q1.c",
                          delta: FitnessScoreDeltas(konsistenz:  1, intensitaet: -2, verantwortung:  1)),
            FitnessAnswer(id: 3, textKey: "assessment.fitness.q1.d",
                          delta: FitnessScoreDeltas(konsistenz:  3, intensitaet:  2, verantwortung:  3)),
        ]),

        // F2
        FitnessQuestion(id: 2, textKey: "assessment.fitness.q2", answers: [
            FitnessAnswer(id: 0, textKey: "assessment.fitness.q2.a",
                          delta: FitnessScoreDeltas(konsistenz: -3, intensitaet:  0, verantwortung: -3)),
            FitnessAnswer(id: 1, textKey: "assessment.fitness.q2.b",
                          delta: FitnessScoreDeltas(konsistenz: -2, intensitaet:  0, verantwortung: -3)),
            FitnessAnswer(id: 2, textKey: "assessment.fitness.q2.c",
                          delta: FitnessScoreDeltas(konsistenz: -1, intensitaet:  0, verantwortung:  1)),
            FitnessAnswer(id: 3, textKey: "assessment.fitness.q2.d",
                          delta: FitnessScoreDeltas(konsistenz:  2, intensitaet:  1, verantwortung:  3)),
        ]),

        // F3
        FitnessQuestion(id: 3, textKey: "assessment.fitness.q3", answers: [
            FitnessAnswer(id: 0, textKey: "assessment.fitness.q3.a",
                          delta: FitnessScoreDeltas(konsistenz:  0, intensitaet: -3, verantwortung: -2)),
            FitnessAnswer(id: 1, textKey: "assessment.fitness.q3.b",
                          delta: FitnessScoreDeltas(konsistenz:  0, intensitaet: -1, verantwortung: -1)),
            FitnessAnswer(id: 2, textKey: "assessment.fitness.q3.c",
                          delta: FitnessScoreDeltas(konsistenz:  1, intensitaet:  2, verantwortung:  2)),
            FitnessAnswer(id: 3, textKey: "assessment.fitness.q3.d",
                          delta: FitnessScoreDeltas(konsistenz:  1, intensitaet:  3, verantwortung:  2)),
        ]),

        // F4
        FitnessQuestion(id: 4, textKey: "assessment.fitness.q4", answers: [
            FitnessAnswer(id: 0, textKey: "assessment.fitness.q4.a",
                          delta: FitnessScoreDeltas(konsistenz:  0, intensitaet:  0, verantwortung: -3)),
            FitnessAnswer(id: 1, textKey: "assessment.fitness.q4.b",
                          delta: FitnessScoreDeltas(konsistenz: -2, intensitaet:  0, verantwortung: -3)),
            FitnessAnswer(id: 2, textKey: "assessment.fitness.q4.c",
                          delta: FitnessScoreDeltas(konsistenz:  1, intensitaet:  0, verantwortung: -1)),
            FitnessAnswer(id: 3, textKey: "assessment.fitness.q4.d",
                          delta: FitnessScoreDeltas(konsistenz:  2, intensitaet:  1, verantwortung:  3)),
        ]),

        // F5
        FitnessQuestion(id: 5, textKey: "assessment.fitness.q5", answers: [
            FitnessAnswer(id: 0, textKey: "assessment.fitness.q5.a",
                          delta: FitnessScoreDeltas(konsistenz: -2, intensitaet: -1, verantwortung: -2)),
            FitnessAnswer(id: 1, textKey: "assessment.fitness.q5.b",
                          delta: FitnessScoreDeltas(konsistenz: -2, intensitaet: -2, verantwortung: -2)),
            FitnessAnswer(id: 2, textKey: "assessment.fitness.q5.c",
                          delta: FitnessScoreDeltas(konsistenz:  1, intensitaet: -1, verantwortung:  1)),
            FitnessAnswer(id: 3, textKey: "assessment.fitness.q5.d",
                          delta: FitnessScoreDeltas(konsistenz:  3, intensitaet:  3, verantwortung:  3)),
        ]),

        // F6
        FitnessQuestion(id: 6, textKey: "assessment.fitness.q6", answers: [
            FitnessAnswer(id: 0, textKey: "assessment.fitness.q6.a",
                          delta: FitnessScoreDeltas(konsistenz: -3, intensitaet:  0, verantwortung: -3)),
            FitnessAnswer(id: 1, textKey: "assessment.fitness.q6.b",
                          delta: FitnessScoreDeltas(konsistenz:  1, intensitaet: -3, verantwortung: -2)),
            FitnessAnswer(id: 2, textKey: "assessment.fitness.q6.c",
                          delta: FitnessScoreDeltas(konsistenz:  0, intensitaet: -1, verantwortung: -2)),
            FitnessAnswer(id: 3, textKey: "assessment.fitness.q6.d",
                          delta: FitnessScoreDeltas(konsistenz:  3, intensitaet:  3, verantwortung:  3)),
        ]),

        // F7
        FitnessQuestion(id: 7, textKey: "assessment.fitness.q7", answers: [
            FitnessAnswer(id: 0, textKey: "assessment.fitness.q7.a",
                          delta: FitnessScoreDeltas(konsistenz:  0, intensitaet:  2, verantwortung: -3)),
            FitnessAnswer(id: 1, textKey: "assessment.fitness.q7.b",
                          delta: FitnessScoreDeltas(konsistenz:  0, intensitaet: -1, verantwortung: -3)),
            FitnessAnswer(id: 2, textKey: "assessment.fitness.q7.c",
                          delta: FitnessScoreDeltas(konsistenz:  1, intensitaet:  1, verantwortung:  3)),
            FitnessAnswer(id: 3, textKey: "assessment.fitness.q7.d",
                          delta: FitnessScoreDeltas(konsistenz:  0, intensitaet: -2, verantwortung: -1)),
        ]),

        // F8
        FitnessQuestion(id: 8, textKey: "assessment.fitness.q8", answers: [
            FitnessAnswer(id: 0, textKey: "assessment.fitness.q8.a",
                          delta: FitnessScoreDeltas(konsistenz: -3, intensitaet:  0, verantwortung: -2)),
            FitnessAnswer(id: 1, textKey: "assessment.fitness.q8.b",
                          delta: FitnessScoreDeltas(konsistenz: -2, intensitaet:  0, verantwortung: -1)),
            FitnessAnswer(id: 2, textKey: "assessment.fitness.q8.c",
                          delta: FitnessScoreDeltas(konsistenz:  2, intensitaet:  2, verantwortung:  2)),
            FitnessAnswer(id: 3, textKey: "assessment.fitness.q8.d",
                          delta: FitnessScoreDeltas(konsistenz:  3, intensitaet:  1, verantwortung:  3)),
        ]),

        // F9
        FitnessQuestion(id: 9, textKey: "assessment.fitness.q9", answers: [
            FitnessAnswer(id: 0, textKey: "assessment.fitness.q9.a",
                          delta: FitnessScoreDeltas(konsistenz: -2, intensitaet: -2, verantwortung: -2)),
            FitnessAnswer(id: 1, textKey: "assessment.fitness.q9.b",
                          delta: FitnessScoreDeltas(konsistenz: -1, intensitaet: -1, verantwortung: -1)),
            FitnessAnswer(id: 2, textKey: "assessment.fitness.q9.c",
                          delta: FitnessScoreDeltas(konsistenz:  1, intensitaet:  0, verantwortung:  1)),
            FitnessAnswer(id: 3, textKey: "assessment.fitness.q9.d",
                          delta: FitnessScoreDeltas(konsistenz:  3, intensitaet:  2, verantwortung:  3)),
        ]),

        // F10
        FitnessQuestion(id: 10, textKey: "assessment.fitness.q10", answers: [
            FitnessAnswer(id: 0, textKey: "assessment.fitness.q10.a",
                          delta: FitnessScoreDeltas(konsistenz: -2, intensitaet: -1, verantwortung: -1)),
            FitnessAnswer(id: 1, textKey: "assessment.fitness.q10.b",
                          delta: FitnessScoreDeltas(konsistenz: -3, intensitaet:  0, verantwortung: -2)),
            FitnessAnswer(id: 2, textKey: "assessment.fitness.q10.c",
                          delta: FitnessScoreDeltas(konsistenz:  1, intensitaet: -2, verantwortung:  1)),
            FitnessAnswer(id: 3, textKey: "assessment.fitness.q10.d",
                          delta: FitnessScoreDeltas(konsistenz:  3, intensitaet:  3, verantwortung:  2)),
        ]),

        // F11
        FitnessQuestion(id: 11, textKey: "assessment.fitness.q11", answers: [
            FitnessAnswer(id: 0, textKey: "assessment.fitness.q11.a",
                          delta: FitnessScoreDeltas(konsistenz: -1, intensitaet: -3, verantwortung: -2)),
            FitnessAnswer(id: 1, textKey: "assessment.fitness.q11.b",
                          delta: FitnessScoreDeltas(konsistenz:  0, intensitaet: -2, verantwortung: -1)),
            FitnessAnswer(id: 2, textKey: "assessment.fitness.q11.c",
                          delta: FitnessScoreDeltas(konsistenz:  2, intensitaet:  3, verantwortung:  2)),
            FitnessAnswer(id: 3, textKey: "assessment.fitness.q11.d",
                          delta: FitnessScoreDeltas(konsistenz: -1, intensitaet: -3, verantwortung: -1)),
        ]),

        // F12
        FitnessQuestion(id: 12, textKey: "assessment.fitness.q12", answers: [
            FitnessAnswer(id: 0, textKey: "assessment.fitness.q12.a",
                          delta: FitnessScoreDeltas(konsistenz:  0, intensitaet: -3, verantwortung: -1)),
            FitnessAnswer(id: 1, textKey: "assessment.fitness.q12.b",
                          delta: FitnessScoreDeltas(konsistenz:  1, intensitaet: -1, verantwortung:  0)),
            FitnessAnswer(id: 2, textKey: "assessment.fitness.q12.c",
                          delta: FitnessScoreDeltas(konsistenz:  2, intensitaet:  1, verantwortung:  1)),
            FitnessAnswer(id: 3, textKey: "assessment.fitness.q12.d",
                          delta: FitnessScoreDeltas(konsistenz:  2, intensitaet:  3, verantwortung:  3)),
        ]),

        // F13
        FitnessQuestion(id: 13, textKey: "assessment.fitness.q13", answers: [
            FitnessAnswer(id: 0, textKey: "assessment.fitness.q13.a",
                          delta: FitnessScoreDeltas(konsistenz: -3, intensitaet: -1, verantwortung: -2)),
            FitnessAnswer(id: 1, textKey: "assessment.fitness.q13.b",
                          delta: FitnessScoreDeltas(konsistenz: -3, intensitaet: -1, verantwortung: -3)),
            FitnessAnswer(id: 2, textKey: "assessment.fitness.q13.c",
                          delta: FitnessScoreDeltas(konsistenz:  1, intensitaet:  1, verantwortung: -1)),
            FitnessAnswer(id: 3, textKey: "assessment.fitness.q13.d",
                          delta: FitnessScoreDeltas(konsistenz:  3, intensitaet:  2, verantwortung:  3)),
        ]),

        // F14
        FitnessQuestion(id: 14, textKey: "assessment.fitness.q14", answers: [
            FitnessAnswer(id: 0, textKey: "assessment.fitness.q14.a",
                          delta: FitnessScoreDeltas(konsistenz: -3, intensitaet: -1, verantwortung: -3)),
            FitnessAnswer(id: 1, textKey: "assessment.fitness.q14.b",
                          delta: FitnessScoreDeltas(konsistenz: -1, intensitaet: -1, verantwortung: -2)),
            FitnessAnswer(id: 2, textKey: "assessment.fitness.q14.c",
                          delta: FitnessScoreDeltas(konsistenz:  2, intensitaet:  1, verantwortung:  2)),
            FitnessAnswer(id: 3, textKey: "assessment.fitness.q14.d",
                          delta: FitnessScoreDeltas(konsistenz:  2, intensitaet:  3, verantwortung:  3)),
        ]),

        // F15
        FitnessQuestion(id: 15, textKey: "assessment.fitness.q15", answers: [
            FitnessAnswer(id: 0, textKey: "assessment.fitness.q15.a",
                          delta: FitnessScoreDeltas(konsistenz: -1, intensitaet: -1, verantwortung: -1)),
            FitnessAnswer(id: 1, textKey: "assessment.fitness.q15.b",
                          delta: FitnessScoreDeltas(konsistenz: -1, intensitaet: -1, verantwortung: -2)),
            FitnessAnswer(id: 2, textKey: "assessment.fitness.q15.c",
                          delta: FitnessScoreDeltas(konsistenz:  1, intensitaet:  0, verantwortung:  1)),
            FitnessAnswer(id: 3, textKey: "assessment.fitness.q15.d",
                          delta: FitnessScoreDeltas(konsistenz:  2, intensitaet:  3, verantwortung:  3)),
        ]),


    ]
}
