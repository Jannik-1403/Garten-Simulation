import json
import os

path = "Garten_Simulation/Localizable.xcstrings"

with open(path, "r", encoding="utf-8") as f:
    data = json.load(f)

langs = ["de", "nl", "en", "fr", "it", "ja", "ko", "pl", "pt", "es", "tr"]
strings_to_add = {
    "health.metric.running": "Joggen",
    "health.metric.strengthTraining": "Krafttraining",
    "apple.health.unit.running": "min",
    "apple.health.unit.strengthTraining": "min"
}

for key, de_value in strings_to_add.items():
    if key not in data["strings"]:
        data["strings"][key] = {
            "extractionState": "manual",
            "localizations": {}
        }
    
    for lang in langs:
        if lang not in data["strings"][key]["localizations"]:
            val = de_value
            if lang == "en":
                if "Joggen" in de_value: val = "Running"
                if "Krafttraining" in de_value: val = "Strength Training"
            data["strings"][key]["localizations"][lang] = {
                "stringUnit": {
                    "state": "translated",
                    "value": val
                }
            }

with open(path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
