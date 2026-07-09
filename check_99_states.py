import json

with open("Garten_Simulation/Localizable.xcstrings", "r", encoding="utf-8") as f:
    data = json.load(f)

bad = 0
missing = 0
for key, val in data["strings"].items():
    locs = val.get("localizations", {})
    if len(locs) < 14:
        missing += 1
    for lang, loc in locs.items():
        if loc.get("stringUnit", {}).get("state") != "translated":
            bad += 1

print(f"Missing languages for some keys: {missing}")
print(f"Keys with non-translated states: {bad}")
