import json

path = "Garten_Simulation/Localizable.xcstrings"

with open(path, "r", encoding="utf-8") as f:
    data = json.load(f)

langs = ["de", "nl", "en", "fr", "it", "ja", "ko", "pl", "pt", "es", "tr"]

strings_to_add = {
    "custom.tracker.delete.title": ("Tracker löschen?", "Delete Tracker?"),
    "custom.tracker.delete.message": ("Bist du sicher, dass du deinen Tracker löschen möchtest? Dein Fortschritt geht dabei verloren.", "Are you sure you want to delete your tracker? Your progress will be lost.")
}

for key, (de_val, en_val) in strings_to_add.items():
    if key not in data["strings"]:
        data["strings"][key] = {
            "extractionState": "manual",
            "localizations": {}
        }
    
    for lang in langs:
        if lang not in data["strings"][key]["localizations"]:
            val = en_val if lang == "en" else de_val
            data["strings"][key]["localizations"][lang] = {
                "stringUnit": {
                    "state": "translated",
                    "value": val
                }
            }
        else:
            val = en_val if lang == "en" else de_val
            data["strings"][key]["localizations"][lang]["stringUnit"]["state"] = "translated"
            data["strings"][key]["localizations"][lang]["stringUnit"]["value"] = val

with open(path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
