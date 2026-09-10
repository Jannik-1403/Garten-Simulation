import json
import re

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

errors = []
for key, value in strings.items():
    locs = value.get("localizations", {})
    de_val = locs.get("de", {}).get("stringUnit", {}).get("value", "")
    en_val = locs.get("en", {}).get("stringUnit", {}).get("value", "")
    
    for lang, loc_data in locs.items():
        if lang in ["de", "en"]: continue
        if "stringUnit" not in loc_data: continue
        
        val = loc_data["stringUnit"].get("value", "")
        
        if "Error 500" in val or "Error 4" in val or "That’s an error." in val:
            errors.append(f"{lang} -> {key}: {val} (API ERROR)")
        elif len(val) >= 10 and re.search(r'[a-zA-Z]', val):
            if lang in ["ru", "ja", "ko", "zh-Hans", "zh-Hant", "hi"]:
                if not has_native_chars(lang, val):
                    errors.append(f"{lang} -> {key}: {val} (NO NATIVE CHARS)")
            else:
                if val == de_val or val == en_val:
                    clean_val = re.sub(r'%\d*\$?[a-zA-Z@\s/\.\-\+]', '', val).strip()
                    if len(clean_val) > 3:
                        errors.append(f"{lang} -> {key}: {val} (MATCHES GERMAN/ENGLISH FALLBACK EXACTLY)")

print(f"Total Errors Found: {len(errors)}")
for e in errors[:20]: # show first 20 errors if they exist
    print(e)
if len(errors) > 20:
    print(f"...and {len(errors) - 20} more.")
