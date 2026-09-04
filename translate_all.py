import json
import time
from deep_translator import GoogleTranslator

with open("Garten_Simulation/Localizable.xcstrings", "r") as f:
    data = json.load(f)

source_lang = data.get("sourceLanguage", "en")

# Ensure the new manual keys exist
new_keys = {
    "body.timerange.t": "T",
    "body.timerange.w": "W",
    "body.timerange.m": "M",
    "body.timerange.sixm": "6 M.",
    "body.timerange.j": "J"
}

for k, v in new_keys.items():
    if k not in data["strings"]:
        data["strings"][k] = {
            "extractionState": "manual",
            "localizations": {
                "de": {
                    "stringUnit": {
                        "state": "translated",
                        "value": v
                    }
                }
            }
        }

languages = set()
for key, value in data["strings"].items():
    if "localizations" in value:
        for lang in value["localizations"].keys():
            languages.add(lang)
languages = sorted(list(languages))

translator_cache = {}

for key, value in data["strings"].items():
    default_text = ""
    # find german or english text
    if "localizations" in value and "de" in value["localizations"] and value["localizations"]["de"].get("stringUnit", {}).get("state") == "translated":
        default_text = value["localizations"]["de"]["stringUnit"]["value"]
    elif "localizations" in value and "en" in value["localizations"] and value["localizations"]["en"].get("stringUnit", {}).get("state") == "translated":
        default_text = value["localizations"]["en"]["stringUnit"]["value"]
    else:
        # Check extractionState
        if value.get("extractionState") == "manual" and not (" " in key or key.istitle()):
            continue
        if "." not in key and "_" not in key:
            default_text = key
        else:
            continue

    if not default_text: continue

    if "localizations" not in value:
        value["localizations"] = {}

    for lang in languages:
        if lang not in value["localizations"] or value["localizations"][lang].get("stringUnit", {}).get("state") != "translated":
            # skip if the translation is already there
            if "stringUnit" in value["localizations"].get(lang, {}) and value["localizations"][lang]["stringUnit"].get("state") == "translated":
                continue
                
            print(f"Translating '{default_text}' to {lang}...")
            try:
                target_lang = lang
                if lang == "zh-Hans": target_lang = "zh-CN"
                elif lang == "zh-Hant": target_lang = "zh-TW"
                elif lang == "pt-BR": target_lang = "pt"
                
                cache_key = f"{default_text}_{target_lang}"
                if cache_key in translator_cache:
                    translated_text = translator_cache[cache_key]
                else:
                    translator = GoogleTranslator(source='auto', target=target_lang)
                    translated_text = translator.translate(default_text)
                    translator_cache[cache_key] = translated_text
                    time.sleep(0.1)
                
                value["localizations"][lang] = {
                    "stringUnit": {
                        "state": "translated",
                        "value": translated_text
                    }
                }
            except Exception as e:
                print(f"Error translating {key} to {lang}: {e}")

with open("Garten_Simulation/Localizable.xcstrings", "w") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print("Done translating!")
