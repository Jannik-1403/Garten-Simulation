import re

content = open("Garten_Simulation/Stores/StreakStore.swift").read()

# Replace checkForMissedDays function
old_func = """    func checkForMissedDays() {
        let today = calendar.startOfDay(for: Date())
        
        // Find the maximum completed/frozen date in terms of CURRENT calendar days.
        // We start from yesterday and go backwards until we find a completed/frozen day.
        var checkDate = calendar.date(byAdding: .day, value: -1, to: today)!
        var missingDays: [Date] = []
        
        // We go back up to 14 days to prevent infinite loops, finding any missing days.
        for _ in 0..<14 {
            if isDateCompleted(checkDate) || isDateFrozen(checkDate) {
                break
            }
            missingDays.append(checkDate)
            checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
        }
        
        // Apply freezes from oldest missing day to newest
        var usedFreeze = false
        for missing in missingDays.reversed() {
            if streakFreezes > 0 {
                withAnimation(.spring()) {
                    streakFreezes -= 1
                    frozenDates.insert(missing)
                    usedFreeze = true
                }
            } else {
                break
            }
        }
        
        if usedFreeze {
            showingFreezeUsed = true
            calculateStreak(shouldAnimate: false)
        }
    }"""

new_func = """    func checkForMissedDays() {
        let today = calendar.startOfDay(for: Date())
        
        var checkDate = calendar.date(byAdding: .day, value: -1, to: today)!
        var missingDays: [Date] = []
        var foundAnchor = false
        
        // We go back up to 14 days to prevent infinite loops, finding any missing days.
        for _ in 0..<14 {
            if isDateCompleted(checkDate) || isDateFrozen(checkDate) {
                foundAnchor = true
                break
            }
            missingDays.append(checkDate)
            checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
        }
        
        // Nur Freezes anwenden, wenn wir dadurch den Streak auch wirklich retten können!
        // (Also wenn wir einen Anker gefunden haben UND genug Freezes für die Lücke haben)
        if foundAnchor && !missingDays.isEmpty && streakFreezes >= missingDays.count {
            var usedFreeze = false
            for missing in missingDays.reversed() {
                withAnimation(.spring()) {
                    streakFreezes -= 1
                    frozenDates.insert(missing)
                    usedFreeze = true
                }
            }
            
            if usedFreeze {
                showingFreezeUsed = true
                calculateStreak(shouldAnimate: false)
            }
        } else if !missingDays.isEmpty && (!foundAnchor || streakFreezes < missingDays.count) {
            // Streak is broken. We do NOT consume freezes here.
            // calculateStreak() will automatically set currentStreak to 0 when it runs.
        }
    }"""

if old_func in content:
    content = content.replace(old_func, new_func)
    open("Garten_Simulation/Stores/StreakStore.swift", "w").write(content)
    print("Success")
else:
    print("Not found")
