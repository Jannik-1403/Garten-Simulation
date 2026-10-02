import json
import time
from deep_translator import GoogleTranslator

file_path = "Garten_Simulation/Localizable.xcstrings"
with open(file_path, "r", encoding="utf-8") as f:
    data = json.load(f)

# Hole alle verfuegbaren Sprachen aus dem ersten verfuegbaren Key, oder wir iterieren einfach über alle existierenden Language Codes im Project
all_langs = set()
strings = data.setdefault("strings", {})
for key, val in strings.items():
    if "localizations" in val:
        for lang in val["localizations"].keys():
            all_langs.add(lang)

print(f"Found {len(all_langs)} languages.")

keys_to_translate = {
    "history.today": "Heute",
    "history.yesterday": "Gestern",
    "history.pick_date": "Datum auswählen"
}

# Mapping fuer deep_translator (deep_translator braucht manchmal andere Codes, z.B. zh-Hans -> zh-CN)
def get_trans_code(lang_code):
    mapping = {
        "zh-Hans": "zh-CN",
        "zh-Hant": "zh-TW",
        "nb": "no",
        "pt-BR": "pt",
        "pt-PT": "pt"
    }
    return mapping.get(lang_code, lang_code.split("-")[0])

for key, de_val in keys_to_translate.items():
    if key not in strings:
        strings[key] = {"localizations": {}}
    localizations = strings[key]["localizations"]
    
    # Deutsch als Default setzen
    localizations["de"] = {"stringUnit": {"state": "translated", "value": de_val}}
    
    for lang_code in all_langs:
        if lang_code == "de": continue
        
        state = localizations.get(lang_code, {}).get("stringUnit", {}).get("state")
        if state != "translated":
            try:
                trans_code = get_trans_code(lang_code)
                translated = GoogleTranslator(source='de', target=trans_code).translate(de_val)
                localizations[lang_code] = {"stringUnit": {"state": "translated", "value": translated}}
                time.sleep(0.05)
                print(f"Translated {key} to {lang_code}: {translated}")
            except Exception as e:
                # Fallback to english if something fails
                print(f"Error on {lang_code}: {e}, using English fallback")
                try:
                    fallback = GoogleTranslator(source='de', target='en').translate(de_val)
                    localizations[lang_code] = {"stringUnit": {"state": "translated", "value": fallback}}
                except:
                    localizations[lang_code] = {"stringUnit": {"state": "translated", "value": de_val}} # de Fallback

with open(file_path, "w", encoding="utf-8") as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

print("Translation done.")
