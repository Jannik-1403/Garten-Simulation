import json
import time
from deep_translator import GoogleTranslator

with open("Garten_Simulation/Localizable.xcstrings", "r") as f:
    data = json.load(f)

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
        
    for lang in ["zh-Hans", "zh-Hant"]:
        current_val = value["localizations"].get(lang, {}).get("stringUnit", {}).get("value", "")
        state = value["localizations"].get(lang, {}).get("stringUnit", {}).get("state", "")
        
        needs_translation = False
        if state != "translated":
            needs_translation = True
        elif current_val == source_text and source_text != "" and any(c.isalpha() for c in source_text):
            needs_translation = True
            
        if lang.startswith("zh") and key == "common.points.short":
            value["localizations"][lang] = {"stringUnit": {"state": "translated", "value": "分"}}
            needs_translation = False
            count += 1
            
        if needs_translation:
            print(f"Translating {key} to {lang} (current: '{current_val}', source: '{source_text}')...", flush=True)
            try:
                target_lang = "zh-CN" if lang == "zh-Hans" else "zh-TW"
                
                translator = GoogleTranslator(source='auto', target=target_lang)
                translated_text = translator.translate(source_text)
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
                print(f"Error translating {key} to {lang}: {e}", flush=True)

with open("Garten_Simulation/Localizable.xcstrings", "w") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print(f"Fixed {count} zh translations!", flush=True)
