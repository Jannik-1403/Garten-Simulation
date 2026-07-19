import Foundation
import SwiftUI

struct DailyFocusTime: Identifiable, Equatable, Codable {
    let id: UUID
    let date: Date
    let minutes: Int
    let dayName: String
    
    init(id: UUID = UUID(), date: Date, minutes: Int, dayName: String) {
        self.id = id
        self.date = date
        self.minutes = minutes
        self.dayName = dayName
    }
}

struct DailyHabitsCount: Identifiable, Equatable, Codable {
    let id: UUID
    let date: Date
    let count: Int
    let dayName: String
    
    init(id: UUID = UUID(), date: Date, count: Int, dayName: String) {
        self.id = id
        self.date = date
        self.count = count
        self.dayName = dayName
    }
}

struct WeeklyReportData: Equatable, Codable {
    let weekStartDate: Date
    let weekEndDate: Date
    
    let totalFocusMinutes: Int
    let completedSessionsCount: Int
    let completedHabitsCount: Int
    let earnedXP: Int
    
    let focusMinutesChangePercentage: Double // z.B. +15.0 oder -10.0
    let habitsChangePercentage: Double
    
    let dailyFocusMinutes: [DailyFocusTime]
    let dailyHabitsCompleted: [DailyHabitsCount]
    
    let feedbackTitle: String
    let feedbackDescription: String
}

final class WeeklyStatsManager {
    static let shared = WeeklyStatsManager()
    
    private let calendar = Calendar.current
    
    func startOfWeek(for date: Date) -> Date {
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        components.weekday = 2 // Montag
        return calendar.date(from: components) ?? date
    }
    
    func endOfWeek(for date: Date) -> Date {
        let start = startOfWeek(for: date)
        return calendar.date(byAdding: .second, value: 7 * 24 * 3600 - 1, to: start) ?? date
    }
    
    func generateReport(for weekStart: Date, gardenStore: GardenStore) -> WeeklyReportData {
        let monday = calendar.startOfDay(for: weekStart)
        let sundayEnd = calendar.date(byAdding: .second, value: 7 * 24 * 3600 - 1, to: monday)!
        
        let prevMonday = calendar.date(byAdding: .day, value: -7, to: monday)!
        let prevSundayEnd = calendar.date(byAdding: .second, value: 7 * 24 * 3600 - 1, to: prevMonday)!
        
        // 1. Current Week Stats
        let currentSessions = gardenStore.focusSessions.filter { $0.date >= monday && $0.date <= sundayEnd }
        let currentFocusMinutes = currentSessions.reduce(0) { $0 + $1.durationMinutes }
        let currentSessionsCount = currentSessions.filter { $0.isCompleted }.count
        
        var currentHabitsCount = 0
        for plant in gardenStore.pflanzen {
            currentHabitsCount += plant.wateringDates.filter { $0 >= monday && $0 <= sundayEnd }.count
        }
        
        // Mocked XP calculation (historisch basierend auf Erledigungen oder Level)
        let currentXP = currentHabitsCount * 10 + currentSessionsCount * 25
        
        // 2. Previous Week Stats
        let prevSessions = gardenStore.focusSessions.filter { $0.date >= prevMonday && $0.date <= prevSundayEnd }
        let prevFocusMinutes = prevSessions.reduce(0) { $0 + $1.durationMinutes }
        
        var prevHabitsCount = 0
        for plant in gardenStore.pflanzen {
            prevHabitsCount += plant.wateringDates.filter { $0 >= prevMonday && $0 <= prevSundayEnd }.count
        }
        
        // 3. Percentage Changes
        let focusChange: Double
        if prevFocusMinutes == 0 {
            focusChange = currentFocusMinutes > 0 ? 100.0 : 0.0
        } else {
            focusChange = Double(currentFocusMinutes - prevFocusMinutes) / Double(prevFocusMinutes) * 100.0
        }
        
        let habitsChange: Double
        if prevHabitsCount == 0 {
            habitsChange = currentHabitsCount > 0 ? 100.0 : 0.0
        } else {
            habitsChange = Double(currentHabitsCount - prevHabitsCount) / Double(prevHabitsCount) * 100.0
        }
        
        // 4. Daily Data for Charts & Consistency Calculation
        var dailyFocus: [DailyFocusTime] = []
        var dailyHabits: [DailyHabitsCount] = []
        
        var currentDailyScores: [Double] = []
        var prevDailyScores: [Double] = []
        
        let weekdayNames = ["Mo", "Di", "Mi", "Do", "Fr", "Sa", "So"]
        
        for i in 0..<7 {
            let day = calendar.date(byAdding: .day, value: i, to: monday)!
            let dayStart = calendar.startOfDay(for: day)
            let dayEnd = calendar.date(byAdding: .second, value: 24 * 3600 - 1, to: dayStart)!
            
            let minutes = gardenStore.focusSessions
                .filter { $0.date >= dayStart && $0.date <= dayEnd }
                .reduce(0) { $0 + $1.durationMinutes }
            
            var habitsDone = 0
            var dailyScore = 0.0
            
            for plant in gardenStore.pflanzen {
                let doneToday = plant.wateringDates.contains(where: { $0 >= dayStart && $0 <= dayEnd })
                if doneToday {
                    habitsDone += 1
                    var weight = 1.0
                    if plant.streak >= 3 { weight += 0.5 }
                    if plant.seltenheit == .diamant || plant.seltenheit == .gold { weight += 0.5 }
                    dailyScore += weight
                }
            }
            currentDailyScores.append(dailyScore)
            
            let pDay = calendar.date(byAdding: .day, value: i, to: prevMonday)!
            let pDayStart = calendar.startOfDay(for: pDay)
            let pDayEnd = calendar.date(byAdding: .second, value: 24 * 3600 - 1, to: pDayStart)!
            
            var pDailyScore = 0.0
            for plant in gardenStore.pflanzen {
                let donePrev = plant.wateringDates.contains(where: { $0 >= pDayStart && $0 <= pDayEnd })
                if donePrev {
                    var weight = 1.0
                    if plant.streak >= 3 { weight += 0.5 }
                    if plant.seltenheit == .diamant || plant.seltenheit == .gold { weight += 0.5 }
                    pDailyScore += weight
                }
            }
            prevDailyScores.append(pDailyScore)
            
            let localizedDayKey = "common.day.\(i)" // Mo=0
            let localizedDay = NSLocalizedString(localizedDayKey, comment: "")
            let dayName = localizedDay.isEmpty ? weekdayNames[i] : localizedDay
            
            dailyFocus.append(DailyFocusTime(date: dayStart, minutes: minutes, dayName: dayName))
            dailyHabits.append(DailyHabitsCount(date: dayStart, count: habitsDone, dayName: dayName))
        }
        
        func calculateStdDev(_ data: [Double]) -> Double {
            let count = Double(data.count)
            guard count > 0 else { return 0.0 }
            let mean = data.reduce(0, +) / count
            let variance = data.reduce(0) { $0 + pow($1 - mean, 2) } / count
            return sqrt(variance)
        }
        
        // Normalize daily minutes and habits to a 0-1 scale to combine them
        let maxFocus = dailyFocus.map { Double($0.minutes) }.max() ?? 1.0
        let safeMaxFocus = maxFocus > 0 ? maxFocus : 1.0
        
        let maxHabits = dailyHabits.map { Double($0.count) }.max() ?? 1.0
        let safeMaxHabits = maxHabits > 0 ? maxHabits : 1.0
        
        var combinedScores: [Double] = []
        for i in 0..<7 {
            let nFocus = Double(dailyFocus[i].minutes) / safeMaxFocus
            let nHabits = Double(dailyHabits[i].count) / safeMaxHabits
            
            // Weight habits slightly more if there's no focus, or combine
            let combined = (nFocus + nHabits) / 2.0
            combinedScores.append(combined)
        }
        
        let currentCombinedStdDev = calculateStdDev(combinedScores)
        
        let title: String
        let desc: String
        
        // 5. Generate Feedback Title and Description
        let hasEnoughData = currentFocusMinutes >= 30 || currentHabitsCount >= 3
        
        if !hasEnoughData {
            title = String(localized: "smart.weekly.title.insufficient", defaultValue: "Mehr Daten benötigt")
            desc = String(localized: "smart.weekly.desc.insufficient", defaultValue: "Sammle in dieser Woche noch etwas mehr Fokuszeit oder hake Gewohnheiten ab, um eine echte Analyse deines Rhythmus zu erhalten. Jeder Tag zählt!")
        } else if currentCombinedStdDev > 0.35 {
            title = String(localized: "smart.weekly.title.fluctuating", defaultValue: "Starke Schwankungen")
            desc = String(localized: "smart.weekly.desc.fluctuating", defaultValue: "Dein Rhythmus war diese Woche sehr instabil. An manchen Tagen warst du extrem produktiv, an anderen ist alles eingebrochen. Versuche nächste Woche nicht alles auf einmal zu wollen, sondern lieber jeden Tag ein kleines bisschen zu machen.")
        } else {
            // Stable performance
            if currentHabitsCount < 10 && currentFocusMinutes < 60 {
                title = String(localized: "smart.weekly.title.stable_low", defaultValue: "Stabiles Fundament")
                desc = String(localized: "smart.weekly.desc.stable_low", defaultValue: "Die absolute Menge an erledigten Aufgaben ist zwar noch gering, aber deine Beständigkeit ist hervorragend. Du vermeidest extreme Schwankungen, was der perfekte Nährboden für langfristige Routinen ist. Baue nächste Woche sanft darauf auf.")
            } else {
                title = String(localized: "smart.weekly.title.consistent", defaultValue: "Eiserne Konstanz")
                desc = String(localized: "smart.weekly.desc.consistent", defaultValue: "Beeindruckend! Du zeigst nicht nur starkes Volumen, sondern hältst deine Leistung auch über die Tage extrem stabil. Es gibt kaum Schwankungen in deiner Routine – du hast dein System gemeistert.")
            }
        }

        return WeeklyReportData(
            weekStartDate: monday,
            weekEndDate: sundayEnd,
            totalFocusMinutes: currentFocusMinutes,
            completedSessionsCount: currentSessionsCount,
            completedHabitsCount: currentHabitsCount,
            earnedXP: currentXP,
            focusMinutesChangePercentage: focusChange,
            habitsChangePercentage: habitsChange,
            dailyFocusMinutes: dailyFocus,
            dailyHabitsCompleted: dailyHabits,
            feedbackTitle: title,
            feedbackDescription: desc
        )
    }
}
