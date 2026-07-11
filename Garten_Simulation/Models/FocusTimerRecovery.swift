import SwiftUI

class FocusTimerRecovery {
    static let shared = FocusTimerRecovery()
    
    @AppStorage("focusTimerIsActive") var isActive: Bool = false
    @AppStorage("focusTimerEndTime") var endTime: Double = 0
    @AppStorage("focusTimerTotalSeconds") var totalSeconds: Int = 0
    @AppStorage("focusTimerPlantId") var plantId: String = ""
    @AppStorage("focusTimerGoalsData") var goalsData: Data = Data()
    
    func saveState(endTime: Date, totalSeconds: Int, plantId: String, goals: [FocusGoal]) {
        self.endTime = endTime.timeIntervalSince1970
        self.totalSeconds = totalSeconds
        self.plantId = plantId
        if let data = try? JSONEncoder().encode(goals) {
            self.goalsData = data
        }
        self.isActive = true
    }
    
    func clearState() {
        self.isActive = false
        self.endTime = 0
        self.totalSeconds = 0
        self.plantId = ""
        self.goalsData = Data()
    }
    
    func getGoals() -> [FocusGoal] {
        if let goals = try? JSONDecoder().decode([FocusGoal].self, from: goalsData) {
            return goals
        }
        return []
    }
}
