import SwiftUI
import Combine

@MainActor
class StreakStore: ObservableObject {
    @Published var currentStreak: Int = 0
    @Published var completedDates: Set<Date> = []
    @Published var streakGoal: Int = 100
    @Published var streakProtectionActive: Bool = false
    
    init() {
        // Started fresh with no mock data
        calculateStreak()
    }
    
    func completeDay(date: Date = Date()) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        
        if !completedDates.contains(startOfDay) {
            withAnimation(.spring()) {
                completedDates.insert(startOfDay)
                calculateStreak()
            }
        }
    }
    
    func calculateStreak() {
        let calendar = Calendar.current
        var streak = 0
        var checkDate = calendar.startOfDay(for: Date())
        
        // Count backwards from today
        while completedDates.contains(checkDate) {
            streak += 1
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
            checkDate = yesterday
        }
        
        // If today is not completed, check if yesterday was part of a streak
        if streak == 0 {
            if let yesterday = calendar.date(byAdding: .day, value: -1, to: checkDate) {
                checkDate = yesterday
                while completedDates.contains(checkDate) {
                    streak += 1
                    guard let prev = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
                    checkDate = prev
                }
            }
        }
        
        currentStreak = streak
    }
    
    func isDateCompleted(_ date: Date) -> Bool {
        completedDates.contains(Calendar.current.startOfDay(for: date))
    }
    
    /// Logic to determine if two dates should be connected by a streak path
    func hasConnection(from date: Date, to otherDate: Date) -> Bool {
        let calendar = Calendar.current
        let d1 = calendar.startOfDay(for: date)
        let d2 = calendar.startOfDay(for: otherDate)
        
        // They must be exactly 1 day apart and both completed
        guard let diff = calendar.dateComponents([.day], from: d1, to: d2).day, abs(diff) == 1 else {
            return false
        }
        
        return isDateCompleted(d1) && isDateCompleted(d2)
    }
}
