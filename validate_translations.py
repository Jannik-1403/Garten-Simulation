import json
import re

with open("Garten_Simulation/Localizable.xcstrings", "r") as f:
    data = json.load(f)

languages = ["de", "en", "es", "fr", "hi", "it", "ja", "ko", "nl", "pl", "pt", "pt-BR", "ru", "tr", "zh-Hans", "zh-Hant"]
strings = data.get("strings", {})

def extract_placeholders(text):
    # Regex to find placeholders like %@, %d, %lld, %.1f, %1$@
    return re.findall(r'%[0-9]*\$?[a-zA-Z\.]+', text)

bad_words = ["error", "server", "null", "undefined", "todo"]
broken_keys = set()

for key, entry in strings.items():
    localizations = entry.get("localizations", {})
    
    # Get the base text (German or English) to compare placeholders
    base_text = key
    if "de" in localizations and "value" in localizations["de"].get("stringUnit", {}):
        base_text = localizations["de"]["stringUnit"]["value"]
    elif "en" in localizations and "value" in localizations["en"].get("stringUnit", {}):
        base_text = localizations["en"]["stringUnit"]["value"]
        
    base_placeholders = sorted(extract_placeholders(base_text))
    
    for lang in languages:
        lang_entry = localizations.get(lang, {}).get("stringUnit", {})
        if not lang_entry or lang_entry.get("state") != "translated":
            continue
            
        val = lang_entry.get("value", "")
        
        # Rule 1: Empty or whitespace
        if not val.strip():
            # If base text is also empty/whitespace, it's fine
            if base_text.strip():
                broken_keys.add((key, lang, "Empty or whitespace"))
            continue
            
        # Rule 2: Contains bad words
        val_lower = val.lower()
        for bw in bad_words:
            if bw in val_lower and bw not in base_text.lower():
                broken_keys.add((key, lang, f"Contains '{bw}'"))
                
        # Rule 3: Identical to key (if key looks like a key and not a word)
        if val == key and "." in key and len(key) > 5:
            # Maybe it just wasn't translated properly
            broken_keys.add((key, lang, "Identical to key"))
            
        # Rule 4: Placeholders mismatch
        val_placeholders = sorted(extract_placeholders(val))
        if base_placeholders != val_placeholders:
            # Only flag if there's a serious mismatch that would crash Xcode
            if len(base_placeholders) != len(val_placeholders):
                broken_keys.add((key, lang, f"Placeholder count mismatch: {base_placeholders} vs {val_placeholders}"))

print(f"Found {len(broken_keys)} broken translations across all languages.")
for issue in list(broken_keys)[:20]:
    print(f"[{issue[1]}] Key: '{issue[0]}' -> Problem: {issue[2]}")
