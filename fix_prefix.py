import json
import time
from deep_translator import GoogleTranslator

with open("Garten_Simulation/Localizable.xcstrings", "r") as f:
    data = json.load(f)

text = "Nimm ein flexibles Maßband, miss im kalten Zustand ohne Pump und setz das Band immer absolut waagerecht an. "
key = "body.measure.info.prefix"
languages = ['de', 'en', 'es', 'fr', 'hi', 'it', 'ja', 'ko', 'nl', 'pl', 'pt', 'ru', 'tr', 'zh-Hans', 'zh-Hant']

if key not in data["strings"]:
    data["strings"][key] = {"extractionState": "manual", "localizations": {}}
elif "localizations" not in data["strings"][key]:
    data["strings"][key]["localizations"] = {}

for lang in languages:
    if lang == "de":
        data["strings"][key]["localizations"]["de"] = {"stringUnit": {"state": "translated", "value": text}}
    else:
        print(f"Translating {key} to {lang}...")
        try:
            target_lang = lang
            if lang == "zh-Hans": target_lang = "zh-CN"
            elif lang == "zh-Hant": target_lang = "zh-TW"
            
            translator = GoogleTranslator(source='de', target=target_lang)
            translated_text = translator.translate(text)
            
            data["strings"][key]["localizations"][lang] = {
                "stringUnit": {
                    "state": "translated",
                    "value": translated_text
                }
            }
            time.sleep(0.1)
        except Exception as e:
            print(f"Error: {e}")

with open("Garten_Simulation/Localizable.xcstrings", "w") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print("Fixed prefix!")
