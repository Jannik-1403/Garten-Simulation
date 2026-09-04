import json
import re

with open("/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Localizable.xcstrings", "r") as f:
    data = json.load(f)

count = 0
for key, value in data["strings"].items():
    if "localizations" not in value: continue
    
    en_text = value["localizations"].get("en", {}).get("stringUnit", {}).get("value", "")
    if not en_text: continue
    if len(en_text) <= 3: continue 
    if en_text in ["Grovy", "Pro", "Streak"]: continue
    
    if "%@" in en_text or "%lld" in en_text or "%d" in en_text or "%1$" in en_text: continue
    if not re.search('[a-zA-Z]{3,}', en_text): continue
    
    for lang, loc in list(value["localizations"].items()):
        if lang in ["en", "de"]: continue
        
        target_text = loc.get("stringUnit", {}).get("value", "")
        if target_text == en_text:
            loc["stringUnit"]["state"] = "needs_translation"
            count += 1

if count > 0:
    with open("/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Localizable.xcstrings", "w") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
    print(f"Flagged {count} translations as needing translation.")
else:
    print("No english fallbacks found.")
