import re

with open('/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Stores/GardenStore.swift', 'r') as f:
    content = f.read()

# 1. Remove BadHabitExecution struct
content = re.sub(r'struct BadHabitExecution: Codable, Identifiable \{[^}]+\}', '', content)

# 2. Remove @Published var badHabitExecutions
content = re.sub(r'@Published var badHabitExecutions: \[String: \[BadHabitExecution\]\] = \[:\] \{\s*didSet \{ saveBadHabits\(\) \}\s*\}', '', content)

# 3. Remove loadBadHabits() and loadBadHabitNotes() calls inside functions (e.g. init)
# We only want to remove the calls, not the method definitions!
# The calls are inside init() usually indented:
content = re.sub(r'(?m)^\s*loadBadHabits\(\)\n', '', content)
content = re.sub(r'(?m)^\s*loadBadHabitNotes\(\)\n', '', content)

# 4. Remove trackBadHabit and all other bad habit functions
# They start at "func trackBadHabit" and end at "func updateTageAktiv"
# Let's match from "func trackBadHabit" up to (but not including) "private func updateTageAktiv"
pattern = r'func trackBadHabit\(id: String, penaltyCoins: Int\).*?(?=private func updateTageAktiv\(\) \{)'
content = re.sub(pattern, '', content, flags=re.DOTALL)

with open('/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Stores/GardenStore.swift', 'w') as f:
    f.write(content)

print("GardenStore updated.")
