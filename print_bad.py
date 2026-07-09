import json

with open("Garten_Simulation/Localizable.xcstrings", "r", encoding="utf-8") as f:
    data = json.load(f)

for key, val in data["strings"].items():
    locs = val.get("localizations", {})
    if len(locs) < 14:
        langs = set(locs.keys())
        print(f"Key '{key}' missing languages. Has: {len(langs)}")
    for lang, loc in locs.items():
        if loc.get("stringUnit", {}).get("state") != "translated":
            print(f"Key '{key}' in '{lang}' has state {loc.get('stringUnit', {}).get('state')}")

