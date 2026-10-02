import re

file_path = "Garten_Simulation/Components/PflanzenCard.swift"
with open(file_path, "r") as f:
    content = f.read()

# 1. Update baseProgress
old_base_progress = """    private var baseProgress: Double {
        let hasManualOverride = pflanze.intradayProgressHistory.contains { Calendar.current.isDateInToday($0.timestamp) }
        if let hp = healthProgress, !hasManualOverride {
            return hp
        }
        if pflanze.wasCompleted(on: targetDate) {
            return 1.0
        }
        return pflanze.sliderProgress
    }"""

new_base_progress = """    private var baseProgress: Double {
        if pflanze.wasCompleted(on: targetDate) {
            return 1.0
        }
        if Calendar.current.isDateInToday(targetDate) {
            let hasManualOverride = pflanze.intradayProgressHistory.contains { Calendar.current.isDateInToday($0.timestamp) }
            if let hp = healthProgress, !hasManualOverride {
                return hp
            }
            return pflanze.sliderProgress
        } else {
            return 0.0
        }
    }"""
content = content.replace(old_base_progress, new_base_progress)

# 2. Update DragGesture
content = content.replace("DragGesture(minimumDistance: 25)", "DragGesture(minimumDistance: 5)")

# 3. Update gardenStore.completeHabit calls to include targetDate
content = content.replace("gardenStore.completeHabit(pflanze: pflanze)", "gardenStore.completeHabit(pflanze: pflanze, on: targetDate)")

# 4. In DragGesture onEnded, update sliderProgress only if it's today
drag_ended_old = """                    pflanze.sliderProgress = finalProgress
                    pflanze.intradayProgressHistory.removeAll { Calendar.current.isDateInToday($0.timestamp) }
                    if finalProgress > 0 {
                        pflanze.intradayProgressHistory.append(DailyProgressEntry(timestamp: Date(), progress: finalProgress))
                    }
                    
                    if finalProgress >= 1.0 {
                        gardenStore.completeHabit(pflanze: pflanze, on: targetDate)"""
                        
drag_ended_new = """                    if Calendar.current.isDateInToday(targetDate) {
                        pflanze.sliderProgress = finalProgress
                        pflanze.intradayProgressHistory.removeAll { Calendar.current.isDateInToday($0.timestamp) }
                        if finalProgress > 0 {
                            pflanze.intradayProgressHistory.append(DailyProgressEntry(timestamp: Date(), progress: finalProgress))
                        }
                    }
                    
                    if finalProgress >= 1.0 {
                        gardenStore.completeHabit(pflanze: pflanze, on: targetDate)"""
content = content.replace(drag_ended_old, drag_ended_new)

with open(file_path, "w") as f:
    f.write(content)
