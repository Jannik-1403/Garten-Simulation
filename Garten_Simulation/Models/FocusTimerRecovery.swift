import SwiftUI

class FocusTimerRecovery {
    static let shared = FocusTimerRecovery()
    
    var isActive: Bool {
        get { UserDefaults.standard.bool(forKey: "focusTimerIsActive") }
        set { UserDefaults.standard.set(newValue, forKey: "focusTimerIsActive") }
    }
    var endTime: Double {
        get { UserDefaults.standard.double(forKey: "focusTimerEndTime") }
        set { UserDefaults.standard.set(newValue, forKey: "focusTimerEndTime") }
    }
    var totalSeconds: Int {
        get { UserDefaults.standard.integer(forKey: "focusTimerTotalSeconds") }
        set { UserDefaults.standard.set(newValue, forKey: "focusTimerTotalSeconds") }
    }
    var plantId: String {
        get { UserDefaults.standard.string(forKey: "focusTimerPlantId") ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: "focusTimerPlantId") }
    }
    var goalsData: Data {
        get { UserDefaults.standard.data(forKey: "focusTimerGoalsData") ?? Data() }
        set { UserDefaults.standard.set(newValue, forKey: "focusTimerGoalsData") }
    }
    
    // Support for generic focus timers
    var isGeneric: Bool {
        get { UserDefaults.standard.bool(forKey: "focusTimerIsGeneric") }
        set { UserDefaults.standard.set(newValue, forKey: "focusTimerIsGeneric") }
    }
    var genericHabitData: Data {
        get { UserDefaults.standard.data(forKey: "focusTimerGenericHabitData") ?? Data() }
        set { UserDefaults.standard.set(newValue, forKey: "focusTimerGenericHabitData") }
    }
    
    func saveState(endTime: Date, totalSeconds: Int, plantId: String, goals: [FocusGoal], genericHabit: HabitModel? = nil) {
        self.endTime = endTime.timeIntervalSince1970
        self.totalSeconds = totalSeconds
        self.plantId = plantId
        if let data = try? JSONEncoder().encode(goals) {
            self.goalsData = data
        }
        
        if let genericHabit = genericHabit {
            self.isGeneric = true
            if let data = try? JSONEncoder().encode(genericHabit) {
                self.genericHabitData = data
            }
        } else {
            self.isGeneric = false
            self.genericHabitData = Data()
        }
        
        self.isActive = true
    }
    
    func clearState() {
        self.isActive = false
        self.endTime = 0
        self.totalSeconds = 0
        self.plantId = ""
        self.goalsData = Data()
        self.isGeneric = false
        self.genericHabitData = Data()
    }
    
    func getGoals() -> [FocusGoal] {
        if let goals = try? JSONDecoder().decode([FocusGoal].self, from: goalsData) {
            return goals
        }
        return []
    }
    
    func getGenericHabit() -> HabitModel? {
        guard isGeneric else { return nil }
        return try? JSONDecoder().decode(HabitModel.self, from: genericHabitData)
    }
}
