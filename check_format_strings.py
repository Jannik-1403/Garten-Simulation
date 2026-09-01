import json
import re

with open('Garten_Simulation/Localizable.xcstrings', 'r') as f:
    data = json.load(f)

def get_format_specifiers(text):
    return sorted(re.findall(r'%[0-9]*\.?[0-9]*[a-zA-Z@]', text))

strings = data.get('strings', {})
errors = []

for key, value in strings.items():
    locs = value.get('localizations', {})
    
    # get base specifiers from German
    de_val = locs.get('de', {}).get('stringUnit', {}).get('value', '')
    if not de_val:
        continue
        
    base_specs = get_format_specifiers(de_val)
    
    for lang in ['zh-Hans', 'zh-Hant']:
        if lang in locs:
            val = locs[lang].get('stringUnit', {}).get('value', '')
            val_specs = get_format_specifiers(val)
            if base_specs != val_specs:
                errors.append(f"Error in {lang} for key '{key}': DE expects {base_specs}, got {val_specs} -> '{val}'")

for e in errors:
    print(e)
