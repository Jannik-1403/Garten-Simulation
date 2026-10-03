import Foundation
import Combine

/// Verwaltet Aufräum-Aufgaben und deren Erledigungen.
/// Bewusst nicht `@MainActor`, da `HabitModel.isScheduled(on:)` (nonisolated) darauf zugreift.
final class CleaningManager: ObservableObject {
    static let shared = CleaningManager()

    @Published private(set) var tasks: [CleaningTask] = []
    @Published private(set) var logs: [CleaningLog] = [] {
        didSet { rebuildCompletionIndex() }
    }

    /// Schneller Lookup: Task-ID → Tage (startOfDay), an denen sie erledigt wurde.
    private var completionIndex: [UUID: Set<Date>] = [:]

    private let defaults: UserDefaults
    private let tasksKey = "cleaning_tasks_v2"
    private let logsKey = "cleaning_logs_v2"
    private let legacyTasksKey = "cleaning_tasks_v1"
    private let legacyLogsKey = "cleaning_logs_v1"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        load()
    }

    // MARK: - Abfragen

    var hasTasks: Bool { !tasks.isEmpty }

    func tasksDue(on date: Date) -> [CleaningTask] {
        tasks.filter { $0.isDue(on: date) }
    }

    func hasTasksDue(on date: Date) -> Bool {
        tasks.contains { $0.isDue(on: date) }
    }

    func isCompleted(_ task: CleaningTask, on date: Date) -> Bool {
        completionIndex[task.id]?.contains(Calendar.current.startOfDay(for: date)) ?? false
    }

    /// Sind alle am Tag fälligen Aufgaben erledigt? `false`, wenn nichts fällig ist.
    func allDueTasksCompleted(on date: Date) -> Bool {
        let due = tasksDue(on: date)
        return !due.isEmpty && due.allSatisfy { isCompleted($0, on: date) }
    }

    func totalCompletions(for task: CleaningTask) -> Int {
        completionIndex[task.id]?.count ?? 0
    }

    // MARK: - Mutationen

    func add(_ task: CleaningTask) {
        tasks.append(task)
        saveTasks()
    }

    func update(_ task: CleaningTask) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[index] = task
        saveTasks()
    }

    func delete(_ task: CleaningTask) {
        tasks.removeAll { $0.id == task.id }
        logs.removeAll { $0.taskId == task.id }
        saveTasks()
        saveLogs()
    }

    /// Schaltet den Erledigt-Status einer Aufgabe für einen Tag um.
    /// - Returns: neuer Status (`true` = erledigt).
    @discardableResult
    func toggleCompletion(_ task: CleaningTask, on date: Date = Date()) -> Bool {
        let calendar = Calendar.current
        if isCompleted(task, on: date) {
            logs.removeAll { $0.taskId == task.id && calendar.isDate($0.timestamp, inSameDayAs: date) }
            saveLogs()
            return false
        }
        logs.append(CleaningLog(taskId: task.id, timestamp: date))
        saveLogs()
        return true
    }

    // MARK: - Persistenz

    private func rebuildCompletionIndex() {
        let calendar = Calendar.current
        var index: [UUID: Set<Date>] = [:]
        for log in logs {
            index[log.taskId, default: []].insert(calendar.startOfDay(for: log.timestamp))
        }
        completionIndex = index
    }

    private func saveTasks() {
        if let data = try? JSONEncoder().encode(tasks) {
            defaults.set(data, forKey: tasksKey)
        }
    }

    private func saveLogs() {
        if let data = try? JSONEncoder().encode(logs) {
            defaults.set(data, forKey: logsKey)
        }
    }

    private func load() {
        let decoder = JSONDecoder()

        if let data = defaults.data(forKey: tasksKey),
           let decoded = try? decoder.decode([CleaningTask].self, from: data) {
            tasks = decoded
        } else if let data = defaults.data(forKey: legacyTasksKey),
                  let legacy = try? decoder.decode([LegacyCleaningTaskV1].self, from: data) {
            // Einmalige Migration der alten Aufgaben (v1 → v2)
            tasks = legacy.filter { $0.isActive ?? true }.map { $0.migrated() }
            saveTasks()
        }

        if let data = defaults.data(forKey: logsKey),
           let decoded = try? decoder.decode([CleaningLog].self, from: data) {
            logs = decoded
        } else if let data = defaults.data(forKey: legacyLogsKey),
                  let legacy = try? decoder.decode([CleaningLog].self, from: data) {
            logs = legacy
            saveLogs()
        }
        rebuildCompletionIndex()
    }
}
