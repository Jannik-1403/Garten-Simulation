import json
import re
from deep_translator import GoogleTranslator
import time
import concurrent.futures

file_path = "Garten_Simulation/Localizable.xcstrings"
with open(file_path, "r", encoding="utf-8") as f:
    data = json.load(f)

strings = data.get("strings", {})

def has_native_chars(lang, val):
    val_clean = re.sub(r'%\d*\$?[a-zA-Z@]', '', val)
    if lang == "ru": return bool(re.search(r'[а-яА-ЯёЁ]', val_clean))
    if lang in ["ja", "ko", "zh-Hans", "zh-Hant"]: return bool(re.search(r'[ぁ-んァ-ン一-龥가-힣]', val_clean))
    if lang == "hi": return bool(re.search(r'[अ-ह]', val_clean))
    return True

to_retranslate = {}

for key, value in strings.items():
    locs = value.get("localizations", {})
    de_val = locs.get("de", {}).get("stringUnit", {}).get("value", "")
    en_val = locs.get("en", {}).get("stringUnit", {}).get("value", "")
    
    source_text = de_val if de_val else key
    
    for lang, loc_data in locs.items():
        if lang in ["de", "en"]: continue
        if "stringUnit" not in loc_data: continue
        
        val = loc_data["stringUnit"].get("value", "")
        needs_fix = False
        
        if "Error 500" in val or "Error 4" in val or "That’s an error." in val:
            needs_fix = True
        elif len(val) >= 10 and re.search(r'[a-zA-Z]', val):
            if lang in ["ru", "ja", "ko", "zh-Hans", "zh-Hant", "hi"]:
                if not has_native_chars(lang, val): needs_fix = True
            else:
                if val == de_val or val == en_val:
                    clean_val = re.sub(r'%\d*\$?[a-zA-Z@\s/\.\-\+]', '', val).strip()
                    if len(clean_val) > 3: needs_fix = True
                        
        if needs_fix:
            if lang not in to_retranslate: to_retranslate[lang] = []
            to_retranslate[lang].append((key, source_text, val))

total_fixes = sum(len(items) for items in to_retranslate.values())
print(f"Found {total_fixes} strings to re-translate.")

def map_lang(lang_code):
    lc = lang_code.lower()
    if 'zh-hans' in lc: return 'zh-CN'
    if 'zh-hant' in lc: return 'zh-TW'
    if 'pt' in lc: return 'pt'
    if 'es' in lc: return 'es'
    return lc.split('-')[0]

def translate_batch(batch, target_lang):
    keys = [item[0] for item in batch]
    texts = [item[1] for item in batch]
    translator = GoogleTranslator(source='de', target=target_lang)
    try:
        translated = translator.translate_batch(texts)
        return keys, translated
    except Exception as e:
        print(f"Batch failed ({e}), falling back to single translation...")
        translated = []
        for text in texts:
            try:
                translated.append(translator.translate(text))
                time.sleep(0.5)
            except:
                translated.append(text)
        return keys, translated

for lang, items in to_retranslate.items():
    target_lang = map_lang(lang)
    batch_size = 20
    batches = [items[i:i+batch_size] for i in range(0, len(items), batch_size)]
    
    completed = 0
    with concurrent.futures.ThreadPoolExecutor(max_workers=3) as executor:
        futures = [executor.submit(translate_batch, b, target_lang) for b in batches]
        for future in concurrent.futures.as_completed(futures):
            keys, translated = future.result()
            if not keys: continue
            for k, t in zip(keys, translated):
                if not t: t = strings[k]["localizations"]["de"]["stringUnit"]["value"] # ultimate fallback
                strings[k]["localizations"][lang]["stringUnit"]["value"] = t
            completed += len(keys)
            print(f"  ... fixed {completed} / {len(items)} for {lang}")

with open(file_path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
    f.write("\n")
print("Finished fixing errors.")
