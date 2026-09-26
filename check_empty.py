import json

file_path = "Garten_Simulation/Localizable.xcstrings"
with open(file_path, "r", encoding="utf-8") as f:
    data = json.load(f)

for key, value in data["strings"].items():
    localizations = value.get("localizations", {})
    for lang, loc in localizations.items():
        state = loc.get("stringUnit", {}).get("state", "")
        val = loc.get("stringUnit", {}).get("value", "")
        if state == "translated" and val == "":
            print(f"Empty translated value: {key} in {lang}")
