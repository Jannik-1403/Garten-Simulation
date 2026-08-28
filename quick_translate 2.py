import json
import time
from deep_translator import GoogleTranslator

file_path = "Garten_Simulation/Localizable.xcstrings"
with open(file_path, "r", encoding="utf-8") as f:
    data = json.load(f)

lang_map = {
    "en": "en", "es": "es", "fr": "fr", "hi": "hi", "it": "it", "ja": "ja", 
    "ko": "ko", "nl": "nl", "pl": "pl", "pt": "pt", "ru": "ru", "tr": "tr", 
    "zh-Hans": "zh-CN", "zh-Hant": "zh-TW"
}

keys_to_translate = [
    "routine.todo.title", "routine.todo.name", "routine.todo.name.placeholder",
    "routine.todo.icon", "routine.todo.description", "routine.todo.description.placeholder",
    "shop.tab.items.short", "shop.tab.plants.short", "shop.seeds.desc",
    "Erstelle dir eigene Gewohnheiten. Für 10 Samen kannst du dir eigene Gewohnheiten erstellen.",
    "badhabit.category.sucht", "badhabit.category.ernaehrung", "badhabit.category.digital",
    "badhabit.category.finanzen", "badhabit.category.freizeit", "badhabit.category.faulheit",
    "badhabit.category.sonstiges", "shop.tab.header"
]

strings = data.setdefault("strings", {})

for key in keys_to_translate:
    if key not in strings: continue
    localizations = strings[key].setdefault("localizations", {})
    de_val = localizations.get("de", {}).get("stringUnit", {}).get("value", key)
    
    for lang_code, trans_code in lang_map.items():
        state = localizations.get(lang_code, {}).get("stringUnit", {}).get("state")
        if state != "translated":
            try:
                translated = GoogleTranslator(source='de', target=trans_code).translate(de_val)
                translated = translated.replace("％", "%").replace("%%", "%")
                localizations[lang_code] = {"stringUnit": {"state": "translated", "value": translated}}
                time.sleep(0.1)
                print(f"Translated {key} to {lang_code}: {translated}")
            except Exception as e:
                print(f"Error on {lang_code}: {e}")

with open(file_path, "w", encoding="utf-8") as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

print("Done translating specific keys.")
