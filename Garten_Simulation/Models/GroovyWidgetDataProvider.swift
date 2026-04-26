import Foundation
import WidgetKit

struct WidgetPlantData: Codable {
    let id: String
    let name: String
    let imageName: String
    let streak: Int
    let isWateredToday: Bool
    let rarityColor: String   // "bronze" | "silber" | "gold" | "diamant"
    let xp: Int
    let xpForNextRarity: Int
}

struct WidgetAppData: Codable {
    let plants: [WidgetPlantData]
    let totalStreak: Int
    let gems: Int
    let lastUpdated: Date

    // NEU:
    let totalWateringCount: Int          // Alle Gießvorgänge aller Pflanzen zusammen
    let wateringCountToday: Int          // Nur heute
    let wateringCountThisWeek: Int       // Diese Woche (Mo–So)
    let wateringCountThisMonth: Int      // Dieser Monat
    let completedStreakDates: [Date]      // Aus StreakStore.completedDates
}

struct GroovyWidgetDataProvider {
    static let appGroupID = "group.com.jannik.grovy"
    static let userDefaultsKey = "groovyWidgetData"

    static func write(
        habits: [HabitModel],
        totalStreak: Int,
        gems: Int,
        streakCompletedDates: Set<Date>
    ) {
        let cal = Calendar.current
        let now = Date()
        let startOfToday = cal.startOfDay(for: now)
        let startOfWeek = cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
        let startOfMonth = cal.date(from: cal.dateComponents([.year, .month], from: now))!

        // Alle wateringDates aller Pflanzen zusammensammeln
        let allDates: [Date] = habits.flatMap { $0.wateringDates }

        let totalCount      = allDates.count
        let todayCount      = allDates.filter { cal.isDate($0, inSameDayAs: now) }.count
        let weekCount       = allDates.filter { $0 >= startOfWeek }.count
        let monthCount      = allDates.filter { $0 >= startOfMonth }.count

        let plants: [WidgetPlantData] = habits.prefix(4).map { habit in
            WidgetPlantData(
                id: habit.id,
                name: habit.displayedHabitName,
                imageName: habit.plantImageName,
                streak: habit.streak,
                isWateredToday: habit.istBewässert,
                rarityColor: habit.seltenheit.rawValue,
                xp: habit.currentXP,
                xpForNextRarity: habit.seltenheit.naechste?.xpSchwelle ?? (habit.seltenheit.xpSchwelle + 500)
            )
        }

        let data = WidgetAppData(
            plants: plants,
            totalStreak: totalStreak,
            gems: gems,
            lastUpdated: now,
            totalWateringCount: totalCount,
            wateringCountToday: todayCount,
            wateringCountThisWeek: weekCount,
            wateringCountThisMonth: monthCount,
            completedStreakDates: Array(streakCompletedDates)
        )

        guard let defaults = UserDefaults(suiteName: appGroupID) else { return }
        if let encoded = try? JSONEncoder().encode(data) {
            defaults.set(encoded, forKey: userDefaultsKey)
        }
        WidgetCenter.shared.reloadAllTimelines()
    }
}
