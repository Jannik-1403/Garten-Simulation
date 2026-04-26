import Foundation
import AppIntents
import SwiftUI
import WidgetKit

struct WaterPlantIntent: AppIntent {
    static var title: LocalizedStringResource = "Pflanze gießen"
    static var description = IntentDescription("Gieße eine deiner Pflanzen direkt vom Widget.")

    @Parameter(title: "Plant ID")
    var plantID: String

    init() {}
    init(plantID: String) {
        self.plantID = plantID
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        // 1. Load current plants from shared storage
        let shared = SharedUserDefaults.suite
        guard let data = shared.data(forKey: "garden_plants"),
              var pflanzen = try? JSONDecoder().decode([HabitModel].self, from: data) else {
            return .result()
        }

        // 2. Find and update the specific plant
        if let index = pflanzen.firstIndex(where: { $0.id == plantID }) {
            let pflanze = pflanzen[index]
            
            // Only update if not already watered today
            if !pflanze.istBewässert {
                pflanze.istBewässert = true
                pflanze.letzteBewaesserung = Date()
                pflanze.streak += 1
                
                // Track total watering
                pflanze.totalMlGegossen += 250 // Typical amount
                
                // Add to history
                pflanze.wateringDates.append(Date())
                
                // Earn some coins (simplistic calculation for background)
                let coins = shared.integer(forKey: "stats_coins")
                shared.set(coins + 10, forKey: "stats_coins")
                
                // Save back
                if let encoded = try? JSONEncoder().encode(pflanzen) {
                    shared.set(encoded, forKey: "garden_plants")
                }
                
                // 3. Mark the day as completed in StreakStore (simplified for widget)
                var completedDates = Set<Date>()
                if let timestamps = shared.array(forKey: "streak_completed_dates") as? [TimeInterval] {
                    completedDates = Set(timestamps.map { Date(timeIntervalSince1970: $0) })
                }
                let calendar = Calendar.current
                completedDates.insert(calendar.startOfDay(for: Date()))
                let newTimestamps = completedDates.map { $0.timeIntervalSince1970 }
                shared.set(newTimestamps, forKey: "streak_completed_dates")
                
                // 4. Force widget refresh
                WidgetCenter.shared.reloadAllTimelines()
                
                shared.synchronize()
            }
        }

        return .result()
    }
}
