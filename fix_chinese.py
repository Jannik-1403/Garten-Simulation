import json
import re

with open('Garten_Simulation/Localizable.xcstrings', 'r', encoding='utf-8') as f:
    data = json.load(f)

def get_format_specifiers(text):
    return sorted(re.findall(r'%[0-9]*\.?[0-9]*[a-zA-Z@]', text))

strings = data.get('strings', {})

for key, value in strings.items():
    locs = value.get('localizations', {})
    
    de_val = locs.get('de', {}).get('stringUnit', {}).get('value', '')
    if not de_val:
        continue
        
    base_specs = get_format_specifiers(de_val)
    
    for lang in locs.keys():
        val = locs[lang].get('stringUnit', {}).get('value', '')
        original_val = val
        
        # fix full-width percent sign
        if '％' in val:
            val = val.replace('％', '%')
            
        val_specs = get_format_specifiers(val)
        
        if base_specs != val_specs:
            if lang in ['zh-Hans', 'zh-Hant'] and key == 'focus.generic.reward':
                val = de_val # fallback to german if broken
                
            elif lang == 'zh-Hant' and key == 'pass.level_range' and '％@-％@' in original_val:
                val = val.replace('％@-％@', '%@-%@')
                
        if val != original_val:
            locs[lang]['stringUnit']['value'] = val
            print(f"Fixed {lang} in {key}: {original_val} -> {val}")

with open('Garten_Simulation/Localizable.xcstrings', 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
    f.write("\n")

