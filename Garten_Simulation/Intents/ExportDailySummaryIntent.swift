import Foundation
import AppIntents
import SwiftUI

struct ExportDailySummaryIntent: AppIntent {
    static var title = LocalizedStringResource("intent.export_summary.title", defaultValue: "Tages-Zusammenfassung exportieren")
    static var description = IntentDescription("intent.export_summary.description")
    
    // Dieser Intent läuft im Hintergrund, daher greifen wir synchron auf die Stores zu.
    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        let summaryJson = await MainActor.run {
            let gardenStore = GardenStore()
            let streakStore = StreakStore()
            let healthManager = HealthManager.shared
            
            var data: [String: Any] = [:]
            
            // Grundlegende Metriken
            let dateFormatter = ISO8601DateFormatter()
            data["date"] = dateFormatter.string(from: Date())
            data["currentStreak"] = streakStore.currentStreak
            data["bestStreak"] = streakStore.bestStreak
            data["coins"] = gardenStore.coins
            data["gesamtXP"] = gardenStore.gesamtXP
            data["leben"] = gardenStore.leben
            data["liveWeeds"] = gardenStore.activeWeeds.count
            
            // Gewohnheiten (gute)
            var habitsArray: [[String: Any]] = []
            for habit in gardenStore.activeHabits {
                let h: [String: Any] = [
                    "name": habit.habitName.isEmpty ? habit.displayedHabitName : habit.habitName,
                    "completedToday": habit.isCompleted,
                    "streak": habit.streak,
                    "currentXP": habit.currentXP,
                    "priority": habit.priority.rawValue,
                    "trackingMode": habit.trackingMode.rawValue,
                    "category": habit.habitCategory.rawValue
                ]
                habitsArray.append(h)
            }
            data["activeHabits"] = habitsArray
            
            // Schlechte Gewohnheiten
            var badHabitsArray: [[String: Any]] = []
            for (habitId, executions) in gardenStore.badHabitExecutions {
                let todayExecutions = executions.filter { Calendar.current.isDateInToday($0.date) }
                if !todayExecutions.isEmpty {
                    let b: [String: Any] = [
                        "id": habitId,
                        "timesTriggeredToday": todayExecutions.count,
                        "coinsLost": todayExecutions.reduce(0) { $0 + $1.coinsLost },
                        "triggers": todayExecutions.compactMap { $0.triggers }.flatMap { $0 }
                    ]
                    badHabitsArray.append(b)
                }
            }
            data["badHabitsTriggeredToday"] = badHabitsArray
            
            // Health / Körper Metriken
            var healthData: [String: Any] = [:]
            if let weight = healthManager.activeWeight?.value {
                healthData["weightKg"] = weight
            }
            healthData["weightGoalType"] = healthManager.weightGoalType
            healthData["weightGoalTargetKg"] = healthManager.weightGoalTargetKg
            
            data["healthMetrics"] = healthData
            
            // Statistiken
            var stats: [String: Any] = [:]
            stats["gesamtVerdient"] = gardenStore.gesamtVerdient
            stats["gesamtGegossen"] = gardenStore.gesamtGegossen
            stats["tageAktiv"] = gardenStore.tageAktiv
            data["stats"] = stats
            
            // JSON Formatieren
            if let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
            
            return "{}"
        }
        
        return .result(value: summaryJson)
    }
}
