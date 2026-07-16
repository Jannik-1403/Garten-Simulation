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
    @Published var streakFreezes: Int = 0 {
        didSet { save() }
    }
    @Published var frozenDates: Set<Date> = [] {
        didSet { save() }
    }
    
    // Flag for UI animation
    @Published var showingStreakIncrease: Bool = false
    @Published var lastShownStreak: Int = 0 {
        didSet { save() }
    }
    @Published var showingFreezeUsed: Bool = false
    
    private let calendar = Calendar.current
    
    init() {
        load()
        checkForMissedDays()
        calculateStreak(shouldAnimate: false)
    }
    
    func checkForMissedDays() {
        let allValidDates = completedDates.union(frozenDates)
        guard let lastValidDate = allValidDates.max() else { return }
        
        let now = Date()
        let hoursSince = now.timeIntervalSince(lastValidDate) / 3600
        
        // Timezone grace period: if less than 48 hours passed, no days were missed
        if hoursSince <= 48 {
            return
        }
        
        let daysMissed = Int((hoursSince - 24) / 24)
        
        if daysMissed > 0 {
            var usedFreeze = false
            var freezeDate = lastValidDate
            
            for _ in 0..<daysMissed {
                if streakFreezes > 0 {
                    streakFreezes -= 1
                    freezeDate = freezeDate.addingTimeInterval(24 * 3600)
                    frozenDates.insert(freezeDate)
                    usedFreeze = true
                } else {
                    break
                }
            }
            
            if usedFreeze {
                showingFreezeUsed = true
                calculateStreak(shouldAnimate: false)
            }
        }
    }
    
    func completeDay(date: Date = Date()) {
        let startOfDay = calendar.startOfDay(for: date)
        
        if !completedDates.contains(startOfDay) {
            withAnimation(.spring()) {
                completedDates.insert(startOfDay)
                calculateStreak(shouldAnimate: true)
            }
        }
    }
    
    func calculateStreak(shouldAnimate: Bool = false) {
        let allDates = Array(completedDates.union(frozenDates)).sorted(by: >)
        guard let mostRecent = allDates.first else {
            currentStreak = 0
            return
        }
        
        let now = Date()
        var isAlive = false
        
        if calendar.isDateInToday(mostRecent) || calendar.isDateInYesterday(mostRecent) {
            isAlive = true
        } else {
            // Timezone fallback: if the most recent completion is within 48 hours
            let hoursSince = now.timeIntervalSince(mostRecent) / 3600
            if hoursSince <= 48 {
                isAlive = true
            }
        }
        
        if !isAlive {
            currentStreak = 0
            lastShownStreak = 0
            return
        }
        
        var streak = 1
        var previous = mostRecent
        
        for date in allDates.dropFirst() {
            let diff = previous.timeIntervalSince(date) / 3600
            if diff < 12 {
                // Too close, likely a timezone shift artifact of the same day
                continue
            } else if diff <= 48 {
                streak += 1
                previous = date
            } else {
                // Gap too large
                break
            }
        }
        
        currentStreak = streak
        
        // Trigger animation if streak increased beyond what was last shown
        if currentStreak > lastShownStreak && currentStreak > 0 && shouldAnimate {
            showingStreakIncrease = true
            lastShownStreak = currentStreak
        } else if currentStreak > lastShownStreak {
            // Keep numerical state in sync even if we don't animate
            lastShownStreak = currentStreak
        } else if currentStreak < lastShownStreak {
            // Reset lastShownStreak if streak decreased so it can trigger again when it goes back up
            lastShownStreak = currentStreak
        }
        
        // Update best streak
        if currentStreak > bestStreak {
            bestStreak = currentStreak
        }
    }
    
    func isDateCompleted(_ date: Date) -> Bool {
        let startOfDay = calendar.startOfDay(for: date)
        if completedDates.contains(startOfDay) { return true }
        
        for completed in completedDates {
            if abs(completed.timeIntervalSince(startOfDay)) <= 14 * 3600 {
                return true
            }
        }
        return false
    }
    
    func isDateFrozen(_ date: Date) -> Bool {
        let startOfDay = calendar.startOfDay(for: date)
        if frozenDates.contains(startOfDay) { return true }
        
        for frozen in frozenDates {
            if abs(frozen.timeIntervalSince(startOfDay)) <= 14 * 3600 {
                return true
            }
        }
        return false
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
        let completedTimestamps = completedDates.map { $0.timeIntervalSince1970 }
        let frozenTimestamps = frozenDates.map { $0.timeIntervalSince1970 }
        
        SharedUserDefaults.suite.set(completedTimestamps, forKey: "streak_completed_dates")
        SharedUserDefaults.suite.set(frozenTimestamps, forKey: "streak_frozen_dates")
        SharedUserDefaults.suite.set(streakFreezes, forKey: "streak_freezes_count")
        SharedUserDefaults.suite.set(bestStreak, forKey: "streak_best_streak")
        SharedUserDefaults.suite.set(lastShownStreak, forKey: "streak_last_shown")
        SharedUserDefaults.suite.synchronize()
    }
    
    private func load() {
        if let timestamps = SharedUserDefaults.suite.array(forKey: "streak_completed_dates") as? [TimeInterval] {
            completedDates = Set(timestamps.map { Date(timeIntervalSince1970: $0) })
        }
        if let timestamps = SharedUserDefaults.suite.array(forKey: "streak_frozen_dates") as? [TimeInterval] {
            frozenDates = Set(timestamps.map { Date(timeIntervalSince1970: $0) })
        }
        streakFreezes = SharedUserDefaults.suite.integer(forKey: "streak_freezes_count")
        bestStreak = SharedUserDefaults.suite.integer(forKey: "streak_best_streak")
        lastShownStreak = SharedUserDefaults.suite.integer(forKey: "streak_last_shown")
        
        // Migration check for gardenStore.bestStreak (if StreakStore is new)
        if bestStreak == 0 {
            let oldBest = SharedUserDefaults.suite.integer(forKey: "stats_best_streak")
            if oldBest > 0 {
                bestStreak = oldBest
                // Try to migrate current streak too if possible
                let oldCurrent = SharedUserDefaults.suite.integer(forKey: "stats_gesamt_streak")
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
            streakFreezes = 0
            frozenDates.removeAll()
            lastShownStreak = 0
        }
    }
}
