import json
import os

file_path = "/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Localizable.xcstrings"
with open(file_path, "r") as f:
    data = json.load(f)

new_keys = {
    "widget_interactive_todos_title": {
        "de": "To-Dos (Pro)",
        "en": "To-Dos (Pro)"
    },
    "widget_interactive_todos_desc": {
        "de": "Erledige deine To-Dos direkt vom Homescreen.",
        "en": "Complete your To-Dos straight from your homescreen."
    },
    "widget_todos_title": {
        "de": "To-Dos",
        "en": "To-Dos"
    },
    "widget_todos_empty": {
        "de": "Keine Aufgaben.",
        "en": "No tasks."
    }
}

langs = ["de", "en", "es", "fr", "it", "ja", "ko", "nl", "pl", "pt", "pt-BR", "ru", "tr", "zh-Hans", "zh-Hant", "hi"]

for key, trans in new_keys.items():
    if key not in data["strings"]:
        data["strings"][key] = {"extractionState": "manual", "localizations": {}}
    for lang in langs:
        val = trans.get(lang, trans["en"])
        if lang == "de": val = trans["de"]
        data["strings"][key]["localizations"][lang] = {
            "stringUnit": {
                "state": "translated",
                "value": val
            }
        }

with open(file_path, "w") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
    f.write("\n")
