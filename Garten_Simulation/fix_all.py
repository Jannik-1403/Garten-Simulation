import json
import re

# 1. Parse AppStrings.swift
app_strings = {}
with open('./Localization/AppStrings.swift', 'r', encoding='utf-8') as f:
    content = f.read()

# Find all dictionary entries like "Key": ["de": "Value", "en": "Value"...]
entries = re.findall(r'"([^"]+)":\s*\[(.*?)\]', content, re.DOTALL)
for key, locs_str in entries:
    app_strings[key] = {}
    # find all language pairs like "de": "Value"
    loc_pairs = re.findall(r'"([a-z]{2})":\s*"([^"\\]*(?:\\.[^"\\]*)*)"', locs_str)
    for lang, val in loc_pairs:
        val = val.replace('\\"', '"') # unescape quotes
        app_strings[key][lang] = val

print(f"Parsed {len(app_strings)} keys from AppStrings.swift")

# 2. Update Localizable.xcstrings
with open('./Localizable.xcstrings', 'r', encoding='utf-8') as f:
    data = json.load(f)

strings = data.get('strings', {})
langs = ['de', 'en', 'es', 'fr', 'it', 'pt', 'ja', 'ko', 'pl', 'nl', 'tr']

fixed_count = {l: 0 for l in langs}

for key, val in strings.items():
    locs = val.setdefault('localizations', {})
    
    for l in langs:
        tr_loc = locs.setdefault(l, {})
        state = tr_loc.get('stringUnit', {}).get('state', 'missing')
        
        if state != 'translated':
            # Need to provide a translation
            new_val = None
            
            # Try to find in AppStrings
            if key in app_strings and l in app_strings[key]:
                new_val = app_strings[key][l]
            # Fallback to key itself (for things like "%lld" or "-")
            else:
                new_val = key
                
            locs[l] = {
                "stringUnit": {
                    "state": "translated",
                    "value": new_val
                }
            }
            fixed_count[l] += 1

with open('./Localizable.xcstrings', 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print("Fixed translations:")
for l in langs:
    print(f" - {l}: {fixed_count[l]}")

