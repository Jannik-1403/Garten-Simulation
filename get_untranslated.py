import json
with open("Garten_Simulation/Localizable.xcstrings", "r") as f:
    data = json.load(f)

missing = []

for key, value in data["strings"].items():
    if "localizations" not in value or "zh-Hans" not in value["localizations"]:
        missing.append(key)
        
print(f"Missing in zh-Hans: {len(missing)}")
for m in missing[:50]:
    print(m)
