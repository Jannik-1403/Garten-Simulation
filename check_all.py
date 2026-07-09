import json

with open("Garten_Simulation/Localizable.xcstrings", "r", encoding="utf-8") as f:
    data = json.load(f)

for key, val in data["strings"].items():
    locs = val.get("localizations", {})
    if len(locs) < 13: # we have 14 languages plus maybe 'de', so it should have many
        print(f"Key {key} only has {len(locs)} translations")

