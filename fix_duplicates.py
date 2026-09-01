import re

with open("Garten_Simulation/Localization/AppStrings.swift", "r") as f:
    lines = f.readlines()

new_lines = []
keys_seen = set()

for i, line in enumerate(reversed(lines)):
    match = re.search(r'^\s*"([^"]+)"\s*:\s*\[', line)
    if match:
        key = match.group(1)
        if key in keys_seen:
            # Skip this line (it's a duplicate and we're going backwards so we keep the LAST occurrence)
            continue
        else:
            keys_seen.add(key)
    new_lines.append(line)

new_lines.reverse()

with open("Garten_Simulation/Localization/AppStrings.swift", "w") as f:
    f.writelines(new_lines)
