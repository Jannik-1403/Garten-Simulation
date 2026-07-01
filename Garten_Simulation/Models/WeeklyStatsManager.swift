import Foundation
import SwiftUI

struct DailyFocusTime: Identifiable, Equatable {
    let id = UUID()
    let date: Date
    let minutes: Int
    let dayName: String
}

struct DailyHabitsCount: Identifiable, Equatable {
    let id = UUID()
    let date: Date
    let count: Int
    let dayName: String
}

struct WeeklyReportData: Equatable {
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
        
        // 4. Daily Data for Charts
        var dailyFocus: [DailyFocusTime] = []
        var dailyHabits: [DailyHabitsCount] = []
        
        let weekdayNames = ["Mo", "Di", "Mi", "Do", "Fr", "Sa", "So"]
        
        for i in 0..<7 {
            let day = calendar.date(byAdding: .day, value: i, to: monday)!
            let dayStart = calendar.startOfDay(for: day)
            let dayEnd = calendar.date(byAdding: .second, value: 24 * 3600 - 1, to: dayStart)!
            
            let minutes = gardenStore.focusSessions
                .filter { $0.date >= dayStart && $0.date <= dayEnd }
                .reduce(0) { $0 + $1.durationMinutes }
            
            var habitsDone = 0
            for plant in gardenStore.pflanzen {
                habitsDone += plant.wateringDates.filter { $0 >= dayStart && $0 <= dayEnd }.count
            }
            
            let localizedDayKey = "common.day.\(i)" // Mo=0
            let localizedDay = NSLocalizedString(localizedDayKey, comment: "")
            let dayName = localizedDay.isEmpty ? weekdayNames[i] : localizedDay
            
            dailyFocus.append(DailyFocusTime(date: dayStart, minutes: minutes, dayName: dayName))
            dailyHabits.append(DailyHabitsCount(date: dayStart, count: habitsDone, dayName: dayName))
        }
        
        // 5. Generate Feedback Title and Description
        let bestDayIndex = dailyFocus.indices.max(by: { dailyFocus[$0].minutes < dailyFocus[$1].minutes }) ?? 0
        let bestDayName = dailyFocus[bestDayIndex].minutes > 0 ? dailyFocus[bestDayIndex].dayName : "—"
        
        let title: String
        let desc: String
        
        let percentFocusString = "\(Int(abs(focusChange)))%"
        
        if focusChange >= 10.0 {
            title = String(localized: "weekly_report.feedback.title.positive", defaultValue: "Großartige Woche!")
            if bestDayName != "—" {
                desc = String(
                    format: String(localized: "weekly_report.feedback.desc.positive_with_day", defaultValue: "Hervorragend! Du hast deine Fokuszeit im Vergleich zur Vorwoche um %@ gesteigert. Dein produktivster Tag war %@. Mach weiter so!"),
                    percentFocusString, bestDayName
                )
            } else {
                desc = String(
                    format: String(localized: "weekly_report.feedback.desc.positive", defaultValue: "Super! Du hast deine Fokuszeit im Vergleich zur Vorwoche um %@ gesteigert. Mach weiter so!"),
                    percentFocusString
                )
            }
        } else if focusChange <= -10.0 {
            title = String(localized: "weekly_report.feedback.title.negative", defaultValue: "Ruhigere Woche")
            if bestDayName != "—" {
                desc = String(
                    format: String(localized: "weekly_report.feedback.desc.negative_with_day", defaultValue: "Diese Woche war etwas ruhiger. Deine Fokuszeit ist um %@ gesunken. Dein bester Tag war %@. Nächste Woche greifen wir wieder voll an!"),
                    percentFocusString, bestDayName
                )
            } else {
                desc = String(
                    format: String(localized: "weekly_report.feedback.desc.negative", defaultValue: "Diese Woche war etwas ruhiger. Deine Fokuszeit ist um %@ gesunken. Kopf hoch, nächste Woche wird wieder produktiver!"),
                    percentFocusString
                )
            }
        } else {
            title = String(localized: "weekly_report.feedback.title.neutral", defaultValue: "Konstante Woche")
            if bestDayName != "—" {
                desc = String(
                    format: String(localized: "weekly_report.feedback.desc.neutral_with_day", defaultValue: "Du warst diese Woche sehr konstant. Deine Fokuszeit ist stabil geblieben. Dein bester Tag war %@."),
                    bestDayName
                )
            } else {
                desc = String(localized: "weekly_report.feedback.desc.neutral", defaultValue: "Eine solide, ausgeglichene Woche. Halte deine Gewohnheiten weiter so konstant!")
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
