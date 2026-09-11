import re

filepath = '/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Views/PflanzeDetailSheet.swift'

with open(filepath, 'r') as f:
    content = f.read()

# Hide GoalPointsBannerView for Gratitude Journal
content = content.replace(
    'if pflanze.showGoals {',
    'if pflanze.showGoals && pflanze.habitName != "habit.dankbarkeit" {'
)

with open(filepath, 'w') as f:
    f.write(content)

print("PflanzeDetailSheet Goal Banner fixed.")
