import re

with open("Localization/AppStrings.swift", "r") as f:
    content = f.read()

pattern = re.compile(r'"([^"]+)":\s*\[(.*?)\]', re.DOTALL)
matches = pattern.findall(content)

keys = []
dupes = []

for key, _ in matches:
    if key in keys:
        dupes.append(key)
    else:
        keys.append(key)

print("Duplicate keys found:", dupes)
