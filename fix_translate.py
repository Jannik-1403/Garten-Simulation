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

for key, value in data["strings"].items():
    default_text = ""
    if "localizations" in value and "de" in value["localizations"] and value["localizations"]["de"].get("stringUnit", {}).get("state") == "translated":
        default_text = value["localizations"]["de"]["stringUnit"]["value"]
    elif "localizations" in value and "en" in value["localizations"] and value["localizations"]["en"].get("stringUnit", {}).get("state") == "translated":
        default_text = value["localizations"]["en"]["stringUnit"]["value"]
    else:
        continue

    if not default_text: continue

    if "localizations" not in value:
        value["localizations"] = {}

    for lang in languages:
        if lang not in value["localizations"] or value["localizations"][lang].get("stringUnit", {}).get("state") != "translated":
            
            target_lang = lang
            if target_lang == "pt-BR": target_lang = "pt"
            if target_lang == "zh-Hans": target_lang = "zh-CN"
            if target_lang == "zh-Hant": target_lang = "zh-TW"
            if target_lang == "pt-PT": target_lang = "pt"
            
            print(f"Translating '{default_text}' to {target_lang}...")
            try:
                cache_key = f"{default_text}_{target_lang}"
                if cache_key in translator_cache:
                    translated_text = translator_cache[cache_key]
                else:
                    translator = GoogleTranslator(source='auto', target=target_lang)
                    translated_text = translator.translate(default_text)
                    translator_cache[cache_key] = translated_text
                    time.sleep(0.05)
                
                value["localizations"][lang] = {
                    "stringUnit": {
                        "state": "translated",
                        "value": translated_text
                    }
                }
            except Exception as e:
                print(f"Error translating to {lang}: {e}")

with open("Garten_Simulation/Localizable.xcstrings", "w") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
print("Done translating!")
