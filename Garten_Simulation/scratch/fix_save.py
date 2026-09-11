import re

# Fix GratitudeJournalView.swift
filepath_view = '/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Views/GratitudeJournalView.swift'
with open(filepath_view, 'r') as f:
    content = f.read()

# Add gardenStore
content = content.replace(
    '@ObservedObject var habit: HabitModel\n    @Environment(\\.dismiss) var dismiss',
    '@ObservedObject var habit: HabitModel\n    @Environment(\\.dismiss) var dismiss\n    @EnvironmentObject var gardenStore: GardenStore'
)

# Add save call
content = content.replace(
    'habit.journalEntries.append(entry)\n        \n        dismiss()',
    'habit.journalEntries.append(entry)\n        gardenStore.savePlants()\n        \n        dismiss()'
)

with open(filepath_view, 'w') as f:
    f.write(content)

# Fix PflanzeDetailSheet.swift
filepath_sheet = '/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Views/PflanzeDetailSheet.swift'
with open(filepath_sheet, 'r') as f:
    content_sheet = f.read()

content_sheet = re.sub(r'(@State private var isTodosExpanded = )true', r'\g<1>false', content_sheet)
content_sheet = re.sub(r'(@State private var isGratitudeExpanded = )true', r'\g<1>false', content_sheet)

with open(filepath_sheet, 'w') as f:
    f.write(content_sheet)

print("Fixes applied.")
