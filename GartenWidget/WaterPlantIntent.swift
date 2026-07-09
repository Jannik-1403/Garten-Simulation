import Foundation
import AppIntents
import SwiftUI
import WidgetKit

public struct WaterPlantIntent: AppIntent {
    public static var title: LocalizedStringResource = LocalizedStringResource("intent_water_title", defaultValue: "Pflanze gießen")
    public static var description = IntentDescription(LocalizedStringResource("intent_water_desc", defaultValue: "Gieße eine deiner Pflanzen."))

    @Parameter(title: "Pflanze")
    public var targetPlant: PlantEntity

    public init() {}
    public init(plant: PlantEntity) {
        self.targetPlant = plant
    }

    @MainActor
    public func perform() async throws -> some IntentResult & ProvidesDialog {
        let shared = SharedUserDefaults.suite


        guard let data = shared.data(forKey: "garden_plants"),
              let pflanzen = try? JSONDecoder().decode([HabitModel].self, from: data) else {
            let errorMsg = String(localized: "intent_water_fail", defaultValue: "Fehler beim Laden der Pflanzen.")
            return .result(dialog: IntentDialog(stringLiteral: errorMsg))
        }

        if let index = pflanzen.firstIndex(where: { $0.id == targetPlant.id }) {
            let pflanze = pflanzen[index]
            
            var displayName = pflanze.habitName
            if displayName.contains(".") {
                displayName = String(localized: String.LocalizationValue(displayName))
            }
            if displayName.isEmpty || displayName.contains(".") {
                if let dbPlant = GameDatabase.allPlants.first(where: { $0.id.lowercased() == pflanze.plantID.lowercased() }) {
                    displayName = String(localized: String.LocalizationValue(dbPlant.name))
                }
            }
            
            if pflanze.istBewässert {
                let msgTemplate = String(localized: "intent_water_already_done", defaultValue: "%@ wurde bereits gegossen.")
                let msg = String(format: msgTemplate, displayName)
                return .result(dialog: IntentDialog(stringLiteral: msg))
            }

            // --- FULL WATERING LOGIC (Matching GardenStore.giessen) ---
            
            // 1. XP & Coins calculation
            let xpGewonnen = pflanze.xpPerCompletion
            let coinsGewonnen = 10 // GameConstants.coinsProGiessen (Usually 10)
            
            pflanze.currentXP += xpGewonnen
            
            // XP History
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let todayKey = formatter.string(from: Date())
            pflanze.xpHistory[todayKey] = (pflanze.xpHistory[todayKey] ?? 0) + xpGewonnen
            
            pflanze.totalCoinsEarned += coinsGewonnen
            
            // 2. Global Stats
            let currentGesamtXP = shared.integer(forKey: "stats_gesamt_xp")
            shared.set(currentGesamtXP + xpGewonnen, forKey: "stats_gesamt_xp")
            
            let currentCoins = shared.integer(forKey: "stats_coins")
            shared.set(currentCoins + coinsGewonnen, forKey: "stats_coins")
            
            let currentGesamtVerdient = shared.integer(forKey: "stats_gesamt_verdient")
            shared.set(currentGesamtVerdient + coinsGewonnen, forKey: "stats_gesamt_verdient")
            
            let currentGesamtGegossen = shared.integer(forKey: "stats_gesamt_gegossen")
            shared.set(currentGesamtGegossen + 1, forKey: "stats_gesamt_gegossen")
            
            // 3. Plant State
            pflanze.istBewässert = true
            pflanze.letzteBewaesserung = Date()
            pflanze.wateringDates.append(Date())
            pflanze.streak += 1
            pflanze.missedCycles = 0
            pflanze.lastNotifiedCycle = 0
            pflanze.totalMlGegossen += 250 // GameConstants.mlProGiessen
            
            // 4. Streak Store Sync (Simplified)
            var completedDates = Set<Date>()
            if let timestamps = shared.array(forKey: "streak_completed_dates") as? [TimeInterval] {
                completedDates = Set(timestamps.map { Date(timeIntervalSince1970: $0) })
            }
            completedDates.insert(Calendar.current.startOfDay(for: Date()))
            shared.set(completedDates.map { $0.timeIntervalSince1970 }, forKey: "streak_completed_dates")

            // 5. Save everything
            if let encoded = try? JSONEncoder().encode(pflanzen) {
                shared.set(encoded, forKey: "garden_plants")
            }
            
            // Transaction log
            var transactionsData: [[String: Any]] = shared.array(forKey: "stats_transactions") as? [[String: Any]] ?? []
            let newTransaction: [String: Any] = [
                "datum": Date().timeIntervalSince1970,
                "beschreibung": String(localized: "profile.coins.tip.watering", defaultValue: "Für das Gießen deiner Pflanze"),
                "betrag": coinsGewonnen,
                "icon": "Drop water",
                "farbeHex": "#00919E"
            ]
            transactionsData.insert(newTransaction, at: 0)
            if transactionsData.count > 100 { transactionsData.removeLast() }
            shared.set(transactionsData, forKey: "stats_transactions")

            // Update widget data directly so the widget reflects the change immediately
            let totalStreak = shared.integer(forKey: "streak_last_shown")
            GroovyWidgetDataProvider.write(
                habits: pflanzen,
                totalStreak: totalStreak,
                gems: currentCoins + coinsGewonnen,
                streakCompletedDates: completedDates
            )

            // Refresh UI components
            WidgetCenter.shared.reloadAllTimelines()
            shared.synchronize()

            let successTemplate = String(localized: "intent_water_success", defaultValue: "%@ erfolgreich gegossen!")
            let successMsg = String(format: successTemplate, displayName)
            return .result(dialog: IntentDialog(stringLiteral: successMsg))
        }

        let failMsg = String(localized: "intent_water_fail", defaultValue: "Fehler beim Laden der Pflanzen.")
        return .result(dialog: IntentDialog(stringLiteral: failMsg))
    }
}
