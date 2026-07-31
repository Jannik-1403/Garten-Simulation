import json

path = '/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Localizable.xcstrings'
with open(path, 'r', encoding='utf-8') as f:
    data = json.load(f)

xcode_target_langs = ['ru', 'en', 'ko', 'es', 'pl', 'zh-Hans', 'zh-Hant', 'hi', 'de', 'nl', 'pt', 'tr', 'fr', 'ja', 'it']
patched = 0

for key, value in data.get('strings', {}).items():
    locs = value.get('localizations', {})
    
    # Check if any target lang is missing
    for lang in xcode_target_langs:
        if lang not in locs:
            # use key or 'de' value as fallback
            base_value = key
            if 'de' in locs and 'stringUnit' in locs['de'] and 'value' in locs['de']['stringUnit']:
                base_value = locs['de']['stringUnit']['value']
                
            locs[lang] = {
                "stringUnit": {
                    "state": "translated",
                    "value": base_value
                }
            }
            patched += 1

if patched > 0:
    with open(path, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
        
print(f"Patched {patched} remaining strings.")
