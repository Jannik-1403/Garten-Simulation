import json
import time
from deep_translator import GoogleTranslator

# Path to the string catalog
FILE_PATH = "/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Localizable.xcstrings"

# Keys to force-translate
KEYS_TO_TRANSLATE = [
    "Add To-Do",
    "For which habit? (Optional)",
    "Enter To-Do...",
    "SAVE",
    "Custom To-Do",
    "To-Do Name",
    "Description (Optional)",
    "Plant Icon",
    "Vitamin B5 (Pantothenic Acid)",
    "Thiamin",
    "Riboflavin",
    "Niacin",
    "Vitamin B6",
    "Biotin",
    "Folate",
    "Vitamin B12",
    "Vitamin C",
    "Vitamin A",
    "Vitamin D",
    "Vitamin E",
    "Vitamin K",
    "Mineralstoffe",
    "Ballaststoffe",
    "Daten & Kalorien",
    "Mein Ziel",
    "Zunehmen",
    "Ziel-Datum",
    "Kalorien Details",
    "Kalorien Historie",
    "Heute",
    "Konsumiert",
    "routine.todo.icon",
    "routine.todo.name",
    "routine.todo.name.placeholder",
    "routine.todo.description",
    "routine.todo.description.placeholder",
    "nutrient.settings.dge_info",
    "nutrient.fiber",
    "nutrient.category.fiber",
    "health.chart.title.fiber.plain",
    "calorie.calc.nav",
    "calorie.detail.nav",
    "calorie.history.title",
    "calorie.history.today",
    "calorie.calc.goal.title",
    "calorie.calc.goal.lose",
    "calorie.calc.goal.gain",
    "calorie.calc.goal.target_date",
    "calorie.calc.goal.info",
    "routine.todo.title",
    "routine.todo.add",
    "routine.todo.add.short",
    "plant.detail.todo.add",
    "plant.detail.todo.edit",
    "plant.detail.todo.placeholder"
]

# Map Xcode language codes to deep-translator codes
LANG_MAP = {
    "de": "de",
    "en": "en",
    "es": "es",
    "fr": "fr",
    "hi": "hi",
    "it": "it",
    "ja": "ja",
    "ko": "ko",
    "nl": "nl",
    "pl": "pl",
    "pt": "pt",
    "pt-BR": "pt",
    "ru": "ru",
    "tr": "tr",
    "zh-Hans": "zh-CN",
    "zh-Hant": "zh-TW"
}

# Manual overrides for specific keys where MT might fail
MANUAL_OVERRIDES = {
    "streak.weekdays.short": {
        "de": "M,D,M,D,F,S,S",
        "en": "M,T,W,T,F,S,S",
        "es": "L,M,X,J,V,S,D",
        "fr": "L,M,M,J,V,S,D",
        "hi": "सो,मं,बु,गु,शु,श,र",
        "it": "L,M,M,G,V,S,D",
        "ja": "月,火,水,木,金,土,日",
        "ko": "월,화,수,목,금,토,일",
        "nl": "M,D,W,D,V,Z,Z",
        "pl": "P,W,Ś,C,P,S,N",
        "pt": "S,T,Q,Q,S,S,D",
        "pt-BR": "S,T,Q,Q,S,S,D",
        "ru": "П,В,С,Ч,П,С,В",
        "tr": "P,S,Ç,P,C,C,P",
        "zh-Hans": "一,二,三,四,五,六,日",
        "zh-Hant": "一,二,三,四,五,六,日"
    }
}

# Values that shouldn't be translated (keys that represent placeholders or code)
IGNORE_VALUES = []

def main():
    with open(FILE_PATH, 'r', encoding='utf-8') as f:
        data = json.load(f)

    strings = data.get("strings", {})
    all_langs = list(LANG_MAP.keys())

    translators = {}
    for lang, dt_lang in LANG_MAP.items():
        if dt_lang == "en":
            translators[lang] = None
        else:
            translators[lang] = GoogleTranslator(source='auto', target=dt_lang)
    
    # We also need an English translator for target=en
    en_translator = GoogleTranslator(source='auto', target='en')

    count = 0
    for key in KEYS_TO_TRANSLATE + ["streak.weekdays.short"]:
        if key not in strings:
            strings[key] = {"extractionState": "manual", "localizations": {}}
        
        locs = strings[key].get("localizations", {})
        
        # Determine source text (try EN or DE or key itself)
        source_text = key
        # Try to find a good source text from existing translations
        for l in ["en", "de"]:
            if l in locs and "stringUnit" in locs[l] and locs[l]["stringUnit"]["value"]:
                source_text = locs[l]["stringUnit"]["value"]
                break

        for lang in all_langs:
            if key in MANUAL_OVERRIDES:
                translated = MANUAL_OVERRIDES[key].get(lang, MANUAL_OVERRIDES[key]["en"])
            else:
                if lang == "de" and source_text == key and any(c in key for c in "äöüÄÖÜß"):
                    translated = key # If key is German, keep it
                elif lang == "en" and source_text == key and not any(c in key for c in "äöüÄÖÜß"):
                    translated = key
                else:
                    translator = translators[lang] if lang != "en" else en_translator
                    
                    if translator is None and lang == "en":
                        translated = source_text # Fallback, shouldn't happen with en_translator
                    else:
                        try:
                            # Avoid translating placeholders like %@
                            if "%@" in source_text:
                                parts = source_text.split("%@")
                                translated_parts = [translator.translate(p) if p.strip() else p for p in parts]
                                translated = "%@".join(translated_parts)
                            else:
                                translated = translator.translate(source_text)
                            time.sleep(0.1)
                        except Exception as e:
                            print(f"Error translating {key} to {lang}: {e}")
                            translated = source_text

            locs[lang] = {
                "stringUnit": {
                    "state": "translated",
                    "value": translated
                }
            }
            print(f"Translated '{key}' to {lang}: {translated}")
        
        strings[key]["localizations"] = locs
        count += 1

    # Specifically check for any missing languages in all other keys to ensure 100%
    for k, v in strings.items():
        locs = v.get("localizations", {})
        for lang in all_langs:
            if lang not in locs or "stringUnit" not in locs[lang] or locs[lang]["stringUnit"]["state"] != "translated":
                # Missing! Let's translate it
                source_text = k
                for l in ["en", "de"]:
                    if l in locs and "stringUnit" in locs[l]:
                        source_text = locs[l]["stringUnit"]["value"]
                        break
                
                translator = translators.get(lang)
                if not translator and lang == "en":
                    translator = en_translator
                
                if translator:
                    try:
                        translated = translator.translate(source_text)
                    except:
                        translated = source_text
                else:
                    translated = source_text

                locs[lang] = {
                    "stringUnit": {
                        "state": "translated",
                        "value": translated
                    }
                }
                print(f"Filled missing {lang} for {k}: {translated}")
        strings[k]["localizations"] = locs

    data["strings"] = strings

    with open(FILE_PATH, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
        f.write("\n")
    print(f"Done! Translated {count} specific keys and filled all missing translations.")

if __name__ == '__main__':
    main()
