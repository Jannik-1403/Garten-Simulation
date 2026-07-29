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
    "tab.heute": {"de": "Heute", "en": "Today"},
    "heute.completed_of": {"de": "von", "en": "of"},
    "heute.done": {"de": "erledigt", "en": "done"},
    "type.routine": {"de": "Routine", "en": "Routine"},
    "type.todo": {"de": "To-Do", "en": "To-Do"}
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

print("Updated Localizable.xcstrings with Heute view translations.")
