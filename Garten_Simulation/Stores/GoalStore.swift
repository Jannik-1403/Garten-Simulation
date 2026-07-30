import Foundation
import Combine

@MainActor
class GoalStore: ObservableObject {
    static let shared = GoalStore()
    
    @Published var activeGoals: [GoalModel] = []
    @Published var habitLinks: [GoalHabitLink] = []
    @Published var goalLogs: [GoalLog] = []
    
    private let saveKey = "GoalStoreData"
    
    init() {
        loadData()
    }
    
    // MARK: - Goal Management
    
    func addGoal(_ goal: GoalModel) {
        activeGoals.append(goal)
        saveData()
    }
    
    func updateGoal(_ goal: GoalModel) {
        if let idx = activeGoals.firstIndex(where: { $0.id == goal.id }) {
            activeGoals[idx] = goal
            saveData()
        }
    }
    
    func linkHabitToGoal(habitId: String, goalId: UUID, weight: GoalWeight) {
        habitLinks.removeAll { $0.habitId == habitId && $0.goalId == goalId }
        let newLink = GoalHabitLink(goalId: goalId, habitId: habitId, weight: weight)
        habitLinks.append(newLink)
        saveData()
    }
    
    func weightForHabit(habitId: String, goalId: UUID) -> GoalWeight? {
        habitLinks.first { $0.habitId == habitId && $0.goalId == goalId }?.weight
    }
    
    // MARK: - Tracking & Analytics
    
    func progressForWeek(goalId: UUID) -> Double {
        let links = habitLinks.filter { $0.goalId == goalId }
        let maxPointsPerDay = links.reduce(0) { $0 + $1.weight.rawValue }
        let maxPointsThisWeek = maxPointsPerDay * 7
        
        guard maxPointsThisWeek > 0 else { return 0.0 }
        
        let cal = Calendar.current
        let now = Date()
        let earnedThisWeek = goalLogs.filter {
            $0.goalId == goalId &&
            cal.component(.weekOfYear, from: $0.date) == cal.component(.weekOfYear, from: now) &&
            cal.component(.yearForWeekOfYear, from: $0.date) == cal.component(.yearForWeekOfYear, from: now)
        }.reduce(0) { $0 + $1.pointsEarned }
        
        return min(Double(earnedThisWeek) / Double(maxPointsThisWeek), 1.0)
    }
    
    func getPointsForWeek(goalId: UUID) -> (earned: Int, target: Int) {
        let links = habitLinks.filter { $0.goalId == goalId }
        let maxPointsPerDay = links.reduce(0) { $0 + $1.weight.rawValue }
        let maxPointsThisWeek = maxPointsPerDay * 7
        
        let cal = Calendar.current
        let now = Date()
        let earnedThisWeek = goalLogs.filter {
            $0.goalId == goalId &&
            cal.component(.weekOfYear, from: $0.date) == cal.component(.weekOfYear, from: now) &&
            cal.component(.yearForWeekOfYear, from: $0.date) == cal.component(.yearForWeekOfYear, from: now)
        }.reduce(0) { $0 + $1.pointsEarned }
        
        return (earnedThisWeek, maxPointsThisWeek)
    }
    
    func progressForFiveYears(goalId: UUID) -> Double {
        let links = habitLinks.filter { $0.goalId == goalId }
        let maxPointsPerDay = links.reduce(0) { $0 + $1.weight.rawValue }
        let maxPointsFiveYears = maxPointsPerDay * 365 * 5
        
        guard maxPointsFiveYears > 0 else { return 0.0 }
        
        let earnedSoFar = goalLogs.filter { $0.goalId == goalId }.reduce(0) { $0 + $1.pointsEarned }
        
        return min(Double(earnedSoFar) / Double(maxPointsFiveYears), 1.0)
    }
    
    func getPointsForFiveYears(goalId: UUID) -> (earned: Int, target: Int) {
        let links = habitLinks.filter { $0.goalId == goalId }
        let maxPointsPerDay = links.reduce(0) { $0 + $1.weight.rawValue }
        let maxPointsFiveYears = maxPointsPerDay * 365 * 5
        
        let earnedSoFar = goalLogs.filter { $0.goalId == goalId }.reduce(0) { $0 + $1.pointsEarned }
        
        return (earnedSoFar, maxPointsFiveYears)
    }
    
    /// Wird aufgerufen, wenn eine Pflanze gegossen / ein Habit erledigt wird
    func logHabitCompletion(habitId: String) {
        // Find all goals this habit is linked to
        let links = habitLinks.filter { $0.habitId == habitId }
        
        let now = Date()
        for link in links {
            let log = GoalLog(date: now, goalId: link.goalId, habitId: habitId, pointsEarned: link.weight.rawValue)
            goalLogs.append(log)
        }
        if !links.isEmpty {
            saveData()
        }
    }
    
    /// Für die Analytics-Ansicht: Liefert ein Dictionary [HabitID : Punkte], summiert für den aktuellen Monat
    func calculatePointsForCurrentMonth(goalId: UUID) -> [String: Int] {
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: Date())
        let currentYear = calendar.component(.year, from: Date())
        
        let relevantLogs = goalLogs.filter { log in
            log.goalId == goalId &&
            calendar.component(.month, from: log.date) == currentMonth &&
            calendar.component(.year, from: log.date) == currentYear
        }
        
        var pointsPerHabit: [String: Int] = [:]
        for log in relevantLogs {
            pointsPerHabit[log.habitId, default: 0] += log.pointsEarned
        }
        return pointsPerHabit
    }
    
    // MARK: - Persistence
    
    private struct SavedData: Codable {
        let activeGoals: [GoalModel]
        let habitLinks: [GoalHabitLink]
        let goalLogs: [GoalLog]
    }
    
    private func saveData() {
        let data = SavedData(activeGoals: activeGoals, habitLinks: habitLinks, goalLogs: goalLogs)
        if let encoded = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    private func loadData() {
        if let saved = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode(SavedData.self, from: saved) {
            self.activeGoals = decoded.activeGoals
            self.habitLinks = decoded.habitLinks
            self.goalLogs = decoded.goalLogs
        }
    }
}
