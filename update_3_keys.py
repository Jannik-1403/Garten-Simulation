import json

file_path = "Garten_Simulation/Localizable.xcstrings"
with open(file_path, "r", encoding="utf-8") as f:
    data = json.load(f)

new_keys = {
    "dopamine_story_s4_l1": {
        "de": "Früher", "en": "Past", "es": "Antes", "fr": "Avant",
        "it": "Prima", "pt-PT": "Antes", "nl": "Vroeger", "tr": "Eskiden",
        "ru": "Раньше", "zh-Hans": "以前", "zh-Hant": "以前",
        "ja": "昔", "ko": "과거", "ar": "سابقاً", "hi": "पहले"
    },
    "dopamine_story_s4_l2": {
        "de": "Vor 2 Jahren", "en": "2 years ago", "es": "Hace 2 años", "fr": "Il y a 2 ans",
        "it": "2 anni fa", "pt-PT": "Há 2 anos", "nl": "2 jaar geleden", "tr": "2 yıl önce",
        "ru": "2 года назад", "zh-Hans": "两年前", "zh-Hant": "兩年前",
        "ja": "2年前", "ko": "2년 전", "ar": "قبل سنتين", "hi": "2 साल पहले"
    },
    "dopamine_story_s4_l3": {
        "de": "Heute", "en": "Today", "es": "Hoy", "fr": "Aujourd'hui",
        "it": "Oggi", "pt-PT": "Hoje", "nl": "Vandaag", "tr": "Bugün",
        "ru": "Сегодня", "zh-Hans": "今天", "zh-Hant": "今天",
        "ja": "今日", "ko": "오늘", "ar": "اليوم", "hi": "आज"
    }
}

langs = ["de", "en", "es", "fr", "it", "pt-PT", "nl", "tr", "ru", "zh-Hans", "zh-Hant", "ja", "ko", "ar", "hi"]

for key, translations in new_keys.items():
    if key not in data["strings"]:
        data["strings"][key] = {"extractionState": "manual", "localizations": {}}
    
    for lang in langs:
        if lang not in data["strings"][key]["localizations"]:
            data["strings"][key]["localizations"][lang] = {
                "stringUnit": {
                    "state": "translated",
                    "value": translations.get(lang, translations["en"])
                }
            }

with open(file_path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print("3 keys added successfully!")
