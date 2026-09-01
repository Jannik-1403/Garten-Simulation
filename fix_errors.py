import json
import time
from deep_translator import GoogleTranslator

with open("Garten_Simulation/Localizable.xcstrings", "r") as f:
    data = json.load(f)

count = 0
for key, value in data["strings"].items():
    if "localizations" in value:
        for lang, lang_data in value["localizations"].items():
            val = lang_data.get("stringUnit", {}).get("value", "")
            if "Error 500" in val or "Server Error" in val:
                print(f"Found error in {key} for {lang}")
                
                # Get German or English source
                de_text = value["localizations"].get("de", {}).get("stringUnit", {}).get("value", "")
                en_text = value["localizations"].get("en", {}).get("stringUnit", {}).get("value", "")
                source = de_text if de_text else (en_text if en_text else key)
                
                target_lang = "zh-CN" if lang == "zh-Hans" else ("zh-TW" if lang == "zh-Hant" else lang)
                
                try:
                    translator = GoogleTranslator(source='auto', target=target_lang)
                    translated_text = translator.translate(source)
                    if translated_text and "Error 500" not in translated_text:
                        lang_data["stringUnit"]["value"] = translated_text
                        lang_data["stringUnit"]["state"] = "translated"
                        count += 1
                        time.sleep(0.5)
                    else:
                        print(f"Failed to translate {key}")
                except Exception as e:
                    print(f"Exception translating {key}: {e}")

# Fix empty translations (like kg, cm)
for key, value in data["strings"].items():
    if key in ["body.tracking.unit.kg", "body.tracking.unit.cm"]:
        if "localizations" not in value:
            value["localizations"] = {}
        for lang in ["zh-Hans", "zh-Hant"]:
            if lang not in value["localizations"] or not value["localizations"][lang].get("stringUnit", {}).get("value"):
                value["localizations"][lang] = {
                    "stringUnit": {
                        "state": "translated",
                        "value": "公斤" if "kg" in key else "厘米"
                    }
                }
                count += 1

with open("Garten_Simulation/Localizable.xcstrings", "w") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print(f"Fixed {count} translations!")
