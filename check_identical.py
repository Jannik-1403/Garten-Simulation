import json

file_path = "Garten_Simulation/Localizable.xcstrings"
with open(file_path, "r", encoding="utf-8") as f:
    data = json.load(f)

count = 0
for key, value in data["strings"].items():
    localizations = value.get("localizations", {})
    de_loc = localizations.get("de", {}).get("stringUnit", {}).get("value")
    if de_loc is None:
        if "extractionState" in value:
            de_loc = key
        else:
            continue
            
    identical_langs = []
    for lang, loc in localizations.items():
        if lang == "de":
            continue
        val = loc.get("stringUnit", {}).get("value", "")
        # Check if the translated value contains ANY German-specific words that shouldn't be in e.g. Spanish.
        # Or just check if the translation is EXACTLY the German string (and is not just placeholders)
        # Let's strip placeholders to see if there's actual text
        import re
        text_only = re.sub(r'%[a-zA-Z0-9@.-]+', '', val).strip()
        text_only_de = re.sub(r'%[a-zA-Z0-9@.-]+', '', de_loc).strip()
        
        if text_only != "" and val == de_loc:
            identical_langs.append(lang)
            
    if identical_langs:
        # Ignore universal strings
        if de_loc in ["Jannik Schill", "Routine (Pro)", "To-Dos (Pro)", "Routine"]:
            continue
        print(f"Key '{key}' is identical to German ('{de_loc}') in: {identical_langs}")
        count += 1
        
print(f"Total identical keys: {count}")
