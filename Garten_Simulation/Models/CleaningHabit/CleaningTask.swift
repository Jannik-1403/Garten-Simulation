import Foundation

/// Wiederholungsrhythmus einer Aufräum-Aufgabe.
/// Wochentage im App-Format: 1 = Mo … 7 = So (siehe `HabitModel.weekdayIndex`).
enum CleaningRecurrence: Codable, Hashable {
    /// Alle `n` Tage ab dem Startdatum (1 = täglich, 2 = jeden zweiten Tag …).
    case everyNDays(Int)
    /// An den gewählten Wochentagen, jede `n`-te Woche ab der Startwoche (2 = alle 14 Tage).
    case weekly(weekdays: Set<Int>, everyNWeeks: Int)
}

struct CleaningTask: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var name: String
    var iconName: String
    var colorKey: String
    var recurrence: CleaningRecurrence
    /// Anker für den Rhythmus (erste Fälligkeit bzw. Startwoche).
    var startDate: Date
    var createdAt: Date = Date()

    // MARK: - Fälligkeit

    /// Ist die Aufgabe am übergebenen Tag fällig? Reine Funktion – hängt nur vom Plan ab,
    /// nicht von Erledigungen. Dadurch sind auch vergangene Tage stabil auswertbar.
    func isDue(on date: Date, calendar: Calendar = .current) -> Bool {
        let day = calendar.startOfDay(for: date)
        let start = calendar.startOfDay(for: startDate)
        guard day >= start else { return false }

        switch recurrence {
        case .everyNDays(let n):
            let interval = max(1, n)
            let diff = calendar.dateComponents([.day], from: start, to: day).day ?? 0
            return diff % interval == 0

        case .weekly(let weekdays, let everyNWeeks):
            guard weekdays.contains(HabitModel.weekdayIndex(for: day, calendar: calendar)) else { return false }
            let interval = max(1, everyNWeeks)
            guard interval > 1 else { return true }
            let startMonday = Self.monday(of: start, calendar: calendar)
            let dayMonday = Self.monday(of: day, calendar: calendar)
            let days = calendar.dateComponents([.day], from: startMonday, to: dayMonday).day ?? 0
            return (days / 7) % interval == 0
        }
    }

    /// Nächster Fälligkeitstag ab (inklusive) `date`. Sucht maximal ein Jahr voraus.
    func nextDueDate(from date: Date = Date(), calendar: Calendar = .current) -> Date? {
        let start = calendar.startOfDay(for: max(date, startDate))
        for offset in 0..<366 {
            guard let day = calendar.date(byAdding: .day, value: offset, to: start) else { return nil }
            if isDue(on: day, calendar: calendar) { return day }
        }
        return nil
    }

    private static func monday(of date: Date, calendar: Calendar) -> Date {
        let offset = HabitModel.weekdayIndex(for: date, calendar: calendar) - 1
        return calendar.date(byAdding: .day, value: -offset, to: calendar.startOfDay(for: date)) ?? date
    }
}

// MARK: - Legacy (v1) Migration

/// Format der ersten Version (bis Okt. 2026). Nur zum Einlesen alter Daten.
struct LegacyCleaningTaskV1: Decodable {
    var id: UUID
    var nameKey: String
    var iconName: String
    var frequencyDays: Int
    var createdAt: Date
    var isActive: Bool?
    var scheduledWeekday: Int? // Apple-Format: 1 = So … 7 = Sa
    var colorHex: String?

    func migrated() -> CleaningTask {
        let recurrence: CleaningRecurrence
        if let appleWeekday = scheduledWeekday {
            let appWeekday = appleWeekday == 1 ? 7 : appleWeekday - 1
            let weeks = max(1, Int((Double(frequencyDays) / 7.0).rounded()))
            recurrence = .weekly(weekdays: [appWeekday], everyNWeeks: weeks)
        } else {
            recurrence = .everyNDays(max(1, frequencyDays))
        }
        return CleaningTask(
            id: id,
            name: nameKey,
            iconName: iconName,
            colorKey: colorHex ?? "gruenPrimary",
            recurrence: recurrence,
            startDate: createdAt,
            createdAt: createdAt
        )
    }
}
