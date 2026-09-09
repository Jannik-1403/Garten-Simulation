import Foundation

// MARK: - FeedbackKey

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

// MARK: - FeedbackResult

struct FeedbackResult {
    let key: FeedbackKey
    /// Ausgefüllter, lokalisierter Text (Platzhalter bereits ersetzt)
    let formattedText: String
    /// Rohe Kontextwerte für FeedbackRating.contextValues
    let contextValues: [String: Int]
}

// MARK: - FeedbackScoringEngine

struct FeedbackScoringEngine {

    // MARK: - Hauptauswertung
    /// Wertet alle Trigger der Prioritätsliste der Reihe nach aus.
    /// Der erste zutreffende Eintrag gewinnt.
    static func evaluate(
        waterHistory: [Date: Double],      // ml pro Kalendertag (heute inkludiert)
        waterGoal: Double,                 // aktuelles Tagesziel in ml
        stepsHistory: [Date: Double],      // Schritte pro Kalendertag
        lastStrengthDate: Date?,           // letztes Krafttraining
        hasWorkoutHistory: Bool,           // true wenn mind. 1 Workout je gefunden
        energyToday: Double,               // dietaryEnergyConsumed heute (kcal)
        worstNutrient: (name: String, daysBelow: Int)?,  // schlechtester Nährstoff aus NutrientIndexManager
        userFactors: (_ key: String) -> Double  // Closure: gibt den Faktor für einen Key zurück

    ) -> FeedbackResult {

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // MARK: Rang 1 – Wasser kritisch (< 50% an 2+ aufeinanderfolgenden Tagen)
        let criticalThreshold = 0.50
        let criticalFactor = userFactors(FeedbackKey.feedbackWasserKritisch.rawValue)
        let criticalConsecutive = countConsecutiveDaysBelowThreshold(
            history: waterHistory,
            goal: waterGoal * criticalFactor,
            thresholdFraction: criticalThreshold,
            endingOn: calendar.date(byAdding: .day, value: -1, to: today) ?? today,
            calendar: calendar
        )
        if criticalConsecutive >= 2 {
            let text = String(format: String(localized: "feedbackWasserKritisch",
                                             defaultValue: "Wasseraufnahme seit %lld Tagen unter 50% des Ziels. Trink dein erstes Glas heute vor 10 Uhr."),
                              criticalConsecutive)
            return FeedbackResult(key: .feedbackWasserKritisch, formattedText: text, contextValues: ["tage": criticalConsecutive])
        }

        // MARK: Rang 2 – Wasser leicht (< 80% an 3+ aufeinanderfolgenden Tagen)
        let lightThreshold = 0.80
        let lightFactor = userFactors(FeedbackKey.feedbackWasserLeicht.rawValue)
        let lightConsecutive = countConsecutiveDaysBelowThreshold(
            history: waterHistory,
            goal: waterGoal * lightFactor,
            thresholdFraction: lightThreshold,
            endingOn: calendar.date(byAdding: .day, value: -1, to: today) ?? today,
            calendar: calendar
        )
        if lightConsecutive >= 3 {
            let text = String(format: String(localized: "feedbackWasserLeicht",
                                             defaultValue: "Wasseraufnahme seit %lld Tagen unter dem Tagesziel. Trink heute ein Glas mehr als gestern."),
                              lightConsecutive)
            return FeedbackResult(key: .feedbackWasserLeicht, formattedText: text, contextValues: ["tage": lightConsecutive])
        }

        // MARK: Rang 3 – Krafttraining inaktiv (> 5 Tage, nur wenn Workout-Historie vorhanden)
        if hasWorkoutHistory, let lastStrength = lastStrengthDate {
            let daysSince = calendar.dateComponents([.day], from: calendar.startOfDay(for: lastStrength), to: today).day ?? 0
            let trainingFactor = userFactors(FeedbackKey.feedbackTrainingInaktiv.rawValue)
            let effectiveThreshold = Int((5.0 * trainingFactor).rounded())
            if daysSince > effectiveThreshold {
                let text = String(format: String(localized: "feedbackTrainingInaktiv",
                                                 defaultValue: "Letztes Krafttraining vor %lld Tagen. Plane heute eine Einheit ein."),
                                  daysSince)
                return FeedbackResult(key: .feedbackTrainingInaktiv, formattedText: text, contextValues: ["tage": daysSince])
            }
        }

        // MARK: Rang 4 – Schritte niedrig (< 50% des 7-Tage-Schnitts, erst ab 17:00 Uhr)
        let currentHour = calendar.component(.hour, from: Date())
        if currentHour >= 17 {
            // Nur Tage der letzten 7 Tage außer heute in die Schnittberechnung
            let past7Days = (1...7).compactMap { calendar.date(byAdding: .day, value: -$0, to: today) }
            let daysWithData = past7Days.compactMap { stepsHistory[$0] }

            if daysWithData.count >= 4 {
                let avg7 = daysWithData.reduce(0, +) / Double(daysWithData.count)
                let todaySteps = stepsHistory[today] ?? 0
                let stepsFactor = userFactors(FeedbackKey.feedbackSchritteNiedrig.rawValue)
                if avg7 > 0 && todaySteps < avg7 * 0.50 * stepsFactor {
                    let text = String(localized: "feedbackSchritteNiedrig",
                                      defaultValue: "Schritte heute unter 50% des 7-Tage-Schnitts. Geh heute noch 20 Minuten spazieren.")
                    return FeedbackResult(key: .feedbackSchritteNiedrig, formattedText: text, contextValues: [:])
                }
            }
        }

        // MARK: Rang 5 – Mikronährstoff-Defizit (nur wenn energyToday > 0)
        if energyToday > 0, let nutrient = worstNutrient, nutrient.daysBelow >= 3 {
            let text = String(format: String(localized: "feedbackNaehrstoffDefizit",
                                             defaultValue: "%@ seit %lld Tagen unter dem empfohlenen Bedarf. Ergänze ihn bei der nächsten Mahlzeit."),
                              nutrient.name, nutrient.daysBelow)
            return FeedbackResult(key: .feedbackNaehrstoffDefizit, formattedText: text, contextValues: ["tage": nutrient.daysBelow])
        }

        // MARK: Rang 6 – Positiv (zufällig 1 von 3)
        let positiveKey = FeedbackKey.positiveKeys.randomElement() ?? .feedbackPositiv1
        let positiveText: String
        switch positiveKey {
        case .feedbackPositiv1:
            positiveText = String(localized: "feedbackPositiv1", defaultValue: "Alle Werte heute im Zielbereich.")
        case .feedbackPositiv2:
            positiveText = String(localized: "feedbackPositiv2", defaultValue: "Wasser, Bewegung und Training entsprechen dem Ziel.")
        default:
            positiveText = String(localized: "feedbackPositiv3", defaultValue: "Alle Tagesziele erreicht.")
        }
        return FeedbackResult(key: positiveKey, formattedText: positiveText, contextValues: [:])
    }

    // MARK: - Hilfsmethode: Aufeinanderfolgende Tage unter Schwellenwert zählen
    /// Zählt wie viele Tage in Folge (endend am Referenztag, rückwärts) die Aufnahme
    /// unter `thresholdFraction * goal` lag. Tage ohne Datenpunkt werden nicht gezählt.
    private static func countConsecutiveDaysBelowThreshold(
        history: [Date: Double],
        goal: Double,
        thresholdFraction: Double,
        endingOn referenceDay: Date,
        calendar: Calendar
    ) -> Int {
        guard goal > 0 else { return 0 }
        let target = goal * thresholdFraction
        var count = 0
        var checkDay = referenceDay

        for _ in 0..<14 { // max 14 Tage zurückschauen
            if let value = history[calendar.startOfDay(for: checkDay)] {
                if value < target {
                    count += 1
                } else {
                    break // Kette unterbrochen
                }
            } else {
                break // Kein Datenpunkt = Kette unterbrochen
            }
            guard let prev = calendar.date(byAdding: .day, value: -1, to: checkDay) else { break }
            checkDay = prev
        }
        return count
    }
}
