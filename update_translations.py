import json
import time

try:
    from deep_translator import GoogleTranslator
except ImportError:
    import os
    os.system('pip3 install deep_translator')
    from deep_translator import GoogleTranslator

with open("Garten_Simulation/Localizable.xcstrings", "r") as f:
    data = json.load(f)

# The keys we want to translate. If there are others, we can just find any keys that have missing translations.
# But let's find all keys that start with "tracking" and have only "de" or missing languages.
target_keys = []
for key, value in data["strings"].items():
    if key.startswith("tracking") or key.startswith("cleaning") or key.startswith("fitness.cleaning"):
        locs = value.get("localizations", {})
        if len(locs) < 16:
            target_keys.append(key)
        else:
            for lang, l_val in locs.items():
                if l_val.get("stringUnit", {}).get("state") != "translated":
                    target_keys.append(key)
                    break

# Map App languages to googletrans languages
lang_map = {
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

print(f"Found {len(target_keys)} tracking keys to translate: {target_keys}")

for key in target_keys:
    string_data = data["strings"][key]
    if "localizations" not in string_data:
        string_data["localizations"] = {}
    
    # Get the default German string.
    # Note: Sometimes it might be in extractionState 'extracted_with_value' and the value is in the localizations dict under 'de'.
    de_val = ""
    if "de" in string_data["localizations"]:
        de_val = string_data["localizations"]["de"]["stringUnit"]["value"]
    else:
        # Fallback if not found, though Xcode should put the defaultValue in the localizations for 'de'
        continue
    
    # Update 'de' to translated state
    string_data["localizations"]["de"]["stringUnit"]["state"] = "translated"

    for app_lang, t_lang in lang_map.items():
        if app_lang not in string_data["localizations"] or string_data["localizations"][app_lang]["stringUnit"]["state"] != "translated":
            try:
                translated_text = GoogleTranslator(source='de', target=t_lang).translate(de_val)
                # handle `%@` if present in original but lost or mangled in translation
                # A simplistic replace for %@
                if "%@" in de_val and "%@" not in translated_text:
                    if "％" in translated_text:
                         translated_text = translated_text.replace("％@", "%@")
                    else:
                         print(f"Warning: '%@' missing in {app_lang} translation for '{key}'")
                
                string_data["localizations"][app_lang] = {
                    "stringUnit": {
                        "state": "translated",
                        "value": translated_text
                    }
                }
                print(f"[{key}] Translated to {app_lang}: {translated_text}")
                time.sleep(0.2)
            except Exception as e:
                print(f"Failed to translate {key} to {app_lang}: {e}")

with open("Garten_Simulation/Localizable.xcstrings", "w") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
    # The original file might have a newline at the end
    f.write("\n")

print("Done translating!")
