import Foundation
import SwiftUI
import Combine

@MainActor
final class StatDetailViewModel: ObservableObject {
    @Published var wateringHistory: [DailyWatering] = []
    @Published var xpHistory: [DailyXP] = []
    @Published var coinHistory: [CoinHistory] = []
    
    @Published var goodHabitsCount: Int = 0
    @Published var badHabitsCount: Int = 0
    
    // Fast lookup dictionaries for O(1) performance during drag gestures
    @Published var eventDetails: [Date: HabitEventDetail] = [:]
    @Published var xpDetails: [Date: XPEventDetail] = [:]
    @Published var coinDetails: [Date: CoinEventDetail] = [:]
    
    struct HabitEventDetail {
        let name: String
        let symbolName: String
        let color: Color
        let change: Int
    }
    
    struct XPEventDetail {
        let name: String
        let color: Color
    }
    
    struct CoinEventDetail {
        let beschreibung: String
        let icon: String
        let farbe: Color
        let betrag: Int
    }
    
    func loadData(for period: StatsPeriod, endDate: Date = Date(), detail: StatisticsDashboard.StatDetail, gardenStore: GardenStore, settings: SettingsStore) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: endDate)
        let targetDate = endDate
        
        switch detail {
        case .activity:
            self.wateringHistory = StatsHelper.getWateringHistory(from: gardenStore.pflanzen, badHabitExecutions: gardenStore.badHabitExecutions, days: period.days, endDate: endDate)
            
            var newEventDetails: [Date: HabitEventDetail] = [:]
            if period == .day {
                for plant in gardenStore.pflanzen {
                    let change = plant.isNegative ? -1 : 1
                    let name = plant.habitName.isEmpty ? plant.name : plant.habitName
                    let localizedName = NSLocalizedString(name, comment: "")
                    let detail = HabitEventDetail(name: localizedName, symbolName: plant.symbolName, color: Color(hex: plant.symbolColor), change: change)
                    
                    for d in plant.wateringDates where calendar.isDate(d, inSameDayAs: today) {
                        newEventDetails[d] = detail
                    }
                }
                
                for (habitID, executions) in gardenStore.badHabitExecutions {
                    var name = habitID
                    var icon = "smoke.fill"
                    var colorHex = "#EF4444"
                    if let dbPlant = GameDatabase.allPlants.first(where: { $0.id == habitID }) {
                        name = dbPlant.habitName.isEmpty ? dbPlant.name : dbPlant.habitName
                        icon = dbPlant.symbolName
                        colorHex = dbPlant.symbolColor
                    }
                    let localizedName = NSLocalizedString(name, comment: "")
                    let detail = HabitEventDetail(name: localizedName, symbolName: icon, color: Color(hex: colorHex), change: -1)
                    
                    for exec in executions where calendar.isDate(exec.date, inSameDayAs: today) {
                        newEventDetails[exec.date] = detail
                    }
                }
            }
            self.eventDetails = newEventDetails
            
            if period != .day {
                self.goodHabitsCount = gardenStore.pflanzen.filter { !$0.isNegative && $0.wateringDates.contains { calendar.isDate($0, inSameDayAs: targetDate) } }.count
                
                let customBadCompleted = gardenStore.pflanzen.filter { $0.isNegative && $0.wateringDates.contains { calendar.isDate($0, inSameDayAs: targetDate) } }.count
                let predefinedBadCompleted = gardenStore.badHabitExecutions.values.flatMap { $0 }.filter { calendar.isDate($0.date, inSameDayAs: targetDate) }.count
                self.badHabitsCount = customBadCompleted + predefinedBadCompleted
            }
            
        case .xp:
            self.xpHistory = StatsHelper.getXPHistory(from: gardenStore.pflanzen, currentTotalXP: gardenStore.gesamtXP, days: period.days, endDate: endDate)
            var newXPDetails: [Date: XPEventDetail] = [:]
            if period == .day {
                for plant in gardenStore.pflanzen {
                    let name = plant.habitName.isEmpty ? plant.name : plant.habitName
                    let localizedName = NSLocalizedString(name, comment: "")
                    let detail = XPEventDetail(name: localizedName, color: Color(hex: plant.symbolColor))
                    
                    for d in plant.wateringDates where calendar.isDate(d, inSameDayAs: today) {
                        newXPDetails[d] = detail
                    }
                }
            }
            self.xpDetails = newXPDetails
            
        case .coins:
            self.coinHistory = StatsHelper.getCoinHistory(from: gardenStore.transactions, currentBalance: gardenStore.coins, days: period.days, endDate: endDate)
            var newCoinDetails: [Date: CoinEventDetail] = [:]
            if period == .day {
                for tx in gardenStore.transactions where calendar.isDate(tx.datum, inSameDayAs: today) {
                    let detail = CoinEventDetail(beschreibung: NSLocalizedString(tx.beschreibung, comment: ""), icon: tx.icon, farbe: tx.farbe, betrag: tx.betrag)
                    newCoinDetails[tx.datum] = detail
                }
            }
            self.coinDetails = newCoinDetails
            
        default:
            break
        }
    }
    
    // MARK: - Binary Search Score Resolvers
    
    func score(at date: Date) -> Int {
        guard !wateringHistory.isEmpty else { return 0 }
        return binarySearchWatering(in: wateringHistory, for: date)?.count ?? wateringHistory.first!.count
    }
    
    func xp(at date: Date) -> Int {
        guard !xpHistory.isEmpty else { return 0 }
        return binarySearchXP(in: xpHistory, for: date)?.amount ?? xpHistory.first!.amount
    }
    
    func coins(at date: Date) -> Int {
        guard !coinHistory.isEmpty else { return 0 }
        return binarySearchCoins(in: coinHistory, for: date)?.balance ?? coinHistory.first!.balance
    }
    
    // MARK: - Event Detail Resolvers
    
    func getEventDetail(at date: Date) -> HabitEventDetail? {
        for (eventDate, detail) in eventDetails {
            if abs(eventDate.timeIntervalSince(date)) < 1.0 {
                return detail
            }
        }
        return nil
    }
    
    func getXPEventDetail(at date: Date) -> XPEventDetail? {
        for (eventDate, detail) in xpDetails {
            if abs(eventDate.timeIntervalSince(date)) < 1.0 {
                return detail
            }
        }
        return nil
    }
    
    func getCoinEventDetail(at date: Date) -> CoinEventDetail? {
        for (eventDate, detail) in coinDetails {
            if abs(eventDate.timeIntervalSince(date)) < 1.0 {
                return detail
            }
        }
        return nil
    }
    
    // MARK: - Private Binary Search Implementations
    
    private func binarySearchWatering(in history: [DailyWatering], for date: Date) -> DailyWatering? {
        var low = 0
        var high = history.count - 1
        var best: DailyWatering?
        
        while low <= high {
            let mid = low + (high - low) / 2
            let current = history[mid]
            
            if current.date <= date {
                best = current
                low = mid + 1
            } else {
                high = mid - 1
            }
        }
        return best
    }
    
    private func binarySearchXP(in history: [DailyXP], for date: Date) -> DailyXP? {
        var low = 0
        var high = history.count - 1
        var best: DailyXP?
        
        while low <= high {
            let mid = low + (high - low) / 2
            let current = history[mid]
            
            if current.date <= date {
                best = current
                low = mid + 1
            } else {
                high = mid - 1
            }
        }
        return best
    }
    
    private func binarySearchCoins(in history: [CoinHistory], for date: Date) -> CoinHistory? {
        var low = 0
        var high = history.count - 1
        var best: CoinHistory?
        
        while low <= high {
            let mid = low + (high - low) / 2
            let current = history[mid]
            
            if current.date <= date {
                best = current
                low = mid + 1
            } else {
                high = mid - 1
            }
        }
        return best
    }
}
