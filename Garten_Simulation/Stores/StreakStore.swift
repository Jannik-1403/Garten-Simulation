import SwiftUI
import Combine

@MainActor
class StreakStore: ObservableObject {
    @Published var currentStreak: Int = 0
    @Published var completedDates: Set<Date> = [] {
        didSet { save() }
    }
    @Published var bestStreak: Int = 0 {
        didSet { save() }
    }
    @Published var streakGoal: Int = 100
    @Published var streakProtectionActive: Bool = false
    
    // Flag for UI animation
    @Published var showingStreakIncrease: Bool = false
    
    private let calendar = Calendar.current
    
    init() {
        load()
        calculateStreak()
    }
    
    func completeDay(date: Date = Date()) {
        let startOfDay = calendar.startOfDay(for: date)
        
        if !completedDates.contains(startOfDay) {
            withAnimation(.spring()) {
                completedDates.insert(startOfDay)
                calculateStreak()
            }
        }
    }
    
    func calculateStreak() {
        let oldStreak = currentStreak
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
            if let yesterday = calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: Date())) {
                checkDate = yesterday
                while completedDates.contains(checkDate) {
                    streak += 1
                    guard let prev = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
                    checkDate = prev
                }
            }
        }
        
        currentStreak = streak
        
        // Trigger animation if streak increased
        if currentStreak > oldStreak && currentStreak > 0 {
            showingStreakIncrease = true
        }
        
        // Update best streak
        if currentStreak > bestStreak {
            bestStreak = currentStreak
        }
    }
    
    func isDateCompleted(_ date: Date) -> Bool {
        completedDates.contains(calendar.startOfDay(for: date))
    }
    
    func hasConnection(from date: Date, to otherDate: Date) -> Bool {
        let d1 = calendar.startOfDay(for: date)
        let d2 = calendar.startOfDay(for: otherDate)
        
        guard let diff = calendar.dateComponents([.day], from: d1, to: d2).day, abs(diff) == 1 else {
            return false
        }
        
        return isDateCompleted(d1) && isDateCompleted(d2)
    }

    private func save() {
        let timestamps = completedDates.map { $0.timeIntervalSince1970 }
        UserDefaults.standard.set(timestamps, forKey: "streak_completed_dates")
        UserDefaults.standard.set(bestStreak, forKey: "streak_best_streak")
    }
    
    private func load() {
        if let timestamps = UserDefaults.standard.array(forKey: "streak_completed_dates") as? [TimeInterval] {
            completedDates = Set(timestamps.map { Date(timeIntervalSince1970: $0) })
        }
        bestStreak = UserDefaults.standard.integer(forKey: "streak_best_streak")
        
        // Migration check for gardenStore.bestStreak (if StreakStore is new)
        if bestStreak == 0 {
            let oldBest = UserDefaults.standard.integer(forKey: "stats_best_streak")
            if oldBest > 0 {
                bestStreak = oldBest
                // Try to migrate current streak too if possible
                let oldCurrent = UserDefaults.standard.integer(forKey: "stats_gesamt_streak")
                if oldCurrent > 0 {
                    currentStreak = oldCurrent
                    // We can't easily recreate the dates, so we'll just set today as completed to keep some logic working
                    // or leave it as currentStreak but no dates (which calculateStreak will reset to 0 next time)
                    // Better to just keep bestStreak for now.
                }
            }
        }
    }

    func reset() {
        withAnimation {
            completedDates.removeAll()
            currentStreak = 0
            bestStreak = 0
        }
    }
}
