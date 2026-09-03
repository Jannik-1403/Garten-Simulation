import json
import re

with open("Garten_Simulation/Localizable.xcstrings", "r") as f:
    data = json.load(f)

languages = ["de", "en", "es", "fr", "hi", "it", "ja", "ko", "nl", "pl", "pt", "pt-BR", "ru", "tr", "zh-Hans", "zh-Hant"]
strings = data.get("strings", {})

def extract_placeholders(text):
    return sorted(re.findall(r'%[0-9]*\$?[a-zA-Z\.@]+', text))

broken_keys = set()
bad_words_pattern = re.compile(r'\b(error|server|null|undefined|todo)\b', re.IGNORECASE)

for key, entry in strings.items():
    localizations = entry.get("localizations", {})
    
    base_text = key
    if "de" in localizations and "value" in localizations["de"].get("stringUnit", {}):
        base_text = localizations["de"]["stringUnit"]["value"]
    elif "en" in localizations and "value" in localizations["en"].get("stringUnit", {}):
        base_text = localizations["en"]["stringUnit"]["value"]
        
    base_placeholders = extract_placeholders(base_text)
    base_lower = base_text.lower()
    
    for lang in languages:
        lang_entry = localizations.get(lang, {}).get("stringUnit", {})
        if not lang_entry or lang_entry.get("state") != "translated":
            continue
            
        val = lang_entry.get("value", "")
        
        # 1. Empty or whitespace
        if not val.strip() and base_text.strip():
            broken_keys.add(key)
            continue
            
        # 2. Bad words
        matches = bad_words_pattern.findall(val)
        for match in matches:
            bw = match.lower()
            if bw == 'todo' and ('todo' in base_lower or lang in ['es', 'pt', 'pt-BR']): continue
            if bw == 'error' and ('fehler' in base_lower or 'error' in base_lower): continue
            if bw == 'server' and 'server' in base_lower: continue
            if bw == 'null' and ('null' in base_lower or lang in ['it']): continue # nulla in IT
            broken_keys.add(key)
                
        # 3. Placeholder mismatch
        val_placeholders = extract_placeholders(val)
        if base_placeholders != val_placeholders:
            if len(base_placeholders) != len(val_placeholders):
                broken_keys.add(key)
                
        # 4. Identical to key
        if val == key and ("." in key or "_" in key) and len(key) > 5 and key != base_text:
            broken_keys.add(key)

print(json.dumps(list(broken_keys), indent=2))
