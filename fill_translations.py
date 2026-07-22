import json
import time
try:
    from deep_translator import GoogleTranslator
except ImportError:
    import os
    os.system("pip3 install deep-translator")
    from deep_translator import GoogleTranslator

xcstrings_path = "Garten_Simulation/Localizable.xcstrings"

new_keys = {
    "screentime_suggestions_title": "Vorschläge",
    "app_name_grovy": "Grovy",
    "path_day_image_error": "Bild fehlerhaft",
    "rarity_accessibility_label": "Seltenheit: %@",
    "common_filter": "Filter",
    "preview_btn_continue": "Weiter",
    "preview_btn_save": "Speichern",
    "common_ok": "OK",
    "preview_btn_inline": "Inline"
}

with open(xcstrings_path, "r", encoding="utf-8") as f:
    xc_data = json.load(f)

if "strings" not in xc_data:
    xc_data["strings"] = {}

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

lang_mapping = {
    'en': 'en', 'es': 'es', 'fr': 'fr', 'hi': 'hi', 'it': 'it',
    'ja': 'ja', 'ko': 'ko', 'nl': 'nl', 'pl': 'pl', 'pt': 'pt',
    'pt-BR': 'pt', 'ru': 'ru', 'tr': 'tr', 'zh-Hans': 'zh-CN', 'zh-Hant': 'zh-TW'
}

total = 0
for lang, google_lang in lang_mapping.items():
    keys_to_translate = []
    texts_to_translate = []
    
    for key, data in xc_data["strings"].items():
        locs = data.get("localizations", {})
        de_text = ""
        if "de" in locs and "stringUnit" in locs["de"]:
            de_text = locs["de"]["stringUnit"]["value"]
        else:
            de_text = key # fallback
            
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
                    if key not in xc_data["strings"]: continue
                    if "localizations" not in xc_data["strings"][key]:
                        xc_data["strings"][key]["localizations"] = {}
                    
                    # Handle %@ placeholder
                    t_text = translated[k]
                    if "%@" in batch_texts[k] and "%@" not in t_text:
                        t_text += " %@" # just in case translator ate it
                        
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

print(f"Done! {total} translations added.")

# Check for 100% completion
all_100 = True
for key, data in xc_data["strings"].items():
    locs = data.get("localizations", {})
    missing = []
    for l in lang_mapping.keys():
        if l not in locs or locs[l].get("stringUnit", {}).get("state") != "translated":
            missing.append(l)
    if missing:
        print(f"Key {key} is missing translations for: {missing}")
        all_100 = False

if all_100:
    print("ALL LANGUAGES ARE 100% TRANSLATED!")
