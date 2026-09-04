import json
import time
from deep_translator import GoogleTranslator

with open("Localizable.xcstrings", "r") as f:
    data = json.load(f)

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

def map_lang(lang):
    if lang == "pt-BR": return "pt"
    if lang == "zh-Hans": return "zh-CN"
    if lang == "zh-Hant": return "zh-TW"
    return lang

translators = {}
for lang in languages:
    if lang in ["en", "de"]: continue
    g_lang = map_lang(lang)
    translators[lang] = GoogleTranslator(source='de', target=g_lang)

count = 0
total_fixed = 0

for key, value in data["strings"].items():
    if "localizations" not in value: continue
    
    orig_text = value["localizations"].get("de", {}).get("stringUnit", {}).get("value", "")
    if not orig_text:
        orig_text = value["localizations"].get("en", {}).get("stringUnit", {}).get("value", "")
    if not orig_text and "." not in key and "_" not in key:
        orig_text = key
        
    if not orig_text: continue

    for lang in languages:
        if lang in ["en", "de"]: continue
        
        loc = value["localizations"].get(lang, {})
        state = loc.get("stringUnit", {}).get("state", "new")
        target_text = loc.get("stringUnit", {}).get("value", "")
        
        needs_translation = False
        if state != "translated" or not target_text.strip():
            needs_translation = True
        else:
            lower_text = target_text.lower()
            for kw in error_keywords:
                if kw in lower_text:
                    needs_translation = True
                    break
        
        if needs_translation:
            count += 1
            print(f"Translating {key} to {lang}...")
            
            success = False
            for attempt in range(5): # retry up to 5 times
                try:
                    translated = translators[lang].translate(orig_text)
                    # Check if result is also an error
                    is_error = False
                    if translated:
                        lower_trans = translated.lower()
                        for kw in error_keywords:
                            if kw in lower_trans:
                                is_error = True
                                break
                    if not translated or is_error:
                        raise Exception("API returned an error text")
                        
                    # Success
                    if lang not in value["localizations"]:
                        value["localizations"][lang] = {}
                    value["localizations"][lang]["stringUnit"] = {
                        "state": "translated",
                        "value": translated
                    }
                    total_fixed += 1
                    success = True
                    break
                except Exception as e:
                    print(f"  Attempt {attempt+1} failed: {e}")
                    time.sleep(2)
            
            if not success:
                print(f"Failed to translate {key} to {lang}")
            
            time.sleep(1) # delay to avoid rate limiting
            
            # Save incrementally every 10 items
            if total_fixed % 10 == 0:
                with open("Localizable.xcstrings", "w") as f:
                    json.dump(data, f, indent=2, ensure_ascii=False)

# Final save
with open("Localizable.xcstrings", "w") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print(f"Finished. Fixed {total_fixed} translations.")
