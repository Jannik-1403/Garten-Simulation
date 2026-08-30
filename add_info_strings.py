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

new_keys = {
    "body.measure.brust": "Brustumfang",
    "body.measure.info.brust": "Miss den Umfang an der breitesten Stelle deiner Brust.",
    "body.measure.info.bizeps": "Miss an der dicksten Stelle deines Oberarms, während der Muskel angespannt ist.",
    "body.measure.info.unterarm": "Miss an der dicksten Stelle deines Unterarms.",
    "body.measure.info.schultern": "Miss den gesamten Umfang um deine Schultern an der breitesten Stelle.",
    "body.measure.info.oberschenkel": "Miss an der dicksten Stelle deines Oberschenkels.",
    "body.measure.info.waden": "Miss an der dicksten Stelle deiner Wade.",
    "body.measure.info.taille": "Miss an der schmalsten Stelle deines Bauches, meist knapp über dem Bauchnabel."
}

strings = data.setdefault("strings", {})

for key, de_val in new_keys.items():
    if key not in strings:
        strings[key] = {"extractionState": "manual", "localizations": {}}
    
    localizations = strings[key].setdefault("localizations", {})
    # Set German
    localizations["de"] = {"stringUnit": {"state": "translated", "value": de_val}}
    
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

print("Done translating new keys.")
