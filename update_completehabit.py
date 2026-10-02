import re

file_path = "Garten_Simulation/Stores/GardenStore.swift"
with open(file_path, "r") as f:
    content = f.read()

# Update signature
content = content.replace("func completeHabit(pflanze: HabitModel, fromRoutine: Bool = false) {", "func completeHabit(pflanze: HabitModel, on date: Date = Date(), fromRoutine: Bool = false) {")

# Update guard
content = content.replace("guard !pflanze.isCompleted else { return }", "guard !pflanze.wasCompleted(on: date) else { return }")

# Update wateringDates.append(Date()) to date
content = content.replace("pflanze.wateringDates.append(Date()) // Log für Verlauf-Tab", "pflanze.wateringDates.append(date) // Log für Verlauf-Tab")

# Update xpHistory key formatter to use date instead of Date()
content = content.replace("let key = formatter.string(from: Date())", "let key = formatter.string(from: date)")

with open(file_path, "w") as f:
    f.write(content)
