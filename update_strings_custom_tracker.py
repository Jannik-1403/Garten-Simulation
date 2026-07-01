import json

path = "Garten_Simulation/Localizable.xcstrings"

with open(path, "r", encoding="utf-8") as f:
    data = json.load(f)

langs = ["de", "nl", "en", "fr", "it", "ja", "ko", "pl", "pt", "es", "tr"]

strings_to_add = {
    "health.metric.steps": ("Schritte", "Steps"),
    "health.metric.water": ("Wasser", "Water"),
    "health.metric.sleep": ("Schlaf", "Sleep"),
    "health.metric.mindfulness": ("Achtsamkeit", "Mindfulness"),
    "health.metric.running": ("Joggen", "Running"),
    "health.metric.strengthTraining": ("Krafttraining", "Strength Training"),
    "custom.tracker.title": ("Eigener Tracker", "Custom Tracker"),
    "custom.tracker.create": ("Tracker erstellen", "Create Tracker"),
    "custom.tracker.create.title": ("Neuen Tracker erstellen", "Create New Tracker"),
    "custom.tracker.name.placeholder": ("z.B. Seiten gelesen", "e.g. Pages read"),
    "custom.tracker.create.message": ("Gib einen Namen für deinen eigenen Fortschritts-Tracker ein.", "Enter a name for your custom progress tracker."),
    "custom.tracker.target": ("Ziel", "Target"),
    "custom.tracker.progress": ("Fortschritt heute", "Today's Progress")
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
            # force update to translated just in case
            val = en_val if lang == "en" else de_val
            data["strings"][key]["localizations"][lang]["stringUnit"]["state"] = "translated"
            data["strings"][key]["localizations"][lang]["stringUnit"]["value"] = val

with open(path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
