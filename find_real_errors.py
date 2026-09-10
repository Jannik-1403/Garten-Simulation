import json
import re

file_path = "Garten_Simulation/Localizable.xcstrings"
with open(file_path, "r", encoding="utf-8") as f:
    data = json.load(f)

strings = data.get("strings", {})
suspicious = {}

def clean_format_specifiers(val):
    # Remove format specifiers like %@, %lld, %1$@, %2$lld, %d, %f
    val = re.sub(r'%\d*\$?[a-zA-Z@]', '', val)
    return val

def has_real_words(val):
    # Find any word that is purely letters and length >= 3
    words = re.findall(r'[a-zA-Z]{3,}', val)
    # Ignore common terms that don't need translation
    ignored = {"pro", "app", "widget", "xp", "id", "url", "ios", "mac", "kcal"}
    real_words = [w for w in words if w.lower() not in ignored]
    return len(real_words) > 0

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
        clean_val = clean_format_specifiers(val)
        
        is_sus = False
        reason = ""
        
        # Check non-Latin scripts for untranslated English/German words
        if lang in ["ru", "ja", "ko", "zh-Hans", "zh-Hant", "hi"]:
            if has_real_words(clean_val):
                is_sus = True
                reason = "Contains untranslated Latin words"
        else:
            # Check Latin scripts for EXACT match with German or English (if the string has real words)
            if has_real_words(clean_val):
                if val == de_val:
                    is_sus = True
                    reason = "Matches German fallback exactly"
                elif val == en_val and de_val != en_val:
                    is_sus = True
                    reason = "Matches English fallback exactly"
                    
        if is_sus:
            if lang not in suspicious:
                suspicious[lang] = []
            suspicious[lang].append({
                "key": key,
                "de": de_val,
                "val": val,
                "reason": reason
            })

for lang, items in suspicious.items():
    print(f"\n--- {lang} (Found {len(items)} real suspicious items) ---")
    for i, item in enumerate(items[:10]):
        print(f"Key: {item['key']}")
        print(f"DE: {item['de']}")
        print(f"Translated: {item['val']} ({item['reason']})")
        print("-")

# Save detailed report to json
with open("real_errors.json", "w", encoding="utf-8") as f:
    json.dump(suspicious, f, indent=2, ensure_ascii=False)
