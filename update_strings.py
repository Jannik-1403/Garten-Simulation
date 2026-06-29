import json
import sys

keys = {
    "plant.detail.notes_header": {"defaultValue": "Notizen", "de": "Notizen", "en": "Notes"},
    "pdf.notes.title": {"defaultValue": "Alle Notizen", "de": "Alle Notizen", "en": "All Notes"},
    "pdf.notes.good_habits": {"defaultValue": "Gute Gewohnheiten", "de": "Gute Gewohnheiten", "en": "Good Habits"},
    "pdf.notes.bad_habits": {"defaultValue": "Schlechte Gewohnheiten", "de": "Schlechte Gewohnheiten", "en": "Bad Habits"},
    "pdf.notes.filename": {"defaultValue": "Notizen.pdf", "de": "Notizen.pdf", "en": "Notes.pdf"}
}

langs = ["de", "nl", "en", "fr", "it", "ja", "ko", "pl", "pt-BR", "es", "tr"]

with open("Garten_Simulation/Localizable.xcstrings", "r") as f:
    data = json.load(f)

for k, v in keys.items():
    if k not in data["strings"]:
        data["strings"][k] = {
            "extractionState": "manual",
            "localizations": {}
        }
    
    for lang in langs:
        # Default to English if language not mapped
        val = v.get(lang[:2], v.get("en"))
        if lang == "de": val = v["de"]
        
        data["strings"][k]["localizations"][lang] = {
            "stringUnit": {
                "state": "translated",
                "value": val
            }
        }

with open("Garten_Simulation/Localizable.xcstrings", "w") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
