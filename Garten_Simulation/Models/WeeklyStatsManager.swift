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
        
        // 5. Generate Dynamic Tips
        let title = String(localized: "smart.weekly.title.tip", defaultValue: "Tipp")
        var tips: [String] = []
        
        // Current Focus / Habits logic
        let hasEnoughData = currentFocusMinutes >= 30 || currentHabitsCount >= 3
        
        // Rule A: Zero Focus Time
        if currentFocusMinutes == 0 {
            tips.append(String(localized: "smart.weekly.tip.no_focus", defaultValue: "Du hast diese Woche keine Fokus-Sessions genutzt. Baue feste Fokus-Zeiten in deinen Alltag ein. Reserviere dir jeden Tag zur selben Uhrzeit (z.B. direkt nach dem Frühstück) 25 Minuten, um eine Routine zu entwickeln."))
        } else {
            // Check for weekend drop-off or specific day drops
            let weekendMinutes = dailyFocus.filter { $0.dayName == "Sa" || $0.dayName == "So" }.reduce(0) { $0 + $1.minutes }
            let weekdayMinutes = dailyFocus.filter { $0.dayName != "Sa" && $0.dayName != "So" }.reduce(0) { $0 + $1.minutes }
            
            if weekendMinutes == 0 && weekdayMinutes > 0 {
                tips.append(String(localized: "smart.weekly.tip.weekend_drop", defaultValue: "Am Wochenende bricht deine Fokuszeit komplett ein. Versuche, auch an diesen Tagen zumindest eine kleine 15-Minuten-Session einzulegen, um den Rhythmus nicht zu verlieren."))
            }
        }
        
        // Rule C: Consistency Check (Gaps)
        let activeDaysCount = dailyHabits.filter { $0.count > 0 }.count
        if activeDaysCount >= 5 && activeDaysCount < 7 {
            let zeroDays = dailyHabits.filter { $0.count == 0 }.map { $0.dayName }
            if !zeroDays.isEmpty {
                let joinedDays = zeroDays.joined(separator: " und ")
                tips.append(String(format: String(localized: "smart.weekly.tip.gaps", defaultValue: "Du hast am %@ pausiert, bist aber sonst konstant. Um solche Aussetzer zu vermeiden, koppele deine Gewohnheiten an feste Anker in deinem Alltag (z.B. immer direkt nach dem Zähneputzen)."), joinedDays))
            }
        }
        
        // Rule D: Habit Specifics (Früh aufstehen)
        for plant in gardenStore.pflanzen {
            let name = plant.name.lowercased()
            if name.contains("früh") || name.contains("aufstehen") || name.contains("aufwachen") {
                var totalHour = 0
                var count = 0
                for date in plant.wateringDates where date >= monday && date <= sundayEnd {
                    let hour = calendar.component(.hour, from: date)
                    totalHour += hour
                    count += 1
                }
                if count > 0 {
                    let avgHour = totalHour / count
                    if avgHour >= 8 {
                        tips.append(String(format: String(localized: "smart.weekly.tip.early_bird", defaultValue: "Du hakst '%@' oft erst spät ab (gegen %d Uhr). Wenn du wirklich früh aufstehen willst, lege dein Handy abends in einen anderen Raum und stelle den Wecker 30 Minuten früher."), plant.name, avgHour))
                    }
                }
            }
        }
        
        // Rule E: General late habits
        if tips.count < 3 && currentHabitsCount > 0 {
            var lateHabitsCount = 0
            for plant in gardenStore.pflanzen {
                for date in plant.wateringDates where date >= monday && date <= sundayEnd {
                    let hour = calendar.component(.hour, from: date)
                    if hour >= 21 {
                        lateHabitsCount += 1
                    }
                }
            }
            if Double(lateHabitsCount) / Double(currentHabitsCount) > 0.6 {
                tips.append(String(localized: "smart.weekly.tip.late_habits", defaultValue: "Du erledigst viele Gewohnheiten erst spät am Abend. Versuche, deine wichtigste Gewohnheit direkt morgens als Erstes abzuhaken (Eat the Frog) – dann hast du den Rest des Tages den Kopf frei."))
            }
        }
        
        // Fallback tip if we have too few
        if tips.isEmpty {
            if !hasEnoughData {
                tips.append(String(localized: "smart.weekly.tip.fallback_low", defaultValue: "Sammle nächste Woche mehr Fokus-Sessions und hake Gewohnheiten ab, um präzise Tipps zu deinem Rhythmus zu erhalten."))
            } else {
                tips.append(String(localized: "smart.weekly.tip.fallback_good", defaultValue: "Deine Routine ist sehr stabil! Halte diese Konsistenz aufrecht, indem du deine Gewohnheiten weiterhin an feste Zeiten koppelst."))
            }
        }
        
        let desc = tips.prefix(3).map { "• \($0)" }.joined(separator: "\n\n")

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
