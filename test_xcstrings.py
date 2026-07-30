import json

with open("Garten_Simulation/Localizable.xcstrings", "r") as f:
    data = json.load(f)

for key, value in data.get("strings", {}).items():
    locs = value.get("localizations", {})
    for lang, lang_data in locs.items():
        if "stringUnit" in lang_data:
            text = lang_data["stringUnit"].get("value", "")
            if "Gartengewohnheiten" in text:
                print(f"Key: {key}, Lang: {lang}, Value: {text}")
            if key == "tab.routines" and lang == "de":
                print(f"Key: {key}, Lang: {lang}, Value: {text}")
