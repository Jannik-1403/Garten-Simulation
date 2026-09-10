import json
import time
import os
import concurrent.futures
from deep_translator import GoogleTranslator

file_path = "Garten_Simulation/Localizable.xcstrings"

with open(file_path, "r", encoding="utf-8") as f:
    data = json.load(f)

if "strings" in data and "1" in data["strings"]:
    del data["strings"]["1"]
    print("Deleted key '1'")

source_language = data.get("sourceLanguage", "en")
strings = data.get("strings", {})

languages_seen = set()
for value in strings.values():
    if "localizations" in value:
        languages_seen.update(value["localizations"].keys())

def map_lang(lang_code):
    lc = lang_code.lower()
    if 'zh-hans' in lc: return 'zh-CN'
    if 'zh-hant' in lc: return 'zh-TW'
    if 'pt' in lc: return 'pt'
    if 'es' in lc: return 'es'
    return lc.split('-')[0]

missing_by_lang = {}

for key, value in strings.items():
    localizations = value.setdefault("localizations", {})
    source_text = key
    if "de" in localizations and "stringUnit" in localizations["de"]:
        source_text = localizations["de"]["stringUnit"]["value"]
    elif "en" in localizations and "stringUnit" in localizations["en"]:
        source_text = localizations["en"]["stringUnit"]["value"]

    for lang in languages_seen:
        if lang == source_language: continue
        needs_translation = False
        if lang not in localizations:
            needs_translation = True
        else:
            loc = localizations[lang]
            if "stringUnit" in loc and loc["stringUnit"].get("state") != "translated":
                needs_translation = True
                
        if needs_translation:
            if lang not in missing_by_lang: missing_by_lang[lang] = []
            missing_by_lang[lang].append((key, source_text))

total_missing = sum(len(items) for items in missing_by_lang.values())
print(f"Total strings to translate: {total_missing}")

def translate_batch(batch, target_lang):
    try:
        translator = GoogleTranslator(source='auto', target=target_lang)
        keys = [item[0] for item in batch]
        texts = [item[1] for item in batch]
        translated = translator.translate_batch(texts)
        return keys, translated
    except Exception as e:
        print(f"Batch failed: {e}")
        return [], []

for lang, items in missing_by_lang.items():
    print(f"Translating {len(items)} strings for {lang}...")
    target_lang = map_lang(lang)
    
    batch_size = 50
    batches = [items[i:i+batch_size] for i in range(0, len(items), batch_size)]
    
    completed = 0
    with concurrent.futures.ThreadPoolExecutor(max_workers=10) as executor:
        futures = [executor.submit(translate_batch, b, target_lang) for b in batches]
        for future in concurrent.futures.as_completed(futures):
            keys, translated = future.result()
            if not keys: continue
            for k, t in zip(keys, translated):
                if not t: t = "fallback" # if translation failed completely
                strings[k]["localizations"][lang] = {
                    "stringUnit": {
                        "state": "translated",
                        "value": t
                    }
                }
            completed += len(keys)
            print(f"  ... translated {completed} / {len(items)} for {lang}")

with open(file_path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
    f.write("\n")

print("Finished updating Localizable.xcstrings")
