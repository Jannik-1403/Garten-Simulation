import json
import time
from deep_translator import GoogleTranslator

with open("Garten_Simulation/Localizable.xcstrings", "r") as f:
    data = json.load(f)

# Find all languages
languages = set()
for key, value in data["strings"].items():
    if "localizations" in value:
        for lang in value["localizations"].keys():
            languages.add(lang)

languages = sorted(list(languages))

for key, value in data["strings"].items():
    default_text = ""
    # find english or german text
    if "localizations" in value and "en" in value["localizations"] and value["localizations"]["en"].get("stringUnit", {}).get("state") == "translated":
        default_text = value["localizations"]["en"]["stringUnit"]["value"]
    elif "localizations" in value and "de" in value["localizations"] and value["localizations"]["de"].get("stringUnit", {}).get("state") == "translated":
        default_text = value["localizations"]["de"]["stringUnit"]["value"]
    else:
        # Check if english or german is available in extractionState
        if "extractionState" in value:
            # We don't have default text easily available if it's manual, but usually it's the key or we can try to guess.
            pass
            
    # If we couldn't find a default text, let's use the key or just skip if it's not a clear default.
    # Actually, in Apple's xcstrings, the `defaultValue` provided in code becomes the source string, but sometimes it's missing if not extracted.
    # For manually added keys, we might need a fallback.
    
    # We will only translate if we have a default text to translate from.
    if not default_text:
        # if the key looks like English words, use it
        if " " in key or key.istitle():
            default_text = key
        else:
            print(f"No default text for {key}")
            continue

    if "localizations" not in value:
        value["localizations"] = {}

    for lang in languages:
        if lang not in value["localizations"] or value["localizations"][lang].get("stringUnit", {}).get("state") != "translated":
            print(f"Translating {key} to {lang}...")
            try:
                # deep-translator uses target codes like 'zh-CN' for zh-Hans, 'zh-TW' for zh-Hant
                target_lang = lang
                if lang == "zh-Hans": target_lang = "zh-CN"
                elif lang == "zh-Hant": target_lang = "zh-TW"
                
                translator = GoogleTranslator(source='auto', target=target_lang)
                translated_text = translator.translate(default_text)
                
                value["localizations"][lang] = {
                    "stringUnit": {
                        "state": "translated",
                        "value": translated_text
                    }
                }
                time.sleep(0.1)
            except Exception as e:
                print(f"Error translating {key} to {lang}: {e}")

with open("Garten_Simulation/Localizable.xcstrings", "w") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print("Done translating!")
