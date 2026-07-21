import json

with open('Garten_Simulation/Localizable.xcstrings', 'r') as f:
    data = json.load(f)

new_keys = {
    "verlauf.analysis.title.new": "Anfangsphase",
    "verlauf.analysis.desc.new": "Du hast gerade erst angefangen! Bleib dran, um bald erste Trends zu sehen.",
    "verlauf.analysis.title.fluctuating": "Starke Schwankungen",
    "verlauf.analysis.desc.fluctuating": "Deine Routine bei dieser Gewohnheit ist noch unregelmäßig. Versuche, sie an eine bereits bestehende Gewohnheit zu koppeln.",
    "verlauf.analysis.title.pro": "Eiserne Disziplin",
    "verlauf.analysis.desc.pro": "Wahnsinn! Du ziehst diese Gewohnheit extrem konstant durch. Das ist eine tief verankerte Routine.",
    "verlauf.analysis.title.stable": "Gute Basis",
    "verlauf.analysis.desc.stable": "Du bist stetig dabei, auch wenn du nicht jeden Tag perfekt bist. Das ist genau der richtige Weg!",
    "verlauf.analysis.title.low": "Wieder reinkommen",
    "verlauf.analysis.desc.low": "Diese Gewohnheit ist in letzter Zeit etwas eingeschlafen. Setze dir ein kleines, machbares Ziel für morgen.",
    "verlauf.analysis.subtitle": "Habit Analyse"
}

translations = {
    "en": {
        "verlauf.analysis.title.new": "Initial Phase",
        "verlauf.analysis.desc.new": "You just started! Keep it up to see your first trends soon.",
        "verlauf.analysis.title.fluctuating": "Strong Fluctuations",
        "verlauf.analysis.desc.fluctuating": "Your routine for this habit is still irregular. Try to anchor it to an existing habit.",
        "verlauf.analysis.title.pro": "Iron Discipline",
        "verlauf.analysis.desc.pro": "Amazing! You are performing this habit extremely consistently. It's a deeply rooted routine.",
        "verlauf.analysis.title.stable": "Solid Base",
        "verlauf.analysis.desc.stable": "You are making steady progress, even if you are not perfect every day. This is exactly the right path!",
        "verlauf.analysis.title.low": "Getting Back",
        "verlauf.analysis.desc.low": "This habit has been neglected recently. Set a small, achievable goal for tomorrow.",
        "verlauf.analysis.subtitle": "Habit Analysis"
    }
}

langs = ["de", "en", "es", "fr", "hi", "it", "ja", "ko", "nl", "pl", "pt", "pt-BR", "ru", "tr", "zh-Hans", "zh-Hant"]

for key, de_text in new_keys.items():
    if key not in data['strings']:
        data['strings'][key] = {
            "extractionState": "manual",
            "localizations": {}
        }
    
    for lang in langs:
        val = translations.get(lang, {}).get(key, de_text)
        data['strings'][key]['localizations'][lang] = {
            "stringUnit": {
                "state": "translated",
                "value": val
            }
        }

with open('Garten_Simulation/Localizable.xcstrings', 'w') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
