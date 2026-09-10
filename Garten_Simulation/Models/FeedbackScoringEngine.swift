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
    /// Aktueller Fortschritt (für Fortschrittsbalken)
    let progress: Double?
    /// Zielwert (für Fortschrittsbalken)
    let goal: Double?
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
        var sleepAvgBedtimeString: String?
        var sleepTargetWakeUpString: String?
        var strengthDaysAgo: Int?           // nil = keine Historie
        var hasStrengthHistory: Bool
        var strengthTodayMinutes: Double
        var strengthGoalMinutes: Double
        var stepsToday: Double
        var stepsGoal: Double
        var energyToday: Double             // > 0 = Ernährung wird getrackt
        var energyGoal: Double
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
        if val < 0 { return -0.05 } // 👎 -> Toleranter (Grenzwert sinkt leicht)
        else if val > 0 { return 0.05 } // 👍 -> Strenger (Grenzwert steigt leicht)
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
            if waterPct >= max(0.1, 1.0 + mod) {
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
                waterSummary = String(format: String(localized: "fitness.water.summary.good", defaultValue: "%lld / %lld ml ✓"), waterActual, waterTarget)
                waterDetail = String(localized: "fitness.water.detail.good",
                                      defaultValue: "Dein Wasserziel ist erreicht. Weiter so!")
            } else {
                waterSummary = String(format: String(localized: "fitness.water.summary", defaultValue: "%lld / %lld ml"), waterActual, waterTarget)
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
                let progressText = String(format: String(localized: "fitness.water.detail.progress", defaultValue: "%lld von %lld ml getrunken."), waterActual, waterTarget)
                waterDetail = "\(progressText) \(actionHint)"
            }
            results.append(CategoryFeedback(category: .water, status: waterStatus,
                                             summaryText: waterSummary, detailText: waterDetail,
                                             progress: Double(waterActual), goal: Double(waterTarget)))
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
            let sleepSummary = String(format: String(localized: "fitness.sleep.summary", defaultValue: "%@ / %@ h"), sleepHoursStr, goalStr)

            var sleepDetail: String
            switch sleepStatus {
            case .good:
                sleepDetail = String(localized: "fitness.sleep.detail.good",
                                     defaultValue: "Guter Schlaf. Dein Körper hat sich gut erholt.")
            case .warning:
                sleepDetail = String(localized: "fitness.sleep.detail.warning",
                                     defaultValue: "Etwas weniger Schlaf als empfohlen.")
            default:
                sleepDetail = String(localized: "fitness.sleep.detail.critical",
                                     defaultValue: "Weniger als 6 Stunden Schlaf beeinträchtigen Konzentration und Erholung.")
            }
            
            if let bed = input.sleepAvgBedtimeString, let wake = input.sleepTargetWakeUpString {
                let timeHint = String(format: String(localized: "fitness.sleep.detail.timehint",
                                                      defaultValue: "Morgen solltest du lieber um %@ Uhr ins Bett gehen und um %@ Uhr aufwachen."), bed, wake)
                sleepDetail += " " + timeHint
            } else if sleepStatus != .good {
                sleepDetail += " " + String(localized: "fitness.sleep.detail.fallback", defaultValue: "Versuche heute früher schlafen zu gehen.")
            }
            
            results.append(CategoryFeedback(category: .sleep, status: sleepStatus,
                                             summaryText: sleepSummary, detailText: sleepDetail,
                                             progress: input.sleepHoursToday, goal: input.sleepGoalHours))
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
            
            // Format minutes e.g., 20 / 45 min
            let minStr = String(format: String(localized: "fitness.strength.summary.min", defaultValue: "%lld / %lld min"), Int(input.strengthTodayMinutes), Int(input.strengthGoalMinutes))
            
            let daysAgoStr = String(format: String(localized: "fitness.strength.summary.daysago", defaultValue: "(Vor %lld Tagen)"), days)
            
            switch strengthStatus {
            case .good:
                strengthSummary = days == 0
                    ? "\(minStr) ✓"
                    : "\(minStr) \(daysAgoStr) ✓"
                strengthDetail = String(localized: "fitness.strength.detail.good",
                                        defaultValue: "Nettes Krafttraining, weiter so! Dein Training liegt voll im Zeitplan.")
            case .warning:
                strengthSummary = days == 0 ? minStr : "\(minStr) \(daysAgoStr)"
                strengthDetail = String(localized: "fitness.strength.detail.warning",
                                        defaultValue: "Dein letztes Training ist schon etwas her. Plane diese Woche noch eine Krafteinheit ein, um dranzubleiben.")
            default:
                strengthSummary = days == 0 ? minStr : "\(minStr) \(daysAgoStr)"
                strengthDetail = String(localized: "fitness.strength.detail.critical",
                                        defaultValue: "Letztes Krafttraining liegt zu lange zurück. Versuche heute eine kurze Einheit einzuplanen, um den Rhythmus nicht zu verlieren.")
            }
            results.append(CategoryFeedback(category: .strength, status: strengthStatus,
                                             summaryText: strengthSummary, detailText: strengthDetail,
                                             progress: input.strengthTodayMinutes, goal: input.strengthGoalMinutes))
        }

        // MARK: Joggen/Laufen (basiert auf Schritten)
        if input.hasRunningPlant {
            let mod = getModifier(for: .running)
            let steps = Int(input.stepsToday)
            let goal = Int(input.stepsGoal)
            let stepsPct = input.stepsGoal > 0 ? input.stepsToday / input.stepsGoal : 0
            
            let runStatus: CategoryStatus
            if stepsPct >= max(0.1, 1.0 + mod) {
                runStatus = .good
            } else if stepsPct >= max(0.1, 0.5 + mod) {
                runStatus = .warning
            } else {
                runStatus = .critical
            }

            let runSummary = String(format: String(localized: "fitness.running.summary", defaultValue: "%lld / %lld Schritte"), steps, goal)
            let runDetail: String
            let missing = max(0, goal - steps)
            
            switch runStatus {
            case .good:
                runDetail = String(localized: "fitness.running.detail.good",
                                   defaultValue: "Schritte-Ziel erreicht ✓ Klasse gemacht!")
            case .warning:
                if missing < 500 {
                    let text = String(format: String(localized: "fitness.running.detail.missing.small", defaultValue: "Dir fehlen nur noch %lld Schritte. Bewege dich nur noch ein bisschen!"), missing)
                    runDetail = text
                } else if missing < 2000 {
                    let text = String(format: String(localized: "fitness.running.detail.missing.medium", defaultValue: "Dir fehlen noch %lld Schritte. Mach noch einen kurzen Spaziergang."), missing)
                    runDetail = text
                } else {
                    let text = String(format: String(localized: "fitness.running.detail.missing.large", defaultValue: "Dir fehlen noch %lld Schritte. Du musst heute noch deutlich aktiver werden, plane einen längeren Spaziergang ein."), missing)
                    runDetail = text
                }
            default:
                if missing < 500 {
                    let text = String(format: String(localized: "fitness.running.detail.missing.small", defaultValue: "Dir fehlen nur noch %lld Schritte. Bewege dich nur noch ein bisschen!"), missing)
                    runDetail = text
                } else if missing < 2000 {
                    let text = String(format: String(localized: "fitness.running.detail.missing.medium", defaultValue: "Dir fehlen noch %lld Schritte. Mach noch einen kurzen Spaziergang."), missing)
                    runDetail = text
                } else {
                    let text = String(format: String(localized: "fitness.running.detail.missing.large", defaultValue: "Dir fehlen noch %lld Schritte. Du musst heute noch deutlich aktiver werden, plane einen längeren Spaziergang ein."), missing)
                    runDetail = text
                }
            }
            
            results.append(CategoryFeedback(category: .running, status: runStatus,
                                             summaryText: runSummary, detailText: runDetail,
                                             progress: input.stepsToday, goal: input.stepsGoal))
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
            let nutSummary = nutritionProblems.isEmpty
                ? String(format: String(localized: "fitness.nutrition.summary.good", defaultValue: "%lld / %lld kcal ✓"), Int(input.energyToday), Int(input.energyGoal))
                : String(format: String(localized: "fitness.nutrition.summary", defaultValue: "%lld / %lld kcal"), Int(input.energyToday), Int(input.energyGoal))
            let nutDetail: String

            if nutritionProblems.isEmpty {
                nutDetail = String(localized: "fitness.nutrition.detail.good", defaultValue: "Ernährung liegt heute im Zielbereich.")
            } else {
                nutDetail = nutritionDetails.joined(separator: "\n")
            }
            results.append(CategoryFeedback(category: .nutrition, status: nutStatus,
                                             summaryText: nutSummary, detailText: nutDetail,
                                             progress: input.energyToday, goal: input.energyGoal))
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
