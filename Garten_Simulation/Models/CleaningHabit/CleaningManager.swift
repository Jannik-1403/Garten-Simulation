import Foundation
import SwiftUI
import Combine

class CleaningManager: ObservableObject {
    static let shared = CleaningManager()
    
    @Published var tasks: [CleaningTask] = []
    @Published var logs: [CleaningLog] = []
    
    private let tasksKey = "cleaning_tasks_v1"
    private let logsKey = "cleaning_logs_v1"
    
    init() {
        loadData()
    }
    
    func addTask(nameKey: String, iconName: String, frequencyDays: Int, scheduledWeekday: Int?, colorHex: String = "gruenPrimary") {
        let newTask = CleaningTask(nameKey: nameKey, iconName: iconName, frequencyDays: frequencyDays, scheduledWeekday: scheduledWeekday, colorHex: colorHex)
        tasks.append(newTask)
        saveData()
    }
    
    func updateTask(_ task: CleaningTask) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
            saveData()
        }
    }
    
    func deleteTask(_ task: CleaningTask) {
        tasks.removeAll(where: { $0.id == task.id })
        // Optional: Delete associated logs, or keep them for historical data?
        // We keep them so overall stats don't drop, but they won't show in detail view anymore if the task is gone.
        saveData()
    }
    
    func completeTask(_ task: CleaningTask) {
        let newLog = CleaningLog(taskId: task.id, timestamp: Date())
        logs.append(newLog)
        saveData()
        
        // Provide Gamification feedback (XP)
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
        
        // Give 20 XP for completing a cleaning task (assuming StatsHelper handles it)
        // TODO: Implement XP reward system for cleaning tasks
    }
    
    func lastCompletedDate(for taskId: UUID) -> Date? {
        return logs.filter { $0.taskId == taskId }
                   .max(by: { $0.timestamp < $1.timestamp })?
                   .timestamp
    }
    
    func totalCompletions(for taskId: UUID) -> Int {
        return logs.filter { $0.taskId == taskId }.count
    }
    
    // MARK: - Persistence
    
    private func saveData() {
        if let encodedTasks = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(encodedTasks, forKey: tasksKey)
        }
        if let encodedLogs = try? JSONEncoder().encode(logs) {
            UserDefaults.standard.set(encodedLogs, forKey: logsKey)
        }
    }
    
    private func loadData() {
        if let savedTasks = UserDefaults.standard.data(forKey: tasksKey),
           let decodedTasks = try? JSONDecoder().decode([CleaningTask].self, from: savedTasks) {
            self.tasks = decodedTasks
        }
        if let savedLogs = UserDefaults.standard.data(forKey: logsKey),
           let decodedLogs = try? JSONDecoder().decode([CleaningLog].self, from: savedLogs) {
            self.logs = decodedLogs
        }
    }
}
