import json
import re

file_path = "Garten_Simulation/Localizable.xcstrings"
# Let's get the state BEFORE my fix (so we know exactly what had Error 500 or English text)
import subprocess
try:
    old_json = subprocess.check_output(['git', 'show', 'HEAD~1:Garten_Simulation/Localizable.xcstrings']).decode('utf-8')
    data = json.loads(old_json)
except Exception as e:
    print(f"Error loading old json: {e}")
    exit(1)

strings = data.get("strings", {})

def has_native_chars(lang, val):
    val_clean = re.sub(r'%\d*\$?[a-zA-Z@]', '', val)
    if lang == "ru": return bool(re.search(r'[а-яА-ЯёЁ]', val_clean))
    if lang in ["ja", "ko", "zh-Hans", "zh-Hant"]: return bool(re.search(r'[ぁ-んァ-ン一-龥가-힣]', val_clean))
    if lang == "hi": return bool(re.search(r'[अ-ह]', val_clean))
    return True

unique_errors = {}

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
            if key not in unique_errors:
                unique_errors[key] = {"de": source_text, "langs": []}
            unique_errors[key]["langs"].append(lang)

print(json.dumps(unique_errors, indent=2, ensure_ascii=False))
