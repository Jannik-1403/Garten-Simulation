import json
import os
import re

with open("Garten_Simulation/Localizable.xcstrings", "r", encoding="utf-8") as f:
    data = json.load(f)

# Find all keys used in .swift files
used_keys = set()
for root, dirs, files in os.walk("Garten_Simulation"):
    for file in files:
        if file.endswith(".swift"):
            with open(os.path.join(root, file), "r", encoding="utf-8") as f:
                content = f.read()
                # Find all String(localized: "key"
                matches = re.findall(r'String\(\s*localized:\s*"([^"]+)"', content)
                used_keys.update(matches)
                # Find LocalizedStringKey("key")
                matches2 = re.findall(r'LocalizedStringKey\(\s*"([^"]+)"', content)
                used_keys.update(matches2)
                # Find Text("key" (if they are direct literals)
                matches3 = re.findall(r'Text\(\s*"([^"]+)"', content)
                used_keys.update(matches3)
                # Find Label("key"
                matches4 = re.findall(r'Label\(\s*"([^"]+)"', content)
                used_keys.update(matches4)

keys_to_delete = []
for key in data["strings"].keys():
    if key not in used_keys:
        keys_to_delete.append(key)

print(f"Found {len(keys_to_delete)} unused keys. E.g. {keys_to_delete[:10]}")
