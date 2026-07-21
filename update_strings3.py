import json

with open('Garten_Simulation/Localizable.xcstrings', 'r') as f:
    data = json.load(f)

new_keys = {
    "smart.weekly.title.insufficient": "Mehr Daten benötigt",
    "smart.weekly.desc.insufficient": "Sammle in dieser Woche noch etwas mehr Fokuszeit oder hake Gewohnheiten ab, um eine echte Analyse deines Rhythmus zu erhalten. Jeder Tag zählt!",
    "smart.weekly.title.fluctuating": "Starke Schwankungen",
    "smart.weekly.desc.fluctuating": "Dein Rhythmus war diese Woche sehr instabil. An manchen Tagen warst du extrem produktiv, an anderen ist alles eingebrochen. Versuche nächste Woche nicht alles auf einmal zu wollen, sondern lieber jeden Tag ein kleines bisschen zu machen.",
    "smart.weekly.title.stable_low": "Stabiles Fundament",
    "smart.weekly.desc.stable_low": "Die absolute Menge an erledigten Aufgaben ist zwar noch gering, aber deine Beständigkeit ist hervorragend. Du vermeidest extreme Schwankungen, was der perfekte Nährboden für langfristige Routinen ist. Baue nächste Woche sanft darauf auf.",
    "smart.weekly.title.consistent": "Eiserne Konstanz",
    "smart.weekly.desc.consistent": "Beeindruckend! Du zeigst nicht nur starkes Volumen, sondern hältst deine Leistung auch über die Tage extrem stabil. Es gibt kaum Schwankungen in deiner Routine – du hast dein System gemeistert."
}

translations = {
    "en": {
        "smart.weekly.title.insufficient": "More Data Needed",
        "smart.weekly.desc.insufficient": "Collect a bit more focus time or complete habits this week to get a real analysis of your rhythm. Every day counts!",
        "smart.weekly.title.fluctuating": "Strong Fluctuations",
        "smart.weekly.desc.fluctuating": "Your rhythm was very unstable this week. Some days you were extremely productive, on others everything collapsed. Try not to want everything at once next week, but rather do a little bit every day.",
        "smart.weekly.title.stable_low": "Stable Foundation",
        "smart.weekly.desc.stable_low": "The absolute amount of completed tasks is still low, but your consistency is excellent. You avoid extreme fluctuations, which is the perfect breeding ground for long-term routines. Build gently on it next week.",
        "smart.weekly.title.consistent": "Iron Consistency",
        "smart.weekly.desc.consistent": "Impressive! You not only show strong volume, but also keep your performance extremely stable over the days. There are hardly any fluctuations in your routine - you have mastered your system."
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
