import json

with open("Localizable.xcstrings", "r") as f:
    data = json.load(f)

error_keywords = [
    "error 500", "error 429", "server error", "internal server error", 
    "bad gateway", "please try again later", "something went wrong", 
    "timeout", "rate limit exceeded", "no support for the provided language",
    "no translation was found", "try another translator"
]

missing_keys = []

for key, value in data["strings"].items():
    if "localizations" not in value: continue
    
    for lang, loc in value["localizations"].items():
        if lang in ["en", "de"]: continue
        
        state = loc.get("stringUnit", {}).get("state", "new")
        target_text = loc.get("stringUnit", {}).get("value", "")
        
        needs_translation = False
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
            missing_keys.append({"key": key, "lang": lang})

print(f"Remaining items to translate: {len(missing_keys)}")
