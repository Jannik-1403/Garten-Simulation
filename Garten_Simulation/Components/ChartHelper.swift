import Foundation

struct ChartHelper {
    static func dayStart(for targetDate: Date) -> Date {
        Calendar.current.startOfDay(for: targetDate)
    }
    
    static func dayEnd(for targetDate: Date) -> Date {
        let start = dayStart(for: targetDate)
        return Calendar.current.date(byAdding: .day, value: 1, to: start)!
    }
    
    static func mappedTime(from date: Date, targetDate: Date) -> Date {
        let cal = Calendar.current
        let start = dayStart(for: targetDate)
        let h = cal.component(.hour, from: date)
        let m = cal.component(.minute, from: date)
        let s = cal.component(.second, from: date)
        return cal.date(bySettingHour: h, minute: m, second: s, of: start) ?? date
    }
    
    static func timeLabel(for date: Date) -> String {
        let cal = Calendar.current
        let h = cal.component(.hour, from: date)
        let m = cal.component(.minute, from: date)
        let roundedMinute = (m >= 30) ? 30 : 0
        return String(format: "%02d:%02d", h, roundedMinute)
    }
    
    static func endOfChart(for targetDate: Date) -> Date {
        if Calendar.current.isDateInToday(targetDate) {
            return Date()
        } else {
            return dayEnd(for: targetDate)
        }
    }
    
    static func dateLabel(for targetDate: Date) -> String {
        let cal = Calendar.current
        if cal.isDateInToday(targetDate) {
            return String(localized: "health.chart.label.today", defaultValue: "Heute")
        } else if cal.isDateInYesterday(targetDate) {
            return String(localized: "health.chart.label.yesterday", defaultValue: "Gestern")
        } else {
            return targetDate.formatted(.dateTime.day().month())
        }
    }
}
