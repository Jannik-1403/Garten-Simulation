import re

file_path = 'Garten_Simulation/Views/FocusSession/FocusSessionView.swift'

with open(file_path, 'r', encoding='utf-8') as f:
    lines = f.readlines()

# We need to find the VStack at line 352
# And we need to fix the braces.

# Let's just output lines 352-422 to see them accurately
for i in range(350, 424):
    print(f"{i+1}: {lines[i]}", end='')

