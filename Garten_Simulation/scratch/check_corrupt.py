import json
import re

with open("/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Localizable.xcstrings", "r") as f:
    data = json.load(f)

corrupt_list = []

error_keywords = [
    "error 500", "error 429", "server error", "internal server error", 
    "bad gateway", "please try again later", "something went wrong", 
    "timeout", "rate limit exceeded", "no support for the provided language",
    "no translation was found", "try another translator"
]

artifacts = ["null", "undefined", "nan", "[object object]"]
placeholders = ["{translation}", "todo", "fixme"]

def count_placeholders(text):
    return len(re.findall(r'%@|%lld|%d|%[0-9]+\$@|%[0-9]+\$lld|%[0-9]+\$d', text))

for key, value in data["strings"].items():
    if "localizations" not in value: continue
    
    # Get original (DE or EN) to check placeholders
    orig_text = value["localizations"].get("de", {}).get("stringUnit", {}).get("value", "")
    if not orig_text:
        orig_text = value["localizations"].get("en", {}).get("stringUnit", {}).get("value", "")
    
    orig_ph_count = count_placeholders(orig_text) if orig_text else 0
    
    for lang, loc in value["localizations"].items():
        if lang in ["en", "de"]: continue
        
        target_text = loc.get("stringUnit", {}).get("value", "")
        if not isinstance(target_text, str):
            continue
            
        lower_text = target_text.lower().strip()
        
        # Rule 2: empty or whitespace
        if not lower_text:
            corrupt_list.append({"key": key, "language": lang, "brokenValue": target_text, "reason": "empty string"})
            continue
            
        # Rule 1: HTTP/Server errors
        is_error = False
        for kw in error_keywords:
            if kw in lower_text:
                corrupt_list.append({"key": key, "language": lang, "brokenValue": target_text, "reason": "server error"})
                is_error = True
                break
        if is_error: continue
        
        # Rule 2: API artifacts
        if lower_text in artifacts:
            corrupt_list.append({"key": key, "language": lang, "brokenValue": target_text, "reason": "api artifact"})
            continue
            
        # Rule 3: placeholders
        has_ph = False
        for ph in placeholders:
            if ph in lower_text:
                corrupt_list.append({"key": key, "language": lang, "brokenValue": target_text, "reason": "placeholder artifact"})
                has_ph = True
                break
        if has_ph: continue
        
        # JSON fragment check
        if (target_text.startswith("{") and target_text.endswith("}")) or (target_text.startswith("[") and target_text.endswith("]")):
            # If orig_text is not a JSON fragment, it's corrupt
            if orig_text and not (orig_text.startswith("{") or orig_text.startswith("[")):
                corrupt_list.append({"key": key, "language": lang, "brokenValue": target_text, "reason": "json fragment"})
                continue
                
        # Rule 4: Value identical to key (and key looks like a localization key)
        if target_text == key and ("." in key or "_" in key) and len(key) > 5:
            corrupt_list.append({"key": key, "language": lang, "brokenValue": target_text, "reason": "equals key"})
            continue
            
        # Rule 5: Placeholder mismatch
        if orig_text:
            target_ph_count = count_placeholders(target_text)
            if target_ph_count != orig_ph_count:
                # Exclude '%' without specifier and some specific cases
                # Actually placeholder mismatch is very common in Google Translate (e.g., translates %lld to % lld).
                # But let's log it just in case.
                pass
                # corrupt_list.append({"key": key, "language": lang, "brokenValue": target_text, "reason": "placeholder mismatch"})
                # continue

with open("scratch/corrupt_translations.json", "w") as f:
    json.dump(corrupt_list, f, indent=2)

print(f"Found {len(corrupt_list)} corrupt translations.")
