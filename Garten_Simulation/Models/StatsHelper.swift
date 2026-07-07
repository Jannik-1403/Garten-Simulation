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

struct DailyFocus: Identifiable {
    let id = UUID()
    let date: Date
    let completedMinutes: Int
    let abortedMinutes: Int
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
    static func getTriggerCounts(from badHabitExecutions: [String: [BadHabitExecution]], days: Int, endDate: Date = Date()) -> [(key: String, value: Int)] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: endDate)
        let startDate: Date
        if days == 0 {
            startDate = .distantPast // Assume 0 means all time if not handled, or just pass Int.max
        } else {
            startDate = calendar.date(byAdding: .day, value: -days, to: today) ?? .distantPast
        }
        
        var triggerCounts: [String: Int] = [:]
        for list in badHabitExecutions.values {
            for execution in list {
                if execution.date >= startDate {
                    if let triggers = execution.triggers {
                        for t in triggers {
                            triggerCounts[t, default: 0] += 1
                        }
                    }
                }
            }
        }
        return triggerCounts.sorted { $0.value > $1.value }
    }

    static func getWateringHistory(from plants: [HabitModel], badHabitExecutions: [String: [BadHabitExecution]] = [:], days: Int = 7, endDate: Date = Date()) -> [DailyWatering] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: endDate)
        
        if days == 1 {
            // Collect all changes today with their exact timestamps
            struct TempEvent {
                let date: Date
                let change: Int
            }
            var tempEvents: [TempEvent] = []
            
            for plant in plants {
                let change = plant.isNegative ? -1 : 1
                for wateringDate in plant.wateringDates {
                    if calendar.isDate(wateringDate, inSameDayAs: today) {
                        tempEvents.append(TempEvent(date: wateringDate, change: change))
                    }
                }
            }
            
            for executionsList in badHabitExecutions.values {
                for execution in executionsList {
                    if calendar.isDate(execution.date, inSameDayAs: today) {
                        tempEvents.append(TempEvent(date: execution.date, change: -1))
                    }
                }
            }
            
            // Sort chronologically
            tempEvents.sort(by: { $0.date < $1.date })
            
            var history: [DailyWatering] = []
            
            // Start of day point (0:00 today)
            history.append(DailyWatering(date: today, count: 0))
            
            var runningTotal = 0
            for event in tempEvents {
                runningTotal += event.change
                history.append(DailyWatering(date: event.date, count: runningTotal))
            }
            
            // End of day point (0:00 of next day)
            if let nextDay = calendar.date(byAdding: .day, value: 1, to: today),
               let midnightNextDay = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: nextDay) {
                history.append(DailyWatering(date: midnightNextDay, count: runningTotal))
            }
            
            return history
        }
        
        // Multi-day view (Week, Month, Year, All Time)
        var actualDays = days
        if days == 10000 {
            var earliest = today
            for plant in plants {
                if let pEarliest = plant.wateringDates.min(), pEarliest < earliest {
                    earliest = pEarliest
                }
                if plant.gekauftAm < earliest {
                    earliest = plant.gekauftAm
                }
            }
            for list in badHabitExecutions.values {
                if let eEarliest = list.map({ $0.date }).min(), eEarliest < earliest {
                    earliest = eEarliest
                }
            }
            let diff = calendar.dateComponents([.day], from: calendar.startOfDay(for: earliest), to: today).day ?? 0
            actualDays = max(7, diff + 1)
        }
        
        // Generate and sort the dates in the timeframe
        var periodDates: [Date] = []
        for i in 0..<actualDays {
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                periodDates.append(calendar.startOfDay(for: date))
            }
        }
        periodDates.append(today)
        let sortedPeriodDates = Array(Set(periodDates)).sorted()
        
        // Start the cumulative total at 0 at the beginning of the period
        var runningTotal = 0
        
        // 2. Count the changes on each day within the period
        var dailyChanges: [Date: Int] = [:]
        for date in sortedPeriodDates {
            dailyChanges[date] = 0
        }
        
        for plant in plants {
            let change = plant.isNegative ? -1 : 1
            for wateringDate in plant.wateringDates {
                let startOfDay = calendar.startOfDay(for: wateringDate)
                if dailyChanges[startOfDay] != nil {
                    dailyChanges[startOfDay, default: 0] += change
                }
            }
        }
        
        for executionsList in badHabitExecutions.values {
            for execution in executionsList {
                let startOfDay = calendar.startOfDay(for: execution.date)
                if dailyChanges[startOfDay] != nil {
                    dailyChanges[startOfDay, default: 0] -= 1
                }
            }
        }
        
        // 3. Accumulate daily changes chronologically
        var history: [DailyWatering] = []
        for date in sortedPeriodDates {
            let change = dailyChanges[date] ?? 0
            runningTotal += change
            history.append(DailyWatering(date: date, count: runningTotal))
        }
        
        return history
    }

    static func getFocusHistory(from sessions: [FocusSessionLog], days: Int = 7, endDate: Date = Date()) -> [DailyFocus] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: endDate)
        
        if days == 1 {
            var hourlyFocus: [Date: (completed: Int, aborted: Int)] = [:]
            for hour in 0..<24 {
                if let date = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: today) {
                    hourlyFocus[date] = (0, 0)
                }
            }
            
            for session in sessions {
                if calendar.isDate(session.date, inSameDayAs: today) {
                    if let hourDate = calendar.date(bySettingHour: calendar.component(.hour, from: session.date), minute: 0, second: 0, of: today) {
                        if session.isCompleted {
                            hourlyFocus[hourDate]!.completed += session.durationMinutes
                        } else {
                            hourlyFocus[hourDate]!.aborted += session.durationMinutes
                        }
                    }
                }
            }
            
            var history: [DailyFocus] = []
            let sortedDates = hourlyFocus.keys.sorted()
            for date in sortedDates {
                let data = hourlyFocus[date]!
                history.append(DailyFocus(date: date, completedMinutes: data.completed, abortedMinutes: data.aborted))
            }
            return history
        }
        
        var actualDays = days
        if days == 10000 {
            var earliest = today
            if let firstSession = sessions.min(by: { $0.date < $1.date }) {
                earliest = calendar.startOfDay(for: firstSession.date)
            }
            let diff = calendar.dateComponents([.day], from: earliest, to: today).day ?? 0
            actualDays = max(7, diff + 1)
        }
        
        var dailyFocus: [Date: (completed: Int, aborted: Int)] = [:]
        
        for i in 0..<actualDays {
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                dailyFocus[calendar.startOfDay(for: date)] = (0, 0)
            }
        }
        dailyFocus[today] = (0, 0)
        
        for session in sessions {
            let startOfDay = calendar.startOfDay(for: session.date)
            if dailyFocus[startOfDay] != nil {
                if session.isCompleted {
                    dailyFocus[startOfDay]!.completed += session.durationMinutes
                } else {
                    dailyFocus[startOfDay]!.aborted += session.durationMinutes
                }
            }
        }
        
        var history: [DailyFocus] = []
        let sortedDates = dailyFocus.keys.sorted()
        
        for date in sortedDates {
            let data = dailyFocus[date]!
            history.append(DailyFocus(date: date, completedMinutes: data.completed, abortedMinutes: data.aborted))
        }
        
        return history
    }

    static func getXPHistory(from plants: [HabitModel], currentTotalXP: Int, days: Int = 7, endDate: Date = Date()) -> [DailyXP] {
        let calendar = Calendar.current
        let realToday = calendar.startOfDay(for: Date())
        let today = calendar.startOfDay(for: endDate)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        var tempXP = currentTotalXP
        let daysToBacktrack = calendar.dateComponents([.day], from: today, to: realToday).day ?? 0
        if daysToBacktrack > 0 {
            for i in 0..<daysToBacktrack {
                if let d = calendar.date(byAdding: .day, value: -i, to: realToday) {
                    let dateString = formatter.string(from: d)
                    for plant in plants {
                        if let gained = plant.xpHistory[dateString] {
                            tempXP -= gained
                        }
                    }
                }
            }
        }
        

        if days == 1 {
            struct TempEvent {
                let date: Date
                let amount: Int
            }
            var tempEvents: [TempEvent] = []
            
            let todayStr = formatter.string(from: today)
            for plant in plants {
                if let xp = plant.xpHistory[todayStr] {
                    // Find watering dates today for this plant
                    let waterings = plant.wateringDates.filter { calendar.isDate($0, inSameDayAs: today) }.sorted()
                    if !waterings.isEmpty {
                        // Distribute XP evenly among waterings
                        let share = xp / waterings.count
                        let remainder = xp % waterings.count
                        for (idx, date) in waterings.enumerated() {
                            tempEvents.append(TempEvent(date: date, amount: share + (idx == 0 ? remainder : 0)))
                        }
                    } else {
                        // If no watering dates but XP exists, default to 12:00
                        if let midDate = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: today) {
                            tempEvents.append(TempEvent(date: midDate, amount: xp))
                        }
                    }
                }
            }
            
            tempEvents.sort(by: { $0.date < $1.date })
            
            var history: [DailyXP] = []
            let totalXPToday = tempEvents.map({ $0.amount }).reduce(0, +)
            var runningTotal = tempXP - totalXPToday
            
            // Start of day
            history.append(DailyXP(date: today, amount: runningTotal))
            
            for event in tempEvents {
                runningTotal += event.amount
                history.append(DailyXP(date: event.date, amount: runningTotal))
            }
            
            // End of day (0:00 next day)
            if let nextDay = calendar.date(byAdding: .day, value: 1, to: today),
               let midnightNextDay = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: nextDay) {
                history.append(DailyXP(date: midnightNextDay, amount: runningTotal))
            }
            
            return history
        }
        
        var actualDays = days
        if days == 10000 {
            var earliest = today
            for plant in plants {
                if plant.gekauftAm < earliest {
                    earliest = plant.gekauftAm
                }
                for dateString in plant.xpHistory.keys {
                    if let date = formatter.date(from: dateString), date < earliest {
                        earliest = date
                    }
                }
            }
            let diff = calendar.dateComponents([.day], from: calendar.startOfDay(for: earliest), to: today).day ?? 0
            actualDays = max(7, diff + 1)
        }
        
        var dailyGains: [Date: Int] = [:]
        
        // Always show the full timeframe (e.g. 7 or 30 days) to allow drawing a complete line
        for i in 0..<actualDays {
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                let startOfDate = calendar.startOfDay(for: date)
                dailyGains[startOfDate] = 0
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
        var runningTotal = tempXP
        let sortedDates = dailyGains.keys.sorted(by: { $0 > $1 })
        
        for date in sortedDates {
            result.append(DailyXP(date: date, amount: runningTotal))
            runningTotal -= dailyGains[date] ?? 0
        }
        
        return result.sorted { $0.date < $1.date }
    }
    static func getCoinHistory(from transactions: [CoinTransaction], currentBalance: Int, days: Int = 7, endDate: Date = Date()) -> [CoinHistory] {
        let calendar = Calendar.current
        let realToday = calendar.startOfDay(for: Date())
        let today = calendar.startOfDay(for: endDate)
        
        var tempBalanceStart = currentBalance
        let daysToBacktrack = calendar.dateComponents([.day], from: today, to: realToday).day ?? 0
        if daysToBacktrack > 0 {
            for i in 0..<daysToBacktrack {
                if let d = calendar.date(byAdding: .day, value: -i, to: realToday) {
                    let dayTxs = transactions.filter { calendar.isDate($0.datum, inSameDayAs: d) }
                    for tx in dayTxs {
                        tempBalanceStart -= tx.betrag
                    }
                }
            }
        }
        
        if days == 1 {
            var tempEvents: [CoinTransaction] = []
            for tx in transactions {
                if calendar.isDate(tx.datum, inSameDayAs: today) {
                    tempEvents.append(tx)
                }
            }
            
            tempEvents.sort(by: { $0.datum < $1.datum })
            
            var history: [CoinHistory] = []
            let totalChangeToday = tempEvents.map({ $0.betrag }).reduce(0, +)
            var runningTotal = tempBalanceStart - totalChangeToday
            
            // Start of day
            history.append(CoinHistory(date: today, balance: runningTotal))
            
            for event in tempEvents {
                runningTotal += event.betrag
                history.append(CoinHistory(date: event.datum, balance: runningTotal))
            }
            
            // End of day (0:00 next day)
            if let nextDay = calendar.date(byAdding: .day, value: 1, to: today),
               let midnightNextDay = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: nextDay) {
                history.append(CoinHistory(date: midnightNextDay, balance: runningTotal))
            }
            
            return history
        }
        
        var actualDays = days
        if days == 10000 {
            var earliest = today
            if let txEarliest = transactions.map({ $0.datum }).min(), txEarliest < earliest {
                earliest = txEarliest
            }
            let diff = calendar.dateComponents([.day], from: calendar.startOfDay(for: earliest), to: today).day ?? 0
            actualDays = max(7, diff + 1)
        }
        
        var history: [CoinHistory] = []
        var tempBalance = tempBalanceStart
        
        let sortedTransactions = transactions.sorted { $0.datum > $1.datum }
        
        // Always show the full timeframe (e.g. 7 or 30 days) to allow drawing a complete line
        for i in 0..<actualDays {
            if let targetDate = calendar.date(byAdding: .day, value: -i, to: today) {
                let startOfTarget = calendar.startOfDay(for: targetDate)
                history.append(CoinHistory(date: startOfTarget, balance: tempBalance))
                
                let dayTxs = sortedTransactions.filter { calendar.isDate($0.datum, inSameDayAs: targetDate) }
                for tx in dayTxs {
                    tempBalance -= tx.betrag
                }
            }
        }
        
        if history.isEmpty {
            history.append(CoinHistory(date: today, balance: tempBalanceStart))
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
    
    static func getCategoryBalance(from plants: [HabitModel], timeframe: StatsPeriod = .week, endDate: Date = Date()) -> [HabitCategory: Double] {
        var results: [HabitCategory: Double] = [:]
        let calendar = Calendar.current
        let today = endDate
        
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
    
    static func calculateXPTrend(from plants: [HabitModel], days: Int = 7, endDate: Date = Date()) -> Double {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: endDate)
        let startDate = calendar.date(byAdding: .day, value: -days, to: today) ?? today
        
        var recentGain = 0
        
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
    
    static func calculateCoinTrend(from transactions: [CoinTransaction], currentBalance: Int, days: Int = 7, endDate: Date = Date()) -> Double {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: endDate)
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
