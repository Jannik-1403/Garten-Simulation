import json
import os

path = "Garten_Simulation/Localizable.xcstrings"
with open(path, "r") as f:
    data = json.load(f)

new_keys = {
    "water.goal.details": "Tagesziel-Berechnung",
    "water.glass": "Glas",
    "water.bottle": "Flasche",
    "water.other": "Andere Menge",
    "water.history": "Verlauf Heute",
    "water.history.empty": "Noch kein Wasser getrunken heute.",
    "water.source.app": "Manuell",
    "water.title": "Wasser",
    "water.goal.base": "Basisbedarf",
    "water.goal.steps": "Schritte Bonus",
    "water.goal.strength": "Krafttraining Bonus",
    "water.goal.endurance": "Ausdauer Bonus",
    "water.goal.total": "Heutiges Ziel",
    "water.custom.title": "Andere Menge hinzufügen",
    "water.target.text": "von %@ ml"
}

added = 0
for k, v in new_keys.items():
    if k not in data["strings"]:
        data["strings"][k] = {
            "extractionState": "manual",
            "localizations": {
                "de": {
                    "stringUnit": {
                        "state": "translated",
                        "value": v
                    }
                }
            }
        }
        added += 1

with open(path, "w") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print(f"Added {added} new keys.")
