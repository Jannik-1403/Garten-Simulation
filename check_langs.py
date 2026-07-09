import json

with open("Garten_Simulation/Localizable.xcstrings", "r", encoding="utf-8") as f:
    data = json.load(f)

langs = set()
for key, val in data["strings"].items():
    locs = val.get("localizations", {})
    langs.update(locs.keys())

print("All languages:", langs)
for key, val in data["strings"].items():
    locs = val.get("localizations", {})
    missing = langs - set(locs.keys())
    if missing:
        print(f"Key {key} missing: {missing}")

