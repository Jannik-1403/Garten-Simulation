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
        let hasEnoughData = currentFocusMinutes >= 30 || currentHabitsCount >= 3
        
        let title: String
        var desc: String = ""
        
        if !hasEnoughData {
            title = String(localized: "weekly_report.feedback.title.insufficient", defaultValue: "Mehr Daten benötigt")
            desc = String(localized: "weekly_report.feedback.desc.insufficient", defaultValue: "Sammle in dieser Woche noch etwas mehr Fokuszeit (mind. 30 Min.) oder hake Gewohnheiten ab (mind. 3), um eine tiefgehende Analyse und Tipps zu erhalten. Jeder kleine Schritt zählt!")
        } else {
            let bestFocusDayIndex = dailyFocus.indices.max(by: { dailyFocus[$0].minutes < dailyFocus[$1].minutes }) ?? 0
            let bestDayName = dailyFocus[bestFocusDayIndex].minutes > 0 ? dailyFocus[bestFocusDayIndex].dayName : "—"
            
            let bestHabitsDayIndex = dailyHabits.indices.max(by: { dailyHabits[$0].count < dailyHabits[$1].count }) ?? 0
            let bestHabitsDayName = dailyHabits[bestHabitsDayIndex].count > 0 ? dailyHabits[bestHabitsDayIndex].dayName : "—"
            
            let percentFocusString = "\(Int(abs(focusChange)))%"
            
            if focusChange >= 10.0 {
                title = String(localized: "weekly_report.feedback.title.positive", defaultValue: "Großartige Woche!")
                desc += String(
                    format: String(localized: "weekly_report.feedback.desc.positive_base", defaultValue: "Diese Woche lief fantastisch! Du hast deine Fokuszeit im Vergleich zur Vorwoche um %@ gesteigert. "),
                    percentFocusString
                )
            } else if focusChange <= -10.0 {
                title = String(localized: "weekly_report.feedback.title.negative", defaultValue: "Ruhigere Woche")
                desc += String(
                    format: String(localized: "weekly_report.feedback.desc.negative_base", defaultValue: "Diese Woche war etwas ruhiger und deine Fokuszeit ist um %@ gesunken. Aber mach dir keinen Kopf, Erholung ist genauso wichtig. Nächste Woche greifen wir wieder voll an! "),
                    percentFocusString
                )
            } else {
                title = String(localized: "weekly_report.feedback.title.neutral", defaultValue: "Konstante Woche")
                desc += String(localized: "weekly_report.feedback.desc.neutral_base", defaultValue: "Du warst diese Woche sehr konstant und hast deine Zeiten solide gehalten. Konstanz ist der Schlüssel zum langfristigen Erfolg! ")
            }
            
            if bestDayName != "—" {
                desc += "\n\n"
                desc += String(
                    format: String(localized: "weekly_report.feedback.desc.best_day_focus", defaultValue: "Dein produktivster Tag für Fokus war %@. Statistisch gesehen warst du an diesem Wochentag besonders leistungsfähig."),
                    bestDayName
                )
            }
            
            if bestHabitsDayName != "—" && bestHabitsDayName != bestDayName {
                desc += " "
                desc += String(
                    format: String(localized: "weekly_report.feedback.desc.best_day_habits", defaultValue: "Am %@ hast du außerdem die meisten Gewohnheiten abgehakt. Tolle Leistung!"),
                    bestHabitsDayName
                )
            }
            
            // Actionable Insights based on Time of Day (Confidence Score)
            let actionableTip: String
            
            if currentFocusMinutes >= 100 {
                var morningMins = 0
                var afternoonMins = 0
                var eveningMins = 0
                
                for session in currentSessions {
                    let hour = calendar.component(.hour, from: session.date)
                    if hour >= 5 && hour < 12 { morningMins += session.durationMinutes }
                    else if hour >= 12 && hour < 18 { afternoonMins += session.durationMinutes }
                    else { eveningMins += session.durationMinutes }
                }
                
                let totalMins = max(1, currentFocusMinutes)
                let morningPct = Double(morningMins) / Double(totalMins)
                let afternoonPct = Double(afternoonMins) / Double(totalMins)
                let eveningPct = Double(eveningMins) / Double(totalMins)
                
                if morningPct > 0.5 {
                    actionableTip = String(format: String(localized: "weekly_report.tip.actionable_morning", defaultValue: "Tipp: Du hast %@ deiner Fokuszeit am Vormittag verbracht. Versuche, deine wichtigsten Blöcke weiterhin vor 12 Uhr zu planen, um diesen Flow zu nutzen."), ">50%")
                } else if afternoonPct > 0.5 {
                    actionableTip = String(format: String(localized: "weekly_report.tip.actionable_afternoon", defaultValue: "Tipp: Du hast %@ deiner Fokuszeit am Nachmittag verbracht. Nutze dieses Zeitfenster auch nächste Woche für fokussiertes Arbeiten."), ">50%")
                } else if eveningPct > 0.5 {
                    actionableTip = String(format: String(localized: "weekly_report.tip.actionable_evening", defaultValue: "Tipp: Du hast %@ deiner Fokuszeit am Abend verbracht. Wenn das für dich funktioniert, plane deine Deep-Work-Sessions ab 18 Uhr."), ">50%")
                } else {
                    let tips = [
                        String(localized: "weekly_report.tip.1", defaultValue: "Tipp: Plane kleine, feste Fokus-Blöcke (z.B. 25 Minuten) ein, anstatt zu versuchen, stundenlang durchzuarbeiten."),
                        String(localized: "weekly_report.tip.2", defaultValue: "Tipp: Versuche, das Handy während deiner Sessions außer Sichtweite zu legen – das reduziert Ablenkungen enorm."),
                        String(localized: "weekly_report.tip.3", defaultValue: "Tipp: Erledige deine wichtigsten Gewohnheiten direkt morgens. So startest du bereits mit einem kleinen Sieg in den Tag!"),
                        String(localized: "weekly_report.tip.4", defaultValue: "Tipp: Weniger ist manchmal mehr. Konzentriere dich nächste Woche auf 2-3 Kern-Gewohnheiten, um sie wirklich zu festigen.")
                    ]
                    actionableTip = tips.randomElement() ?? tips[0]
                }
            } else {
                actionableTip = String(localized: "weekly_report.tip.low_confidence", defaultValue: "Tipp: Zu wenig Daten für eine detaillierte Tageszeit-Analyse. Sammle mehr Fokus-Sessions (mind. 100 Min), um präzise Tipps zu erhalten.")
            }
            
            desc += "\n\n" + actionableTip
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
