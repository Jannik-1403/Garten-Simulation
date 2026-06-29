import json

path = "Garten_Simulation/Localizable.xcstrings"
with open(path, "r", encoding="utf-8") as f:
    data = json.load(f)

key = "routine.timer.apply_all"
translations = {
    "de": "Für alle Tage übernehmen",
    "en": "Apply to all days",
    "nl": "Op alle dagen toepassen",
    "fr": "Appliquer à tous les jours",
    "it": "Applica a tutti i giorni",
    "ja": "すべての日に適用",
    "ko": "모든 요일에 적용",
    "pl": "Zastosuj do wszystkich dni",
    "pt": "Aplicar a todos os dias",
    "es": "Aplicar a todos los días",
    "tr": "Tüm günlere uygula"
}

if key not in data["strings"]:
    data["strings"][key] = {"extractionState": "manual", "localizations": {}}

for lang, text in translations.items():
    data["strings"][key]["localizations"][lang] = {
        "stringUnit": {
            "state": "translated",
            "value": text
        }
    }

with open(path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
