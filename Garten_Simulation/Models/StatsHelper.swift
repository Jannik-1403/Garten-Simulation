import Foundation
import SwiftUI

struct DailyXP: Identifiable {
    let id = UUID()
    let date: Date
    let amount: Int
}

struct DailyWatering: Identifiable {
    let id = UUID()
    let date: Date
    let count: Int
}

struct CoinHistory: Identifiable {
    let id = UUID()
    let date: Date
    let balance: Int
}

struct RarityData: Identifiable {
    let id = UUID()
    let rarity: PflanzenSeltenheit
    let count: Int
    let color: Color
    let percentage: Double
}

class StatsHelper {
    static func getWateringHistory(from plants: [HabitModel]) -> [DailyWatering] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Find the absolute oldest activity to determine the true start of history
        var firstActivityDate: Date? = nil
        for plant in plants {
            if let first = plant.wateringDates.min() {
                if firstActivityDate == nil || first < firstActivityDate! {
                    firstActivityDate = calendar.startOfDay(for: first)
                }
            }
        }
        
        let startDate = firstActivityDate ?? today
        var history: [Date: Int] = [:]
        
        // Always show at least today and up to 7 days, but only back to startDate
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                let startOfDate = calendar.startOfDay(for: date)
                if startOfDate >= startDate {
                    history[startOfDate] = 0
                }
            }
        }
        
        // Always ensure at least today is present
        history[today] = 0
        
        for plant in plants {
            for wateringDate in plant.wateringDates {
                let startOfDay = calendar.startOfDay(for: wateringDate)
                if history[startOfDay] != nil {
                    history[startOfDay, default: 0] += 1
                }
            }
        }
        
        return history.map { DailyWatering(date: $0.key, count: $0.value) }
            .sorted { $0.date < $1.date }
    }
    
    static func getXPHistory(from plants: [HabitModel], currentTotalXP: Int) -> [DailyXP] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        var firstActivityDate: Date? = nil
        for plant in plants {
            for dateStr in plant.xpHistory.keys {
                if let d = formatter.date(from: dateStr) {
                    if firstActivityDate == nil || d < firstActivityDate! {
                        firstActivityDate = calendar.startOfDay(for: d)
                    }
                }
            }
        }
        
        let startDate = firstActivityDate ?? today
        var dailyGains: [Date: Int] = [:]
        
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                let startOfDate = calendar.startOfDay(for: date)
                if startOfDate >= startDate {
                    dailyGains[startOfDate] = 0
                }
            }
        }
        
        dailyGains[today] = 0
        
        for plant in plants {
            for (dateString, xp) in plant.xpHistory {
                if let date = formatter.date(from: dateString) {
                    let startOfDay = calendar.startOfDay(for: date)
                    if dailyGains[startOfDay] != nil {
                        dailyGains[startOfDay, default: 0] += xp
                    }
                }
            }
        }
        
        var result: [DailyXP] = []
        var runningTotal = currentTotalXP
        let sortedDates = dailyGains.keys.sorted(by: { $0 > $1 })
        
        for date in sortedDates {
            result.append(DailyXP(date: date, amount: runningTotal))
            runningTotal -= dailyGains[date] ?? 0
        }
        
        return result.sorted { $0.date < $1.date }
    }
    
    static func getCoinHistory(from transactions: [CoinTransaction], currentBalance: Int) -> [CoinHistory] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        var firstTxDate: Date? = nil
        if let first = transactions.map({ $0.datum }).min() {
            firstTxDate = calendar.startOfDay(for: first)
        }
        
        let startDate = firstTxDate ?? today
        var history: [CoinHistory] = []
        var tempBalance = currentBalance
        
        let sortedTransactions = transactions.sorted { $0.datum > $1.datum }
        
        for i in 0..<7 {
            if let targetDate = calendar.date(byAdding: .day, value: -i, to: today) {
                let startOfTarget = calendar.startOfDay(for: targetDate)
                if startOfTarget >= startDate {
                    history.append(CoinHistory(date: startOfTarget, balance: tempBalance))
                    
                    let dayTxs = sortedTransactions.filter { calendar.isDate($0.datum, inSameDayAs: targetDate) }
                    for tx in dayTxs {
                        tempBalance -= tx.betrag
                    }
                }
            }
        }
        
        if history.isEmpty {
            history.append(CoinHistory(date: today, balance: currentBalance))
        }
        
        return history.sorted { $0.date < $1.date }
    }
    
    static func getRarityDistribution(from plants: [HabitModel]) -> [RarityData] {
        let total = max(1, plants.count)
        let bronze = plants.filter { $0.seltenheit == .bronze }.count
        let silber = plants.filter { $0.seltenheit == .silber }.count
        let gold = plants.filter { $0.seltenheit == .gold }.count
        let diamant = plants.filter { $0.seltenheit == .diamant }.count
        
        return [
            RarityData(rarity: .diamant, count: diamant, color: .diamantPrimary, percentage: Double(diamant) / Double(total)),
            RarityData(rarity: .gold, count: gold, color: .goldPrimary, percentage: Double(gold) / Double(total)),
            RarityData(rarity: .silber, count: silber, color: .silberPrimary, percentage: Double(silber) / Double(total)),
            RarityData(rarity: .bronze, count: bronze, color: .bronzePrimary, percentage: Double(bronze) / Double(total))
        ]
    }
    
    static func getCategoryBalance(from plants: [HabitModel], timeframe: StatsPeriod = .week) -> [HabitCategory: Double] {
        var results: [HabitCategory: Double] = [:]
        let calendar = Calendar.current
        let today = Date()
        
        let days = timeframe.days
        
        // XP Goal per plant for the period (roughly 100 XP per day for 100% score)
        let xpGoal = Double(days) * 100.0
        
        for category in HabitCategory.allCases {
            let catPlants = plants.filter { $0.habitCategory == category }
            if catPlants.isEmpty {
                results[category] = 0.0
                continue
            }
            
            let totalConsistency = catPlants.reduce(0.0) { acc, plant in
                // 1. Long-term Achievement: XP gained in the last X days
                var periodXP = 0
                for i in 0..<days {
                    if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                        let dateString = StatsHelper.dateFormatter.string(from: date)
                        periodXP += plant.xpHistory[dateString] ?? 0
                    }
                }
                
                // For 'Week' we also consider current XP as a baseline for new users
                if timeframe == .week && periodXP < 100 {
                    periodXP = max(periodXP, plant.currentXP)
                }
                
                let xpProgress = min(1.0, Double(periodXP) / xpGoal)
                
                // 2. Short-term Consistency: Streak
                // For Month/Year, streak should have slightly less weight than daily achievement
                let streakWeight = timeframe == .week ? 0.6 : 0.3
                let xpWeight = 1.0 - streakWeight
                
                let streakProgress = min(1.0, Double(plant.streak) / 10.0)
                
                let combined = (xpProgress * xpWeight) + (streakProgress * streakWeight)
                
                // Penalty for missed cycles (25% reduction per missed 24h window)
                let penalty = Double(plant.missedCycles) * 0.25
                
                let score = max(0.0, min(1.0, combined - penalty))
                return acc + score
            }
            
            results[category] = totalConsistency / Double(catPlants.count)
        }
        
        return results
    }
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    static func calculateXPTrend(from plants: [HabitModel], days: Int = 7) -> Double {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let startDate = calendar.date(byAdding: .day, value: -days, to: today) ?? today
        
        var recentGain = 0
        var totalBefore = 0
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        for plant in plants {
            for (dateString, xp) in plant.xpHistory {
                if let date = formatter.date(from: dateString) {
                    if date >= startDate {
                        recentGain += xp
                    }
                }
            }
        }
        
        // This is an approximation since we don't know the exact starting total XP
        // But for a badge, "XP gained in last 7 days" is often better than a percentage of a huge total.
        return Double(recentGain)
    }
    
    static func calculateCoinTrend(from transactions: [CoinTransaction], currentBalance: Int, days: Int = 7) -> Double {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let startDate = calendar.date(byAdding: .day, value: -days, to: today) ?? today
        
        var netChange = 0
        for tx in transactions {
            if tx.datum >= startDate {
                netChange += tx.betrag
            }
        }
        
        let previousBalance = currentBalance - netChange
        if previousBalance <= 0 { return 1.0 }
        return Double(netChange) / Double(previousBalance)
    }
}
