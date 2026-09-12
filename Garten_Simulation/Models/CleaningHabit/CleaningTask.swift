import Foundation

struct CleaningTask: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var nameKey: String
    var iconName: String
    var frequencyDays: Int
    var createdAt: Date = Date()
    var isActive: Bool = true
    var scheduledWeekday: Int? = nil // 1 = Sunday, 2 = Monday, etc.
    var colorHex: String = "gruenPrimary" // Named color key from AppColors
    var progress: Double? = 0.0
    
    // Berechnet die Fälligkeit in Kombination mit den Logs
    func dueDate(lastCompleted: Date?) -> Date {
        let calendar = Calendar.current
        guard let last = lastCompleted else {
            let start = calendar.startOfDay(for: Date())
            if let weekday = scheduledWeekday {
                return Self.next(weekday: weekday, after: start, includeToday: true)
            }
            return start // Sofort fällig
        }
        
        let baseDate = calendar.startOfDay(for: calendar.date(byAdding: .day, value: frequencyDays, to: last) ?? Date())
        
        if let weekday = scheduledWeekday {
            return Self.next(weekday: weekday, after: baseDate, includeToday: true)
        }
        
        return baseDate
    }
    
    private static func next(weekday: Int, after date: Date, includeToday: Bool) -> Date {
        let calendar = Calendar.current
        let currentWeekday = calendar.component(.weekday, from: date)
        if includeToday && currentWeekday == weekday {
            return calendar.startOfDay(for: date)
        }
        var daysToAdding = weekday - currentWeekday
        if daysToAdding <= 0 {
            daysToAdding += 7
        }
        let nextDate = calendar.date(byAdding: .day, value: daysToAdding, to: date) ?? date
        return calendar.startOfDay(for: nextDate)
    }
    
    func isOverdue(lastCompleted: Date?) -> Bool {
        let due = dueDate(lastCompleted: lastCompleted)
        return Calendar.current.startOfDay(for: Date()) > due
    }
}
