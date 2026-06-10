import Foundation
import WidgetKit

struct WidgetPlantData: Codable, Sendable {
    let id: String
    let name: String
    let imageName: String
    let streak: Int
    let isWateredToday: Bool
    let rarityColor: String   // "bronze" | "silber" | "gold" | "diamant"
    let xp: Int
    let xpForNextRarity: Int

    init(id: String, name: String, imageName: String, streak: Int, isWateredToday: Bool, rarityColor: String, xp: Int, xpForNextRarity: Int) {
        self.id = id
        self.name = name
        self.imageName = imageName
        self.streak = streak
        self.isWateredToday = isWateredToday
        self.rarityColor = rarityColor
        self.xp = xp
        self.xpForNextRarity = xpForNextRarity
    }
}

struct WidgetAppData: Codable, Sendable {
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

    init(plants: [WidgetPlantData], totalStreak: Int, gems: Int, lastUpdated: Date, totalWateringCount: Int, wateringCountToday: Int, wateringCountThisWeek: Int, wateringCountThisMonth: Int, completedStreakDates: [Date]) {
        self.plants = plants
        self.totalStreak = totalStreak
        self.gems = gems
        self.lastUpdated = lastUpdated
        self.totalWateringCount = totalWateringCount
        self.wateringCountToday = wateringCountToday
        self.wateringCountThisWeek = wateringCountThisWeek
        self.wateringCountThisMonth = wateringCountThisMonth
        self.completedStreakDates = completedStreakDates
    }
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
        let startOfWeek = cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
        let startOfMonth = cal.date(from: cal.dateComponents([.year, .month], from: now))!

        // Alle wateringDates aller Pflanzen zusammensammeln
        let allDates: [Date] = habits.flatMap { $0.wateringDates }

        let totalCount      = allDates.count
        let todayCount      = allDates.filter { cal.isDate($0, inSameDayAs: now) }.count
        let weekCount       = allDates.filter { $0 >= startOfWeek }.count
        let monthCount      = allDates.filter { $0 >= startOfMonth }.count

        let lang = SharedUserDefaults.suite.string(forKey: "appLanguage") ?? Locale.current.language.languageCode?.identifier ?? "de"

        let plants: [WidgetPlantData] = habits.prefix(4).map { habit in
            var finalName = habit.displayedHabitName
            
            if finalName.contains(".") {
                finalName = AppStrings.get(finalName, language: lang)
            }
            
            // Fallback: If it's still a raw key (e.g. translation failed), use the plant's actual display name
            if finalName.isEmpty || finalName.contains(".") {
                if let dbPlant = GameDatabase.allPlants.first(where: { $0.id.lowercased() == habit.plantID.lowercased() }) {
                    finalName = AppStrings.get(dbPlant.name, language: lang)
                }
            }
            
            return WidgetPlantData(
                id: habit.id,
                name: finalName,
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
