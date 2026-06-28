import re

with open("Localization/AppStrings.swift", "r") as f:
    content = f.read()

# Find all dictionary entries like "key": [ ... ]
# We look for lines starting with "key": [
matches = re.finditer(r'"([^"]+)":\s*\[(.*?)\]', content, re.DOTALL)
missing = 0
for match in matches:
    key = match.group(1)
    value = match.group(2)
    if '"it"' not in value:
        print(f"Missing IT for key: {key}")
        missing += 1

print(f"Total missing IT: {missing}")
