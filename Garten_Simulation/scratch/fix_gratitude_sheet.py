import re

filepath = '/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Views/PflanzeDetailSheet.swift'

with open(filepath, 'r') as f:
    content = f.read()

# 1. Add State variable
content = re.sub(r'(@State private var zeigeGratitudeJournal = false\n)', 
                 r'\1    @State private var isGratitudeExpanded = true\n', 
                 content)

# 2. Hide healthKitConfigSection for Gratitude Journal
content = content.replace(
    'if pflanze.showStats && pflanze.habitName != "habit.wasser_trinken" {',
    'if pflanze.showStats && pflanze.habitName != "habit.wasser_trinken" && pflanze.habitName != "habit.dankbarkeit" {'
)

# 3. Modify Dankbarkeitsjournal if statement
content = content.replace(
    'if pflanze.habitName == "habit.dankbarkeit" {',
    'if pflanze.habitName == "habit.dankbarkeit" && pflanze.showStats {'
)

# 4. Modify DisclosureGroup
content = content.replace(
    'DisclosureGroup(isExpanded: .constant(true)) {',
    'DisclosureGroup(isExpanded: $isGratitudeExpanded) {'
)

with open(filepath, 'w') as f:
    f.write(content)

print("PflanzeDetailSheet fixed.")
