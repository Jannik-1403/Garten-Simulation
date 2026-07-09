import json

with open("Garten_Simulation/Localizable.xcstrings", "r", encoding="utf-8") as f:
    data = json.load(f)

for key, val in data["strings"].items():
    locs = val.get("localizations", {})
    
    for lang in ["zh-Hans", "zh-Hant"]:
        if lang not in locs:
            print(f"Missing language {lang} for key {key}")
            continue
        state = locs[lang].get("stringUnit", {}).get("state", "")
        if state != "translated":
            print(f"State not translated ({state}) in {lang} for key {key}")

