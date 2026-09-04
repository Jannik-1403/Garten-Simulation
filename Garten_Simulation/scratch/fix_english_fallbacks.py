import json
import time
from deep_translator import GoogleTranslator

with open("/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Localizable.xcstrings", "r") as f:
    data = json.load(f)

translator_cache = {}

count = 0
for key, value in data["strings"].items():
    if "localizations" not in value: continue
    
    en_text = value["localizations"].get("en", {}).get("stringUnit", {}).get("value", "")
    if not en_text: continue
    if len(en_text) <= 3: continue # ignore short strings like "1W", "Pt", etc.
    if en_text in ["Grovy", "Pro"]: continue
    
    for lang, loc in value["localizations"].items():
        if lang in ["en", "de"]: continue
        
        target_text = loc.get("stringUnit", {}).get("value", "")
        # If target text is exactly English, it's a failed translation
        if target_text == en_text:
            print(f"Suspicious: [{lang}] '{key}' is English: '{target_text}'")
            
            # Translate it!
            try:
                t_lang = lang
                if lang == "zh-Hans": t_lang = "zh-CN"
                elif lang == "zh-Hant": t_lang = "zh-TW"
                
                cache_key = f"{en_text}_{t_lang}"
                if cache_key in translator_cache:
                    translated = translator_cache[cache_key]
                else:
                    translator = GoogleTranslator(source='en', target=t_lang)
                    translated = translator.translate(en_text)
                    translator_cache[cache_key] = translated
                    time.sleep(0.1)
                
                print(f"  -> Translated to: {translated}")
                loc["stringUnit"]["value"] = translated
                count += 1
            except Exception as e:
                print(f"  -> Error translating: {e}")

if count > 0:
    with open("/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Localizable.xcstrings", "w") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
    print(f"Fixed {count} translations.")
else:
    print("No english fallbacks found.")
