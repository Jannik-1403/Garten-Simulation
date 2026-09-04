import json
import re

with open("Garten_Simulation/Localizable.xcstrings", "r") as f:
    data = json.load(f)

languages = ["de", "en", "es", "fr", "hi", "it", "ja", "ko", "nl", "pl", "pt", "pt-BR", "ru", "tr", "zh-Hans", "zh-Hant"]
strings = data.get("strings", {})

bad_words_pattern = re.compile(r'\b(error|server|null|undefined|todo)\b', re.IGNORECASE)

found = []

for key, entry in strings.items():
    localizations = entry.get("localizations", {})
    
    base_text = key
    if "de" in localizations and "value" in localizations["de"].get("stringUnit", {}):
        base_text = localizations["de"]["stringUnit"]["value"]
    elif "en" in localizations and "value" in localizations["en"].get("stringUnit", {}):
        base_text = localizations["en"]["stringUnit"]["value"]
        
    base_lower = base_text.lower()
    
    for lang in languages:
        lang_entry = localizations.get(lang, {}).get("stringUnit", {})
        if not lang_entry or lang_entry.get("state") != "translated":
            continue
            
        val = lang_entry.get("value", "")
        
        matches = bad_words_pattern.findall(val)
        for match in matches:
            bw = match.lower()
            if bw == 'todo' and ('todo' in base_lower or lang in ['es', 'pt', 'pt-BR']): continue
            if bw == 'error' and ('fehler' in base_lower or 'error' in base_lower): continue
            if bw == 'server' and 'server' in base_lower: continue
            if bw == 'null' and ('null' in base_lower or lang in ['it']): continue # nulla in IT
            
            found.append(f"KEY: {key} | LANG: {lang} | BASE: {base_text} | FOUND: {val}")

if not found:
    print("Keine kaputten Strings mehr gefunden!")
else:
    for f in found:
        print(f)
