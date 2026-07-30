import json

with open("Garten_Simulation/Localizable.xcstrings", "r") as f:
    data = json.load(f)

locs = data["strings"].get("tab.garten", {}).get("localizations", {})
for lang, lang_data in locs.items():
    print(f"Lang: {lang}, Value: {lang_data.get('stringUnit', {}).get('value', 'N/A')}")
