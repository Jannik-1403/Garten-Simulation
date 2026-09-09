import Foundation

// MARK: - FitnessCategory

enum FitnessCategory: String, CaseIterable, Identifiable {
    case water
    case sleep
    case strength
    case running
    case nutrition

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .water:     return "drop.fill"
        case .sleep:     return "moon.fill"
        case .strength:  return "dumbbell.fill"
        case .running:   return "figure.run"
        case .nutrition: return "fork.knife"
        }
    }
}

// MARK: - CategoryStatus

enum CategoryStatus: Equatable {
    case good
    case warning
    case critical
    case unavailable // keine Daten vorhanden, Kategorie wird ausgeblendet
}

// MARK: - CategoryFeedback

struct CategoryFeedback: Identifiable {
    var id: FitnessCategory { category }
    let category: FitnessCategory
    let status: CategoryStatus
    /// Kurztext für die eingeklappte Zeile, z.B. "1.200 / 2.400 ml"
    let summaryText: String
    /// Aufgeklappter Detail-Text mit konkreter Handlungsanweisung
    let detailText: String
}

// MARK: - FeedbackResult (Kompatibilität mit FeedbackStore bleibt erhalten)

enum FeedbackKey: String, CaseIterable {
    case feedbackWasserKritisch
    case feedbackWasserLeicht
    case feedbackTrainingInaktiv
    case feedbackSchritteNiedrig
    case feedbackNaehrstoffDefizit
    case feedbackPositiv1
    case feedbackPositiv2
    case feedbackPositiv3

    static var positiveKeys: [FeedbackKey] { [.feedbackPositiv1, .feedbackPositiv2, .feedbackPositiv3] }
}

struct FeedbackResult {
    let key: FeedbackKey
    let formattedText: String
    let contextValues: [String: Int]
}

// MARK: - FeedbackScoringEngine

struct FeedbackScoringEngine {

    // MARK: - Multi-Kategorie Auswertung (neue Hauptmethode)

    struct EvaluationInput {
        var hasWaterPlant: Bool
        var hasSleepPlant: Bool
        var hasStrengthPlant: Bool
        var hasRunningPlant: Bool
        var hasNutritionPlant: Bool

        var waterToday: Double
        var waterGoal: Double
        var waterHistory7Days: [Date: Double]
        var sleepHoursToday: Double         // 0 = keine Daten
        var sleepGoalHours: Double          // Default 8h
        var sleepRegularity: Double?        // 0–1 aus HealthManager
        var strengthDaysAgo: Int?           // nil = keine Historie
        var hasStrengthHistory: Bool
        var runningMinutesToday: Double
        var energyToday: Double             // > 0 = Ernährung wird getrackt
        var proteinToday: Double
        var proteinGoal: Double
        var fiberToday: Double
        var fiberGoal: Double
        var worstMineralName: String?
        var worstMineralScore: Double       // 0–100
        var userFactors: (_ key: String) -> Double
    }

    static func getModifier(for category: FitnessCategory) -> Double {
        let val = UserDefaults.standard.integer(forKey: "feedback_modifier_\(category.rawValue)")
        if val < 0 { return -0.15 } // 👎 -> Toleranter (Grenzwert sinkt)
        else if val > 0 { return 0.10 } // 👍 -> Strenger (Grenzwert steigt)
        return 0.0
    }

    static func evaluateAll(input: EvaluationInput) -> [CategoryFeedback] {
        var results: [CategoryFeedback] = []
        let hour = Calendar.current.component(.hour, from: Date())

        // MARK: Wasser
        if input.hasWaterPlant {
            let mod = getModifier(for: .water)
            let waterPct = input.waterGoal > 0 ? input.waterToday / input.waterGoal : 0
            let waterStatus: CategoryStatus
            if waterPct >= max(0.1, 0.8 + mod) {
                waterStatus = .good
            } else if waterPct >= max(0.1, 0.5 + mod) {
                waterStatus = .warning
            } else {
                waterStatus = .critical
            }

            let waterSummary: String
            let waterDetail: String
            let waterActual = Int(input.waterToday)
            let waterTarget = Int(input.waterGoal)

            if waterStatus == .good {
                waterSummary = "\(waterActual) / \(waterTarget) ml ✓"
                waterDetail = String(localized: "fitness.water.detail.good",
                                      defaultValue: "Dein Wasserziel ist erreicht. Weiter so!")
            } else {
                waterSummary = "\(waterActual) / \(waterTarget) ml"
                let remaining = waterTarget - waterActual
                // Zeitabhängige Handlungsanweisung
                let actionHint: String
                switch hour {
                case 0..<10:
                    actionHint = String(localized: "fitness.water.action.morning",
                                        defaultValue: "Trink jetzt dein erstes Glas.")
                case 10..<14:
                    actionHint = String(format: String(localized: "fitness.water.action.midday",
                                                        defaultValue: "Noch %lld ml bis zum Mittag schaffen."),
                                        remaining)
                case 14..<19:
                    actionHint = String(localized: "fitness.water.action.afternoon",
                                        defaultValue: "Trink in den nächsten 2 Stunden ein großes Glas.")
                default:
                    actionHint = String(format: String(localized: "fitness.water.action.evening",
                                                        defaultValue: "Du kannst noch %lld ml schaffen, wenn du jetzt anfängst."),
                                        remaining)
                }
                waterDetail = "\(waterActual) von \(waterTarget) ml getrunken. \(actionHint)"
            }
            results.append(CategoryFeedback(category: .water, status: waterStatus,
                                             summaryText: waterSummary, detailText: waterDetail))
        }

        // MARK: Schlaf (nur wenn Pflanze vorhanden)
        if input.hasSleepPlant {
            let mod = getModifier(for: .sleep) * 10.0 // +/- 1.5h
            let sleepStatus: CategoryStatus
            if input.sleepHoursToday >= max(1.0, 7.0 + mod) {
                sleepStatus = .good
            } else if input.sleepHoursToday >= max(1.0, 6.0 + mod) {
                sleepStatus = .warning
            } else {
                sleepStatus = .critical
            }

            let sleepHoursStr = String(format: "%.1f", input.sleepHoursToday)
            let goalStr = String(format: "%.0f", input.sleepGoalHours)
            let sleepSummary = "\(sleepHoursStr) / \(goalStr) h"

            let sleepDetail: String
            switch sleepStatus {
            case .good:
                sleepDetail = String(localized: "fitness.sleep.detail.good",
                                     defaultValue: "Guter Schlaf. Dein Körper konnte sich erholen.")
            case .warning:
                sleepDetail = String(localized: "fitness.sleep.detail.warning",
                                     defaultValue: "Etwas weniger als empfohlen. Versuche heute früher schlafen zu gehen.")
            default:
                sleepDetail = String(localized: "fitness.sleep.detail.critical",
                                     defaultValue: "Weniger als 6 Stunden Schlaf beeinträchtigen Konzentration und Erholung. Heute früher ins Bett.")
            }
            results.append(CategoryFeedback(category: .sleep, status: sleepStatus,
                                             summaryText: sleepSummary, detailText: sleepDetail))
        }

        // MARK: Krafttraining (nur wenn Workout-Pflanze vorhanden)
        if input.hasStrengthPlant {
            let modDays = Int(getModifier(for: .strength) * -20.0) // 👎=-0.15 -> +3 days toleranter
            let days = input.strengthDaysAgo ?? 999
            let strengthStatus: CategoryStatus
            if days <= max(1, 2 + modDays) {
                strengthStatus = .good
            } else if days <= max(1, 5 + modDays) {
                strengthStatus = .warning
            } else {
                strengthStatus = .critical
            }

            let strengthSummary: String
            let strengthDetail: String
            switch strengthStatus {
            case .good:
                strengthSummary = days == 0
                    ? String(localized: "fitness.strength.summary.today", defaultValue: "Heute ✓")
                    : String(format: String(localized: "fitness.strength.summary.recent",
                                            defaultValue: "Vor %lld Tag(en) ✓"), days)
                strengthDetail = String(localized: "fitness.strength.detail.good",
                                        defaultValue: "Krafttraining liegt im Zeitplan.")
            case .warning:
                strengthSummary = String(format: String(localized: "fitness.strength.summary.warning",
                                                         defaultValue: "Vor %lld Tagen"), days)
                strengthDetail = String(localized: "fitness.strength.detail.warning",
                                        defaultValue: "Plane diese Woche noch eine Krafteinheit ein.")
            default:
                strengthSummary = String(format: String(localized: "fitness.strength.summary.critical",
                                                         defaultValue: "Vor %lld Tagen"), days)
                strengthDetail = String(localized: "fitness.strength.detail.critical",
                                        defaultValue: "Letztes Krafttraining liegt zu lange zurück. Heute eine kurze Einheit einplanen.")
            }
            results.append(CategoryFeedback(category: .strength, status: strengthStatus,
                                             summaryText: strengthSummary, detailText: strengthDetail))
        }

        // MARK: Laufen (nur wenn Nutzer eine Lauf-Pflanze hat)
        if input.hasRunningPlant {
            let runMins = Int(input.runningMinutesToday)
            let runStatus: CategoryStatus = runMins > 0 ? .good : .warning

            let runSummary: String
            let runDetail: String
            if runMins > 0 {
                runSummary = String(format: String(localized: "fitness.running.summary.done",
                                                    defaultValue: "%lld min ✓"), runMins)
                runDetail = String(localized: "fitness.running.detail.done",
                                   defaultValue: "Gute Ausdauereinheit heute.")
            } else {
                runSummary = String(localized: "fitness.running.summary.none",
                                    defaultValue: "Heute noch nichts")
                runDetail = String(localized: "fitness.running.detail.none",
                                   defaultValue: "Heute noch keine Laufeinheit. Ein kurzer 20-Minuten-Lauf reicht für den Tag.")
            }
            results.append(CategoryFeedback(category: .running, status: runStatus,
                                             summaryText: runSummary, detailText: runDetail))
        }

        // MARK: Ernährung (nur wenn Ernährungs-Pflanze vorhanden)
        if input.hasNutritionPlant {
            let mod = getModifier(for: .nutrition)
            var nutritionProblems: [String] = []
            var nutritionDetails: [String] = []

            // Protein
            if input.proteinGoal > 0 {
                let proteinPct = input.proteinToday / input.proteinGoal
                if proteinPct < max(0.1, 0.7 + mod) {
                    nutritionProblems.append(String(localized: "fitness.nutrition.protein", defaultValue: "Protein"))
                    let detail = String(format: String(localized: "fitness.nutrition.protein.detail",
                                                        defaultValue: "Protein: %lld / %lld g"),
                                        Int(input.proteinToday), Int(input.proteinGoal))
                    nutritionDetails.append(detail)
                }
            }

            // Ballaststoffe
            if input.fiberGoal > 0 {
                let fiberPct = input.fiberToday / input.fiberGoal
                if fiberPct < max(0.1, 0.7 + mod) {
                    nutritionProblems.append(String(localized: "fitness.nutrition.fiber", defaultValue: "Ballaststoffe"))
                    let detail = String(format: String(localized: "fitness.nutrition.fiber.detail",
                                                        defaultValue: "Ballaststoffe: %lld / %lld g"),
                                        Int(input.fiberToday), Int(input.fiberGoal))
                    nutritionDetails.append(detail)
                }
            }

            // Mineralstoffe (generisch)
            if input.worstMineralScore < max(10.0, 70.0 + (mod * 100.0)) {
                nutritionProblems.append(String(localized: "fitness.nutrition.mineral.generic", defaultValue: "Vitamine & Mineralien"))
                let detail = String(localized: "fitness.nutrition.mineral.detail.generic", defaultValue: "Dein Bedarf an einigen Vitaminen & Mineralien ist heute nicht gedeckt.")
                nutritionDetails.append(detail)
            }

            let nutStatus: CategoryStatus = nutritionProblems.isEmpty ? .good : .warning
            let nutSummary: String
            let nutDetail: String

            if nutritionProblems.isEmpty {
                nutSummary = String(localized: "fitness.nutrition.summary.good", defaultValue: "Alle Werte erreicht ✓")
                nutDetail = String(localized: "fitness.nutrition.detail.good", defaultValue: "Ernährung liegt heute im Zielbereich.")
            } else {
                nutSummary = nutritionProblems.joined(separator: ", ")
                nutDetail = nutritionDetails.joined(separator: "\n")
            }
            results.append(CategoryFeedback(category: .nutrition, status: nutStatus,
                                             summaryText: nutSummary, detailText: nutDetail))
        }

        return results
    }

    // MARK: - Kopfzeilen-Text

    static func headerText(from feedbacks: [CategoryFeedback]) -> String {
        let problems = feedbacks.filter { $0.status == .warning || $0.status == .critical }
        if problems.isEmpty {
            return String(localized: "fitness.header.allgood", defaultValue: "Alle Werte im Ziel")
        }
        let names = problems.map { localizedCategoryName($0.category) }
        let joined = names.joined(separator: ", ")
        return String(format: String(localized: "fitness.header.warning",
                                     defaultValue: "Achtung bei: %@"), joined)
    }

    private static func localizedCategoryName(_ category: FitnessCategory) -> String {
        switch category {
        case .water:     return String(localized: "fitness.category.water",     defaultValue: "Wasser")
        case .sleep:     return String(localized: "fitness.category.sleep",     defaultValue: "Schlaf")
        case .strength:  return String(localized: "fitness.category.strength",  defaultValue: "Krafttraining")
        case .running:   return String(localized: "fitness.category.running",   defaultValue: "Laufen")
        case .nutrition: return String(localized: "fitness.category.nutrition", defaultValue: "Ernährung")
        }
    }
}
