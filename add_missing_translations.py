import json

path = "Garten_Simulation/Localizable.xcstrings"

translations = {
    "water.goal.details": {
        "de": "Tagesziel-Berechnung",
        "en": "Daily Goal Calculation",
        "es": "Cálculo del objetivo diario",
        "fr": "Calcul de l'objectif quotidien",
        "hi": "दैनिक लक्ष्य गणना",
        "it": "Calcolo dell'obiettivo giornaliero",
        "ja": "1日の目標の計算",
        "ko": "일일 목표 계산",
        "nl": "Dagelijks doel berekening",
        "pl": "Obliczanie celu dziennego",
        "pt": "Cálculo da meta diária",
        "pt-BR": "Cálculo da meta diária",
        "ru": "Расчет дневной цели",
        "tr": "Günlük Hedef Hesaplama",
        "zh-Hans": "每日目标计算",
        "zh-Hant": "每日目標計算"
    }
}

with open(path, "r", encoding="utf-8") as f:
    data = json.load(f)

for key, langs in translations.items():
    if key not in data["strings"]:
        data["strings"][key] = {
            "extractionState": "manual",
            "localizations": {}
        }
    
    for lang, val in langs.items():
        data["strings"][key]["localizations"][lang] = {
            "stringUnit": {
                "state": "translated",
                "value": val
            }
        }

with open(path, "w", encoding="utf-8") as f:
    json.dump(data, f, ensure_ascii=False, indent=2)
    f.write('\n')

print("Missing translations added!")
