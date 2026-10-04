import SwiftUI
import Combine

/// Logik für das Aufräum-Dashboard (Statistik, Heute, Demnächst, Abhaken).
@MainActor
final class CleaningDashboardViewModel: ObservableObject {

    struct Stats: Equatable {
        var doneToday: Int
        var dueToday: Int
        /// Anteil erledigter Fälligkeiten der letzten 7 Tage (0…1), `nil` wenn nichts fällig war.
        var weekRate: Double?
        /// Aufeinanderfolgende Aufräum-Tage mit allen Aufgaben erledigt.
        var cleanStreak: Int
        var totalCompletions: Int
    }

    struct UpcomingItem: Identifiable {
        var id: UUID { task.id }
        let task: CleaningTask
        let nextDate: Date?
    }

    let manager: CleaningManager
    private var cancellable: AnyCancellable?

    init(manager: CleaningManager = .shared) {
        self.manager = manager
        cancellable = manager.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }
    }

    // MARK: - Abschnitte

    var hasTasks: Bool { manager.hasTasks }

    var todayTasks: [CleaningTask] {
        let today = Date()
        return manager.tasksDue(on: today).sorted {
            let lhsDone = manager.isCompleted($0, on: today)
            let rhsDone = manager.isCompleted($1, on: today)
            if lhsDone != rhsDone { return !lhsDone }
            return $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
        }
    }

    var upcomingItems: [UpcomingItem] {
        let calendar = Calendar.current
        guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: Date())) else { return [] }
        let todayIDs = Set(manager.tasksDue(on: Date()).map(\.id))
        return manager.tasks
            .filter { !todayIDs.contains($0.id) }
            .map { UpcomingItem(task: $0, nextDate: $0.nextDueDate(from: tomorrow)) }
            .sorted { ($0.nextDate ?? .distantFuture) < ($1.nextDate ?? .distantFuture) }
    }

    func isCompletedToday(_ task: CleaningTask) -> Bool {
        manager.isCompleted(task, on: Date())
    }

    // MARK: - Statistik

    var stats: Stats {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let dueToday = manager.tasksDue(on: today)
        let doneToday = dueToday.filter { manager.isCompleted($0, on: today) }.count

        // 7-Tage-Quote
        var dueCount = 0
        var doneCount = 0
        for offset in 0..<7 {
            guard let day = calendar.date(byAdding: .day, value: -offset, to: today) else { continue }
            let due = manager.tasksDue(on: day)
            dueCount += due.count
            doneCount += due.filter { manager.isCompleted($0, on: day) }.count
        }

        // Streak: Tage ohne Aufgaben überspringen, heute zählt nur, wenn bereits komplett.
        var streak = 0
        for offset in 0..<366 {
            guard let day = calendar.date(byAdding: .day, value: -offset, to: today) else { break }
            let due = manager.tasksDue(on: day)
            if due.isEmpty { continue }
            let allDone = due.allSatisfy { manager.isCompleted($0, on: day) }
            if allDone {
                streak += 1
            } else if offset == 0 {
                continue // heute noch offen → bricht den Streak nicht
            } else {
                break
            }
        }

        return Stats(
            doneToday: doneToday,
            dueToday: dueToday.count,
            weekRate: dueCount > 0 ? Double(doneCount) / Double(dueCount) : nil,
            cleanStreak: streak,
            totalCompletions: manager.logs.count
        )
    }

    // MARK: - Aktionen

    /// Hakt eine Aufgabe ab/auf. Sind danach alle heutigen Aufgaben erledigt,
    /// wird die Gewohnheit automatisch abgeschlossen (XP, Coins, Streak).
    func toggle(_ task: CleaningTask, pflanze: HabitModel, gardenStore: GardenStore) {
        let isNowDone = manager.toggleCompletion(task)
        UIImpactFeedbackGenerator(style: isNowDone ? .medium : .light).impactOccurred()

        if isNowDone, manager.allDueTasksCompleted(on: Date()), !pflanze.wasCompleted(on: Date()) {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            gardenStore.completeHabit(pflanze: pflanze)
        } else {
            if !isNowDone, pflanze.wasCompleted(on: Date()) {
                gardenStore.undoCompleteHabit(pflanze: pflanze)
            } else {
                gardenStore.updateWidgetData()
            }
        }
    }

    func save(_ task: CleaningTask, isNew: Bool, gardenStore: GardenStore) {
        if isNew { manager.add(task) } else { manager.update(task) }
        refreshGarden(gardenStore)
    }

    func delete(_ task: CleaningTask, gardenStore: GardenStore) {
        manager.delete(task)
        refreshGarden(gardenStore)
    }

    /// Fälligkeit der Pflanze hat sich evtl. geändert → Garten-Listen + Widget aktualisieren.
    private func refreshGarden(_ gardenStore: GardenStore) {
        gardenStore.objectWillChange.send()
        gardenStore.updateWidgetData()
    }
}

// MARK: - Anzeige-Texte

extension CleaningRecurrence {
    /// Lokalisierte Kurzbeschreibung, z. B. „Täglich“, „Alle 2 Tage“, „Alle 2 Wochen: Sa“.
    var localizedDescription: String {
        switch self {
        case .everyNDays(let n):
            if n <= 1 { return String(localized: "cleaning.recurrence.daily", defaultValue: "Täglich") }
            return String(format: String(localized: "cleaning.recurrence.everyNDays", defaultValue: "Alle %@ Tage"), "\(n)")
        case .weekly(let weekdays, let everyNWeeks):
            let days = Self.weekdayList(weekdays)
            if everyNWeeks <= 1 {
                return String(format: String(localized: "cleaning.recurrence.weekly", defaultValue: "Jede Woche: %@"), days)
            }
            return String(format: String(localized: "cleaning.recurrence.everyNWeeks", defaultValue: "Alle %1$@ Wochen: %2$@"), "\(everyNWeeks)", days)
        }
    }

    /// Kurze, lokalisierte Wochentagsnamen in Reihenfolge Mo…So.
    static func weekdayList(_ weekdays: Set<Int>) -> String {
        weekdays.sorted().map(shortWeekdaySymbol).joined(separator: ", ")
    }

    /// App-Wochentag (1=Mo … 7=So) → lokalisiertes Kürzel.
    static func shortWeekdaySymbol(_ appWeekday: Int) -> String {
        let symbols = Calendar.current.shortWeekdaySymbols // [So, Mo, …, Sa]
        return symbols[appWeekday % 7]
    }
}
