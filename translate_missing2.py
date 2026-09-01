import json
import time
from deep_translator import GoogleTranslator

with open("Garten_Simulation/Localizable.xcstrings", "r") as f:
    data = json.load(f)

source_lang = data.get("sourceLanguage", "en")

# Find all languages
languages = set()
for key, value in data["strings"].items():
    if "localizations" in value:
        for lang in value["localizations"].keys():
            languages.add(lang)

languages = sorted(list(languages))
languages = [l for l in languages if l != source_lang]

for key, value in data["strings"].items():
    default_text = ""
    # find english or german text
    if "localizations" in value and "en" in value["localizations"] and value["localizations"]["en"].get("stringUnit", {}).get("state") == "translated":
        default_text = value["localizations"]["en"]["stringUnit"]["value"]
    elif "localizations" in value and "de" in value["localizations"] and value["localizations"]["de"].get("stringUnit", {}).get("state") == "translated":
        default_text = value["localizations"]["de"]["stringUnit"]["value"]
    else:
        # Check extractionState
        if value.get("extractionState") == "manual" and not (" " in key or key.istitle()):
            # skip manual keys that are just ids
            continue
        # Use the key as the default source string if it's not a pure ID
        if "." not in key and "_" not in key:
            default_text = key
        else:
            # We don't have a reliable default text
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
