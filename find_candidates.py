import json
import re

with open("Garten_Simulation/Localizable.xcstrings", "r") as f:
    data = json.load(f)

languages = ["de", "en", "es", "fr", "hi", "it", "ja", "ko", "nl", "pl", "pt", "pt-BR", "ru", "tr", "zh-Hans", "zh-Hant"]
strings = data.get("strings", {})

def extract_placeholders(text):
    return re.findall(r'%[0-9]*\$?[a-zA-Z\.@]+', text)

candidates = []

for key, entry in strings.items():
    localizations = entry.get("localizations", {})
    
    base_text = key
    if "de" in localizations and "value" in localizations["de"].get("stringUnit", {}):
        base_text = localizations["de"]["stringUnit"]["value"]
    elif "en" in localizations and "value" in localizations["en"].get("stringUnit", {}):
        base_text = localizations["en"]["stringUnit"]["value"]
        
    base_placeholders = sorted(extract_placeholders(base_text))
    base_lower = base_text.lower()
    
    for lang in languages:
        lang_entry = localizations.get(lang, {}).get("stringUnit", {})
        if not lang_entry or lang_entry.get("state") != "translated":
            continue
            
        val = lang_entry.get("value", "")
        if not val.strip() and base_text.strip():
            continue
            
        val_lower = val.lower()
        val_placeholders = sorted(extract_placeholders(val))
        
        issue = None
        
        # 1. Placeholder mismatch
        if len(base_placeholders) != len(val_placeholders):
            # Check if it's a real placeholder issue
            if base_placeholders:
                issue = f"Placeholders mismatch: Base has {base_placeholders}, {lang} has {val_placeholders}"
        
        # 2. Contains error/server/null (and base doesn't)
        for bw in ["error ", "server", " null", "undefined"]:
            if bw in val_lower and bw not in base_lower:
                if bw == "error " and lang in ["es", "pt", "pt-BR"]: continue # Error is valid in ES/PT
                if bw == "server" and lang in ["fr"]: continue # Réserver
                issue = f"Contains suspicious word '{bw}'"
        
        # 3. Value equals key (and key looks like a key)
        if val == key and ("." in key or "_" in key) and len(key) > 6:
            issue = "Value identical to technical key"
            
        if issue:
            candidates.append({
                "key": key,
                "lang": lang,
                "base_text": base_text,
                "translated_text": val,
                "issue": issue
            })

print(f"Found {len(candidates)} candidates.")
with open("candidates.json", "w") as f:
    json.dump(candidates, f, indent=2, ensure_ascii=False)
