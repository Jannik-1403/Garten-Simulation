import json

with open("/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Localizable.xcstrings", "r") as f:
    data = json.load(f)

missing_list = []

error_keywords = [
    "error 500", "error 429", "server error", "internal server error", 
    "bad gateway", "please try again later", "something went wrong", 
    "timeout", "rate limit exceeded", "no support for the provided language",
    "no translation was found", "try another translator"
]

languages = set()
for key, value in data["strings"].items():
    if "localizations" in value:
        for lang in value["localizations"].keys():
            languages.add(lang)
languages = sorted(list(languages))

for key, value in data["strings"].items():
    # find german or english text
    orig_text = ""
    if "localizations" in value and "de" in value["localizations"]:
        orig_text = value["localizations"]["de"].get("stringUnit", {}).get("value", "")
    if not orig_text and "localizations" in value and "en" in value["localizations"]:
        orig_text = value["localizations"]["en"].get("stringUnit", {}).get("value", "")
        
    if not orig_text:
        # Check extractionState
        if value.get("extractionState") == "manual" and not (" " in key or key.istitle()):
            continue
        if "." not in key and "_" not in key:
            orig_text = key
            
    if not orig_text: continue

    if "localizations" not in value:
        value["localizations"] = {}

    for lang in languages:
        if lang in ["en", "de"]: continue
        
        needs_translation = False
        target_text = ""
        
        if lang not in value["localizations"]:
            needs_translation = True
        else:
            loc = value["localizations"][lang]
            state = loc.get("stringUnit", {}).get("state", "new")
            target_text = loc.get("stringUnit", {}).get("value", "")
            
            if state != "translated":
                needs_translation = True
            elif not target_text.strip():
                needs_translation = True
            else:
                lower_text = target_text.lower()
                for kw in error_keywords:
                    if kw in lower_text:
                        needs_translation = True
                        break
                        
        if needs_translation:
            missing_list.append({
                "key": key,
                "language": lang,
                "original_text": orig_text,
                "current_broken_value": target_text
            })

with open("scratch/needs_translation.json", "w") as f:
    json.dump(missing_list, f, indent=2, ensure_ascii=False)

print(f"Total items needing translation: {len(missing_list)}")
