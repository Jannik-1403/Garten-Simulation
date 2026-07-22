import os
import json
import re
import time
import shutil

try:
    from deep_translator import GoogleTranslator
except ImportError:
    os.system("pip3 install deep-translator")
    from deep_translator import GoogleTranslator

widget_strings_path = "GartenWidget/de.lproj/Localizable.strings"
xcstrings_path = "Garten_Simulation/Localizable.xcstrings"

# 1. Extract keys and values from GartenWidget/de.lproj/Localizable.strings
new_keys = {}
with open(widget_strings_path, "r", encoding="utf-8") as f:
    for line in f:
        line = line.strip()
        if not line or line.startswith("//"): continue
        match = re.match(r'^"(.+?)"\s*=\s*"(.*?)";', line)
        if match:
            new_keys[match.group(1)] = match.group(2)

print(f"Found {len(new_keys)} keys in widget strings.")

# 2. Add them to Localizable.xcstrings
with open(xcstrings_path, "r", encoding="utf-8") as f:
    xc_data = json.load(f)

for key, de_text in new_keys.items():
    if key not in xc_data["strings"]:
        xc_data["strings"][key] = {
            "extractionState": "manual",
            "localizations": {}
        }
    locs = xc_data["strings"][key]["localizations"]
    if "de" not in locs:
        locs["de"] = {
            "stringUnit": {
                "state": "translated",
                "value": de_text
            }
        }

# 3. Translate missing
lang_mapping = {
    'en': 'en', 'es': 'es', 'fr': 'fr', 'hi': 'hi', 'it': 'it',
    'ja': 'ja', 'ko': 'ko', 'nl': 'nl', 'pl': 'pl', 'pt': 'pt',
    'pt-BR': 'pt', 'ru': 'ru', 'tr': 'tr', 'zh-Hans': 'zh-CN', 'zh-Hant': 'zh-TW'
}

total = 0
for lang, google_lang in lang_mapping.items():
    keys_to_translate = []
    texts_to_translate = []
    
    for key in new_keys.keys():
        data = xc_data["strings"][key]
        locs = data.get("localizations", {})
        de_text = locs.get("de", {}).get("stringUnit", {}).get("value", key)
            
        if lang not in locs or locs.get(lang, {}).get("stringUnit", {}).get("state") != "translated":
            keys_to_translate.append(key)
            texts_to_translate.append(de_text)
            
    if keys_to_translate:
        print(f"Translating {len(keys_to_translate)} strings for {lang}...")
        batch_size = 50
        for i in range(0, len(texts_to_translate), batch_size):
            batch_keys = keys_to_translate[i:i+batch_size]
            batch_texts = texts_to_translate[i:i+batch_size]
            try:
                translated = GoogleTranslator(source='de', target=google_lang).translate_batch(batch_texts)
                for k, key in enumerate(batch_keys):
                    if "localizations" not in xc_data["strings"][key]:
                        xc_data["strings"][key]["localizations"] = {}
                    
                    t_text = translated[k]
                    # Format placeholders
                    if "%@" in batch_texts[k] and "%@" not in t_text:
                        t_text += " %@"
                    if "%d" in batch_texts[k] and "%d" not in t_text:
                        t_text += " %d"
                        
                    xc_data["strings"][key]["localizations"][lang] = {
                        "stringUnit": {
                            "state": "translated",
                            "value": t_text
                        }
                    }
                    total += 1
            except Exception as e:
                print(f"Error for {lang}: {e}")
        time.sleep(0.5)

with open(xcstrings_path, "w", encoding="utf-8") as f:
    json.dump(xc_data, f, indent=2, ensure_ascii=False)

print(f"Added and translated {total} translations.")

# 4. Delete the widget strings folders
for root, dirs, files in os.walk("GartenWidget"):
    for dir_name in dirs:
        if dir_name.endswith(".lproj"):
            shutil.rmtree(os.path.join(root, dir_name))

print("Deleted all .lproj folders in GartenWidget.")
