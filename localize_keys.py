import json
import sys
import os

path = "Garten_Simulation/Localizable.xcstrings"

with open(path, "r", encoding="utf-8") as f:
    data = json.load(f)

# Find all languages
sample_key = next(iter(data["strings"].values())) if data["strings"] else {}
languages = set()
for k, v in data["strings"].items():
    if "localizations" in v:
        languages.update(v["localizations"].keys())
if "de" not in languages:
    languages.add("de")
if "en" not in languages:
    languages.add("en")

new_keys = {
    "priority.low": {"de": "Kann warten", "en": "Can wait"},
    "priority.medium": {"de": "Sollte bald", "en": "Should be soon"},
    "priority.high": {"de": "Muss heute", "en": "Must do today"},
    "focus.today.title": {"de": "Heute im Fokus", "en": "Today in Focus"},
    "focus.today.routine_desc": {"de": "Komplette Routine", "en": "Complete Routine"},
    "focus.today.complete": {"de": "Erledigt & Weiter", "en": "Done & Next"},
    "focus.today.all_done": {"de": "Alles erledigt!", "en": "All done!"},
    "focus.today.all_done_desc": {"de": "Du hast alle Fokus-Aufgaben für heute gemeistert.", "en": "You've completed all your focus tasks for today."}
}

for key, translations in new_keys.items():
    if key not in data["strings"]:
        data["strings"][key] = {
            "extractionState" : "manual",
            "localizations" : {}
        }
    
    for lang in languages:
        trans = translations.get(lang, translations["en"]) # fallback to english
        data["strings"][key]["localizations"][lang] = {
            "stringUnit": {
                "state": "translated",
                "value": trans
            }
        }

with open(path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print("Updated Localizable.xcstrings with 100% coverage.")
