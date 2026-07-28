import json

file_path = 'Garten_Simulation/Localizable.xcstrings'
with open(file_path, 'r', encoding='utf-8') as f:
    data = json.load(f)

translations = {
    "focus.session.open_goals": {
        "en": "Open Goals",
        "de": "Offene Ziele",
        "es": "Objetivos Abiertos",
        "fr": "Objectifs Ouverts",
        "it": "Obiettivi Aperti",
        "pt": "Objetivos Abertos",
        "nl": "Open Doelen",
        "pl": "Otwarte cele",
        "ru": "Открытые цели",
        "tr": "Açık Hedefler",
        "ja": "オープンな目標",
        "ko": "열린 목표",
        "zh-Hans": "待完成目标",
        "zh-Hant": "待完成目標",
        "hi": "खुले लक्ष्य"
    },
    "focus.session.completed_goals": {
        "en": "Completed Goals",
        "de": "Abgeschlossene Ziele",
        "es": "Objetivos Completados",
        "fr": "Objectifs Atteints",
        "it": "Obiettivi Completati",
        "pt": "Objetivos Concluídos",
        "nl": "Voltooide Doelen",
        "pl": "Ukończone cele",
        "ru": "Завершенные цели",
        "tr": "Tamamlanan Hedefler",
        "ja": "達成した目標",
        "ko": "완료된 목표",
        "zh-Hans": "已完成目标",
        "zh-Hant": "已完成目標",
        "hi": "पूरे किए गए लक्ष्य"
    }
}

existing_langs = ['pt', 'nl', 'zh-Hans', 'ko', 'ja', 'tr', 'es', 'fr', 'en', 'ru', 'pl', 'it', 'hi', 'de', 'zh-Hant']

# Fix strings
for key, lang_dict in translations.items():
    if key not in data['strings']:
        continue
    
    for lang in existing_langs:
        val = lang_dict.get(lang) or lang_dict.get('en')
        
        if 'localizations' not in data['strings'][key]:
            data['strings'][key]['localizations'] = {}
            
        data['strings'][key]['localizations'][lang] = {
            "stringUnit": {
                "state": "translated",
                "value": val
            }
        }

with open(file_path, 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

print("Injected additional translations successfully!")
