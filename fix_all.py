import json
import time
from deep_translator import GoogleTranslator

with open("Garten_Simulation/Localizable.xcstrings", "r") as f:
    data = json.load(f)

languages = set()
for key, value in data["strings"].items():
    if "localizations" in value:
        for lang in value["localizations"].keys():
            languages.add(lang)
languages = sorted(list(languages))

translator_cache = {}

count = 0
for key, value in data["strings"].items():
    de_text = ""
    en_text = ""
    if "localizations" in value:
        if "de" in value["localizations"]:
            de_text = value["localizations"]["de"].get("stringUnit", {}).get("value", "")
        if "en" in value["localizations"]:
            en_text = value["localizations"]["en"].get("stringUnit", {}).get("value", "")
            
    source_text = de_text if de_text else (en_text if en_text else key)
    
    if "localizations" not in value:
        value["localizations"] = {}
        
    for lang in languages:
        if lang in ["de", "en"]: continue
        
        current_val = value["localizations"].get(lang, {}).get("stringUnit", {}).get("value", "")
        state = value["localizations"].get(lang, {}).get("stringUnit", {}).get("state", "")
        
        needs_translation = False
        if state != "translated":
            needs_translation = True
        elif current_val == source_text and source_text != "" and any(c.isalpha() for c in source_text):
            # The "translated" text is identical to the source text. It's probably a fake translation!
            # EXCEPT for things like "6 M." or "T", wait, "T", "W", "M", "J" might be valid in some languages, 
            # but usually they should be translated.
            needs_translation = True
            
        # Pkt should also be translated, in Chinese it became "铂", which is Platinum, not Points.
        if lang.startswith("zh") and key == "common.points.short":
            value["localizations"][lang] = {"stringUnit": {"state": "translated", "value": "分"}}
            needs_translation = False
        
        if needs_translation:
            print(f"Translating {key} to {lang} (current: '{current_val}', source: '{source_text}')...")
            try:
                target_lang = lang
                if lang == "zh-Hans": target_lang = "zh-CN"
                elif lang == "zh-Hant": target_lang = "zh-TW"
                
                cache_key = f"{source_text}_{target_lang}"
                if cache_key in translator_cache:
                    translated_text = translator_cache[cache_key]
                else:
                    translator = GoogleTranslator(source='auto', target=target_lang)
                    translated_text = translator.translate(source_text)
                    translator_cache[cache_key] = translated_text
                    time.sleep(0.1)
                
                if translated_text:
                    value["localizations"][lang] = {
                        "stringUnit": {
                            "state": "translated",
                            "value": translated_text
                        }
                    }
                    count += 1
            except Exception as e:
                print(f"Error translating {key} to {lang}: {e}")

# Fix prefix translation explicitly
prefix_key = "body.measure.info.prefix"
if prefix_key in data["strings"]:
    prefix_text = "Nimm ein flexibles Maßband, miss im kalten Zustand ohne Pump und setz das Band immer absolut waagerecht an."
    for lang in languages:
        if lang in ["de", "en"]: continue
        target_lang = lang
        if lang == "zh-Hans": target_lang = "zh-CN"
        elif lang == "zh-Hant": target_lang = "zh-TW"
        try:
            translator = GoogleTranslator(source='de', target=target_lang)
            translated_text = translator.translate(prefix_text)
            if translated_text:
                data["strings"][prefix_key]["localizations"][lang] = {
                    "stringUnit": {
                        "state": "translated",
                        "value": translated_text
                    }
                }
        except:
            pass

with open("Garten_Simulation/Localizable.xcstrings", "w") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print(f"Fixed {count} translations!")
