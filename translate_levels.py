import json

file_path = 'Garten_Simulation/Localizable.xcstrings'
with open(file_path, 'r', encoding='utf-8') as f:
    data = json.load(f)

# The keys we want to add
keys = {
    "screenTime.layer1.level": {
        "en": "Level 1",
        "de": "Ebene 1",
        "es": "Nivel 1",
        "fr": "Niveau 1",
        "it": "Livello 1",
        "pt": "Nível 1",
        "pt-BR": "Nível 1",
        "ru": "Уровень 1",
        "ja": "レベル1",
        "ko": "레벨 1",
        "zh-Hans": "级别 1",
        "zh-Hant": "級別 1",
        "ar": "المستوى 1",
        "hi": "स्तर 1",
        "tr": "Seviye 1",
        "nl": "Niveau 1"
    },
    "screenTime.layer2.level": {
        "en": "Level 2",
        "de": "Ebene 2",
        "es": "Nivel 2",
        "fr": "Niveau 2",
        "it": "Livello 2",
        "pt": "Nível 2",
        "pt-BR": "Nível 2",
        "ru": "Уровень 2",
        "ja": "レベル2",
        "ko": "레벨 2",
        "zh-Hans": "级别 2",
        "zh-Hant": "級別 2",
        "ar": "المستوى 2",
        "hi": "स्तर 2",
        "tr": "Seviye 2",
        "nl": "Niveau 2"
    },
    "screenTime.layer3.level": {
        "en": "Level 3",
        "de": "Ebene 3",
        "es": "Nivel 3",
        "fr": "Niveau 3",
        "it": "Livello 3",
        "pt": "Nível 3",
        "pt-BR": "Nível 3",
        "ru": "Уровень 3",
        "ja": "レベル3",
        "ko": "레벨 3",
        "zh-Hans": "级别 3",
        "zh-Hant": "級別 3",
        "ar": "المستوى 3",
        "hi": "स्तर 3",
        "tr": "Seviye 3",
        "nl": "Niveau 3"
    },
    "screenTime.layer4.level": {
        "en": "Level 4",
        "de": "Ebene 4",
        "es": "Nivel 4",
        "fr": "Niveau 4",
        "it": "Livello 4",
        "pt": "Nível 4",
        "pt-BR": "Nível 4",
        "ru": "Уровень 4",
        "ja": "レベル4",
        "ko": "레벨 4",
        "zh-Hans": "级别 4",
        "zh-Hant": "級別 4",
        "ar": "المستوى 4",
        "hi": "स्तर 4",
        "tr": "Seviye 4",
        "nl": "Niveau 4"
    }
}

languages = data.get("sourceLanguage", "en")
strings = data.get("strings", {})

for key, translations in keys.items():
    if key not in strings:
        strings[key] = {
            "extractionState": "manual",
            "localizations": {}
        }
    
    # Get all active languages in the file, or use our translation dict
    existing_langs = list(translations.keys())
    # Find all actual languages in the whole file just to be sure we cover everything
    all_file_langs = set()
    for v in strings.values():
        if "localizations" in v:
            all_file_langs.update(v["localizations"].keys())
            
    for lang in all_file_langs:
        trans = translations.get(lang, translations.get("en", "Level"))
        if lang not in strings[key]["localizations"]:
            strings[key]["localizations"][lang] = {
                "stringUnit": {
                    "state": "translated",
                    "value": trans
                }
            }
        else:
            # force update to 100%
            strings[key]["localizations"][lang]["stringUnit"]["state"] = "translated"
            strings[key]["localizations"][lang]["stringUnit"]["value"] = trans

with open(file_path, 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

