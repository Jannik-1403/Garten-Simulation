import json
import re

file_path = "Garten_Simulation/Localizable.xcstrings"
with open(file_path, "r", encoding="utf-8") as f:
    data = json.load(f)

strings = data.get("strings", {})

suspicious = {}

def is_mostly_latin_but_should_not_be(lang, val):
    val_clean = re.sub(r'%\d*\.?\d*[a-zA-Z@]', '', val) # remove %@, %d, %1$@
    val_clean = re.sub(r'[^a-zA-Zа-яА-ЯёЁぁ-んァ-ン一-龥가-힣अ-ह\s]', '', val_clean)
    
    if not val_clean.strip():
        return False # only punctuation/numbers left
        
    has_cyrillic = bool(re.search(r'[а-яА-ЯёЁ]', val_clean))
    has_cjk = bool(re.search(r'[ぁ-んァ-ン一-龥가-힣]', val_clean))
    has_devanagari = bool(re.search(r'[अ-ह]', val_clean))
    has_latin = bool(re.search(r'[a-zA-Z]', val_clean))
    
    if lang == "ru" and not has_cyrillic and has_latin: return True
    if lang in ["ja", "ko", "zh-Hans", "zh-Hant"] and not has_cjk and has_latin: return True
    if lang == "hi" and not has_devanagari and has_latin: return True
    
    return False

ignore_list = ["pro", "app", "widget", "xp", "ml", "kcal", "id", "url"]

for key, value in strings.items():
    locs = value.get("localizations", {})
    
    de_val = ""
    en_val = ""
    if "de" in locs and "stringUnit" in locs["de"]:
        de_val = locs["de"]["stringUnit"].get("value", "")
    if "en" in locs and "stringUnit" in locs["en"]:
        en_val = locs["en"]["stringUnit"].get("value", "")
        
    for lang, loc_data in locs.items():
        if lang in ["de", "en"]: continue
        if "stringUnit" not in loc_data: continue
        
        val = loc_data["stringUnit"].get("value", "")
        
        if val.lower() in ignore_list:
            continue
            
        is_sus = False
        reason = ""
        
        # Check 1: Non-Latin languages containing only Latin text
        if is_mostly_latin_but_should_not_be(lang, val):
            is_sus = True
            reason = "Latin text in non-Latin script language"
            
        # Check 2: Exact match with English or German (and not short/ignored)
        elif len(val) > 3 and val.lower() not in ignore_list:
            if val == de_val:
                is_sus = True
                reason = "Exact match with German fallback"
            elif val == en_val and de_val != en_val:
                is_sus = True
                reason = "Exact match with English fallback"
                
        if is_sus:
            if lang not in suspicious:
                suspicious[lang] = []
            suspicious[lang].append({
                "key": key,
                "de": de_val,
                "en": en_val,
                "val": val,
                "reason": reason
            })

for lang, items in suspicious.items():
    print(f"\n--- {lang} (Found {len(items)} suspicious items) ---")
    for i, item in enumerate(items[:5]): # Print first 5 to keep output short
        print(f"Key: {item['key']}")
        print(f"DE: {item['de']}")
        print(f"EN: {item['en']}")
        print(f"Translated: {item['val']} ({item['reason']})")
        print("-")
    if len(items) > 5:
        print(f"... and {len(items) - 5} more.")

with open("suspicious_translations.json", "w", encoding="utf-8") as f:
    json.dump(suspicious, f, indent=2, ensure_ascii=False)
