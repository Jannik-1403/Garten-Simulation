import json
import os

filepath = 'Garten_Simulation/Localizable.xcstrings'

with open(filepath, 'r', encoding='utf-8') as f:
    data = json.load(f)

new_keys = {
    "streak.label": {
        "de": "Streak",
        "en": "Streak",
        "nl": "Reeks",
        "fr": "Série",
        "it": "Serie",
        "ja": "ストリーク",
        "ko": "연속",
        "pl": "Seria",
        "pt": "Sequência",
        "es": "Racha",
        "tr": "Seri"
    },
    "bad_habit.label": {
        "de": "Schlechte Gewohnheit",
        "en": "Bad Habit",
        "nl": "Slechte Gewoonte",
        "fr": "Mauvaise Habitude",
        "it": "Cattiva Abitudine",
        "ja": "悪い習慣",
        "ko": "나쁜 습관",
        "pl": "Zły Nawyk",
        "pt": "Mau Hábito",
        "es": "Mal Hábito",
        "tr": "Kötü Alışkanlık"
    }
}

langs = ["de", "nl", "en", "fr", "it", "ja", "ko", "pl", "pt", "es", "tr"]

for key, translations in new_keys.items():
    if key not in data["strings"]:
        data["strings"][key] = {
            "extractionState": "manual",
            "localizations": {}
        }
    
    for lang in langs:
        data["strings"][key]["localizations"][lang] = {
            "stringUnit": {
                "state": "translated",
                "value": translations[lang]
            }
        }

with open(filepath, 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print("Done")
